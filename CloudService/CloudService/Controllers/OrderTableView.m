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
    __weak typeof(self) weakSelf = self;
    cell.deletedOrderHander = ^{
                    NSMutableArray *tem =  weakSelf.dataList.mutableCopy;
                    [tem removeObjectAtIndex:indexPath.row];
                    weakSelf.dataList = tem.copy;
        [weakSelf reloadData];
    };
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


//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
//    return YES;
//}
//
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        
//        NSString *url = [NSString stringWithFormat:@"%@%@",BaseAPI,kdelegateOrderBybaseId];
//        Order *_order = _dataList[indexPath.row];
//        
//        [MHNetworkManager postReqeustWithURL:url params:@{@"baseId":_order.baseId} successBlock:^(id returnData) {
//            if ([returnData[@"flag"] isEqualToString:@"success"]) {
//                
////                _deletedOrderHander();
//                NSMutableArray *tem =  self.dataList.mutableCopy;
//                [tem removeObjectAtIndex:indexPath.row];
//                self.dataList = tem.copy;
//                [self reloadData];
//                
//            }
//        } failureBlock:^(NSError *error) {
//            [MBProgressHUD showMessag:@"网络连接断开,删除失败!" toView:nil];
//        } showHUD:NO];
//
//
//    }
//}


- (void)setEditing:(BOOL)editing{
    [super setEditing:editing];
    
}

- (UIViewController *)getViewController{
    UIResponder *responder = [self nextResponder];
    while (![responder isKindOfClass:[UIViewController class]]) {
        responder = [responder nextResponder];
    }
    return (UIViewController *)responder;
    
}





@end
