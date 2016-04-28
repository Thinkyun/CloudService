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
        
        [[FireData sharedInstance] eventWithCategory:@"积分商城" action:@"返回" evar:nil attributes:nil];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.webView];
    self.webView.delegate = self;
    
    User *user = [SingleHandle shareSingleHandle].user;
    NSLog(@"%@*****%@",user.userNum,user.totalNum);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"www.baidu.con"]];
    [self.webView loadRequest:request];
}

- (void)loadData{
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [dateFormatter stringFromDate:date];
    
    User *user = [SingleHandle shareSingleHandle].user;
    NSDictionary *params = @{@"Trstype":@"YG",@"Trscode":@"300001",@"Channel":@"B2C",@"transationId":@"1001101",@"dateTime":dateStr,@"usrNum":user.userNum,@"totalCredits":user.totalNum};
    NSString *paramStr = [NSString stringWithFormat:@"%@%@",kSecretKey,[self JSONDataByDictionary:params]];
    NSString *md5Str = [HelperUtil md5HexDigest:paramStr];
    NSData *paramsData = [md5Str dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url;
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
    [request setHTTPBody:paramsData];
    request.HTTPMethod = @"POST";
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@",error);
//            faliureHander(error);
        }else{
            NSLog(@"%@",response);
//            successHander(data);
        }
    }];
    [dataTask resume];
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

- (NSData *)JSONDataByDictionary:(NSDictionary *)dict{
    NSMutableString *mutableStr = [NSMutableString new];
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (mutableStr.length==0) {
            [mutableStr appendFormat:@"%@=%@",key,obj];
        }else{
            [mutableStr appendFormat:@"&%@=%@",key,obj];
        }
    }];
    NSData *data = [NSJSONSerialization dataWithJSONObject:mutableStr options:NSJSONWritingPrettyPrinted error:nil];
    return data;
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
