//
//  SegmentControl.m
//  Project-two
//
//  Created by mac on 16/3/5.
//  Copyright © 2016年 CXWL. All rights reserved.
//

#define kColor_navigationBarColor [HelperUtil colorWithHexString:@"277FD9"]
#define kSeleViewWidthLessScreenWidth 38
#define kSeleViewHeight 2

#import "SegmentControl.h"

@implementation SegmentControl{
    NSMutableArray *_titleLabels;
    NSInteger _lastIndex;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 设置默认参数
        [self defaultProperty];
    }
    return self;
}

// 设置默认参数
- (void)defaultProperty
{
    // 设置默认颜色
    self.backgroundColor = [UIColor whiteColor];
    self.titleColer = [UIColor colorWithRed:0 green:0 blue:0 alpha:.5];
    self.selectedTitleColer = kColor_navigationBarColor;
    self.selectedViewBgColer = kColor_navigationBarColor;
}
#pragma mark - 设置颜色
- (void)setTitleColer:(UIColor *)titleColer
{
    if (_titleColer != titleColer) {
        _titleColer = titleColer;
        // 改变当前文本所有选中的颜色
        for (int i = 0; i < _titleLabels.count; i++) {
            // 如果当前文本不是选中文本
            if (i != _selectedIndex) {
                // 改变文本的默认颜色
                UILabel *titleLabel = _titleLabels[i];
                titleLabel.textColor = _titleColer;
            }
        }
    }
}

- (void)setSelectedTitleColer:(UIColor *)selectedTitleColer
{
    if (_selectedTitleColer != selectedTitleColer) {
        _selectedTitleColer = selectedTitleColer;
        
        // 改变选中文本的颜色
        UILabel *selectedTitleLabel = _titleLabels[_selectedIndex];
        selectedTitleLabel.textColor = _selectedTitleColer;
        
    }
}

- (void)setSelectedViewBgColer:(UIColor *)selectedViewBgColer
{
    if (_selectedViewBgColer != selectedViewBgColer) {
        _selectedViewBgColer = selectedViewBgColer;
        
        if (_selectedView != nil) {
            _selectedView.backgroundColor = _selectedViewBgColer;
        }
    }
}

#pragma mark - 当有标题数组的时候就有选项按钮显示
- (void)setTitles:(NSArray *)titles
{
    if (_titles != titles) {
        _titles = titles;
        
    }
}


#pragma mark - 点击事件
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // 1.获取当前手指对象
    UITouch *touch = [touches anyObject];
    // 2.获取手指点在当前控件上的位置
    CGPoint touchPoint = [touch locationInView:self];
    // 3.获取当前点击视图的索引位置
    NSInteger selectedIndex = (int)touchPoint.x / (int)(self.frame.size.width / _titles.count);
    // 4.判断点击位置是否和之前位置相等
    if (_selectedIndex != selectedIndex) {
        self.selectedIndex = selectedIndex;
        // 发送值改变的事件
        
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

#pragma mark - 当选中索引位置发生了改变的时候
- (void)setSelectedIndex:(NSInteger)selectedIndex
{
  
        // 1.获取之前选中的文本把颜色设置成默认颜色
        UILabel *oldSelectedLabel = _titleLabels[_selectedIndex];
        oldSelectedLabel.textColor = _titleColer;
        
        // 2.记录当前选中索引围着
        _selectedIndex = selectedIndex;
        
        // 3.设置最新的选中文本的颜色
        UILabel *newSelectedLabel = _titleLabels[_selectedIndex];
        newSelectedLabel.textColor = _selectedTitleColer;
    
        UILabel *label = (UILabel *)[self viewWithTag:1050029+selectedIndex];
        UILabel *lastLabel = (UILabel *)[self viewWithTag:1050029+_lastIndex];
        // 4.让选中背景视图跟随滑动
        [UIView animateWithDuration:.25 animations:^{
            [label setFont:[UIFont systemFontOfSize:16]];
            [lastLabel setFont:[UIFont systemFontOfSize:14]];
            _selectedView.center = CGPointMake(newSelectedLabel.center.x, _selectedView.center.y);
        } completion:^(BOOL finished) {
            
            _lastIndex = selectedIndex;
        }];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    // 1.移除之前所有的文本视图
    for (UILabel *titleLabel in _titleLabels) {
        [titleLabel removeFromSuperview];
    }
    [_titleLabels removeAllObjects];
    
    // 2.根据当前文本数组创建所有的子视图
    // 01 文本的宽度
    float label_width = self.frame.size.width / _titles.count;
    // 02 创建存有文本视图的数组
    if (_titleLabels == nil) {
        _titleLabels = [[NSMutableArray alloc] init];
    }
    // 03 开始创建文本视图
    for (int i = 0; i < _titles.count; i++) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(i * label_width, 0, label_width, self.frame.size.height)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont systemFontOfSize:14];
        titleLabel.textColor = _titleColer;
        titleLabel.text = _titles[i];
        titleLabel.tag = 1050029+i;
        [self addSubview:titleLabel];
        // 把文本保存到数组中
        [_titleLabels addObject:titleLabel];
    }
    
    // 3.创建选中文本背景视图
    if (_selectedView == nil) {
        _selectedView = [[UIView alloc] initWithFrame:CGRectMake(kSeleViewWidthLessScreenWidth/2.0, self.frame.size.height - kSeleViewHeight, label_width-kSeleViewWidthLessScreenWidth, kSeleViewHeight)];
        _selectedView.backgroundColor = _selectedViewBgColer;
    }
    // 从新设置宽度
//    _selectedView.frame = CGRectMake(25, self.frame.size.height - 3, label_width-50, 2);
    [self addSubview:_selectedView];
    
    // 04 设置默认选中按钮索引位置
    _selectedIndex = 0;
    // 设置对应为本的标题颜色
    UILabel *titleLabel = _titleLabels[_selectedIndex];
    titleLabel.textColor = _selectedTitleColer;
}

@end
