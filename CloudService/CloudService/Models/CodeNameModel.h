//
//  CodeNameModel.h
//  CloudService
//
//  Created by zhangqiang on 16/3/12.
//  Copyright © 2016年 zhangqiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CodeNameModel : NSObject

@property (nonatomic,copy) NSString *companyCode;//公司编码
@property (nonatomic,copy) NSString *companyName;//公司名
@property (nonatomic,copy) NSString *provinceCode;//省份编码
@property (nonatomic,copy) NSString *provinceName;//省份名
@property (nonatomic,copy) NSString *cityCode;//城市编码
@property (nonatomic,copy) NSString *cityName;//城市名
@property (nonatomic, assign) BOOL isCheck;

@end
