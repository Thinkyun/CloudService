//
//  InviteFriendViewController.m
//  CloudService
//
//  Created by zhangqiang on 15/1/2.
//  Copyright © 2015年 zhangqiang. All rights reserved.
//

#import "InviteFriendViewController.h"
#import "Tools.h"
#import "ShareManager.h"

@interface InviteFriendViewController ()
{
    NSString *_linkUrl;
    NSString *_personInviteCode;
    NSString *_teamInviteCode;
}
@property (weak, nonatomic)IBOutlet UIImageView *qrImgView;
@end

@implementation InviteFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"邀请";
    [self setUpInviteLink];
    
    _qrImgView.image = [Tools createQRForString:kCreateQRAPI withSize:188];
    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(188.0/2-20, 188.0/2-20, 40, 40)];
    logoImageView.image = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon80.png" ofType:nil]];
    [_qrImgView addSubview:logoImageView];
    
    __weak typeof(self) weakSelf = self;
    [self setLeftImageBarButtonItemWithFrame:CGRectMake(0, 0, 30, 30) image:@"title-back" selectImage:@"" action:^(AYCButton *button) {
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    
}
- (void)setUpInviteLink {
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseAPI,kfindInviteLink];
    User *user = [[SingleHandle shareSingleHandle] getUserInfo];
    
    __weak typeof(self) weakSelf = self;
    [MHNetworkManager postReqeustWithURL:url params:@{@"userId":user.userId} successBlock:^(id returnData) {
        
        if ([[returnData objectForKey:@"flag"] isEqualToString:@"success"]) {
            NSDictionary *dataDic = [returnData objectForKey:@"data"];
            _linkUrl = [dataDic objectForKey:@"inviteLink"];
            AYCLog(@"%@",_linkUrl);
            _personInviteCode = [dataDic objectForKey:@"personInviteCode"];
            _teamInviteCode = [dataDic objectForKey:@"teamInviteCode"];
            
        }else {
            [MBProgressHUD showMessag:[returnData objectForKey:@"msg"] toView:weakSelf.view];
        }
        
    } failureBlock:^(NSError *error) {
      
        
    } showHUD:NO];

}

- (IBAction)shareAction:(id)sender {
    [[FireData sharedInstance] eventWithCategory:@"邀请页面" action:@"分享" evar:nil attributes:nil];
    if (_linkUrl.length <= 0) {
        [MBProgressHUD showMessag:@"生成邀请url失败" toView:self.view];
        return;
    }
    //1、创建分享参数
    NSArray* imageArray = @[[UIImage imageNamed:@"sharLogo"]];
        if (imageArray) {
            NSString *content = nil;
            if (self.isTeamInvite) {
                content = [NSString stringWithFormat:@"诚心邀请您加入点点云服，送万元梦想基金\n团队邀请码:%@",_teamInviteCode];
            }else {
                content = [NSString stringWithFormat:@"诚心邀请您加入点点云服，送万元梦想基金\n个人邀请码:%@",_personInviteCode];
            }
            
            /**
             *  微信分享
             */
            [[ShareManager manager] shareParamsByText:content images:imageArray url:[NSURL URLWithString:kCreateQRAPI] title:@"点点云服"];

        }
    
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
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
