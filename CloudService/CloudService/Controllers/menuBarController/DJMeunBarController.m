//
//  DJMeunBarController.m
//  Project-two
//
//  Created by mac on 16/3/9.
//  Copyright © 2016年 CXWL. All rights reserved.
//

#define kScreen_width KWidth
#define kScreen_height kHeight
#import "DJMeunBarController.h"
#import "SegmentControl.h"
#import "UIView+YYAdd.h"

@interface DJMeunBarController ()<UIScrollViewDelegate>{
    UIScrollView *_scrollView;
}

@property (nonatomic,assign)NSInteger willSeletedIndex;

@end

@implementation DJMeunBarController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isObligate = NO;
        _isScrollEnable = NO;
        _contentSizeHeight = 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
  
    [self setupUserInteraction1];
    // Do any additional setup after loading the view.
}



- (void)setupUserInteraction1{
    _contentSizeHeight = _contentSizeHeight ==  0 ? self.view.bounds.size.height:_contentSizeHeight;
    CGFloat Y = _isObligate?44:0;
    _scrollView = [UIScrollView new];
    _scrollView.canCancelContentTouches = YES;
    _scrollView.pagingEnabled = YES;
    _scrollView.bounces = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.frame = CGRectMake(0, Y, self.view.bounds.size.width,_contentSizeHeight);
    _scrollView.scrollEnabled = NO;
    _scrollView.canCancelContentTouches = NO;
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width*_viewControllers.count,0);
    [self.view addSubview:_scrollView];
    for (int i = 0; i<_viewControllers.count; i++) {
        UIViewController *VC = _viewControllers[i];
        [self addChildViewController:VC];
        VC.view.frame = CGRectMake(_scrollView.frame.size.width*i, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
        [_scrollView addSubview:VC.view];
    }
//    UIViewController *VC = _viewControllers[_selectedIndex];
//    [self addChildViewController:VC];
//    VC.view.frame = CGRectMake(_scrollView.frame.size.width * _selectedIndex, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
//    [_scrollView addSubview:VC.view];

}


- (void)setIsScrollEnable:(BOOL)isScrollEnable{
    if (isScrollEnable == YES) {
        _isScrollEnable = isScrollEnable;
        _scrollView.delegate = self;
        _scrollView.scrollEnabled = YES;
    }
}

- (void)setTitles:(NSArray *)titles{
    if (_titles != titles) {
        _titles = titles;
        SegmentControl *segmentControl = [[SegmentControl alloc] initWithFrame:CGRectMake(0, 0, kScreen_width, 44)];
        segmentControl.titles = titles;
        [segmentControl addTarget:self action:@selector(segmentControlAction:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:segmentControl];
        _segmentControl = segmentControl;
    }
}


- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    if (_selectedIndex != selectedIndex ) {
        // 设置之前视图控制器视图视图消失状态
//        UIViewController *disappearViewController = _viewControllers[_selectedIndex];
        // 把当前控制器的根视图从滑动视图上移除
//        [disappearViewController.view removeFromSuperview];
        // 设置当前视图选中位置
        _selectedIndex = selectedIndex;
        
        // 01 设置当前滑动视图要显示的位置
        _scrollView.contentOffset = CGPointMake(_scrollView.frame.size.width * _selectedIndex, 0);
        // 02 判断将要显示的视图控制器的根视图是否已经添加到滑动视图上
        // 获取当前显示视图控制器
        UIViewController *displayViewController = _viewControllers[_selectedIndex];
        [self addChildViewController:displayViewController];
        if (displayViewController.view.superview == nil) {
            // 当前控制器的根视图还没添加到滑动视图上
            // 03 设置将要显示视图控制器根视图的大小和位置
            displayViewController.view.frame = CGRectMake(_scrollView.frame.size.width * _selectedIndex, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
            // 04 将要显示视图控制器的根视图添加到滑动视图上
            [_scrollView addSubview:displayViewController.view];
        } else {
            // 05 调用将要显示视图控制器将要显示根视图
            [displayViewController viewWillAppear:NO];
            // 06 调用将要显示视图控制器已经显示根视图
            [displayViewController viewDidAppear:NO];
        }
    }
}



- (void)setWillSeletedIndex:(NSInteger)willSeletedIndex{
    if (_willSeletedIndex != willSeletedIndex) {
        _willSeletedIndex = willSeletedIndex;
        UIViewController *displayVC = _viewControllers[_willSeletedIndex];
        if ([displayVC.view superview]) {
            [displayVC viewWillAppear:NO];
            
        }else{
            [self addChildViewController:displayVC];
            displayVC.view.frame = CGRectMake(_scrollView.frame.size.width * _willSeletedIndex, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
            [_scrollView addSubview:displayVC.view];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat offset_x = _selectedIndex*scrollView.frame.size.width;
    if (self.titles.count>0) {
        CGFloat scrollView_contentOffset_x = scrollView.contentOffset.x;
        // 3.获取当前滑动视图的页数索引
        NSInteger pageIndex = (int)scrollView_contentOffset_x / (int)scrollView.frame.size.width;
        // 获取当前页面视图的偏移宽度
        float p_width = scrollView_contentOffset_x - pageIndex * scrollView.frame.size.width;
        // 4.获取当前页面的偏移比例
        float scale = p_width / scrollView.frame.size.width;
        // 5.设置选中视图的位置
        CGFloat width = kScreen_width/self.titles.count;
        CGFloat centerX = (pageIndex+1/2.0) * width + width * scale ;
        CGFloat centerY = _segmentControl.selectedView.center.y;
        _segmentControl.selectedView.center = CGPointMake(centerX, centerY);
    }
    if (scrollView.contentOffset.x<offset_x) {
        //欲后退一页
        self.willSeletedIndex = _selectedIndex-1;
    }else if(scrollView.contentOffset.x>offset_x){
        //欲前进一页
        self.willSeletedIndex = _selectedIndex+1;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    if (decelerate == NO) {
        NSInteger pageIndex = (scrollView.contentOffset.x) / scrollView.frame.size.width;
        if (_selectedIndex != pageIndex) {
            // 设置之前视图控制器视图视图消失状态
//            UIViewController *disappearViewController = _viewControllers[_selectedIndex];
            // 把当前控制器的根视图从滑动视图上移除
//            [disappearViewController removeFromParentViewController];
//            [disappearViewController.view removeFromSuperview];
             _selectedIndex = pageIndex;
            self.selectedIndex = pageIndex;
            _willSeletedIndex = pageIndex;
            UIViewController *displayVC = _viewControllers[_selectedIndex];
            [displayVC viewDidAppear:NO];
            _segmentControl.selectedIndex = pageIndex;
        }
        
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    NSInteger pageIndex = (int)(scrollView.contentOffset.x) / (int)scrollView.frame.size.width;
    if (_selectedIndex != pageIndex) {
        // 设置之前视图控制器视图视图消失状态
//        UIViewController *disappearViewController = _viewControllers[_selectedIndex];
        // 把当前控制器的根视图从滑动视图上移除
//        [disappearViewController removeFromParentViewController];

//        [disappearViewController.view removeFromSuperview];
        // 保存当前状态
        _selectedIndex = pageIndex;
        self.selectedIndex = pageIndex;
        _willSeletedIndex = pageIndex;
        UIViewController *displayVC = _viewControllers[_selectedIndex];
        [displayVC viewDidAppear:NO];
        _segmentControl.selectedIndex = pageIndex;
    }

}

- (void)segmentControlAction:(SegmentControl *)segmentControl{
    self.selectedIndex = segmentControl.selectedIndex;
    _willSeletedIndex = segmentControl.selectedIndex;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
