//
//  OrderTableView.m
//  0420-EDianYunFu
//
//  Created by mac on 16/4/21.
//  Copyright © 2016年 DJ. All rights reserved.
//

#import "OrderTableView.h"
#import "OrderInfoViewController.h"
#import "OrderManagerCell.h"
#import "OrderInfoTableViewCell.h"
#import "Order.h"
#import "HelperUtil.h"

@implementation OrderTableView{
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    if (self = [super initWithFrame:frame style:style]) {
        [self setup];
    }
    return self;
}

- (void)setup{
    self.showsHorizontalScrollIndicator = NO;
    self.delegate = self;
    self.dataSource = self;
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.backgroundColor = [HelperUtil colorWithHexString:@"F4F4F4"];
    [self registerNib:[UINib nibWithNibName:@"OrderManagerCell" bundle:nil] forCellReuseIdentifier:@"OrderManagerCell"];
   
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    Order *order = _dataList[indexPath.row];
        static NSString *ID = @"OrderManagerCell";
        OrderManagerCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
        cell.order = order;
        return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 155;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIViewController *VC = [[self getViewController] parentViewController];
    [VC performSegueWithIdentifier:@"orderInfo" sender:_dataList[indexPath.row]];
}


- (UIViewController *)getViewController{
    UIResponder *responder = [self nextResponder];
    while (![responder isKindOfClass:[UIViewController class]]) {
        responder = [responder nextResponder];
    }
    return (UIViewController *)responder;
    
}



@end
