//
//  CouponsDistributeViewController.h
//  CloudService
//
//  Created by 安永超 on 16/3/8.
//  Copyright © 2016年 zhangqiang. All rights reserved.
//

#import "BaseViewController.h"

typedef void (^refreshBlock)();

@class Coupons;
@interface CouponsDistributeViewController : BaseViewController

@property (nonatomic, strong)Coupons *coupons;

@property (nonatomic , copy) refreshBlock refreshBlock;

- (void)refresh:(refreshBlock)block;


@end
