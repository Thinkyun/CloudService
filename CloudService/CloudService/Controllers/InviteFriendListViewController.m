//
//  InviteFriendListViewController.m
//  cutPhoto
//
//  Created by mac on 16/5/3.
//  Copyright © 2016年 DJ. All rights reserved.
//

#import "InviteFriendListViewController.h"
#import "InviteFriendListTableViewCell.h"

@interface InviteFriendListViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UILabel *_label;
    UITableView *_tableView;
    NSInteger _pageNo;
    NSInteger _allPageNo;
}

@property (nonatomic,strong)NSMutableArray *dataList;

@end

@implementation InviteFriendListViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [_tableView.mj_header beginRefreshing];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.navigationItem.title = @"好友邀请列表";
    __weak typeof(self) weakSelf = self;
    [self setLeftImageBarButtonItemWithFrame:CGRectMake(0, 0, 30, 30) image:@"title-back" selectImage:@"" action:^(AYCButton *button) {
        
        [[FireData sharedInstance] eventWithCategory:@"好友邀请列表" action:@"返回" evar:nil attributes:nil];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    
    [self setupUI];
    _dataList = [NSMutableArray array];
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self refreshData];
    }];
    _tableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
        [self loadMoreData];
    }];
    // Do any additional setup after loading the view.
}

- (void)setupUI{
    //tableView 初始化
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KWidth, KHeight-64-49) style:UITableViewStylePlain];
    tableView.showsHorizontalScrollIndicator = NO;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.tableFooterView = [UIView new];
    tableView.delegate = self;
    tableView.dataSource = self;
    _tableView = tableView;
    [self.view addSubview:tableView];
    
    //底下的View
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, KHeight-49-64, KWidth, 49)];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    
    //地下的label
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, KWidth, 49)];
    label.font = [UIFont systemFontOfSize:16];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor grayColor];
    _label = label;
    [bottomView addSubview:label];
}

- (void)refreshData{
    _pageNo = 1;
    User *user = [SingleHandle shareSingleHandle].user;
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseAPI,kFindInviteRecord];
    NSDictionary *params = @{@"userId":user.userId,@"pageSize":@8,@"pageNo":@(_pageNo)};
    [MHNetworkManager postReqeustWithURL:url params:params successBlock:^(id returnData) {
        
        [_tableView.mj_header endRefreshing];
        NSMutableArray *temArray = [NSMutableArray array];
        if ([returnData[@"flag"] isEqualToString:@"success"]) {
            _allPageNo = [[[returnData[@"data"] objectForKey:@"pageVO"] objectForKey:@"recordCount"] integerValue];
            for (NSDictionary *dict in [returnData[@"data"] objectForKey:@"list"]) {
                [temArray addObject:dict];
            }
            _dataList = temArray;
            [_tableView reloadData];
            _label.text = [NSString stringWithFormat:@"共邀请%ld个好友",_allPageNo];
        }
    } failureBlock:^(NSError *error) {
        [_tableView.mj_header endRefreshing];
    } showHUD:YES];
    
}

- (void)loadMoreData{
    if (_pageNo >= _allPageNo/8) {
        _pageNo = _allPageNo/8;
        [_tableView.mj_footer endRefreshing];
        return;
    }
    User *user = [SingleHandle shareSingleHandle].user;
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseAPI,kFindInviteRecord];
    NSDictionary *params = @{@"userId":user.userId,@"pageSize":@8,@"pageNo":@(++_pageNo)};
    [MHNetworkManager postReqeustWithURL:url params:params successBlock:^(id returnData) {
        [_tableView.mj_footer endRefreshing];
        NSMutableArray *temArray = [NSMutableArray array];
        if ([returnData[@"flag"] isEqualToString:@"success"]) {
            _allPageNo = [[[returnData[@"data"] objectForKey:@"pageVO"] objectForKey:@"recordCount"] integerValue];
            for (NSDictionary *dict in [returnData[@"data"] objectForKey:@"list"]) {
                [temArray addObject:dict];
            }
            [_dataList addObjectsFromArray:temArray];
            [_tableView reloadData];
            _label.text = [NSString stringWithFormat:@"共邀请%ld个好友",_allPageNo];
        }
    } failureBlock:^(NSError *error) {
        [_tableView.mj_footer endRefreshing];
    } showHUD:YES];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    InviteFriendListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[InviteFriendListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.dataDict = _dataList[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 85;
}

- (UIImage *)cutPhoot:(UIImage *)oldImage{
    UIGraphicsBeginImageContextWithOptions(oldImage.size, 0, 0);
    [oldImage drawInRect:CGRectMake(-7, -5, oldImage.size.width, oldImage.size.height)];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClipToRect(context, CGRectMake(0, 0, 74, 74));
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
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
