//
//  AppDelegate.m
//  CloudService
//
//  Created by zhangqiang on 16/2/22.
//  Copyright © 2016年 zhangqiang. All rights reserved.
//

#import "AppDelegate.h"
#import "BaseNaviViewController.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>
#import "WXApi.h"
#import "Utility.h"
#import "MHAsiNetworkHandler.h"
#import "FireData.h"
#import <JPUSHService.h>
#import "ButelHandle.h"
#import "SingleHandle.h"

#define MObAppKey     @"100082c56c5c0"
#define WXAppID       @"wx5ba999122c08bd76"
#define WXAppSecret   @"64865cd279891a0929b1343ef63c7412"
#define JAppKey       @"f8500a8c6752cafab40e7daf"
#define Jchannel      @"Publish channel"
@interface AppDelegate ()<CLLocationManagerDelegate,UIAlertViewDelegate,FireDataDelegate> {
    BOOL _isSetCity;
    NSString *_updateUrl;
}

@end

@implementation AppDelegate
@synthesize window =_window;

@synthesize isThird;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
   
    // Override point for customization after application launch.
    //极光推送
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                          UIUserNotificationTypeSound |
                                                          UIUserNotificationTypeAlert)
                                              categories:nil];
    } else {
        //categories 必须为nil
        [JPUSHService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                          UIRemoteNotificationTypeSound |
                                                          UIRemoteNotificationTypeAlert)
                                              categories:nil];
    }
    //JAppKey : 是你在极光推送申请下来的appKey Jchannel : 可以直接设置默认值即可 Publish channel
    [JPUSHService setupWithOption:launchOptions appKey:JAppKey
                          channel:Jchannel apsForProduction:YES]; //如果是生产环境应该设置为Y                                                                                                                                                                                                                                                                                                                                                                            ES
    
    NSDictionary *remoteNotification = [launchOptions objectForKey: UIApplicationLaunchOptionsRemoteNotificationKey];
    AYCLog(@"%@",remoteNotification);
    
    //检测网络状态
    if ([[HelperUtil getNetWorkStates] isEqualToString:@"2G"]) {
        [MBProgressHUD showMessag:@"当前处于2G网络，您当前所有操作可能会有延迟！" toView:nil];
    }
    

    /**
     *  获取省份列表
     *
     */
    
    [[SingleHandle shareSingleHandle] getAreas];
    
    
    __weak typeof(self) weakSelf = self;
    // 检查版本号
    [Utility checkNewVersion:^(BOOL hasNewVersion,NSString *updateUrl) {
        [Utility saveVersion:hasNewVersion];
        if (hasNewVersion) {
            _updateUrl = updateUrl;
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"版本更新" message:@"系统检测有新版本" delegate:weakSelf cancelButtonTitle:nil otherButtonTitles:@"点击进入下载", nil];
            alertView.tag = 100;
            [alertView show];
        }
    }];
    
    // 注册shareSDK
    [self registerShareSDK];
    // 注册通知
    [self registerNotifications];
    // 注册定位
    [self registerLocation];
    
    //设置状态栏为白色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    /**
     *  火炬统计
     */
    [self registerFireData];
    
    /**
     *  判断是否免登陆
     */
//    if ([Utility passWord]) {
//        [self exemptLogin];
//    }else {
//        
//        [self loginToLogin];
//    }
    
    return YES;
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex NS_DEPRECATED_IOS(2_0, 9_0) {
    
    if(buttonIndex == 0) {

        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.ddyunf.com/html/download.html"]];
    }
    
    
}

/**
 *  数据统计
 */
-(void)registerFireData {
    // 配置统计 SDK
    [[FireData sharedInstance] initWithAppKey:@"YUNKFD3SXE" distributors:@"ios"];
    [FireData sharedInstance].debugMode = NO;
    [FireData sharedInstance].enableCrashReport = YES;
    [FireData sharedInstance].enableLocationReport = YES;
    [FireData sharedInstance].sendTimeInterval = 10;
    [FireData sharedInstance].enableIDFA = NO;
    [FireData sharedInstance].delegate = self;
    
    
    
//    [FireData sharedInstance].refcode = @"refcode100000";
}
/* 统计SDK捕获到异常，程序即将崩溃时，回调此函数 */
-(void)onCrash {
    
}


/**
 定义协议函数，在SDK内部捕获到对应崩溃事件，并将对应的崩溃事件添加到事件队列后进行对应的事件处理，并将当前获取到的异常信息对象传递
 */
- (void)onCrashAfterAddedToEventArrWithCrashInfo:(NSDictionary *)exception {
    
}

- (void)registerShareSDK {
    [ShareSDK registerApp:MObAppKey
     
          activePlatforms:@[
                            @(SSDKPlatformTypeWechat)]
                 onImport:^(SSDKPlatformType platformType)
     {
         switch (platformType)
         {
             case SSDKPlatformTypeWechat:
                 [ShareSDKConnector connectWeChat:[WXApi class]];
                 break;
             default:
                 break;
         }
     }
          onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo)
     {
         
         switch (platformType)
         {
             case SSDKPlatformTypeWechat:
                 [appInfo SSDKSetupWeChatByAppId:WXAppID
                                       appSecret:WXAppSecret];
                 break;
             default:
                 break;
         }
     }];
}
/**
 *  注册通知
 */
- (void)registerNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginToMenu) name:LoginToMenuViewNotice object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logOut) name:LogOutViewNotice object:nil];
    /**
     *  注册极光推送监听
     *
     *  @return
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkDidSetup:) name:kJPFNetworkDidSetupNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkDidClose:) name:kJPFNetworkDidCloseNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkDidRegister:) name:kJPFNetworkDidRegisterNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkDidLogin:) name:kJPFNetworkDidLoginNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkDidReceiveMessage:) name:kJPFNetworkDidReceiveMessageNotification object:nil];
}

/**
 *  注册定位
 */
- (void)registerLocation {
    
    self.locateManager = [[CLLocationManager alloc] init];
    if (![CLLocationManager locationServicesEnabled]) {
        return;
    }
    //如果没有授权则请求用户授权
    //设置代理
    self.locateManager.delegate = self;
    //设置定位精度
    self.locateManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    //定位频率,每隔多少米定位一次
    CLLocationDistance distance=100.0;//十米定位一次
    self.locateManager.distanceFilter=distance;
    //启动跟踪定位
    if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusNotDetermined){
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
            [self.locateManager requestWhenInUseAuthorization];
        }
        
//        [self registerLocation];
    }else if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusAuthorizedWhenInUse){
   
        [self.locateManager startUpdatingLocation];
    }
}

- (void)loginToMenu {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BaseNaviViewController *menuVC = [storyBoard instantiateViewControllerWithIdentifier:@"MenuNavi"];

    UIViewController *oldVC = self.window.rootViewController;
    oldVC = nil;
    self.window.rootViewController = menuVC;

    
}

- (void)logOut{
    [[ButelHandle shareButelHandle] logOutButel];
}

- (void)loginToLogin {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *loginVC = [storyBoard instantiateViewControllerWithIdentifier:@"loginNavi"];
    UIViewController *oldVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    oldVC = nil;
    
    [UIApplication sharedApplication].keyWindow.rootViewController = loginVC;
}



#pragma mark -- CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    CLLocation *currentLocation = [locations lastObject];
    CLGeocoder *geoder = [[CLGeocoder alloc] init];
    __block CLPlacemark *placeMark = nil;
//    __weak typeof(self) weakSelf = self;
    [geoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (_isSetCity) {
            return ;
        }
        if (placemarks.count > 0) {
            placeMark = [placemarks firstObject];
            NSString *city = [NSString stringWithFormat:@"%@%@",placeMark.locality,placeMark.subLocality];
            [Utility saveLocation:city];
            _isSetCity = YES;
        }
    }];
    
    //如果不需要实时定位，使用完即使关闭定位服务
    [self.locateManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status  {
    
    if(status==kCLAuthorizationStatusAuthorizedWhenInUse)
    {
        [self.locateManager startUpdatingLocation];
    }
}

#pragma mark JPush
/**
 *  JPush建立连接
 *
 *  @param notification
 */
- (void)networkDidSetup:(NSNotification *)notification {
    AYCLog(@"JPush建立连接");
}
/**
 *  JPush关闭连接
 *
 *  @param notification
 */
- (void)networkDidClose:(NSNotification *)notification {
    AYCLog(@"JPush关闭连接");
}
/**
 *  JPush注册成功
 *
 *  @param notification
 */
- (void)networkDidRegister:(NSNotification *)notification {
    AYCLog(@"JPush注册成功");
}
/**
 *  JPush登录成功
 *
 *  @param notification
 */
- (void)networkDidLogin:(NSNotification *)notification {
    AYCLog(@"JPush登录成功");
    /**
     *  获取
     */
    NSString *registrationID = [Utility RegistrationID];
    if (!registrationID) {
        registrationID = [JPUSHService registrationID];
        [Utility saveRegistrationID:registrationID];
    }

}
/**
 *  JPush收到自定义消息(非APNS)
 *
 *  @param notification
 */
- (void)networkDidReceiveMessage:(NSNotification *)notification {
    AYCLog(@"JPush收到自定义消息(非APNS)");
    NSDictionary * userInfo = [notification userInfo];
    NSString *content = [userInfo valueForKey:@"content"];
    NSDictionary *extras = [userInfo valueForKey:@"extras"];
    NSString *customizeField1 = [extras valueForKey:@"customizeField1"]; //自定义参数，key是自己定义的
    
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Required
    [JPUSHService registerDeviceToken:deviceToken];
   
}

//-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
//    NSString *alert = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
//    if (application.applicationState == UIApplicationStateActive) {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"推送消息"
//                                                            message:alert
//                                                           delegate:self
//                                                  cancelButtonTitle:@"OK"
//                                                  otherButtonTitles:nil];
//        [alertView show];
//    }
//    [application setApplicationIconBadgeNumber:0];
//
//    
//    // 取得 APNs 标准信息内容
//    NSDictionary *aps = [userInfo valueForKey:@"aps"];
//    NSString *content = [aps valueForKey:@"alert"]; //推送显示的内容
//
//    
//    // 取得Extras字段内容
//    NSString *customizeField1 = [userInfo valueForKey:@"customizeExtras"]; //服务端中Extras字段，key是自己定义的
//    AYCLog(@"content =[%@], customize field  =[%@]",content,customizeField1);
//    
//    // Required
//    [JPUSHService handleRemoteNotification:userInfo];
//}



- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    NSString *alert = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    if (application.applicationState == UIApplicationStateActive) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"推送消息"
                                                            message:alert
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        alertView.tag = 101;
        [alertView show];
    }
    [application setApplicationIconBadgeNumber:0];
    
    
    // 取得 APNs 标准信息内容
    NSDictionary *aps = [userInfo valueForKey:@"aps"];
    NSString *content = [aps valueForKey:@"alert"]; //推送显示的内容
    
    
    // 取得Extras字段内容
    NSString *customizeField1 = [userInfo valueForKey:@"customizeExtras"]; //服务端中Extras字段，key是自己定义的
    AYCLog(@"content =[%@], customize field  =[%@]",content,customizeField1);

    // IOS 7 Support Required
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}



- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    //Optional
    AYCLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

#pragma mark AppDelegate



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [application setApplicationIconBadgeNumber:0];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    if ([Utility isNewVersion]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"版本更新" message:@"系统检测有新版本" delegate:self cancelButtonTitle:nil otherButtonTitles:@"点击进入下载", nil];
        [alertView show];
    }
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    

    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
