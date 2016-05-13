//
//  CityChooseViewController.h
//  CloudService
//
//  Created by 安永超 on 16/5/9.
//  Copyright © 2016年 zhangqiang. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^chooseCityHander)(UIViewController *VC,NSString *countyStr,NSString *cityStr, NSString *province,NSString *code);

@interface CityChooseViewController : BaseViewController

@property (nonatomic,copy)chooseCityHander cityblock;

//@property (nonatomic,assign)BOOL is

@property (nonatomic,copy)NSString *provinceName;

@property (nonatomic,strong)id cityList;

@end
