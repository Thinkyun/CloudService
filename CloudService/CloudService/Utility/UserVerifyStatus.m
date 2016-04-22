//
//  UserVerifyStatus.m
//  CloudService
//
//  Created by 安永超 on 16/4/22.
//  Copyright © 2016年 zhangqiang. All rights reserved.
//

#import "UserVerifyStatus.h"
#import "EYPopupView.h"

static UserVerifyStatus *userVerifyStatus = nil;
@implementation UserVerifyStatus

+(UserVerifyStatus *)shareUserVerifyStatus {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        userVerifyStatus = [[UserVerifyStatus alloc] init];
    });
    return userVerifyStatus;

}

- (void)userVerifyStatus:(NSString *)userId success:(VerifyBlock)verifyBlock{
    NSDictionary *paramDic = @{@"userId":userId};
    [MHNetworkManager postReqeustWithURL:[RequestEntity urlString:kUserVerifyStatus] params:paramDic successBlock:^(id returnData) {
        NSString *flagStr = [returnData valueForKey:@"flag"];
        if ([flagStr isEqualToString:@"needVerify"]) {
            verifyBlock(NeedVerify);
        }if ([flagStr isEqualToString:@"verify"]) {
            verifyBlock(verify);
            [MBProgressHUD showMessag:[returnData valueForKey:@"msg"] toView:nil];

        }if ([flagStr isEqualToString:@"success"]) {
            verifyBlock(VerifySuccess);
        }
        if ([flagStr isEqualToString:@"error"]) {
            verifyBlock(verifyError);
            [MBProgressHUD showMessag:[returnData valueForKey:@"msg"] toView:nil];
        }
        
    } failureBlock:^(NSError *error) {
        verifyBlock(verifyError);
    } showHUD:NO];

}
@end
