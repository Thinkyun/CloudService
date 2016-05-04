//
//  MHAsiNetworkItem.m
//  MHProject
//
//  Created by MengHuan on 15/4/23.
//  Copyright (c) 2015年 MengHuan. All rights reserved.
//

#import "MHAsiNetworkItem.h"
#import "AFNetworking.h"
#import "MBProgressHUD+Add.h"
#import "MHAsiNetworkDefine.h"
#import "MHNetwrok.h"
#import "AppDelegate.h"
#import "SingleHandle.h"
@interface MHAsiNetworkItem ()

@end

@implementation MHAsiNetworkItem


#pragma mark - 创建一个网络请求项，开始请求网络
/**
 *  创建一个网络请求项，开始请求网络
 *
 *  @param networkType  网络请求方式
 *  @param url          网络请求URL
 *  @param params       网络请求参数
 *  @param delegate     网络请求的委托，如果没有取消网络请求的需求，可传nil
 *  @param hashValue    网络请求的委托delegate的唯一标示
 *  @param showHUD      是否显示HUD
 *  @param successBlock 请求成功后的block
 *  @param failureBlock 请求失败后的block
 *
 *  @return MHAsiNetworkItem对象
 */
- (MHAsiNetworkItem *)initWithtype:(MHAsiNetWorkType)networkType
                               url:(NSString *)url
                            params:(NSDictionary *)params
                          delegate:(id)delegate
                            target:(id)target
                            action:(SEL)action
                         hashValue:(NSUInteger)hashValue
                           showHUD:(BOOL)showHUD
                      successBlock:(MHAsiSuccessBlock)successBlock
                      failureBlock:(MHAsiFailureBlock)failureBlock
{
    if (self = [super init])
    {
        self.networkType    = networkType;
        self.url            = url;
        self.params         = params;
        self.delegate       = delegate;
        self.showHUD        = showHUD;
        self.tagrget        = target;
        self.select         = action;
        if (showHUD==YES) {
            [MBProgressHUD showHUDAddedTo:(UIView*)[[[UIApplication sharedApplication]delegate]window] animated:YES];
            
        }
        __weak typeof(self)weakSelf = self;
        DTLog(@"--请求url地址--%@\n",url);
        DTLog(@"----请求参数%@\n",params);
        
        NSArray *temArray = [url componentsSeparatedByString:@"/"];
        NSString *category = [temArray lastObject];
        DTLog(@"category--%@",category);
        [[FireData sharedInstance] eventWithCategory:category action:@"网络请求" evar:params attributes:@{@"url":url}];
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
        manager.responseSerializer.acceptableContentTypes =  [NSSet setWithObject:@"text/html"];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/xml", nil];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
      
        AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
        if (delegate.isThird) {
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
        }
        //设置请求超时时长
        [manager.requestSerializer setTimeoutInterval:10];
        if (networkType==MHAsiNetWorkGET)
        {
            [manager GET:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [MBProgressHUD hideAllHUDsForView:(UIView*)[[[UIApplication sharedApplication]delegate]window] animated:YES];
                DTLog(@"\n\n----请求的返回结果 %@\n",responseObject);
                if (successBlock) {
                   
                    successBlock(responseObject);
                }
                if ([weakSelf.delegate respondsToSelector:@selector(requestDidFinishLoading:)]) {
                    [weakSelf.delegate requestDidFinishLoading:responseObject];
                }
                [weakSelf performSelector:@selector(finishedRequest: didFaild:) withObject:responseObject withObject:nil];
                [weakSelf removewItem];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [MBProgressHUD hideAllHUDsForView:(UIView*)[[[UIApplication sharedApplication]delegate]window] animated:YES];
                DTLog(@"---error==%@\n",error.localizedDescription);
                if (failureBlock) {
                    failureBlock(error);
                }
                if ([weakSelf.delegate respondsToSelector:@selector(requestdidFailWithError:)]) {
                    [weakSelf.delegate requestdidFailWithError:error];
                }
                [weakSelf performSelector:@selector(finishedRequest: didFaild:) withObject:nil withObject:error];
                [weakSelf removewItem];

            }];

            
        }else{
            [manager POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [MBProgressHUD hideHUDForView:(UIView*)[[[UIApplication sharedApplication]delegate]window] animated:YES];
                DTLog(@"\n\n----请求的返回结果 %@\n",responseObject);
                if ([[responseObject objectForKey:@"flag"] isEqualToString:@"userConflict"]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:LogOutViewNotice object:nil];
//                    [[SingleHandle shareSingleHandle] logOut];
                    
                    //火炬
                    NSArray *temArray = [url componentsSeparatedByString:@"/"];
                    NSString *category = [temArray lastObject];
                    DTLog(@"category--%@",category);
                    [[FireData sharedInstance] eventWithCategory:category action:@"网络请求成功,用户被挤下线" evar:params attributes:@{@"url":url}];
                    
                    [MBProgressHUD showMessag:[responseObject objectForKey:@"msg"] toView:nil];
                   
                }else{
                    if (successBlock) {
                        
                        //火炬
                        NSArray *temArray = [url componentsSeparatedByString:@"/"];
                        NSString *category = [temArray lastObject];
                        DTLog(@"category--%@",category);
                        [[FireData sharedInstance] eventWithCategory:category action:@"网络请求成功" evar:params attributes:@{@"url":url}];
                        
                        successBlock(responseObject);
                    }
                    if ([weakSelf.delegate respondsToSelector:@selector(requestDidFinishLoading:)]) {
                        [weakSelf.delegate requestDidFinishLoading:responseObject];
                    }
                    [weakSelf performSelector:@selector(finishedRequest: didFaild:) withObject:responseObject withObject:nil];
                }
                
                [weakSelf removewItem];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [MBProgressHUD hideAllHUDsForView:(UIView*)[[[UIApplication sharedApplication]delegate]window] animated:YES];
                DTLog(@"---error==%@\n",error.localizedDescription);
                [MBProgressHUD showMessag:[NSString stringWithFormat:@"%@",error.localizedDescription] toView:nil];
                
                //火炬
                NSArray *temArray = [url componentsSeparatedByString:@"/"];
                NSString *category = [temArray lastObject];
                DTLog(@"category--%@",category);
                [[FireData sharedInstance] eventWithCategory:category action:@"网络请求失败" evar:params attributes:@{@"url":url,@"error":error.localizedDescription}];
                if (failureBlock) {
                    failureBlock(error);
                }
                if ([weakSelf.delegate respondsToSelector:@selector(requestdidFailWithError:)]) {
                    [weakSelf.delegate requestdidFailWithError:error];
                }
                [weakSelf performSelector:@selector(finishedRequest: didFaild:) withObject:nil withObject:error];
                [weakSelf removewItem];

            }];
            

        }
    }
    return self;
}
/**
 *   移除网络请求项
 */
- (void)removewItem
{
    __weak typeof(self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([weakSelf.delegate respondsToSelector:@selector(netWorkWillDealloc:)]) {
            [weakSelf.delegate netWorkWillDealloc:weakSelf];
        }
    });
}

- (void)finishedRequest:(id)data didFaild:(NSError*)error
{
    if ([self.tagrget respondsToSelector:self.select]) {
        [self.tagrget performSelector:@selector(finishedRequest:didFaild:) withObject:data withObject:error];
    }
}

- (void)dealloc
{
    
    
}

@end
