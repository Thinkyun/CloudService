//
//  OrderH5ViewController.m
//  CloudService
//
//  Created by zhangqiang on 16/3/12.
//  Copyright © 2016年 zhangqiang. All rights reserved.
//

#import "OrderH5ViewController.h"
#import "ButelHandle.h"
#import "CallView.h"

@interface OrderH5ViewController ()<UIWebViewDelegate>

@property (nonatomic,strong)UIWebView *webView;

@end

@implementation OrderH5ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fireDataApp = [[FiredataApp alloc] init];
    [self setupViews];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[ButelHandle shareButelHandle] showCallView];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[ButelHandle shareButelHandle] showCallView];
    [[[ButelHandle shareButelHandle] callView] setTelNumStr:self.telPhoneNum];
    ;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[ButelHandle shareButelHandle] hideCallView];;
}

- (void)setupViews {
    
    self.title = @"报价页面";
    __weak typeof(self) weakSelf = self;
    [self setLeftImageBarButtonItemWithFrame:CGRectMake(0, 0, 30, 30) image:@"title-back" selectImage:@"" action:^(AYCButton *button) {
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, KWidth, KHeight - 64)];
    [self.view addSubview:self.webView];
    self.webView.delegate = self;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    [self.webView loadRequest:request];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    AYCLog(@"开始加载");
//    [MBProgressHUD showHUDAddedTo:(UIView*)[[[UIApplication sharedApplication]delegate]window] animated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
//    [MBProgressHUD hideHUDForView:(UIView*)[[[UIApplication sharedApplication]delegate]window] animated:YES];
    // 绑定 webView
    [self.fireDataApp bindWebView:webView
                   categoryPrefix:@"直客报价"
                             uvar:nil
                             cvar:nil
                             evar:nil
                        contentId:nil
                       contentCat:nil];
    AYCLog(@"结束加载");
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error {
    
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
