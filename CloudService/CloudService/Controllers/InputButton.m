//
//  InputButton.m
//  CloudService
//
//  Created by 安永超 on 16/5/11.
//  Copyright © 2016年 zhangqiang. All rights reserved.
//

#import "InputButton.h"
#import "UIView+YYAdd.h"

@interface InputButton ()<UITextFieldDelegate>

@end

@implementation InputButton{
    UILabel *_titleLabel;
    UILabel *_textLabel;
    UITextField *_textField;
    BOOL _isEdit;
}


- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title  text:(NSString *)text image:(NSString *)imageName isKeyBoardEdit:(BOOL)isEdit{
    self = [super initWithFrame:frame];
    if (!self) {
        return self;
    }
    
    UILabel *titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 44)];
    titlelabel.font = [UIFont systemFontOfSize:16];
    titlelabel.text = title;
    _titleLabel = titlelabel;
    [self addSubview:titlelabel];
    
    CGFloat textLabelW = (imageName&&(imageName.length>0)) ? frame.size.width-110-15-35:frame.size.width-110-15;
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(titlelabel.right, 0, textLabelW, 44)];
    textLabel.font = [UIFont systemFontOfSize:14];
    textLabel.textAlignment = NSTextAlignmentRight;
    textLabel.text = text;
    _textLabel = textLabel;
    [self addSubview:textLabel];
    
    if (imageName&&(imageName.length>0)) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(textLabel.right+15, 5, 25, 25)];
        imageView.image = [UIImage imageNamed:imageName];
        [self addSubview:imageView];
    }
    if (isEdit) {
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(textLabel.right, 0, 1, 44)];
        [textField addTarget:self action:@selector(textFieldTextChange:) forControlEvents:UIControlEventEditingChanged];
//        textField.hidden = YES;
        _textField = textField;
//        _textField.keyboardType = UIKeyboardTypeASCIICapable;
//        _textField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
        [self addSubview:textField];
    }
    _isEdit = isEdit;
    self.layer.cornerRadius = 3;
    self.layer.masksToBounds = YES;

    return self;
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    if (_isEdit) {
        [_textField becomeFirstResponder];
        _textLabel.text = @"";
    }
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesCancelled:touches withEvent:event];
}


- (void)textFieldTextChange:(UITextField *)textField{
    _textLabel.text = textField.text;
}

@end
