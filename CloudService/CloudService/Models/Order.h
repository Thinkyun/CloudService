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
@property (nonatomic, copy) NSString *licenseNo;//车牌号
@property (nonatomic, copy) NSString *customerName;//客户姓名
@property (nonatomic, copy) NSString *biPremium;//商业险
@property (nonatomic, copy) NSString *ciPremium;//交强险
@property (nonatomic, copy) NSString *vehicleTaxPremium;//车船税
@property (nonatomic, copy) NSString *customerId;//客户Id
@property (nonatomic, copy) NSString *endCode;//结束码
@property (nonatomic, copy) NSString *phoneNo;//手机号
@property (nonatomic, copy) NSString *cappld;//
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
@property (nonatomic, copy) NSString *policyNo;//商业险保单号
@property (nonatomic, copy) NSString *proposalNo;//商业险投保单号
@property (nonatomic, copy) NSString *ciProposalNo;//交强险投保单号
@property (nonatomic, copy) NSString *ciPolicyNo;//交强险保单号
@end

