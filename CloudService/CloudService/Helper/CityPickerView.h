//
//  CityPickerView.h
//  省市
//
//  Created by 安永超 on 16/4/19.
//  Copyright © 2016年 zph. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^hidePickerViewBlock)(NSString *province,NSString *city);

@interface CityPickerView : UIView

@property (nonatomic,copy)NSString *city;
@property (nonatomic,copy)NSString *province;


- (instancetype)initWithCount:(NSInteger )count;

/**
 *  显示
 */
- (void)showPickViewAnimated:(hidePickerViewBlock )block;
@end

@interface Province : NSObject
@property (nonatomic,strong)NSArray *cities;
@property (nonatomic,copy)NSString *state;

//重写init方法
-(instancetype)initWithDic:(NSDictionary *)dic;
+(instancetype)citiesWithDic:(NSDictionary *)dic;
@end
