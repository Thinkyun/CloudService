//
//  OrderManagerCell.m
//  CloudService
//
//  Created by 安永超 on 16/2/23.
//  Copyright © 2016年 zhangqiang. All rights reserved.
//

#import "OrderManagerCell.h"
#import "Order.h"

@implementation OrderManagerCell

- (void)awakeFromNib {
    // Initialization code
    
//    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
//    [self.contentView addGestureRecognizer:longPress];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setOrder:(Order *)order{
    if (_order != order) {
        _order = order;
        self.lbLicenseNo.text = [NSString stringWithFormat:@"车牌号：%@",order.licenseNo];
        [self.btnOrderStatus setTitle:order.orderStatus forState:UIControlStateNormal];
        self.lbCustomerName.text = [NSString stringWithFormat:@"客户姓名：%@",order.customerName];
        self.lbBiPremium.text = order.biPremium;
        self.lbCiPremium.text = order.ciPremium;
        self.lbVehicleTaxPremium.text = order.vehicleTaxPremium;
        
    }
}

- (void)longPressAction:(UILongPressGestureRecognizer *)longPress{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        NSString *string = [NSString stringWithFormat:@"您确定删除%@的订单",_order.customerName];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"删除订单" message:string delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
    }

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"%@",alertView);
    if (buttonIndex == 1) {
        NSString *url = [NSString stringWithFormat:@"%@%@",BaseAPI,kdelegateOrderBybaseId];
    
        [MHNetworkManager postReqeustWithURL:url params:@{@"baseId":_order.baseId} successBlock:^(id returnData) {
            if ([returnData[@"flag"] isEqualToString:@"success"]) {
                
                _deletedOrderHander();
    
            }
        } failureBlock:^(NSError *error) {
            [MBProgressHUD showMessag:@"网络连接断开,删除失败!" toView:nil];
        } showHUD:NO];
    }
}



@end
