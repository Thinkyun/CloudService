//
//  ShareManager.h
//  CloudService
//
//  Created by 安永超 on 16/4/20.
//  Copyright © 2016年 zhangqiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShareManager : NSObject

+ (instancetype)manager;
/**
 *  sharkSDK分享
 *
 *  @param text   分享文本
 *  @param images 分享图片
 *  @param url    分享url
 *  @param title  分享标题
 */
- (void)shareParamsByText:(NSString *)text
                   images:(id)images
                      url:(NSURL *)url
                    title:(NSString *)title
              WeChatTitle:(NSString *)WeChatTitle;
@end
