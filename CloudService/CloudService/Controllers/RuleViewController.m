//
//  RuleViewController.m
//  CloudService
//
//  Created by 安永超 on 16/3/16.
//  Copyright © 2016年 zhangqiang. All rights reserved.
//

#import "RuleViewController.h"
#import "ShareManager.h"

@interface RuleViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLayout;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic)IBOutlet UIImageView *imageView;
@end

@implementation RuleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (KHeight == 736) {
        if ([self.ruleStr isEqualToString:@"活动4"]) {
            self.topLayout.constant = 220.f;
        }else{
            self.topLayout.constant = 210.f;
        }
    }else if (KHeight == 667) {
        if ([self.ruleStr isEqualToString:@"活动4"]) {
            self.topLayout.constant = 200.f;
        }else{
            self.topLayout.constant = 190.f;
        }
        
    }else {
        if ([self.ruleStr isEqualToString:@"活动4"]) {
            self.topLayout.constant = 270.f;
        }else{
            self.topLayout.constant = 160.f;
        }
        
    }
    __weak typeof(self) weakSelf = self;
    [weakSelf setLeftImageBarButtonItemWithFrame:CGRectMake(0, 0, 30, 30) image:@"title-back" selectImage:@"back" action:^(AYCButton *button) {
        
        [[FireData sharedInstance] eventWithCategory:@"活动规则" action:@"返回" evar:nil attributes:nil];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, KWidth, 10)];
    [_scrollView addSubview:label];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 8;// 字体的行间距
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont systemFontOfSize:15],
                                 NSParagraphStyleAttributeName:paragraphStyle
                                 };
    if ([self.ruleStr isEqualToString:@"活动1"]) {
        self.imageView.image = [UIImage imageNamed:@"rulebg1"];
                                
        label.attributedText = [[NSAttributedString alloc] initWithString:@"【活动参与规则】\n 1.首次注册的用户并认证成功（每位用户限参与一次）；\n 2.通过邀请新用户，（注册时必须要填写邀请人的邀请码，否则邀请人无法正常获取猴子）新用户注册成功后，赠送邀请人一只猴子（猴子种类随机派分）。\n 3.活动时间内集齐三种不同的猴子方可成功获得创业基金5000元优惠券。\n【兑现规则】\n 凡是在活动期间按照活动规则集满三种不同的小猴子，5000元创业基金优惠劵当日打到点点云服优惠劵账户。\n【优惠劵使用规则】\n 车险保费每满1500元可使用50元优惠券，出单时保费满1500元系统会自动将优惠劵转换为积分打到用户积分账户内（积分转换比例为：1:100）\n【活动时间】\n2016年4月20日00时起\n2016年5月31日24时止。" attributes:attributes];
        label.textColor = [UIColor whiteColor];
    }else if ([self.ruleStr isEqualToString:@"活动2"]) {
        self.imageView.image = [UIImage imageNamed:@"rulebg2"];
        label.attributedText = [[NSAttributedString alloc] initWithString:@"【活动内容】\n 邀请好友注册成功后（注册时必须要填写邀请人的邀请码，否则无法正常获得优惠券），赠送邀请人100元优惠劵。\n【兑现规则】\n 优惠劵实时到账。\n【优惠劵使用规则】\n 车险保费每满1500元可使用50元优惠券，出单时保费满1500元系统会自动将优惠劵转换为积分打到用户积分账户内（积分转换比例为：1:100）。\n【活动时间】\n2016年4月20日00时起\n2016年5月31日24时止。" attributes:attributes];
        label.textColor = [UIColor whiteColor];
//        UIButton *shareBtn = [[UIButton alloc] initWithFrame:cgrectmak]
        
    }else if ([self.ruleStr isEqualToString:@"活动4"]) {
        self.imageView.image = [UIImage imageNamed:@"rulebg4"];
        label.textColor = [HelperUtil colorWithHexString:@"#525252"];
        label.attributedText = [[NSAttributedString alloc] initWithString:@"【活动内容】\n 创建订单并投保支付成功，即可获10000积分奖励。\n【活动规则】\n 1、可与其它活动叠加；\n2、每单以车牌为准，新车以车架号为准；\n3、积分兑换比例1：100，如：10000积分能兑换100元；\n4、积分实时到账。\n【活动时间】\n2016年5月1日00时起\n2016年5月31日24时止。" attributes:attributes];
        
        //        UIButton *shareBtn = [[UIButton alloc] initWithFrame:cgrectmak]
        
    }else {
        self.imageView.image = [UIImage imageNamed:@"rulebg3"];
        label.attributedText = [[NSAttributedString alloc] initWithString:@"【活动内容】\n 邀请好友注册认证成功后（注册时必须要填写邀请人的邀请码，否则邀请人无法获得师傅激励）并连续3个月出单，邀请人可获得前3个月的师傅激励。\n【奖励规则】\n 师傅可获得徒弟前三个月积分的1个点的积分奖励，如：徒弟的积分为：30000积分（积分转换比例为：1:100），邀请人将获得300积分！\n【兑现规则】\n 激励积分次月5号前到账（即徒弟注册日起3个月为止）。\n【活动时间】\n2016年4月20日00时起\n2016年5月31日24时止。" attributes:attributes];
        label.textColor = [UIColor whiteColor];
        
    }
    label.numberOfLines = 0;
    
    CGRect rect = [label.attributedText boundingRectWithSize:CGSizeMake(KWidth-20, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:NULL];
    label.frame = CGRectMake(10, 0, KWidth-20, rect.size.height);
    
    UIButton *btn =[[ UIButton alloc] initWithFrame:CGRectMake(0.125*KWidth, rect.size.height+20, 0.75*KWidth, 36)];
    [btn addTarget:self action:@selector(sharedAction) forControlEvents:UIControlEventTouchUpInside];
    [btn setBackgroundImage:[UIImage imageNamed:@"card-btn"] forState:UIControlStateNormal];
    [btn setTitle:@"分享" forState:UIControlStateNormal];
    btn.layer.cornerRadius = 15;
    btn.layer.masksToBounds = YES;
    [_scrollView addSubview:btn];
    _scrollView.contentSize = CGSizeMake(0, rect.size.height+54+20);
    _scrollView.showsVerticalScrollIndicator = NO;
//    if ([self.ruleStr isEqualToString:@"活动1"]) {
//        label.frame = CGRectMake(10, 0, KWidth-20, rect.size.height+30);
//        btn.frame = CGRectMake(0.25*KWidth, rect.size.height+40, 0.5*KWidth, 36);
//        _scrollView.contentSize = CGSizeMake(0, rect.size.height+54+35);
//    }
    // Do any additional setup after loading the view.
}

- (void)sharedAction{
    
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    delegate.isThird=NO;
    // 获取邀请码
    [MHNetworkManager postReqeustWithURL:[RequestEntity urlString:kfindInviteLink] params:@{@"userId":[[SingleHandle shareSingleHandle] getUserInfo].userId} successBlock:^(id returnData) {
        [self successHander:returnData];
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];

}

/*
 1、集候纳财的改成：诚心邀请您加入点点云服，参加集候纳财活动，万元梦想基金等你拿！！   2、邀请好友，注册有礼：诚心邀请您加入点点云服，邀请好友，万元积分等你拿！！
 */

- (void)successHander:(id)returnData{
    [[FireData sharedInstance] eventWithCategory:@"活动规则" action:@"分享" evar:nil attributes:nil];
 
    if ([[returnData objectForKey:@"flag"] isEqualToString:@"success"]) {
        NSDictionary *dataDic = [returnData objectForKey:@"data"];
        NSString *_personInviteCode = [dataDic objectForKey:@"personInviteCode"];
        NSArray *imageArray = @[[UIImage imageNamed:@"sharLogo"]];
        if (imageArray) {
            NSString *content;
            NSString *weChatTitle;
            if ([self.ruleStr isEqualToString:@"活动1"]) {
                content =[NSString stringWithFormat:@"邀请您加入点点云服，参加集猴活动，万元梦想基金等你拿！邀请码:%@",_personInviteCode];
            }else if ([self.ruleStr isEqualToString:@"活动2"]){
                
                content= [NSString stringWithFormat:@"邀请有礼：邀请您加入点点云服，邀请好友，万元现金等你拿！邀请码:%@",_personInviteCode];
            }else if ([self.ruleStr isEqualToString:@"活动4"]){
                
                content= [NSString stringWithFormat:@"创建订单并投保支付成功，即有百元奖励，奖励无上限！邀请码:%@",_personInviteCode];
            }
            
            /**
             *  微信分享
             */
            weChatTitle= [NSString stringWithFormat:@"诚心邀请您加入点点云服，邀请码:%@",_personInviteCode];
            [[ShareManager manager] shareParamsByText:content images:imageArray url:[NSURL URLWithString:kCreateQRAPI] title:@"点点云服" WeChatTitle:weChatTitle];
        }
        
    }else {
        [MBProgressHUD showMessag:[returnData objectForKey:@"msg"] toView:nil];
    }
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
