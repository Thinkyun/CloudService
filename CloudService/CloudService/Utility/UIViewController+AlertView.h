//
//  UIViewController+AlertView.h
//  JinYeFeiLin
//
//  Created by zhangqiang on 15/11/17.
//  Copyright © 2015年 zhangqiang. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, AlertControllerStyle) {
    AlertControllerStyleActionSheet = 0,
    AlertControllerStyleAlert
} NS_ENUM_AVAILABLE_IOS(8_0);

@interface UIViewController (AlertView)
-(void)showAlertViewWithTitle:(nullable NSString *)title message:(nullable NSString *)message cancelButtonTitle:(nullable NSString *)cancelButtonTitle otherButtonTitles:(nullable NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

@end

@interface UIViewController (ActionSheet)

-(void)showAlertViewWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(UIAlertControllerStyle)preferredStyle cancelButtonTitle:(nullable NSString *)cancelButtonTitle otherButtonTitles:(nullable NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;
@end