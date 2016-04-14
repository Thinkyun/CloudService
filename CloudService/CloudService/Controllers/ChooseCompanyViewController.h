//
//  ChooseCompanyViewController.h
//  CloudService
//
//  Created by zhangqiang on 16/3/15.
//  Copyright © 2016年 zhangqiang. All rights reserved.
//

#import "BaseViewController.h"
typedef enum{
    chooseCompany,
    chooseCity
}chooseType;

@interface ChooseCompanyViewController : BaseViewController

@property(nonatomic,strong)NSMutableArray *selectArray;
@property(nonatomic,strong)NSMutableArray *dataArray;
@property (nonatomic, assign) chooseType type;

@end
