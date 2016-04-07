//
//  AppointmentViewController.h
//  CloudService
//
//  Created by 安永超 on 16/2/26.
//  Copyright © 2016年 zhangqiang. All rights reserved.
//

#import "BaseViewController.h"

typedef void (^refreshBlock)(NSString *endCode,NSString *time,NSString *comment);
@interface AppointmentViewController : BaseViewController

@property (nonatomic, strong)NSString *customerId;
@property (nonatomic, strong) NSString *baseId;
@property (nonatomic, strong) NSString *phoneNo;

@property (nonatomic , copy) refreshBlock refreshBlock;

- (void)refreshTableview:(refreshBlock)block;
@end
