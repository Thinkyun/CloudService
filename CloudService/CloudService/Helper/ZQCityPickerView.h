//
//  ZQCityPickerView.h
//  CloudService
//
//  Created by zhangqiang on 16/3/8.
//  Copyright © 2016年 zhangqiang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^hidePickerViewBlock)(NSString *province,NSString *city,NSString *cityCode,NSString *provinceCode,BOOL limit);

@interface ZQCityPickerView : UIView

@property (nonatomic,copy)NSString *city;
@property (nonatomic,copy)NSString *province;
@property (nonatomic,copy)NSString *cityCode;
@property (nonatomic,assign) BOOL limit;

- (instancetype)initWithCount:(NSInteger )count;

/**
 *  显示
 */
- (void)showPickViewAnimated:(hidePickerViewBlock )block;

@end
