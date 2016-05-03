//
//  SingleHandle.m
//  CloudService
//
//  Created by zhangqiang on 16/3/1.
//  Copyright © 2016年 zhangqiang. All rights reserved.
//

#import "SingleHandle.h"
#import "Utility.h"
#import "ButelHandle.h"
#import <JPUSHService.h>
#import "MyFile.h"

static SingleHandle *singleHandle = nil;
@implementation SingleHandle

+(SingleHandle *)shareSingleHandle {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleHandle = [[SingleHandle alloc] init];
    });
    return singleHandle;
}

- (User *)getUserInfo {
    if (!self.user) {
        self.user = [[User alloc] init];
        self.user = [User mj_objectWithKeyValues:[Utility getUserInfoFromLocal]];
    }
    return self.user;
}

-(void)saveUserInfo:(User *)userModel {
    
    self.user = userModel;
    NSDictionary *dict = [userModel mj_keyValues];
    [Utility saveUserInfo:dict];
    
}

- (NSArray *)getEndCodeArray {
    NSArray *array = @[@"初始",
                       @"已报价",
                       @"未报价",
                       @"未联系到",
                       @"空错号",
                       @"到期日不准",
                       @"客户毁单",
                       @"客户拒绝",
                       @"费用少",
                       @"无效数据",
                       @"成交"];

    return array;
}

- (void)loginAppDic:(NSMutableDictionary *)paramDic{

    /**
     *  每次登录前取JPush的RegistrationID，如果RegistrationID存在，取出
     *  如果RegistrationID不存在，则手动生成一个UUID
     */
    NSString *registrationID = [Utility RegistrationID];
    if (!registrationID) {
        registrationID = [HelperUtil uuidString];
       
    }
    [paramDic setObject:registrationID forKey:@"imei"];
    
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    delegate.isThird=NO;
    
    __weak typeof(self) weakSelf = self;
    [MHNetworkManager postReqeustWithURL:[RequestEntity urlString:kLoginAPI] params:paramDic successBlock:^(id returnData) {
        if ([[returnData valueForKey:@"flag"] isEqualToString:@"success"]) {
            User *user = [User mj_objectWithKeyValues:[returnData valueForKey:@"data"]];
            [[SingleHandle shareSingleHandle] saveUserInfo:user];
            AYCLog(@"%@",user.userNum);
            /**
             *  火炬登陆信息
             */
            [[FireData sharedInstance] loginWithUserid:user.userNum uvar:@{@"roleName":user.roleName}];
            /**
             *  注册极光推送标签
             */
            [JPUSHService setTags:[NSSet setWithObject:user.roleName] alias:user.userNum callbackSelector:nil target:nil];
//            [JPUSHService setTags:[NSSet setWithObject:user.roleName] callbackSelector:nil object:nil];
            
            [[ButelHandle shareButelHandle] ButelHttpLogin];
            [[NSNotificationCenter defaultCenter] postNotificationName:LoginToMenuViewNotice object:nil];
            
         
        }else if([[returnData valueForKey:@"flag"] isEqualToString:@"error"]){
            NSString *msgStr = [returnData valueForKey:@"msg"];
                [MBProgressHUD showMessag:msgStr toView:nil];
                //2秒后再调用self的run方法
                [weakSelf performSelector:@selector(logOut) withObject:nil afterDelay:2.0];
       
            
            
        }
    } failureBlock:^(NSError *error) {
        [self logOut];
    } showHUD:YES];

}


- (void) logOut {
    /**
     *  退出登录时清除账号信息
     */
    //    [JPUSHService setTags:[NSSet set] alias:@"" callbackSelector:nil target:nil];
    //        User *user = [[SingleHandle shareSingleHandle] getUserInfo];
    //
    //        [Utility saveUserName:user.phoneNo passWord:nil];
    [Utility remberPassWord:NO];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *loginVC = [storyBoard instantiateViewControllerWithIdentifier:@"loginNavi"];
    UIViewController *oldVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    oldVC = nil;
    
    [UIApplication sharedApplication].keyWindow.rootViewController = loginVC;
}
- (void)getAreas {
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    delegate.isThird=NO;
   
    [MHNetworkManager postReqeustWithURL:[RequestEntity urlString:kGetAreas] params:nil successBlock:^(id returnData) {
        if ([[returnData valueForKey:@"flag"] isEqualToString:@"success"]) {
            NSArray *dataArray = [returnData valueForKey:@"data"];
             NSMutableArray *provinceArray = [NSMutableArray array];
            for (NSDictionary *province in dataArray) {
                NSMutableDictionary *provinceDict = [NSMutableDictionary dictionary];
                
                NSString *provinceId = [province valueForKey:@"branchId"];
                NSString *provinceName = [province valueForKey:@"branchName"];
                [provinceDict setObject:provinceId forKey:@"provinceId"];
                [provinceDict setObject:provinceName forKey:@"provinceName"];
                [provinceArray addObject:provinceDict];
            }

            AYCLog(@"%@",provinceArray);
            NSString *provincePath = [MyFile fileDocumentPath:PROVINCE_LIST];
            //保存路径
            
            BOOL result = [NSKeyedArchiver archiveRootObject:provinceArray toFile:provincePath];
            if (result) {
                
                AYCLog(@"success");
                
            }else {
                
                AYCLog(@"no success");
                
            }
        }else if([[returnData valueForKey:@"flag"] isEqualToString:@"error"]){
            [MBProgressHUD showMessag:[returnData valueForKey:@"msg"] toView:nil];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];

}

@end
