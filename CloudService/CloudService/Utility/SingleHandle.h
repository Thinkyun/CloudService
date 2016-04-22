//
//  SingleHandle.h
//  CloudService
//
//  Created by zhangqiang on 16/3/1.
//  Copyright © 2016年 zhangqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface SingleHandle : NSObject
@property (nonatomic,strong)User *user;
+(SingleHandle *)shareSingleHandle;

/**
 *  获取用户信息model
 */
- (User *)getUserInfo;

/**
 *  存储用户信息
 */
- (void)saveUserInfo:(User *)userModel;
/**
 *  获取结束码
 */
- (NSArray *)getEndCodeArray;
/**
 *  获取登陆信息
 *
 *  @param userName 用户名
 *  @param password 用户密码
 *  @param location 定位信息
 */
- (void)loginAppDic:(NSMutableDictionary *)paramDic;
/**
 *  退出登录
 */
- (void)logOut;

/**
 *  获取省份列表
 */
- (void)getAreas;

@end
