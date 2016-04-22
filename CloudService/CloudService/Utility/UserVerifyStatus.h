//
//  UserVerifyStatus.h
//  CloudService
//
//  Created by 安永超 on 16/4/22.
//  Copyright © 2016年 zhangqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum{
    VerifySuccess,
    NeedVerify,
    verify,
    verifyError
}VerifyStatus;

@interface UserVerifyStatus : NSObject



+(UserVerifyStatus *)shareUserVerifyStatus;
/**
 *  请求成功回调
 *
 *  @param success 验证成功回调
 */
typedef void (^VerifyBlock)(VerifyStatus verifyStatus);



/**
 *  认证用户信息
 *
 *  @param userId        用户Id
 *  @param verifySuccess 认证成功返回

 */
- (void)userVerifyStatus:(NSString *)userId success:(VerifyBlock)verifyBlock;

@end
