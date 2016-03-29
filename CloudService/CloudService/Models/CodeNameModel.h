//
//  CodeNameModel.h
//  CloudService
//
//  Created by zhangqiang on 16/3/12.
//  Copyright © 2016年 zhangqiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CodeNameModel : NSObject

@property (nonatomic,copy) NSString *companyCode;
@property (nonatomic,copy) NSString *companyName;
@property (nonatomic,copy) NSString *provinceCode;
@property (nonatomic,copy) NSString *provinceName;
@property (nonatomic,copy) NSString *cityCode;
@property (nonatomic,copy) NSString *cityName;
@property (nonatomic, assign) BOOL isCheck;

@end
