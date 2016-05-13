//
//  InputButton.h
//  CloudService
//
//  Created by 安永超 on 16/5/11.
//  Copyright © 2016年 zhangqiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class InputButton;

@interface InputButton : UIControl

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title  text:(NSString *)text image:(NSString *)imageName isKeyBoardEdit:(BOOL)isEdit;


@end
