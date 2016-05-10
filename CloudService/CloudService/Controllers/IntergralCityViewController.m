//
//  IntergralCityViewController.m
//  CloudService
//
//  Created by zhangqiang on 16/3/1.
//  Copyright © 2016年 zhangqiang. All rights reserved.
//

#define kSecretKey @"D04220001"
#import "IntergralCityViewController.h"
#import "HelperUtil.h"

@interface IntergralCityViewController ()<UIWebViewDelegate>

@property(nonatomic,strong)UIWebView *webView;

@end

@implementation IntergralCityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
}

- (void)setupViews {
    
    self.title = @"积分商城";
    __weak typeof(self) weakSelf = self;
    [self setLeftImageBarButtonItemWithFrame:CGRectMake(0, 0, 30, 30) image:@"title-back" selectImage:@"" action:^(AYCButton *button) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ExchangeIntegralSuccess object:nil];
        [[FireData sharedInstance] eventWithCategory:@"积分商城" action:@"返回" evar:nil attributes:nil];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, KWidth, KHeight-64)];
    [self.view addSubview:self.webView];
    self.webView.delegate = self;
    
    
    
    //url
    NSURL *url = [NSURL URLWithString: _goodsCityUrl];
    //参数
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [dateFormatter stringFromDate:date];
    NSString *userNum = [[[SingleHandle shareSingleHandle] user] userNum];
    NSString *totalCredits = [NSString stringWithFormat:@"%@",[[[SingleHandle shareSingleHandle] user] usableNum]];
    NSString *key = [NSString stringWithFormat:@"%@%@",kSecretKey,userNum];
    NSString *sign = [self md5String:key];
    
    NSDictionary *params = @{@"Trstype":@"YG",@"Trscode":@"300001",@"Channel":@"B2C",@"transationId":@"1001101",@"dateTime":dateStr,@"userNum":userNum,@"totalCredits":totalCredits,@"sign":sign};
    AYCLog(@"商城：**%@*****%@",url,params);
    [[FireData sharedInstance] eventWithCategory:@"商城" action:@"进入商城" evar:params attributes:nil];
    NSData *paramsData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: url];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod: @"POST"];
    [request setHTTPBody: paramsData];
    
    [self.webView loadRequest:request];
}

- (void)loadData{
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (NSString*)md5String:(NSString*)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[32];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    
    // 先转MD5，再转大写
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
    
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
