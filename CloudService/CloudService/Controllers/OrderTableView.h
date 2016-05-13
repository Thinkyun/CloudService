//
//  OrderTableView.h
//  0420-EDianYunFu
//
//  Created by mac on 16/4/21.
//  Copyright © 2016年 DJ. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface OrderTableView : UITableView<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong)NSArray *dataList;


- (void)setEditing:(BOOL)editing;

@end
