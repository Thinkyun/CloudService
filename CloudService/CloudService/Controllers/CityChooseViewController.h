//
//  CityChooseViewController.h
//  CloudService
//
//  Created by 安永超 on 16/5/9.
//  Copyright © 2016年 zhangqiang. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^chooseCityHander)(UIViewController *VC,NSString *cityStr, NSString *province);

@interface CityChooseViewController : BaseViewController

@property (nonatomic,copy)chooseCityHander cityblock;

@property (nonatomic,copy)NSString *provinceName;

@property (nonatomic,strong)NSArray *cityList;

@end
