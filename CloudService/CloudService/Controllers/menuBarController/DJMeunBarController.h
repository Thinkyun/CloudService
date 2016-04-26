//
//  DJMeunBarController.h
//  Project-two
//
//  Created by mac on 16/3/9.
//  Copyright © 2016年 CXWL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SegmentControl.h"

@interface DJMeunBarController : UIViewController

@property (nonatomic,weak)SegmentControl *segmentControl;
//对应的标题
@property (nonatomic, strong) NSArray *titles;

//当前所在控制器的标号
@property (nonatomic,assign)NSInteger selectedIndex;

//管理的controller
@property (nonatomic,strong)NSArray *viewControllers;

//控制器内scrollView的高度(默认是屏高－49-64）
@property (nonatomic,assign)CGFloat contentSizeHeight;

//施肥给segement预留出44的高度
@property (nonatomic,assign)BOOL isObligate;

//是否能滚动
@property (nonatomic,assign)BOOL isScrollEnable;

@end
