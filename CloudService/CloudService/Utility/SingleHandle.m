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
     *  获取
     */
    NSString *uuid = [Utility UUID];
    if (!uuid) {
        uuid = [HelperUtil uuidString];
        [Utility saveUUID:uuid];
    }
    [paramDic setObject:uuid forKey:@"imei"];
    
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    delegate.isThird=NO;
  
    [MHNetworkManager postReqeustWithURL:[RequestEntity urlString:kLoginAPI] params:paramDic successBlock:^(id returnData) {
        if ([[returnData valueForKey:@"flag"] isEqualToString:@"success"]) {
            User *user = [User mj_objectWithKeyValues:[returnData valueForKey:@"data"]];
            [[SingleHandle shareSingleHandle] saveUserInfo:user];
            AYCLog(@"%@",user.userNum);
            /**
             *  火炬登陆信息
             */
            [[FireData sharedInstance] loginWithUserid:user.userNum uvar:nil];
            /**
             *  注册极光推送标签别名
             */
            
            [JPUSHService setTags:[NSSet setWithObject:user.roleName] alias:user.userName callbackSelector:nil target:nil];
            
            [[ButelHandle shareButelHandle] ButelHttpLogin];
            [[NSNotificationCenter defaultCenter] postNotificationName:LoginToMenuViewNotice object:nil];
        }else if([[returnData valueForKey:@"flag"] isEqualToString:@"error"]){
            [MBProgressHUD showMessag:[returnData valueForKey:@"msg"] toView:nil];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];

}

@end
