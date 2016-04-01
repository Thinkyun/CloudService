//
//  FiredataApp.h
//  WebDemo
//
//  Created by 韦兴华 on 16/3/23.
//  Copyright © 2016年 weixinghua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <JavaScriptCore/JSExport.h>

@protocol FiredataJSProtocol <JSExport>
JSExportAs
(event  /** eventWithCategory:action:evar 作为js方法的别名, evar 为 JSON 格式的字符串 */,
 - (void)eventWithCategory:(NSString *)category action:(NSString *)action evar:(NSString *)evar
 );
- (NSString *)getGuid;
- (NSString *)getuserId;

@end

@interface FiredataApp : NSObject <FiredataJSProtocol>

@property (strong, nonatomic) JSContext *context;

/*
 ** 绑定 webview
 ** @param webview 为必选参数
 ** @param prefix 为事件分类前缀，可以为空
 ** @param uvar, cvar, evar, cid, cch 可以为空。为空时保持 FireData sdk 已存储的默认值。若传入新值则更新 sdk 中的对应值。
 */

- (void)bindWebView:(UIWebView *)webView
     categoryPrefix:(NSString *)prefix
               uvar:(NSDictionary *)uvar
               cvar:(NSDictionary *)cvar
               evar:(NSDictionary *)evar
          contentId:(NSString *)cid
         contentCat:(NSString *)cch;
@end
