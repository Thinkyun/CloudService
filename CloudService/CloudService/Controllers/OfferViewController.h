//
//  OfferViewController.h
//  CloudService
//
//  Created by 安永超 on 16/2/29.
//  Copyright © 2016年 zhangqiang. All rights reserved.
//

#import "BaseViewController.h"

typedef void (^refreshBlock)();

@class Order;

@interface OfferViewController : BaseViewController

@property (nonatomic,strong)Order *order;

@property (nonatomic , copy) refreshBlock refreshBlock;

- (void) refresh:(refreshBlock)block;

@end
