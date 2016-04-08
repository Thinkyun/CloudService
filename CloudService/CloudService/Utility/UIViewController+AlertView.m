//
//  UIViewController+AlertView.m
//  JinYeFeiLin
//
//  Created by zhangqiang on 15/11/17.
//  Copyright © 2015年 zhangqiang. All rights reserved.
//

#import "UIViewController+AlertView.h"

@implementation UIViewController (AlertView)

-(void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... {

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];

    if (cancelButtonTitle.length > 0) {
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:cancleAction];
    }
    
    if (otherButtonTitles.length > 0) {
        UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherButtonTitles style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:otherAction];
    }
    [self presentViewController:alert animated:YES completion:nil];
#else
        UIAlertView *aletView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, nil];
        [aletView show];
    
    
#endif

    
    
}

@end

@implementation UIViewController (ActionSheet)

-(void)showAlertViewWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(UIAlertControllerStyle)preferredStyle cancelButtonTitle:(nullable NSString *)cancelButtonTitle otherButtonTitles:(nullable NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:preferredStyle];
    
    if (cancelButtonTitle.length > 0) {
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:cancleAction];
    }
    
    if (otherButtonTitles.length > 0) {
        UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherButtonTitles style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:otherAction];
    }
    [self presentViewController:alert animated:YES completion:nil];
    
#else
    UIActionSheet *actionSheet=[[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:nil otherButtonTitles:otherButtonTitles, nil];
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    
    
#endif
}

@end
