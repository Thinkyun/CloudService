//
//  OrderViewController.m
//  0420-EDianYunFu
//
//  Created by mac on 16/4/20.
//  Copyright © 2016年 DJ. All rights reserved.
//

#import "OrderViewController.h"
#import "UnfinishedViewController.h"
#import "UnPaidViewController.h"
#import "PaidViewController.h"
#import "OrderInfoViewController.h"
#import "Order.h"

@interface OrderViewController ()

@end

@implementation OrderViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    __weak typeof(self) weakSelf = self;
    [self.tabBarController setRightImageBarButtonItemWithFrame:CGRectMake(0, 0, 30, 30) image:@"title-search" selectImage:@"title-search_" action:^(AYCButton *button) {
        [[FireData sharedInstance] eventWithCategory:@"订单管理" action:@"搜索订单" evar:nil attributes:nil];
        [weakSelf performSegueWithIdentifier:@"searchOrder" sender:weakSelf];
    }];

    self.tabBarController.title = @"订单管理";

}

- (void)viewDidLoad {
    self.viewControllers = @[[UnfinishedViewController new],[UnPaidViewController new],[PaidViewController new]];
    self.titles = @[@"未完成",@"待支付",@"已支付"];
    self.isObligate = YES;
    [super viewDidLoad];
    self.isScrollEnable = YES;
    
//    self.tabBarController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchItemAction)];
   

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // segue.identifier：获取连线的ID
    
    if ([segue.identifier isEqualToString:@"orderInfo"]) {
        [[FireData sharedInstance] eventWithCategory:@"订单管理" action:@"订单详情" evar:nil attributes:nil];
        // segue.destinationViewController：获取连线时所指的界面（VC）
        OrderInfoViewController *receive = segue.destinationViewController;
        //        _dataList[]
        receive.order = sender;
        Order *order = sender;
        AYCLog(@"%@",receive.order);
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
