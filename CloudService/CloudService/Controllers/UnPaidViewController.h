//
//  UnPaidViewController.h
//  0420-EDianYunFu
//
//  Created by mac on 16/4/20.
//  Copyright © 2016年 DJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MJRefresh.h>


@class OrderTableView;
@interface UnPaidViewController : UIViewController

@property (nonatomic,assign)BOOL isLoadData;

@property (nonatomic,weak)OrderTableView *tableView;

@end
