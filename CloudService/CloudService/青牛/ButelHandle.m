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
#import "SingleHandle.h"

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
    BOOL _isLogOut;//是否登出操作
    BOOL _isUnInit;//是否反初始化
    BOOL _isInit;//是否初始化
   
    
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
//        [[NSNotificationCenter defaultCenter] postNotificationName:LoginToMenuViewNotice object:nil];
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
        _isLogin = NO;
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
/**
 *  app登出操作
 */
- (void)logOut {
    /**
     *  在app退出登录操作之前首先判断用户类型:
     *  ****1.   如果用户是普通用户的话，不具备打电话的功能，直接退出app，不做其他操作
     *  ****2.   如果用户是非普通用户的话，要先登出青牛
     *       登出青牛之前要做一些判断：
     *       ****2.1  判断http是否成功登陆
     *       ****2.2  判断sdk是否登陆成功，如果未登录，重新登陆一遍sdk。
     *                                  如果登陆中，则提示用户等待.
     *                                  如果登录成功，先http登出。http登出成功后再进行sdk登出
     */
    User *user = [[SingleHandle shareSingleHandle] getUserInfo];
    if ([user.roleName isEqualToString:@"普通用户"] || user.roleName.length <= 0) {
        [[SingleHandle shareSingleHandle] logOut];
        return ;
    }
    if (!_isLogin) {
       [[SingleHandle shareSingleHandle] logOut];
        return;
        
    }
    if (isCanCall) {
        ButelStatus status = [self.connect GetButelConnStatus];
   
        switch (status.curConnStatus) {
            case BS_UNConnect:
                [MBProgressHUD showMessag:@"青牛未登陆" toView:nil];
                /**
                 *  先判断一下青牛是否初始化成功，如果初始化成功，先进行反初始化，然后退出app
                 *  如果没有初始化直接退出app
                 */
                if (_isInit) {
                    [MBProgressHUD showHUDAddedTo:(UIView*)[[[UIApplication sharedApplication]delegate]window] animated:YES];
                    [self.connect Uninit];
                    _isUnInit = YES;
                }else {
                    [[SingleHandle shareSingleHandle] logOut];
                }

                AYCLog(@"%@%@%@",_UUID,_number,_deviceId);
                break;
            case BS_Connecting:
                [MBProgressHUD showMessag:@"青牛正在登陆，请稍候" toView:nil];
                
                break;
            case BS_Connect2ButelNet:
            {
                [[FireData sharedInstance] eventWithCategory:@"青牛" action:@"退出登陆" evar:nil attributes:nil];
                [MBProgressHUD showHUDAddedTo:(UIView*)[[[UIApplication sharedApplication]delegate]window] animated:YES];
                //http登陆
                __block AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
                delegate.isThird=YES;
                
                NSDictionary *paramDic = @{@"entId":EntId,
                                           @"agentId":user.userNum};
                [MHNetworkManager postReqeustWithURL:kButelLogOut params:paramDic successBlock:^(id returnData) {
             
                    delegate.isThird = NO;
                    NSDictionary *dic = returnData;
                    if ([[dic objectForKey:@"code"] isEqualToString:@"000"]) {
                        [MBProgressHUD showHUDAddedTo:(UIView*)[[[UIApplication sharedApplication]delegate]window] animated:YES];
                        [self.connect Logout];
                        _isLogOut = YES;
                    }
                } failureBlock:^(NSError *error) {
                    delegate.isThird = NO;
                } showHUD:NO];
               
                

            }
                break;
            default:
                break;
        }
       

        
    }else {
        
        [MBProgressHUD showMessag:@"青牛未登陆" toView:nil];
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
            ButelStatus status = [self.connect GetButelConnStatus];
            
            switch (status.curConnStatus) {
                case BS_UNConnect:
                    [MBProgressHUD showMessag:@"青牛未登陆" toView:nil];

                    isCall = !isCall;
                    break;
                case BS_Connecting:
                    [MBProgressHUD showMessag:@"青牛正在登陆，请稍候" toView:nil];
                    isCall = !isCall;
                    break;
                case BS_Connect2ButelNet:
                {
                    
                    [[FireData sharedInstance] eventWithCategory:@"青牛" action:@"http拨打电话" evar:@{@"phone":phoneNo} attributes:nil];
                    
                    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
                    delegate.isThird=YES;
                    
                    /**
                     *  每次打电话前生成一次uuid
                     */
                    _phoneNo = phoneNo;
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
                                                   
                                                }else {
                                                    if ([[dic objectForKey:@"msg"] isEqual:[NSNull null]]) {
                                                        [MBProgressHUD showError:@"服务器异常" toView:nil];
                                                        
                                                    }else{
                                                        
                                                        [MBProgressHUD showError:[dic objectForKey:@"msg"] toView:nil];
                                                    }
                                                    
                                                }
                                                delegate.isThird = NO;
                                            } failureBlock:^(NSError *error) {
                                                delegate.isThird = NO;
                                            } showHUD:NO];
                    isCall = !isCall;
                    
                }
                    break;
                default:
                    break;
            }

           
        }else {
            [MBProgressHUD showMessag:@"青牛未登陆" toView:nil];
          
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
        _isInit = YES;
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
    NSLog(@"-----%@",Sid);
    /**
     *  挂断电话后向后台传录音流水号
     */
    [self sendTape:_requestId sidWithPhone:_phoneNo];
    
}
-(void)OnCdrNotify:(NSString *)cdrInfo {
    
}

- (void)OnUninit:(int)reason {
    if (_isUnInit) {
            _isInit = NO;
            [MBProgressHUD hideAllHUDsForView:(UIView*)[[[UIApplication sharedApplication]delegate]window] animated:YES];
            //释放青牛sdk
            [ButelEventConnectSDK destroyButelCommonConn:self.connect];
            self.callView = nil;
            [[SingleHandle shareSingleHandle] logOut];
            _isUnInit = NO;
      

    }
//    if (_isTOut) {
//        //释放青牛sdk
//        [ButelEventConnectSDK destroyButelCommonConn:self.connect];
//        self.callView = nil;
//        _isTOut = NO;
//
//    }
    
 
    
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
    
   
            if (_isLogOut) {
                ButelStatus status = [self.connect GetButelConnStatus];
                AYCLog(@"%i",status.curConnStatus);
                [self.connect Uninit];
                _isUnInit = YES;
                _isLogOut = NO;
            }
            
    

}


// 登陆
- (void)loginWithLogin:(NSString *)UUID number:(NSString *)number deviceId:(NSString *)deviceID nickname:(NSString *)nickName userUniqueIdentifer:(NSString *)userID {
    [self.connect Login:UUID number:number deviceId:deviceID nickname:nickName userUniqueIdentifer:userID];
}


/**
 *  往后台服务器传录音流水号
 */
- (void)sendTape:(NSString *)sid sidWithPhone:(NSString *)phone{
    NSDictionary *params = @{@"userId":[[SingleHandle shareSingleHandle] getUserInfo].userId,
                             @"requestId":sid,
                             @"phoneNo":phone,
                             @"baseId":_baseId};
    [MHNetworkManager postReqeustWithURL:[NSString stringWithFormat:@"%@%@",BaseAPI,kSaveTape] params:params successBlock:^(id returnData) {
        
        if ([[returnData valueForKey:@"flag"] isEqualToString:@"success"]) {
          
        }else{
            [MBProgressHUD showMessag:[returnData valueForKey:@"msg"] toView:nil];
        }
        
    } failureBlock:^(NSError *error) {
        
    } showHUD:NO];
}
/**
 *  被别人踢掉退出青牛
 */
- (void)logOutButel {
    if (_isInit) {
//        [MBProgressHUD showHUDAddedTo:(UIView*)[[[UIApplication sharedApplication]delegate]window] animated:YES];
        [self.connect Uninit];
        _isUnInit = YES;
    }else {
        [[SingleHandle shareSingleHandle] logOut];
    }
    
//    _isLogOut = YES;
}
@end
