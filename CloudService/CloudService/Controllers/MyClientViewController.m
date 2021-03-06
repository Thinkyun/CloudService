//
//  MyClientViewController.m
//  CloudService
//
//  Created by 安永超 on 16/2/29.
//  Copyright © 2016年 zhangqiang. All rights reserved.
//

#import "MyClientViewController.h"
#import "MyClientTableViewCell.h"
#import <MJRefresh.h>
#import "Order.h"
#import "OfferViewController.h"
#import "OrderInfoViewController.h"
#import "ButelHandle.h"

@interface MyClientViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
{
    int _page;//当前页数
    int _pageSize;//每页加载数
    NSMutableArray *_clientArray;
    __block NSString *_conditon;//模糊搜索
    Order *_order;
    UIImageView *_noDataImg;
    UILabel *_lbNoData;
}
@property (weak, nonatomic)IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic)IBOutlet UITableView *tableView;
@end

@implementation MyClientViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //客户数组
    _clientArray = [NSMutableArray array];
    //模糊搜索
    _conditon = @"";
    //滑动tableview隐藏键盘
    self.tableView.keyboardDismissMode  = UIScrollViewKeyboardDismissModeInteractive;
    self.tableView.tableFooterView = [UIView new];
    __weak typeof(self) weakSelf = self;
    [weakSelf setLeftImageBarButtonItemWithFrame:CGRectMake(0, 0, 30, 30) image:@"title-back" selectImage:@"back" action:^(AYCButton *button) {
        
        [[FireData sharedInstance] eventWithCategory:@"我的客户" action:@"返回" evar:nil attributes:nil];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    [self addMjRefresh];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.title = @"我的客户";
    __weak typeof(self) weakSelf = self;
    [weakSelf setRightImageBarButtonItemWithFrame:CGRectMake(0, 0, 35, 35) image:@"head-add" selectImage:@"head-add" action:^(AYCButton *button) {
        
        [[FireData sharedInstance] eventWithCategory:@"我的客户" action:@"添加" evar:nil attributes:nil];
        [weakSelf performSegueWithIdentifier:@"creatClient" sender:weakSelf];
    }];
    if (self.isSaveCarInfo) {
        self.isSaveCarInfo = NO;
        _conditon = @"";
        [self.tableView.mj_header beginRefreshing];
    }
}

- (void)setupNoData {
    _noDataImg = [[UIImageView alloc] initWithFrame:CGRectMake(KWidth/2-30, KHeight/2-80, 75, 85)];
    _noDataImg.image = [UIImage imageNamed:@"pix2"];
    _lbNoData = [[UILabel alloc] initWithFrame:CGRectMake(KWidth/2-20, KHeight/2+10, 60, 25)];
    _lbNoData.text = @"暂无数据";
    _lbNoData.font = [UIFont systemFontOfSize:14];
    _lbNoData.textColor = [UIColor lightGrayColor];
    [self.tableView addSubview:_noDataImg];
    [self.tableView addSubview:_lbNoData];
}
- (void)removeNoData {

    [_noDataImg removeFromSuperview];
    [_lbNoData removeFromSuperview];
    _noDataImg = nil;
    _lbNoData = nil;
}
//添加mj
- (void)addMjRefresh {
    _pageSize=7;
     __weak typeof(self) weakSelf = self;
    // 下拉刷新
    weakSelf.tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{

        [weakSelf requestData];
        
    }];
    
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    weakSelf.tableView.mj_header.automaticallyChangeAlpha = YES;
    [weakSelf.tableView.mj_header beginRefreshing];
    
    // 上拉刷新
    weakSelf.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        
        [weakSelf requestMoreData];
        
    }];
}

- (void)requestData{

    _page = 1;
    [self removeNoData];
    
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    delegate.isThird=NO;
    NSDictionary *paramsDic=@{@"userId":[[SingleHandle shareSingleHandle] getUserInfo].userId,
                              @"pageSize":[NSString stringWithFormat:@"%i",_pageSize],
                              @"pageNo":[NSString stringWithFormat:@"%i",_page],
                              @"condition":_conditon};
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseAPI,kfindPersonCustList];

    
    __weak typeof(self) weakSelf = self;
    [MHNetworkManager postReqeustWithURL:url params:paramsDic successBlock:^(id returnData) {
        
        NSDictionary *dic = returnData;
        if ([[dic objectForKey:@"flag"] isEqualToString:@"success"]) {
            [_clientArray removeAllObjects];
            NSDictionary *dataDic = [dic objectForKey:@"data"];
            //取出总条数
            int totalCount=[[[dataDic objectForKey:@"pageVO"] objectForKey:@"recordCount"] intValue];
            //如果有数据显示数据，如果没有数据则显示暂无数据
            if (totalCount>0) {
                [self removeNoData];
            }else{
               [weakSelf setupNoData];
            }
            
            if (totalCount-_pageSize*_page<=0) {
                //没有数据，直接提示没有更多数据
                [_tableView.mj_footer endRefreshingWithNoMoreData];
            }else{
                [_tableView.mj_footer endRefreshing];
            }
            
            NSArray *listArray = [dataDic objectForKey:@"list"];
            [_clientArray addObjectsFromArray:[Order mj_objectArrayWithKeyValuesArray:listArray]];
        }else {
            [MBProgressHUD showMessag:[dic objectForKey:@"msg"] toView:weakSelf.view];
           [weakSelf setupNoData];
        }
        
        [_tableView reloadData];
        [_tableView.mj_header endRefreshing];
        
    } failureBlock:^(NSError *error) {
        [weakSelf setupNoData];
        [_tableView.mj_header endRefreshing];
    } showHUD:YES];
}

- (void)requestMoreData{
    _page++;
    
    NSDictionary *paramsDic=@{@"userId":[[SingleHandle shareSingleHandle] getUserInfo].userId,
                              @"pageSize":[NSString stringWithFormat:@"%i",_pageSize],
                              @"pageNo":[NSString stringWithFormat:@"%i",_page],
                              @"condition":_conditon};
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseAPI,kfindPersonCustList];
    
    __weak typeof(self) weakSelf = self;
    [MHNetworkManager postReqeustWithURL:url params:paramsDic successBlock:^(id returnData) {
        AYCLog(@"%@",returnData);
        
        NSDictionary *dic = returnData;
        if ([[dic objectForKey:@"flag"] isEqualToString:@"success"]) {
            NSDictionary *dataDic = [dic objectForKey:@"data"];
            //取出总条数
            int totalCount=[[[dataDic objectForKey:@"pageVO"] objectForKey:@"recordCount"] intValue];
            if (totalCount-_pageSize*_page<=0) {
                //没有数据，直接提示没有更多数据
                [_tableView.mj_footer endRefreshingWithNoMoreData];
            }else{
                //有数据，则结束刷新状态，以便下次能够刷新
                [_tableView.mj_footer endRefreshing];
            }
            
            NSArray *listArray = [dataDic objectForKey:@"list"];
            [_clientArray addObjectsFromArray:[Order mj_objectArrayWithKeyValuesArray:listArray]];
            AYCLog(@"%@",_clientArray);
        }else {
            [MBProgressHUD showMessag:[dic objectForKey:@"msg"] toView:weakSelf.view];
            
        }

        [weakSelf.tableView reloadData];
        
    } failureBlock:^(NSError *error) {
        AYCLog(@"%@",error);
        [weakSelf.tableView.mj_footer endRefreshing];
    } showHUD:YES];
    
}
#pragma mark tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _clientArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellId=@"cell";
    
    MyClientTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"MyClientTableViewCell" owner:self options:nil];
        cell = [array objectAtIndex:0];
    }
    Order *order = [_clientArray objectAtIndex:indexPath.row];
    cell.lbCustName.text = order.customerName;
    cell.lbLicenseNo.text = order.licenseNo;
    cell.lbInfo.layer.borderColor = [[HelperUtil colorWithHexString:@"FDB164"]CGColor];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 79;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [[FireData sharedInstance] eventWithCategory:@"我的客户" action:@"详情" evar:nil attributes:nil];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _order = [_clientArray objectAtIndex:indexPath.row];
    
    if ([_order.baseId isEqualToString:@""]) {
        [self performSegueWithIdentifier:@"offerInfo" sender:self];
    }else{
        [self performSegueWithIdentifier:@"clientOrder" sender:self];
    }
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // segue.identifier：获取连线的ID
    if ([segue.identifier isEqualToString:@"offerInfo"]) {
        // segue.destinationViewController：获取连线时所指的界面（VC）
        OfferViewController *receive = segue.destinationViewController;
        
        receive.order = _order;
    }
    if ([segue.identifier isEqualToString:@"clientOrder"]) {
        // segue.destinationViewController：获取连线时所指的界面（VC）
        OrderInfoViewController *receive = segue.destinationViewController;
        receive.order = _order;
    }
}
#pragma mark searchBar
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    
    _conditon = searchBar.text;
    [self.tableView.mj_header beginRefreshing];
    [searchBar resignFirstResponder];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    _conditon = searchBar.text;
    [self.tableView.mj_header beginRefreshing];
    [searchBar resignFirstResponder];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
