//
//  PaidViewController.m
//  0420-EDianYunFu
//
//  Created by mac on 16/4/20.
//  Copyright © 2016年 DJ. All rights reserved.
//

#import "PaidViewController.h"
#import "OrderTableView.h"
#import "Order.h"
#import "ButelHandle.h"
#import "UIView+YYAdd.h"

@interface PaidViewController (){
    OrderTableView *_tableView;
    NSInteger _pageNo;
    UIImageView *_noDataimageView;
}

@end

@implementation PaidViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    OrderTableView *tableView = [[OrderTableView alloc] initWithFrame:CGRectMake(0, 0, KWidth, KHeight-64-49) style:UITableViewStylePlain];
    _tableView = tableView;
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self refreshData];
    }];
    _tableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
        [self loadMoreData];
    }];
    [self.view addSubview:tableView];
    _isLoadData = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadDataView) name:@"ComingIn" object:nil];
    // Do any additional setup after loading the view.
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (!_isLoadData) {
        _isLoadData = YES;
        return;
    }
    [[FireData sharedInstance] eventWithCategory:@"订单管理" action:@"已支付" evar:nil attributes:nil
     ];
    [_tableView.mj_header beginRefreshing];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

- (void)refreshData{
    
    _pageNo = 0;
    NSDictionary *paramsDic=@{@"userId":[[SingleHandle shareSingleHandle] getUserInfo].userId,
                              @"pageSize":[NSString stringWithFormat:@"%@",@4],
                              @"pageNo":[NSString stringWithFormat:@"%@",@1],
                              @"orderStatus":@"已支付"};
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseAPI,kfindMainOrder];
    __weak typeof(self) weakSelf = self;
    [MHNetworkManager postReqeustWithURL:url params:paramsDic successBlock:^(id returnData) {
        [_tableView.mj_header endRefreshing];
        NSDictionary *dic = returnData;
        if ([[dic objectForKey:@"flag"] isEqualToString:@"success"]) {
            NSDictionary *dataDic = [dic objectForKey:@"data"];
            //取出总条数
            NSArray *listArray = [dataDic objectForKey:@"list"];
            NSMutableArray *_unfinishedArray = [NSMutableArray array];
            [_unfinishedArray addObjectsFromArray:[Order mj_objectArrayWithKeyValuesArray:listArray]];
            AYCLog(@"%@",_unfinishedArray);
            if (_unfinishedArray.count <= 0) {
                if (!_noDataimageView) {
                    _noDataimageView = [[UIImageView alloc] initWithFrame:CGRectMake(KWidth/2-75/2.0, 0, 75, 85)];
                    _noDataimageView.centerY = KHeight/2-108;
                    _noDataimageView.image = [UIImage imageNamed:@"pix2"];
                    _noDataimageView.hidden = YES;
                    
                    UILabel *noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(-_noDataimageView.left, 90, KWidth, 25)];
                    noDataLabel.font = [UIFont systemFontOfSize:14];
                    noDataLabel.textColor = [UIColor lightGrayColor];
                    noDataLabel.textAlignment = NSTextAlignmentCenter;
                    noDataLabel.text = @"当前暂无数据";
                    [_noDataimageView addSubview:noDataLabel];
                    [self.view addSubview:_noDataimageView];
                }
                _noDataimageView.hidden = NO;
            }else{
                _noDataimageView.hidden = YES;
                
            }
            _tableView.dataList = _unfinishedArray;
            [_tableView reloadData];
        }else {
            [MBProgressHUD showMessag:[dic objectForKey:@"msg"] toView:weakSelf.view];
        }
        
    } failureBlock:^(NSError *error) {
        [_tableView.mj_header endRefreshing];
    } showHUD:NO];
}

- (void)loadMoreData{
    
    NSInteger index = _tableView.dataList.count/4;
    if (index == _pageNo) {
        [_tableView.mj_footer endRefreshing];
        //        [_tableView.mj_footer endRefreshingWithNoMoreData];
        return;
    }
    NSDictionary *paramsDic=@{@"userId":[[SingleHandle shareSingleHandle] getUserInfo].userId,
                              @"pageSize":[NSString stringWithFormat:@"%@",@4],
                              @"pageNo":@(index),
                              @"orderStatus":@"已支付"};
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseAPI,kfindMainOrder];
    __weak typeof(self) weakSelf = self;
    [MHNetworkManager postReqeustWithURL:url params:paramsDic successBlock:^(id returnData) {
        [_tableView.mj_footer endRefreshing];
        NSDictionary *dic = returnData;
        if ([[dic objectForKey:@"flag"] isEqualToString:@"success"]) {
            NSDictionary *dataDic = [dic objectForKey:@"data"];
            //取出总条数
            NSArray *listArray = [dataDic objectForKey:@"list"];
            NSMutableArray *_unfinishedArray = [NSMutableArray array];
            [_unfinishedArray addObjectsFromArray:[Order mj_objectArrayWithKeyValuesArray:listArray]];
            AYCLog(@"%@",_unfinishedArray);
            NSMutableArray *tem = [_tableView.dataList mutableCopy];
            [tem addObjectsFromArray:_unfinishedArray];
            _tableView.dataList = tem;
            //            _tableView.dataList = _unfinishedArray;
            AYCLog(@"----*****-------%ld",_tableView.dataList.count);
            
            [_tableView reloadData];
            _pageNo = index;
        }else {
            [MBProgressHUD showMessag:[dic objectForKey:@"msg"] toView:weakSelf.view];
        }
        
    } failureBlock:^(NSError *error) {
        [_tableView.mj_header endRefreshing];
    } showHUD:NO];
}

- (void)loadDataView{
    [_tableView.mj_header beginRefreshing];
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
