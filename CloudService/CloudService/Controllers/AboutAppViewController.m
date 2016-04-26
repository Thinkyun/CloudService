//
//  AboutAppViewController.m
//  CloudService
//
//  Created by zhangqiang on 16/3/14.
//  Copyright © 2016年 zhangqiang. All rights reserved.
//

#import "AboutAppViewController.h"
#import "Tools.h"

@interface AboutAppViewController ()

@property (weak, nonatomic) IBOutlet UILabel *copyrightLabel1;
@property (weak, nonatomic) IBOutlet UILabel *copyrightLabel2;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *iconLabel;

@property (weak, nonatomic) IBOutlet UIImageView *qrImageView;
@end

@implementation AboutAppViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"关于";
    
    _qrImageView.image = [Tools createQRForString:kCreateQRAPI withSize:170.0];
    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(170.0/2-20, 170.0/2-20, 40, 40)];
    logoImageView.image = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon80.png" ofType:nil]];
    [_qrImageView addSubview:logoImageView];
    
    __weak typeof(self) weakSelf = self;
    [logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.and.width.equalTo(weakSelf.qrImageView).multipliedBy(0.25);
        make.center.equalTo(weakSelf.qrImageView);
    }];
    
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    double currentVersion = [[infoDict objectForKey:@"CFBundleShortVersionString"] doubleValue];
    self.versionLabel.text = [NSString stringWithFormat:@"版本号 V%.1f",currentVersion];
    [self setLeftImageBarButtonItemWithFrame:CGRectMake(0, 0, 30, 30) image:@"title-back" selectImage:@"" action:^(AYCButton *button) {
//        NSLog(@"Retain count is %ld", CFGetRetainCount((__bridge CFTypeRef)self));
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    // Do any additional setup after loading the view.
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
