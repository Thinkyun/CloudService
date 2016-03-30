//
//  VerifyCodeViewController.m
//  CloudService
//
//  Created by zhangqiang on 15/1/1.
//  Copyright © 2015年 zhangqiang. All rights reserved.
//

#import "VerifyCodeViewController.h"
#import "Utility.h"

@interface VerifyCodeViewController ()
{
    BOOL _isEye;
}
@property (weak, nonatomic) IBOutlet UITextField *pwdTextWord;
@property (strong, nonatomic)UIImageView *eyeImg;
@end

@implementation VerifyCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.eyeImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login-line"]];

    self.pwdTextWord.rightView = self.eyeImg;
    
    self.pwdTextWord.rightView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(eyeTap:)];
    [self.pwdTextWord.rightView addGestureRecognizer:tap];
    self.pwdTextWord.rightViewMode = UITextFieldViewModeAlways;
    
    self.title = @"验证原始密码";
    __weak typeof(self) weakSelf = self;
    [self setLeftImageBarButtonItemWithFrame:CGRectMake(0, 0, 35, 35) image:@"title-back" selectImage:@"" action:^(AYCButton *button) {
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)eyeTap:(UITapGestureRecognizer *)sender {
    _isEye = !_isEye;
    if (_isEye) {
        [[FireData sharedInstance] eventWithCategory:@"验证原始密码" action:@"显示密码" evar:nil attributes:nil];
        self.eyeImg.image = [UIImage imageNamed:@"login-line_"];
        self.pwdTextWord.secureTextEntry = NO;
    }else {
        [[FireData sharedInstance] eventWithCategory:@"验证原始密码" action:@"隐藏密码" evar:nil attributes:nil];
        self.eyeImg.image = [UIImage imageNamed:@"login-line"];
        self.pwdTextWord.secureTextEntry = YES;
    }
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (IBAction)nextStepActopn:(id)sender {
    [[FireData sharedInstance] eventWithCategory:@"验证原始密码" action:@"下一步" evar:nil attributes:nil];
    NSString *pwd = [Utility passWord];
    if ([pwd isEqualToString:self.pwdTextWord.text])
    {
        [self performSegueWithIdentifier:@"setNewPwd_push" sender:self];
    }else
    {
        [MBProgressHUD showMessag:@"原始密码错误" toView:self.view];
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
