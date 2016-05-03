//
//  OfferTableViewCell.m
//  CloudService
//
//  Created by 安永超 on 16/2/29.
//  Copyright © 2016年 zhangqiang. All rights reserved.
//

#import "OfferTableViewCell.h"
#import "HZQDatePickerView.h"
#import "ButelHandle.h"

@interface OfferTableViewCell()<HZQDatePickerViewDelegate>
{
    HZQDatePickerView *_pickerView;
}
@end
@implementation OfferTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.carCode.enabled = NO;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(carFrameCodeChanged:) name:UITextFieldTextDidChangeNotification object:self.carFrameCode];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(carUserCardChanged:) name:UITextFieldTextDidChangeNotification object:self.carUserCard];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(carUserPhoneChanged:) name:UITextFieldTextDidChangeNotification object:self.carUserPhone];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(engineChanged:) name:UITextFieldTextDidChangeNotification object:self.engine];
    self.carFrameCode.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    self.carUserCard.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    self.engine.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
}
- (void)carFrameCodeChanged:(NSNotificationCenter *)sender {
  
    if (self.carFrameCode.text.length >=17) {
        
        self.carFrameCode.text = [self.carFrameCode.text substringToIndex:17];
    }
}
- (void)carUserPhoneChanged:(NSNotificationCenter *)sender {
   
    if (self.carUserPhone.text.length >=11) {
        self.carUserPhone.text = [self.carUserPhone.text substringToIndex:11];
        [[ButelHandle shareButelHandle] setPhoneNo:self.carUserPhone.text phoneWithBaseId:@""];
    }
}
- (void)carUserCardChanged:(NSNotificationCenter *)sender {
    
    if (self.carUserCard.text.length >=18) {
        self.carUserCard.text = [self.carUserCard.text substringToIndex:18];
    }
}

- (IBAction)tapDateButton:(UIButton *)sender {
    [HelperUtil resignKeyBoardInView:self.superview];
    _pickerView = [HZQDatePickerView instanceDatePickerView];
    [_pickerView showDateViewWithDelegate:self];
    
}

#pragma mark -- HZQDatePickerViewDelegate
- (void)getSelectDate:(NSDate *)date type:(DateType)type {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *currentOlderOneDateStr = [dateFormatter stringFromDate:date];
    self.firstTime.text = currentOlderOneDateStr;
    _pickerView = nil;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
