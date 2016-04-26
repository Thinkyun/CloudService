//
//  SegmentControl.h
//  Project-two
//
//  Created by mac on 16/3/5.
//  Copyright © 2016年 CXWL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SegmentControl : UIControl


/**
 *  储存文本的数组（从而知道按钮的个数）
 */
@property (nonatomic, strong) NSArray *titles;

/**
 *  当前按钮选中的索引位置
 */
@property (nonatomic, assign) NSInteger selectedIndex;

/**
 *  当前选中按钮的效果视图
 */
@property (nonatomic, strong, readonly) UIView *selectedView;

/**
 *  设置默认的文本颜色
 */
@property (nonatomic, strong) UIColor *titleColer;

/**
 *  设置选中的文本颜色
 */
@property (nonatomic, strong) UIColor *selectedTitleColer;

/**
 *  设置选中的效果视图的背景颜色
 */
@property (nonatomic, strong) UIColor *selectedViewBgColer;



@end
