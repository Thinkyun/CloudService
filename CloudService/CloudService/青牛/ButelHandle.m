//
//  ButelHandle.m
//  CloudService
//
//  Created by 安永超 on 16/3/4.
//  Copyright © 2016年 zhangqiang. All rights reserved.
//

#import "ButelHandle.h"
#import "CallView.h"
#import "AppDelegate.h"
#import <ButelCommonConnectSDK/ButelCommonConnectSDK.h>
#import <ButelCommonConnectSDK/ButelRecordConnect.h>
#import "Utility.h"
#import <JPUSHService.h>

#define EntId  @"7593111023"
static ButelHandle *singleHandle = nil;

@interface ButelHandle()<ButelCommonConnectDelegateV1>
{
    BOOL isCall;//是否拨号
   
    BOOL isCanCall;  // 拨号之前判断能否拨号
    NSString *_deviceId;
    NSString *_UUID;
    NSString *_number;
    NSString *_phoneNo;
    NSString *_requestId;
    BOOL _isLogin;//是否登陆状态
    NSString *_butelMsg;
    NSString *_baseId;//baseId
    
}

@property (retain) ButelCommonConnectV1 *connect;

@property (nonatomic,strong)CallView *callView;
@end

@implementation ButelHandle

+ (ButelHandle *)shareButelHandle {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleHandle = [[ButelHandle alloc] init];
        
    });
    return singleHandle;
}
/**
 *  青牛http登陆
 */
- (void)ButelHttpLogin {
    [[FireData sharedInstance] eventWithCategory:@"青牛" action:@"http登陆" evar:nil attributes:nil];
    User *user = [[SingleHandle shareSingleHandle] getUserInfo];
    if ([user.roleName isEqualToString:@"普通用户"] || user.roleName.length <= 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:LoginToMenuViewNotice object:nil];
        return;
    }
    //http登陆
    __block AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    delegate.isThird=YES;
    [MHNetworkManager postReqeustWithURL:kButelUrl params:@{@"entId":EntId,
                                                            @"agentId":user.userNum,
                                                            @"passWord":user.userNum}
                            successBlock:^(NSDictionary *returnData) {
        delegate.isThird = NO;
        NSDictionary *dic = returnData;
        if ([[dic objectForKey:@"code"] isEqualToString:@"000"]) {
            NSDictionary *extDic = [dic objectForKey:@"ext"];
            NSString *str = [extDic objectForKey:@"dn"];
            NSArray *array = [str componentsSeparatedByString:@":"];
            _deviceId = [extDic objectForKey:@"nubeUUID"];
            _UUID = [extDic objectForKey:@"nubeAppKey"];
            _number = [array objectAtIndex:1];
            _isLogin = YES;
            /**
             *  初始化青牛
             */
            [[ButelHandle shareButelHandle] Init];
            
        }else {

            _butelMsg = [dic objectForKey:@"msg"];
            _isLogin = NO;
        }
        
    } failureBlock:^(NSError *error) {
        delegate.isThird = NO;
   
    } showHUD:NO];
}

- (void)Init {
    [[FireData sharedInstance] eventWithCategory:@"青牛" action:@"青牛sdk初始化" evar:nil attributes:nil];
    if (![_number isEqualToString:@""]&&![_UUID isEqualToString:@""]&&![_number isEqualToString:@""]) {
        self.callView = nil;
        //初始化青牛
        self.connect = [ButelEventConnectSDK CreateButelCommonConn:self];
        
        if ([self.connect Init] == -50006) {
            
        }
    }else{
        
        [MBProgressHUD showMessag:@"正在登陆青牛" toView:nil];    
    }
    
}

- (void)logOut {
    User *user = [[SingleHandle shareSingleHandle] getUserInfo];
    if ([user.roleName isEqualToString:@"普通用户"] || user.roleName.length <= 0) {
        self.callView = nil;
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *loginVC = [storyBoard instantiateViewControllerWithIdentifier:@"loginNavi"];
        UIViewController *oldVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        oldVC = nil;
        
        [UIApplication sharedApplication].keyWindow.rootViewController = loginVC;
        return ;
    }
    if (!_isLogin) {
        self.callView = nil;
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *loginVC = [storyBoard instantiateViewControllerWithIdentifier:@"loginNavi"];
        UIViewController *oldVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        oldVC = nil;
        
        [UIApplication sharedApplication].keyWindow.rootViewController = loginVC;
        return;
        
    }
    if (isCanCall) {
        [[FireData sharedInstance] eventWithCategory:@"青牛" action:@"退出登陆" evar:nil attributes:nil];
        [self.connect Logout];
         self.callView = nil;
        /**
         *  退出登录时清除账号信息
         */
        [JPUSHService setTags:[NSSet set] alias:@"" callbackSelector:nil target:nil];
//        User *user = [[SingleHandle shareSingleHandle] getUserInfo];
//        
//        [Utility saveUserName:user.phoneNo passWord:nil];
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *loginVC = [storyBoard instantiateViewControllerWithIdentifier:@"loginNavi"];
        UIViewController *oldVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        oldVC = nil;
       
        [UIApplication sharedApplication].keyWindow.rootViewController = loginVC;
    }else {
        
        [MBProgressHUD showMessag:@"青牛正在登陆，请稍候" toView:nil];
    }

}

// 扬声器
- (void)openSpeaker:(BOOL )isSpeaker {
    [[FireData sharedInstance] eventWithCategory:@"青牛" action:@"开启扬声器" evar:nil attributes:nil];
    [self.connect OpenSpeaker:isSpeaker];
}

// 静音
- (void)enableMute:(bool )isMute {
    [[FireData sharedInstance] eventWithCategory:@"青牛" action:@"静音" evar:nil attributes:nil];
    [self.connect EnableMute:isMute];
}

// 设置拨打手机号
- (void)setPhoneNo:(NSString *)phoneNo phoneWithBaseId:(NSString *)baseId{
    self.callView.telNumStr = phoneNo;
    _baseId = baseId;
}

- (void)showCallView {
    if (!self.callView) {
        self.callView = [[CallView alloc] initWithFrame:CGRectMake(KWidth-20, KHeight/2, 220, 80)];
    }
    self.callView.telNumStr = nil;
    self.callView.hidden = NO;
}

- (void)hideCallView {
    self.callView.hidden = YES;
}

- (void)makeCallWithPhoneNo:(NSString *)phoneNo {
    
    if (isCall) {
        //挂断
        [self.connect HangupCall:0];
        
    }else {
        User *user = [[SingleHandle shareSingleHandle] getUserInfo];
        if ([user.roleName isEqualToString:@"普通用户"] || user.roleName.length <= 0) {
            [MBProgressHUD showMessag:@"当前用户为普通用户,不能拨打电话" toView:nil];
            return ;
        }
        if (!_isLogin) {
            [MBProgressHUD showMessag:_butelMsg toView:nil];
            return;
            
        }
        if (isCanCall) {
            
            if (![HelperUtil checkTelNumber:phoneNo]) {
                [MBProgressHUD showError:@"手机号格式不正确" toView:nil];
                return;
            }
            
            [[FireData sharedInstance] eventWithCategory:@"青牛" action:@"http拨打电话" evar:@{@"phone":phoneNo} attributes:nil];
            
            AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
            delegate.isThird=YES;
            
            /**
             *  每次打电话前生成一次uuid
             */
            _requestId = [HelperUtil uuidString];
            [MHNetworkManager postReqeustWithURL:kButelMakeCall
                                          params:@{@"entId":EntId,
                                                   @"agentId":user.userNum,
                                                   @"number":phoneNo,
                                                   @"ani":@"12345",
                                                   @"uuid":_requestId,
                                                   @"requestType":@"test" }
                                    successBlock:^(NSDictionary *returnData) {
                NSDictionary *dic = returnData;
                if ([[dic objectForKey:@"code"] isEqualToString:@"000"]) {
                    _phoneNo = phoneNo;
                }else {
                    if ([[dic objectForKey:@"msg"] isEqual:[NSNull null]]) {
                        [MBProgressHUD showError:@"服务器异常" toView:nil];
                        
                    }else{
                        [self loginWithLogin:_UUID number:_number deviceId:_deviceId nickname:@"CONNECT" userUniqueIdentifer:_deviceId];
                        [MBProgressHUD showError:[dic objectForKey:@"msg"] toView:nil];
                    }
                    
                }
                delegate.isThird = NO;
            } failureBlock:^(NSError *error) {
                delegate.isThird = NO;
            } showHUD:NO];
            isCall = !isCall;
        }else {
            [MBProgressHUD showMessag:@"正在集成中，请稍候" toView:[UIApplication sharedApplication].keyWindow];
          
            return;

        }
    }
    [self.callView callPhoneOrHangUp];

}
- (void)popCallView {
    [self.callView popCallView];
}
#pragma mark 回调入口
/****************************************************回调实现****************************************************************/
- (void)OnInit:(int)reason
{
    AYCLog(@"APP::OnInit()...");
    
    if (reason == 0) {
       [self loginWithLogin:_UUID number:_number deviceId:_deviceId nickname:@"CONNECT" userUniqueIdentifer:_deviceId];
        
    }
}

- (void)OnLogin:(int)reason
{
    AYCLog(@"APP::OnLogin()...");
    
    if (reason == 0) {
        isCanCall = YES;
       
        //        [RedAlertUtil showAlertWithText:@"登录成功..."];
        AYCLog(@"denglu chengg");
        
    }
}
- (void)OnRing:(NSString*)Sid {
    AYCLog(@"%@",Sid);
    
}
//打电话成功回调
- (void)OnConnect:(int)mediaFormat Sid:(NSString*)Sid {
    [[FireData sharedInstance] eventWithCategory:@"青牛" action:@"拨打电话成功回调" evar:nil attributes:nil];
    [self.callView OnConnectSuccess];
    AYCLog(@"%i,%@",mediaFormat,Sid);
}


- (void)OnNewcall:(NSString*)szCallerNum szCallerNickname:(NSString*)szCallerNickname Sid:(NSString*)Sid  nCallType:(int) nCallType  szExtendSignalInfo:(NSString*)szExtendSignalInfo{
    AYCLog(@"%@",szCallerNum); 
}

//挂断回调
- (void)OnDisconnect:(int) nReason Sid:(NSString*)Sid{
    [[FireData sharedInstance] eventWithCategory:@"青牛" action:@"挂断电话回掉" evar:nil attributes:nil];
    isCall = !isCall;

    [self.callView OnDisconnect];
    /**
     *  挂断电话后向后台传录音流水号
     */
    [self sendTape:_requestId];
    
}
-(void)OnCdrNotify:(NSString *)cdrInfo {
    
}

- (void)OnUninit:(int)reason {
    if (reason == 0) {
        @try {
            //释放青牛sdk
            [ButelEventConnectSDK destroyButelCommonConn:self.connect];
        } @catch (NSException *exception) {
            AYCLog(@"%@",[[exception callStackSymbols] componentsJoinedByString:@"\n"]);

        }
        
    }
    
}

/** 申请注册新号回调
 @param reason 申请注册新号成功与否 0：成功， <0：失败原因
 @param number 返回的新号
 @return void
 */
- (void)OnRegister:(int)reason number:(NSString *)number{
    
}

/** 注销号码回调
 @param reason 注销号码成功与否 0：成功， <0：失败原因
 @return void
 */
- (void)OnUnRegister:(int)reason{
    
}



/**描述 登陆结果回调
 @param nReason	0：成功，<0：失败原因
 @param token	    登陆使用的token
 */
- (void)OnLoginWithToken:(int)nReason token:(NSString *)token {
    if (nReason == 0) {
     
    }
}

///** 登出回调
// @param reason 登出成功与否 0：成功， <0：失败原因

-(void)onLogout:(int)reason {
    if (reason == 0) {
        @try {
            ButelStatus status = [self.connect GetButelConnStatus];
            AYCLog(@"%i",status.curConnStatus);
            [self.connect Uninit];
        } @catch (NSException *exception) {
            AYCLog(@"%@",[[exception callStackSymbols] componentsJoinedByString:@"\n"]);
        }
    }

}


// 登陆
- (void)loginWithLogin:(NSString *)UUID number:(NSString *)number deviceId:(NSString *)deviceID nickname:(NSString *)nickName userUniqueIdentifer:(NSString *)userID {
    [self.connect Login:UUID number:number deviceId:deviceID nickname:nickName userUniqueIdentifer:userID];
}

/**
 *  往后台服务器传录音流水号
 */
- (void)sendTape:(NSString *)sid {
    NSDictionary *params = @{@"userId":[[SingleHandle shareSingleHandle] getUserInfo].userId,
                             @"requestId":sid,
                             @"phoneNo":_phoneNo,
                             @"baseId":_baseId};
    [MHNetworkManager postReqeustWithURL:[NSString stringWithFormat:@"%@%@",BaseAPI,kSaveTape] params:params successBlock:^(id returnData) {
        
        if ([[returnData valueForKey:@"flag"] isEqualToString:@"success"]) {
            _phoneNo = @"";
        }else{
            [MBProgressHUD showMessag:[returnData valueForKey:@"msg"] toView:nil];
        }
        
    } failureBlock:^(NSError *error) {
        
    } showHUD:NO];
}
@end
