//
//  OrderH5ViewController.h
//  CloudService
//
//  Created by zhangqiang on 16/3/12.
//  Copyright © 2016年 zhangqiang. All rights reserved.
//

#import "BaseViewController.h"
#import "FiredataApp.h"

@interface OrderH5ViewController : BaseViewController

@property (nonatomic,copy)NSString *url;

@property (nonatomic,copy)NSString *telPhoneNum;

@property (nonatomic, strong) FiredataApp *fireDataApp;
@end
