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
    //http登陆
    __block AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    delegate.isThird=YES;
    [MHNetworkManager postReqeustWithURL:@"http://221.4.250.108:8088/apHttpService/agent/login4Butel" params:@{@"entId":@"7593111023", @"agentId":@"1001",@"passWord":@"1001"} successBlock:^(NSDictionary *returnData) {
        delegate.isThird = NO;
        NSDictionary *dic = returnData;
        if ([[dic objectForKey:@"code"] isEqualToString:@"000"]) {
            NSDictionary *extDic = [dic objectForKey:@"ext"];
            NSString *str = [extDic objectForKey:@"dn"];
            NSArray *array = [str componentsSeparatedByString:@":"];
            _deviceId = [extDic objectForKey:@"nubeUUID"];
            _UUID = [extDic objectForKey:@"nubeAppKey"];
            _number = [array objectAtIndex:1];
            
             [[NSNotificationCenter defaultCenter] postNotificationName:LoginToMenuViewNotice object:nil];
            NSLog(@"%@",dic);
            
        }else {
            [MBProgressHUD showError:[dic objectForKey:@"msg"] toView:nil];
        }
        
    } failureBlock:^(NSError *error) {
        delegate.isThird = NO;
        NSLog(@"%@",error);
    } showHUD:YES];
}

- (void)Init {
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
    if (isCanCall) {
        [self.connect Logout];
         self.callView = nil;
        
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
    [self.connect OpenSpeaker:isSpeaker];
}

// 静音
- (void)enableMute:(bool )isMute {
    [self.connect EnableMute:isMute];
}

// 设置拨打手机号
- (void)setPhoneNo:(NSString *)phoneNo {
    self.callView.telNumStr = phoneNo;
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
        if (isCanCall) {
            User *user = [[SingleHandle shareSingleHandle] getUserInfo];
            if (![HelperUtil checkTelNumber:phoneNo]) {
                [MBProgressHUD showError:@"手机号格式不正确" toView:nil];
                return;
            }
            if ([user.roleName isEqualToString:@"普通用户"] || user.roleName.length <= 0) {
                [MBProgressHUD showError:@"当前用户为普通用户,不能拨打电话" toView:nil];
                return ;
            }
            AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
            delegate.isThird=YES;
            _requestId = [HelperUtil uuidString];
            NSLog(@"----------------------------------%@",_requestId);
            [MHNetworkManager postReqeustWithURL:@"http://221.4.250.108:8088/apHttpService/agent/makeCall" params:@{@"entId":@"7593111023", @"agentId":@"1001",@"number":phoneNo, @"ani":@"12345", @"uuid":_requestId, @"requestType":@"test" } successBlock:^(NSDictionary *returnData) {
                NSDictionary *dic = returnData;
                NSLog(@"%@",dic);
                if ([[dic objectForKey:@"code"] isEqualToString:@"000"]) {
                    _phoneNo = phoneNo;
                    NSLog(@"拨打电话成功");
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
                NSLog(@"%@",error);
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
    NSLog(@"APP::OnInit()...");
    
    if (reason == 0) {
       [self loginWithLogin:_UUID number:_number deviceId:_deviceId nickname:@"CONNECT" userUniqueIdentifer:_deviceId];
        
    }
}

- (void)OnLogin:(int)reason
{
    NSLog(@"APP::OnLogin()...");
    
    if (reason == 0) {
        isCanCall = YES;
        //        [RedAlertUtil showAlertWithText:@"登录成功..."];
        NSLog(@"denglu chengg");
        
    }
}
- (void)OnRing:(NSString*)Sid {
    NSLog(@"%@",Sid);
    
}
//打电话成功回调
- (void)OnConnect:(int)mediaFormat Sid:(NSString*)Sid {
    
    [self.callView OnConnectSuccess];
    NSLog(@"%i,%@",mediaFormat,Sid);
}


- (void)OnNewcall:(NSString*)szCallerNum szCallerNickname:(NSString*)szCallerNickname Sid:(NSString*)Sid  nCallType:(int) nCallType  szExtendSignalInfo:(NSString*)szExtendSignalInfo{
    NSLog(@"%@",szCallerNum);
}

//挂断回调
- (void)OnDisconnect:(int) nReason Sid:(NSString*)Sid{
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
            NSLog(@"%@",[[exception callStackSymbols] componentsJoinedByString:@"\n"]);

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
            NSLog(@"%i",status.curConnStatus);
            [self.connect Uninit];
        } @catch (NSException *exception) {
            NSLog(@"%@",[[exception callStackSymbols] componentsJoinedByString:@"\n"]);
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
                             @"phoneNo":_phoneNo};
    [MHNetworkManager postReqeustWithURL:[NSString stringWithFormat:@"%@%@",BaseAPI,kSaveTape] params:params successBlock:^(id returnData) {
        
        if ([[returnData valueForKey:@"flag"] isEqualToString:@"success"]) {
            
        }
        
    } failureBlock:^(NSError *error) {
        
    } showHUD:NO];
}
@end
