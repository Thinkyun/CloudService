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
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setOrder:(Order *)order{
    if (_order != order) {
        self.lbLicenseNo.text = [NSString stringWithFormat:@"车牌号：%@",order.licenseNo];
        [self.btnOrderStatus setTitle:order.orderStatus forState:UIControlStateNormal];
        self.lbCustomerName.text = [NSString stringWithFormat:@"客户姓名：%@",order.customerName];
        self.lbBiPremium.text = order.biPremium;
        self.lbCiPremium.text = order.ciPremium;
        self.lbVehicleTaxPremium.text = order.vehicleTaxPremium;
        
    }
}

@end
