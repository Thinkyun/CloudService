//
//  CountyViewController.h
//  CloudService
//
//  Created by 安永超 on 16/5/12.
//  Copyright © 2016年 zhangqiang. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^chooseCityHander)(UIViewController *VC,NSString *countyStr,NSString *cityStr, NSString *province,NSString *code);

@interface CountyViewController : BaseViewController

@property (nonatomic,copy)chooseCityHander cityblock;

@property (nonatomic,copy)NSString *provinceName;

@property (nonatomic,copy)NSString *cityName;

@property (nonatomic,strong)id countyList;
@end
