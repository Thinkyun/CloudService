//
//  IntergralSearchViewController.m
//  CloudService
//
//  Created by 安永超 on 16/3/3.
//  Copyright © 2016年 zhangqiang. All rights reserved.
//

#import "IntergralSearchViewController.h"
#import "HZQDatePickerView.h"
#import <MJRefresh.h>
#import "Integral.h"
#import "IntegralTableViewCell.h"

@interface IntergralSearchViewController ()<HZQDatePickerViewDelegate>
{
    UIView *_searchView;//搜索菜单页面
    UIButton *_blackBtn;//背景层
    BOOL isOpen;//菜单是否展开
    UITextField *_tfStart;//开始时间
    UITextField *_tfEnd;
    HZQDatePickerView *_pickerView;//时间选择器
    __block int _page;//当前页数
    int _pageSize;//每页加载数
    NSMutableArray *_integralArray;
    UIImageView *_noDataImg;
    UILabel *_lbNoData;
    NSDate *_startDate;
}

@property (weak, nonatomic)IBOutlet UITableView *tableView;
@end

@implementation IntergralSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _integralArray = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;
    [weakSelf setLeftImageBarButtonItemWithFrame:CGRectMake(0, 0, 30, 30) image:@"title-back" selectImage:@"back" action:^(AYCButton *button) {
        CFRelease((__bridge CFTypeRef)weakSelf);
         AYCLog(@"Retain count is %ld", CFGetRetainCount((__bridge CFTypeRef)weakSelf));
        [[FireData sharedInstance] eventWithCategory:@"积分搜索" action:@"返回" evar:nil attributes:nil];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    
    _blackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _blackBtn.backgroundColor = [UIColor blackColor];
    _blackBtn.frame = self.view.frame;
    _blackBtn.alpha = 0.5f;
//    [_blackBtn addTarget:self action:@selector(upMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_blackBtn];
    [self initSearchMenu];
    [self addMjRefresh];
    self.tableView.tableFooterView = [[UIView alloc] init];

}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title=@"积分搜索";
    __weak typeof(self) weakSelf = self;
    [weakSelf setRightImageBarButtonItemWithFrame:CGRectMake(0, 0, 30, 30) image:@"title-search" selectImage:@"title-search_" action:^(AYCButton *button) {
        
        [[FireData sharedInstance] eventWithCategory:@"积分搜索" action:@"搜索" evar:nil attributes:nil];
        if (isOpen) {
            [weakSelf upMenu];
        }else {
            [weakSelf downMenu];
        }
        
    }];
    [self downMenu];
}
- (void)setupNoData {
    _noDataImg = [[UIImageView alloc] initWithFrame:CGRectMake(KWidth/2-30, KHeight/2-80, 75, 85)];
    _noDataImg.image = [UIImage imageNamed:@"pix2"];
    _lbNoData = [[UILabel alloc] initWithFrame:CGRectMake(KWidth/2-20, KHeight/2+10, 60, 25)];
    _lbNoData.text = @"暂无数据";
    _lbNoData.font = [UIFont systemFontOfSize:14];
    _lbNoData.textColor = [UIColor lightGrayColor];
    [self.tableView addSubview:_noDataImg];
    [self.tableView addSubview:_lbNoData];
}
- (void)removeNoData {
    [_noDataImg removeFromSuperview];
    [_lbNoData removeFromSuperview];
    _noDataImg = nil;
    _lbNoData = nil;
}


/** 搜索菜单*/
- (void)initSearchMenu {
    _searchView = [[UIView alloc] initWithFrame:CGRectMake(0, -160, KWidth, 160)];
    _searchView.backgroundColor = [HelperUtil colorWithHexString:@"#F4F4F4"];
    [self.view addSubview:_searchView];
    
   
    
    
    UILabel *lbStartTime = [UILabel new];
    lbStartTime.textColor = [UIColor darkGrayColor];
    lbStartTime.font = [UIFont systemFontOfSize:14];
    lbStartTime.text = @"起始时间:";
    [_searchView addSubview:lbStartTime];
    
    [lbStartTime mas_makeConstraints:^(MASConstraintMaker *make) {
        //添加大小约束
        make.size.mas_equalTo(CGSizeMake(80, 34));
        //添加左边距约束
        make.left.mas_equalTo(20);
        //添加上边距约束（上边距 = lbName的下边框 + 偏移量15）
        make.top.mas_equalTo(15);
    }];
    

    
    _tfStart = [UITextField new];
    _tfStart.font = [UIFont systemFontOfSize:14];
    _tfStart.placeholder = @"起始时间";
    _tfStart.userInteractionEnabled = NO;
    [_searchView addSubview:_tfStart];
    
    UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    startBtn.backgroundColor = [UIColor clearColor];
    [startBtn addTarget:self action:@selector(startDateClick:) forControlEvents:UIControlEventTouchUpInside];
    [_searchView addSubview:startBtn];
    
    UILabel *lbEndTime = [UILabel new];
    lbEndTime.textColor = [UIColor darkGrayColor];
    lbEndTime.font = [UIFont systemFontOfSize:14];
    lbEndTime.text = @"终止时间:";
    [_searchView addSubview:lbEndTime];
    
    [lbEndTime mas_makeConstraints:^(MASConstraintMaker *make) {
        //添加大小约束
        make.size.mas_equalTo(CGSizeMake(80, 34));
        //添加左边距约束
        make.left.mas_equalTo(20);
        //添加上边距约束（上边距 = lbName的下边框 + 偏移量15）
        make.top.equalTo(lbStartTime.mas_bottom).offset(15);
    }];
    

    
    _tfEnd = [UITextField new];
    _tfEnd.font = [UIFont systemFontOfSize:14];
    _tfEnd.placeholder = @"终止时间";
    _tfEnd.userInteractionEnabled = NO;
    [_searchView addSubview:_tfEnd];
    
    UIButton *endBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    endBtn.backgroundColor = [UIColor clearColor];
    [endBtn addTarget:self action:@selector(endDateClick:) forControlEvents:UIControlEventTouchUpInside];
    [_searchView addSubview:endBtn];
    [_tfStart mas_makeConstraints:^(MASConstraintMaker *make) {
        //添加高约束
        make.height.mas_equalTo(34);
        //添加上边距约束
        make.top.mas_equalTo(15);
        // 添加左边距约束（距离当前主视图左边的距离）
        make.left.equalTo(lbStartTime.mas_right).offset(15);
        // 添加右边距约束（距离第二个按键左边的距离）
        make.right.mas_equalTo(-60);
        
        // 添加宽度（宽度跟右边按键一样）
        make.width.equalTo(_tfEnd);
    }];
    [startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        //添加高约束
        make.height.mas_equalTo(34);
        //添加上边距约束
        make.top.mas_equalTo(15);
        // 添加左边距约束（距离当前主视图左边的距离）
        make.left.equalTo(lbStartTime.mas_right).offset(15);
        // 添加右边距约束（距离第二个按键左边的距离）
        make.right.mas_equalTo(-60);
        
        // 添加宽度（宽度跟右边按键一样）
        make.width.equalTo(_tfEnd);
    }];
    
    
    [_tfEnd mas_makeConstraints:^(MASConstraintMaker *make) {
        //添加高约束
        make.height.mas_equalTo(34);
        //添加上边距约束
        make.top.equalTo(_tfStart.mas_bottom).offset(15);
        // 添加左边距约束（距离左边按键的距离）
        make.left.equalTo(_tfStart.mas_right).with.offset(20);
        // 添加右边距约束（距离当前主视图右边的距离）
        make.right.mas_equalTo(-60);
        
        // 添加宽度（宽度跟右边按键一样）
        make.width.equalTo(_tfEnd);
    }];
    [endBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        //添加高约束
        make.height.mas_equalTo(34);
        //添加上边距约束
        make.top.equalTo(_tfStart.mas_bottom).offset(15);
        // 添加左边距约束（距离左边按键的距离）
        make.left.equalTo(_tfStart.mas_right).with.offset(20);
        // 添加右边距约束（距离当前主视图右边的距离）
        make.right.mas_equalTo(-60);
        
        // 添加宽度（宽度跟右边按键一样）
        make.width.equalTo(_tfStart);
    }];
   
    
    UIButton *btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCancel.layer.cornerRadius = 5.0f;
    btnCancel.layer.masksToBounds = YES;
    [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
    btnCancel.titleLabel.font = [UIFont systemFontOfSize:14];
    btnCancel.backgroundColor = [UIColor lightGrayColor];
    [btnCancel addTarget:self action:@selector(cancelSearch:) forControlEvents:UIControlEventTouchUpInside];
    [_searchView addSubview:btnCancel];
    
    UIButton *btnSearch = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSearch.layer.cornerRadius = 5.0f;
    btnSearch.layer.masksToBounds = YES;
    [btnSearch setTitle:@"搜索" forState:UIControlStateNormal];
    btnSearch.titleLabel.font = [UIFont systemFontOfSize:14];
    btnSearch.backgroundColor = [HelperUtil colorWithHexString:@"FF6271"];
    [btnSearch addTarget:self action:@selector(searchClick:) forControlEvents:UIControlEventTouchUpInside];
    [_searchView addSubview:btnSearch];
    
    // 给左边视图添加约束
    [btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        //添加上边距约束
        make.top.equalTo(lbEndTime.mas_bottom).offset(15);
        // 添加左边距约束（距离当前主视图左边的距离）
        make.left.equalTo(self.view.mas_left).with.offset(20);
        // 添加右边距约束（距离第二个按键左边的距离）
        make.right.equalTo(btnSearch.mas_left).with.offset(-20);
        // 添加当前按钮的高度
        make.height.mas_equalTo(34);
        // 添加宽度（宽度跟右边按键一样）
        make.width.equalTo(btnSearch);
    }];
    
    // 给右边视图添加约束
    [btnSearch mas_makeConstraints:^(MASConstraintMaker *make) {
        
        //添加上边距约束
        make.top.equalTo(_tfEnd.mas_bottom).offset(15);
        // 添加左边距约束（距离左边按键的距离）
        make.left.equalTo(btnCancel.mas_right).with.offset(20);
        // 添加右边距约束（距离当前主视图右边的距离）
        make.right.equalTo(self.view.mas_right).with.offset(-20);
        // 添加当前按钮的高度
        make.height.mas_equalTo(34);
        // 添加宽度（宽度跟左边按键一样）
        make.width.equalTo(btnCancel);
    }];
    
    
}


/** 下拉菜单*/
- (void)downMenu {
    isOpen = !isOpen;
    [UIView animateWithDuration:0.5 animations:^{
        _searchView.frame = CGRectMake(0, 0, KWidth, 160);
        _blackBtn.hidden = NO;
    }];
}
/** 收回菜单*/
- (void)upMenu {
    [HelperUtil resignKeyBoardInView:self.view];
    isOpen = !isOpen;
    [UIView animateWithDuration:0.5 animations:^{
        _searchView.frame = CGRectMake(0, -160, KWidth, 160);
        _blackBtn.hidden = YES;
    }];
}
// 开始时间
- (void)startDateClick:(UITapGestureRecognizer *)tap {
    
    [[FireData sharedInstance] eventWithCategory:@"积分搜索" action:@"起始时间" evar:nil attributes:nil];
    [HelperUtil resignKeyBoardInView:self.view];
    [self setupDateView:DateTypeOfStart];
    
}

// 结束时间
- (void)endDateClick:(UITapGestureRecognizer *)tap {
    
    [[FireData sharedInstance] eventWithCategory:@"积分搜索" action:@"终止时间" evar:nil attributes:nil];
    [HelperUtil resignKeyBoardInView:self.view];
    [self setupDateView:DateTypeOfEnd];
    
}
#pragma mark HZQDatePickerView
- (void)setupDateView:(DateType)type {
    
    _pickerView = [HZQDatePickerView instanceDatePickerView];
    _pickerView.frame = CGRectMake(0, 0, KWidth, KHeight + 20);
    [_pickerView setBackgroundColor:[UIColor clearColor]];
    [_pickerView.datePickerView setDatePickerMode:UIDatePickerModeDate];
    _pickerView.delegate = self;
    _pickerView.type = type;
    if (type == DateTypeOfStart) {
        [_pickerView.datePickerView setMaximumDate:[NSDate date]];
    }else {
        [_pickerView.datePickerView setMinimumDate:_startDate];
        [_pickerView.datePickerView setMaximumDate:[NSDate date]];
    }
    [self.view addSubview:_pickerView];
    
}

- (void)getSelectDate:(NSDate *)date type:(DateType)type {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *currentOlderOneDateStr = [dateFormatter stringFromDate:date];
    
    switch (type) {
        case DateTypeOfStart:
            _tfStart.text = currentOlderOneDateStr;
            _startDate = date;
            break;
            
        case DateTypeOfEnd:
            _tfEnd.text = currentOlderOneDateStr;
            
            break;
            
        default:
            break;
    }
}


- (void)searchClick:(UIButton *)sender {
    
    [[FireData sharedInstance] eventWithCategory:@"积分搜索" action:@"搜索" evar:nil attributes:nil];
    [self upMenu];
    [self.tableView.mj_header beginRefreshing];
}
- (void)cancelSearch:(UIButton *)sender {
    
    [[FireData sharedInstance] eventWithCategory:@"积分搜索" action:@"取消" evar:nil attributes:nil];
    [self upMenu];

}

- (void)addMjRefresh {
  
    _pageSize=7;
    // 下拉刷新
    self.tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        [self requestData];
        
    }];
    
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
   
    
    // 上拉刷新
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        
        [self requestMoreData];
        
    }];
}
- (void)requestData {
    
    _page=1;
    [self removeNoData];
    
    NSDictionary *paramsDic=@{@"userId":[[SingleHandle shareSingleHandle] getUserInfo].userId,
                              @"pageSize":[NSString stringWithFormat:@"%i",_pageSize],
                              @"pageNo":[NSString stringWithFormat:@"%i",_page],
                              @"startDate":_tfStart.text,
                              @"endDate":_tfEnd.text};
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseAPI,kfindUserCreditsRecord];
    
    __weak typeof(self) weakSelf = self;
    [MHNetworkManager postReqeustWithURL:url params:paramsDic successBlock:^(id returnData) {
        AYCLog(@"%@",returnData);
        NSDictionary *dic = returnData;
        if ([[dic objectForKey:@"flag"] isEqualToString:@"success"]) {
            [_integralArray removeAllObjects];
            NSDictionary *dataDic = [dic objectForKey:@"data"];
            //取出总条数
            __block int totalCount=[[[dataDic objectForKey:@"pageVO"] objectForKey:@"recordCount"] intValue];
            if (totalCount>0) {
                [weakSelf removeNoData];
            }else {
                [weakSelf setupNoData];
            }
            if (totalCount-_pageSize*_page<=0) {
                //没有数据，直接提示没有更多数据
                [_tableView.mj_footer endRefreshingWithNoMoreData];
            }else{
                [_tableView.mj_footer endRefreshing];
            }

            NSArray *listArray = [dataDic objectForKey:@"list"];
            [_integralArray addObjectsFromArray:[Integral mj_objectArrayWithKeyValuesArray:listArray]];
            AYCLog(@"%@",_integralArray);
        }else {
            [MBProgressHUD showMessag:[dic objectForKey:@"msg"] toView:weakSelf.view];
            [weakSelf setupNoData];
            
        }
        
        [weakSelf.tableView reloadData];
        [weakSelf.tableView.mj_header endRefreshing];
        
    } failureBlock:^(NSError *error) {
        [weakSelf setupNoData];
        [weakSelf.tableView reloadData];
        [weakSelf.tableView.mj_header endRefreshing];
    } showHUD:YES];

   
  
    
}

- (void)requestMoreData {
    _page++;
    
    NSDictionary *paramsDic=@{@"userId":[[SingleHandle shareSingleHandle] getUserInfo].userId,
                              @"pageSize":[NSString stringWithFormat:@"%i",_pageSize],
                              @"pageNo":[NSString stringWithFormat:@"%i",_page],
                              @"startDate":_tfStart.text,
                              @"endDate":_tfEnd.text};
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseAPI,kfindUserCreditsRecord];
    
    __weak typeof(self) weakSelf = self;
    [MHNetworkManager postReqeustWithURL:url params:paramsDic successBlock:^(id returnData) {
        
        NSDictionary *dic = returnData;
        NSDictionary *dataDic = [dic objectForKey:@"data"];
        //取出总条数
        int totalCount=[[[dataDic objectForKey:@"pageVO"] objectForKey:@"recordCount"] intValue];
        if (totalCount-_pageSize*_page<=0) {
            //没有数据，直接提示没有更多数据
            [_tableView.mj_footer endRefreshingWithNoMoreData];
        }else{
            //有数据，则结束刷新状态，以便下次能够刷新
            [_tableView.mj_footer endRefreshing];
        }
        
        NSArray *listArray = [dataDic objectForKey:@"list"];
        [_integralArray addObjectsFromArray:[Integral mj_objectArrayWithKeyValuesArray:listArray]];
        [weakSelf.tableView reloadData];
     
    } failureBlock:^(NSError *error) {
        [weakSelf.tableView.mj_footer endRefreshing];
    } showHUD:YES];
    
}
#pragma mark tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _integralArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellId=@"cell";
    
    IntegralTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"IntegralTableViewCell" owner:self options:nil];
        cell = [array objectAtIndex:0];
    }
    Integral *integral = [_integralArray objectAtIndex:indexPath.row];
    cell.lbComment.text = integral.comment;
    cell.lbTime.text = [HelperUtil timeFormat:integral.time format:@"yyyy-MM-dd HH:mm"];
    cell.lbReason.text = integral.reason;
    cell.lbCreditsNum.text = integral.creditsNum;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 96;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}



-(void)dealloc {
    
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
