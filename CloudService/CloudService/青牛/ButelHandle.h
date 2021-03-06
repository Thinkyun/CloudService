//
//  ButelHandle.h
//  CloudService
//
//  Created by 安永超 on 16/3/4.
//  Copyright © 2016年 zhangqiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CallView;
@interface ButelHandle : NSObject

@property (nonatomic,strong)CallView *callView;


+ (ButelHandle *)shareButelHandle;


/**
 *  青牛http登陆
 */
- (void)ButelHttpLogin;
/**
 *  初始化
 */
- (void)Init;
/**
 *  退出青牛VOIP
 */
- (void)logOut;

/**
 *  拨号
 */
- (void)makeCallWithPhoneNo:(NSString *)phoneNo;

/**
 *  是否开启扬声器
 */
- (void)openSpeaker:(BOOL )isSpeaker;

/**
 *  是否静音
 */
- (void)enableMute:(bool )isMute;

/**
 *  显示拨打视图
 */
- (void)showCallView;
/**
 *  隐藏拨打视图
 */
- (void)hideCallView;

/**
 * 设置拨打手机号
 */
- (void)setPhoneNo:(NSString *)phoneNo phoneWithBaseId:(NSString *)baseId;
/**
 *  弹出拨打视图
 */
- (void)popCallView;


- (void)logOutButel ;
@end
