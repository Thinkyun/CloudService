//
//  MyTeamViewController.m
//  CloudService
//
//  Created by zhangqiang on 16/2/27.
//  Copyright © 2016年 zhangqiang. All rights reserved.
// 我的团队

#import "MyTeamViewController.h"
#import "MyTeamTableViewCell.h"
#import <MJRefresh.h>
#import "TeamMember.h"
#import "InviteFriendViewController.h"

@interface MyTeamViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *_teamMemberArray;
    int _page;//当前页数
    int _pageSize;//每页加载数
    
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *inviteBtn;

@end

static NSString *cell_id = @"myTeamCell";
@implementation MyTeamViewController

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _teamMemberArray = [NSMutableArray array];
    if ([[[SingleHandle shareSingleHandle] getUserInfo].roleName isEqualToString:@"团队长"]) {
        [self setupViews];
        [self addMjRefresh];
    }else{
        [self.inviteBtn setTitle:@"申请团队长" forState:UIControlStateNormal];
        [self setupViews];
    }

    
  
}

- (void)addMjRefresh {
    
    _pageSize=8;
    
    __weak typeof(self) weakSelf = self;
    // 下拉刷新
    _tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
     
        [weakSelf requestTeamMemberData];
        
    }];
    
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    _tableView.mj_header.automaticallyChangeAlpha = YES;
    [_tableView.mj_header beginRefreshing];
    
    // 上拉刷新
    _tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        
        [weakSelf requestMoreTeamMemberData];
        
    }];

}

- (void)setupViews {
    
    self.title = @"我的团队";
    __weak typeof(self) weakSelf = self;
    [self setLeftImageBarButtonItemWithFrame:CGRectMake(0, 0, 30, 30) image:@"title-back" selectImage:@"" action:^(AYCButton *button) {
        AYCLog(@"Retain count is %ld", CFGetRetainCount((__bridge CFTypeRef)weakSelf));
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    
    // 注册cell
    [self.tableView registerNib:[UINib nibWithNibName:@"MyTeamTableViewCell" bundle:nil] forCellReuseIdentifier:cell_id];
    self.tableView.tableFooterView = [[UIView alloc] init];
}

#pragma mark 加载个人优惠券
- (void)requestTeamMemberData {
    _page=1;
    NSDictionary *paramsDic=@{@"userId":[[SingleHandle shareSingleHandle] getUserInfo].userId,
                              @"pageSize":[NSString stringWithFormat:@"%i",_pageSize],
                              @"pageNo":[NSString stringWithFormat:@"%i",_page]};
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseAPI,kfindTeamMember];
    
    __weak typeof(self) weakSelf = self;
    [MHNetworkManager postReqeustWithURL:url params:paramsDic successBlock:^(id returnData) {
        AYCLog(@"%@",returnData);
        
        NSDictionary *dic = returnData;
        if ([[dic objectForKey:@"flag"] isEqualToString:@"success"]) {
            [_teamMemberArray removeAllObjects];
            NSDictionary *dataDic = [dic objectForKey:@"data"];
            //取出总条数
            int totalCount=[[[dataDic objectForKey:@"pageVO"] objectForKey:@"recordCount"] intValue];
            AYCLog(@"总条数：%i",totalCount);
            if (totalCount-_pageSize*_page<=0) {
                //没有数据，直接提示没有更多数据
                [_tableView.mj_footer endRefreshingWithNoMoreData];
            }else{
                [_tableView.mj_footer endRefreshing];
            }
            
            NSArray *listArray = [dataDic objectForKey:@"list"];
            [_teamMemberArray addObjectsFromArray:[TeamMember mj_objectArrayWithKeyValuesArray:listArray]];
            AYCLog(@"%@",_teamMemberArray);
        }else {
            [MBProgressHUD showMessag:[dic objectForKey:@"msg"] toView:weakSelf.view];
        }
        
        [_tableView reloadData];
        [_tableView.mj_header endRefreshing];
      
    } failureBlock:^(NSError *error) {
    
        [_tableView.mj_header endRefreshing];
    } showHUD:YES];
}

#pragma mark - 加载数据
- (void)requestMoreTeamMemberData {
    _page++;
    
    NSDictionary *paramsDic=@{@"userId":[[SingleHandle shareSingleHandle] getUserInfo].userId,
                              @"pageSize":[NSString stringWithFormat:@"%i",_pageSize],
                              @"pageNo":[NSString stringWithFormat:@"%i",_page]};
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseAPI,kfindTeamMember];
    
    __weak typeof(self) weakSelf = self;
    [MHNetworkManager postReqeustWithURL:url params:paramsDic successBlock:^(id returnData) {
        AYCLog(@"%@",returnData);
        
        NSDictionary *dic = returnData;
        if ([[dic objectForKey:@"flag"] isEqualToString:@"success"]) {
            NSDictionary *dataDic = [dic objectForKey:@"data"];
            //取出总条数
            int totalCount=[[[dataDic objectForKey:@"pageVO"] objectForKey:@"recordCount"] intValue];
            AYCLog(@"总条数：%i",totalCount);
            if (totalCount-_pageSize*_page<=0) {
                //没有数据，直接提示没有更多数据
                [_tableView.mj_footer endRefreshingWithNoMoreData];
            }else{
                //有数据，则结束刷新状态，以便下次能够刷新
                [_tableView.mj_footer endRefreshing];
            }
            
            NSArray *listArray = [dataDic objectForKey:@"list"];
            [_teamMemberArray addObjectsFromArray:[TeamMember mj_objectArrayWithKeyValuesArray:listArray]];
            AYCLog(@"%@",_teamMemberArray);
        }else {
            [MBProgressHUD showMessag:[dic objectForKey:@"msg"] toView:weakSelf.view];
        }
        [_tableView reloadData];
 
    } failureBlock:^(NSError *error) {
        AYCLog(@"%@",error);
        [_tableView.mj_footer endRefreshing];
    } showHUD:YES];
}

#pragma mark - btn-Target事件

- (IBAction)inviteAction:(id)sender {
    if ([[[SingleHandle shareSingleHandle] getUserInfo].roleName isEqualToString:@"团队长"]) {
        
        [[FireData sharedInstance] eventWithCategory:@"我的团队" action:@"邀请队友" evar:nil attributes:nil];
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        InviteFriendViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"InviteFriendsVC"];
        vc.isTeamInvite = YES;
        [self.navigationController pushViewController:vc animated:YES];
//        [self performSegueWithIdentifier:@"invite" sender:self];
    }else{
        [[FireData sharedInstance] eventWithCategory:@"我的团队" action:@"申请团队长" evar:nil attributes:nil];
        NSString *url = [NSString stringWithFormat:@"%@%@",BaseAPI,kapplyTeamLeader];
        
        __weak typeof(self) weakSelf = self;
        [MHNetworkManager postReqeustWithURL:url params:@{@"userId":[[SingleHandle shareSingleHandle] getUserInfo].userId} successBlock:^(id returnData) {
            
            if ([[returnData objectForKey:@"flag"] isEqualToString:@"success"]) {
                [MBProgressHUD showMessag:@"提交申请团队长成功" toView:nil];
                [weakSelf.navigationController popViewControllerAnimated:YES];
                
            }else {
                [MBProgressHUD showMessag:[returnData objectForKey:@"msg"] toView:weakSelf.view];
            }
            
        } failureBlock:^(NSError *error) {
         
            
        } showHUD:NO];

    }
    
}




#pragma mark - tableView DataSource delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _teamMemberArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MyTeamTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
    if (cell == nil) {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"MyTeamTableViewCell" owner:self options:nil];
        cell = [array objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    TeamMember *teamMember = [_teamMemberArray objectAtIndex:indexPath.row];
    NSString *userName = nil;
    userName = teamMember.realName.length > 0 ? teamMember.realName : teamMember.userName;

    cell.lbName.text = userName;
    cell.lbIdCard.text = [NSString stringWithFormat:@"ID:%@",teamMember.userNum];
    [cell.phoneBtn setTitle:teamMember.phoneNo forState:UIControlStateNormal];
    [cell.chatName setTitle:teamMember.chatName forState:UIControlStateNormal];
    return cell;
    
}

- (CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (70.0 / 375) * KWidth;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
