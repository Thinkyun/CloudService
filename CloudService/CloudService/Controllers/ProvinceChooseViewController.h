//
//  ProvinceChooseViewController.h
//  CloudService
//
//  Created by 安永超 on 16/5/9.
//  Copyright © 2016年 zhangqiang. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^chooseCityHander)(UIViewController *VC,NSString *cityStr,NSString *province,NSString *code);

typedef void (^popProvinceHander)(NSString *string);

@interface ProvinceChooseViewController : BaseViewController

@property (nonatomic,copy)chooseCityHander cityblock;

@property (nonatomic,copy)popProvinceHander popBlock;

@property (nonatomic,strong)NSMutableArray *proviceList;

@property (nonatomic,copy)NSString *locationCity;

@property (nonatomic,assign)BOOL isHidenLocation;

@end
