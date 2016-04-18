//
//  Order.h
//  CloudService
//
//  Created by 安永超 on 16/3/14.
//  Copyright © 2016年 zhangqiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Order : NSObject

@property (nonatomic, copy) NSString *orderId;//订单Id
@property (nonatomic, copy) NSString *orderStatus;//订单状态
@property (nonatomic, copy) NSString *licenseNo;
@property (nonatomic, copy) NSString *customerName;
@property (nonatomic, copy) NSString *biPremium;
@property (nonatomic, copy) NSString *ciPremium;
@property (nonatomic, copy) NSString *vehicleTaxPremium;
@property (nonatomic, copy) NSString *customerId;
@property (nonatomic, copy) NSString *endCode;
@property (nonatomic, copy) NSString *phoneNo;
@property (nonatomic, copy) NSString *cappld;
@property (nonatomic, copy) NSString *comment;
@property (nonatomic, copy) NSString *engineNo;
@property (nonatomic, copy) NSString *frameNo;
@property (nonatomic, copy) NSString *cityCode;
@property (nonatomic, copy) NSString *vehicleModelName;
@property (nonatomic, copy) NSString *primaryDate;
@property (nonatomic, copy) NSString *baseId;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *reserveTime;//预约时间
@property (nonatomic, copy) NSString *gift;//投保礼
@property (nonatomic, copy) NSString *payUrl;//支付地址
@property (nonatomic, copy) NSString *insureComName;//销售保险公司
@property (nonatomic, copy) NSString *agentName;//数据来源
@end

