//
//  SearchOrderViewController.m
//  CloudService
//
//  Created by 安永超 on 16/2/24.
//  Copyright © 2016年 zhangqiang. All rights reserved.
//

#import "SearchOrderViewController.h"
#import "HZQDatePickerView.h"
#import "PellTableViewSelect.h"
#import <MJRefresh.h>
#import "OrderManagerCell.h"
#import "Order.h"
#import "ButelHandle.h"
#import "OrderInfoViewController.h"

#define ThreeDay    86400*3

@interface SearchOrderViewController ()<HZQDatePickerViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UIView *_searchView;//搜索菜单页面
    UIButton *_blackBtn;//背景层
    BOOL isOpen;//菜单是否展开
    UITextField *_tfName;//客户姓名
    UITextField *_tfTel;//客户手机号
    UITextField *_tfCar;//车牌号
    UITextField *_tfStart;//开始时间
    UITextField *_tfEnd;
    HZQDatePickerView *_pickerView;//时间选择器
    UITextField *_tfCode;//结束码
    int _page;//当前页数
    int _pageSize;//每页加载数
    UIImageView *_noDataImg;
    UILabel *_lbNoData;
    NSMutableArray *_orderArray;//搜索到的订单数组
    Order *_order;//订单信息
    NSDate *_startDate;//开始日期
    NSDate *_endDate;//结束日期

}
@property (weak, nonatomic)IBOutlet UITableView *tableView;
@end

@implementation SearchOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _orderArray = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;
    [weakSelf setLeftImageBarButtonItemWithFrame:CGRectMake(0, 0, 30, 30) image:@"title-back" selectImage:@"back" action:^(AYCButton *button) {
        [[FireData sharedInstance] eventWithCategory:@"订单搜索" action:@"返回订单管理" evar:nil attributes:nil];
  
        CFRelease((__bridge CFTypeRef)weakSelf);

        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    
    self.title=@"订单搜索";
    
    [weakSelf setRightImageBarButtonItemWithFrame:CGRectMake(0, 0, 30, 30) image:@"title-search" selectImage:@"title-search_" action:^(AYCButton *button) {
        if (isOpen) {
            [[FireData sharedInstance] eventWithCategory:@"订单搜索" action:@"收回搜索菜单" evar:nil attributes:nil];
            [weakSelf upMenu];
        }else {
            [[FireData sharedInstance] eventWithCategory:@"订单搜索" action:@"下拉搜索菜单" evar:nil attributes:nil];
            [weakSelf downMenu];
        }
        
    }];
    
   
    self.tableView.tableFooterView = [UIView new];
    [self addMjRefresh];
    //蒙版
    _blackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _blackBtn.backgroundColor = [UIColor blackColor];
    _blackBtn.frame = self.view.frame;
    _blackBtn.alpha = 0.5f;
//    [_blackBtn addTarget:self action:@selector(upMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_blackBtn];
    //加载搜索试图
    [self initSearchMenu];
    
    [self downMenu];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}

/** 搜索菜单*/
- (void)initSearchMenu {
    _searchView = [[UIView alloc] initWithFrame:CGRectMake(0, -310, KWidth, 310)];
    _searchView.backgroundColor = [HelperUtil colorWithHexString:@"#F4F4F4"];
    [self.view addSubview:_searchView];
    
    UILabel *lbName = [UILabel new];
    lbName.textColor = [UIColor darkGrayColor];
    lbName.font = [UIFont systemFontOfSize:14];
    lbName.text = @"姓名";
    [_searchView addSubview:lbName];
    
    [lbName mas_makeConstraints:^(MASConstraintMaker *make) {
        //添加大小约束
        make.size.mas_equalTo(CGSizeMake(50, 34));
        //添加左边距约束
        make.left.mas_equalTo(20);
        //添加上边距约束
        make.top.mas_equalTo(15);
    }];
    
    _tfName = [UITextField new];
    _tfName.placeholder = @"请输入客户姓名";
    [_tfName setValue:[UIFont boldSystemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
    [_tfName setFont:[UIFont systemFontOfSize:14]];
    _tfName.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _tfName.borderStyle = UITextBorderStyleRoundedRect;
    [_searchView addSubview:_tfName];
    [_tfName mas_makeConstraints:^(MASConstraintMaker *make) {
        //添加高约束
        make.height.mas_equalTo(34);
        //添加左边距约束(距离左边label的距离)
        make.left.mas_equalTo(90);
        //添加右边距约束
        make.right.mas_equalTo(-20);
        //添加上边距约束
        make.top.mas_equalTo(15);
        
        
    }];
    
    UILabel *lbTel = [UILabel new];
    lbTel.textColor = [UIColor darkGrayColor];
    lbTel.font = [UIFont systemFontOfSize:14];
    lbTel.text = @"手机号";
    [_searchView addSubview:lbTel];
    
    [lbTel mas_makeConstraints:^(MASConstraintMaker *make) {
        //添加大小约束
        make.size.mas_equalTo(CGSizeMake(50, 34));
        //添加左边距约束
        make.left.mas_equalTo(20);
        //添加上边距约束（上边距 = lbName的下边框 + 偏移量15）
        make.top.equalTo(lbName.mas_bottom).offset(15);
    }];
    
    _tfTel = [UITextField new];
    _tfTel.placeholder = @"请输入客户手机号";
    [_tfTel setValue:[UIFont boldSystemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
    [_tfTel setFont:[UIFont systemFontOfSize:14]];
    _tfTel.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _tfTel.borderStyle = UITextBorderStyleRoundedRect;
    _tfTel.keyboardType = UIKeyboardTypePhonePad;
    [_searchView addSubview:_tfTel];
    [_tfTel mas_makeConstraints:^(MASConstraintMaker *make) {
        //添加高约束
        make.height.mas_equalTo(34);
        //添加左边距约束(距离左边label的距离)
        make.left.mas_equalTo(90);
        //添加右边距约束
        make.right.mas_equalTo(-20);
        //添加上边距约束
        make.top.equalTo(_tfName.mas_bottom).offset(15);
 
    }];
    
    UILabel *lbCar = [UILabel new];
    lbCar.textColor = [UIColor darkGrayColor];
    lbCar.font = [UIFont systemFontOfSize:14];
    lbCar.text = @"车牌号";
    [_searchView addSubview:lbCar];
    
    [lbCar mas_makeConstraints:^(MASConstraintMaker *make) {
        //添加大小约束
        make.size.mas_equalTo(CGSizeMake(50, 34));
        //添加左边距约束
        make.left.mas_equalTo(20);
        //添加上边距约束（上边距 = lbName的下边框 + 偏移量15）
        make.top.equalTo(lbTel.mas_bottom).offset(15);
    }];
    
    _tfCar = [UITextField new];
    _tfCar.placeholder = @"请输入车牌号";
    [_tfCar setValue:[UIFont boldSystemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
    [_tfCar setFont:[UIFont systemFontOfSize:14]];
    _tfCar.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _tfCar.borderStyle = UITextBorderStyleRoundedRect;
    [_searchView addSubview:_tfCar];
    [_tfCar mas_makeConstraints:^(MASConstraintMaker *make) {
        //添加高约束
        make.height.mas_equalTo(34);
        //添加左边距约束(距离左边label的距离)
        make.left.mas_equalTo(90);
        //添加右边距约束
        make.right.mas_equalTo(-20);
        //添加上边距约束
        make.top.equalTo(_tfTel.mas_bottom).offset(15);
        
    }];
    
    UILabel *lbState = [UILabel new];
    lbState.textColor = [UIColor darkGrayColor];
    lbState.font = [UIFont systemFontOfSize:14];
    lbState.text = @"结束码";
    [_searchView addSubview:lbState];
    
    [lbState mas_makeConstraints:^(MASConstraintMaker *make) {
        //添加大小约束
        make.size.mas_equalTo(CGSizeMake(50, 34));
        //添加左边距约束
        make.left.mas_equalTo(20);
        //添加上边距约束（上边距 = lbName的下边框 + 偏移量15）
        make.top.equalTo(lbCar.mas_bottom).offset(15);
    }];
    

    
    _tfCode = [UITextField new];
    _tfCode.font = [UIFont systemFontOfSize:14];
    _tfCode.placeholder = @"请选择结束码";
    _tfCode.userInteractionEnabled = NO;
    [_searchView addSubview:_tfCode];
    
    UIButton *endCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    endCodeBtn.backgroundColor = [UIColor clearColor];
    [endCodeBtn addTarget:self action:@selector(codeClick:) forControlEvents:UIControlEventTouchUpInside];
    [_searchView addSubview:endCodeBtn];
    
    [_tfCode mas_makeConstraints:^(MASConstraintMaker *make) {
        //添加高约束
        make.height.mas_equalTo(34);
        //添加左边距约束(距离左边label的距离)
        make.left.mas_equalTo(90);
        //添加右边距约束
        make.right.mas_equalTo(-20);
        //添加上边距约束
        make.top.equalTo(_tfCar.mas_bottom).offset(15);
        
    }];
    [endCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        //添加高约束
        make.height.mas_equalTo(34);
        //添加左边距约束(距离左边label的距离)
        make.left.mas_equalTo(90);
        //添加右边距约束
        make.right.mas_equalTo(-20);
        //添加上边距约束
        make.top.equalTo(_tfCar.mas_bottom).offset(15);
        
    }];
    
    
    UILabel *lbTime = [UILabel new];
    lbTime.textColor = [UIColor darkGrayColor];
    lbTime.font = [UIFont systemFontOfSize:14];
    lbTime.text = @"起止时间";
    [_searchView addSubview:lbTime];
    
    [lbTime mas_makeConstraints:^(MASConstraintMaker *make) {
        //添加大小约束
        make.size.mas_equalTo(CGSizeMake(60, 34));
        //添加左边距约束
        make.left.mas_equalTo(20);
        //添加上边距约束（上边距 = lbName的下边框 + 偏移量15）
        make.top.equalTo(lbState.mas_bottom).offset(15);
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
        make.top.equalTo(_tfCode.mas_bottom).offset(15);
        // 添加左边距约束（距离当前主视图左边的距离）
        make.left.equalTo(lbTime.mas_right).offset(15);
        // 添加右边距约束（距离第二个按键左边的距离）
        make.right.equalTo(_tfEnd.mas_left).with.offset(-20);

        // 添加宽度（宽度跟右边按键一样）
        make.width.equalTo(_tfEnd);
    }];
    [startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        //添加高约束
        make.height.mas_equalTo(34);
        //添加上边距约束
        make.top.equalTo(_tfCode.mas_bottom).offset(15);
        // 添加左边距约束（距离当前主视图左边的距离）
        make.left.equalTo(lbTime.mas_right).offset(15);
        // 添加右边距约束（距离第二个按键左边的距离）
        make.right.equalTo(_tfEnd.mas_left).with.offset(-20);
        
        // 添加宽度（宽度跟右边按键一样）
        make.width.equalTo(_tfEnd);
    }];
    
    
    [_tfEnd mas_makeConstraints:^(MASConstraintMaker *make) {
        //添加高约束
        make.height.mas_equalTo(34);
        //添加上边距约束
        make.top.equalTo(_tfCode.mas_bottom).offset(15);
        // 添加左边距约束（距离左边按键的距离）
        make.left.equalTo(_tfStart.mas_right).with.offset(20);
        // 添加右边距约束（距离当前主视图右边的距离）
        make.right.equalTo(self.view.mas_right).with.offset(-20);
        
        // 添加宽度（宽度跟右边按键一样）
        make.width.equalTo(_tfStart);
    }];
    [endBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        //添加高约束
        make.height.mas_equalTo(34);
        //添加上边距约束
        make.top.equalTo(_tfCode.mas_bottom).offset(15);
        // 添加左边距约束（距离左边按键的距离）
        make.left.equalTo(_tfStart.mas_right).with.offset(20);
        // 添加右边距约束（距离当前主视图右边的距离）
        make.right.equalTo(self.view.mas_right).with.offset(-20);
        
        // 添加宽度（宽度跟右边按键一样）
        make.width.equalTo(_tfStart);
    }];
    
    UIView *lineView = [UIView new];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [_searchView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        //添加大小约束
        make.size.mas_equalTo(CGSizeMake(10, 1));
        //添加左边距约束
         make.left.equalTo(_tfStart.mas_right).with.offset(5);
        //添加上边距约束（上边距 = lbName的下边框 + 偏移量15）
        make.top.equalTo(lbState.mas_bottom).offset(31);
    }];
    
    UIButton *btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCancel.layer.cornerRadius = 5.0f;
    btnCancel.layer.masksToBounds = YES;
    [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
    btnCancel.titleLabel.font = [UIFont systemFontOfSize:14];
    btnCancel.backgroundColor = [UIColor lightGrayColor];
    [btnCancel addTarget:self action:@selector(cancelClick:) forControlEvents:UIControlEventTouchUpInside];
    [_searchView addSubview:btnCancel];
    
    UIButton *btnSearch = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSearch.layer.cornerRadius = 5.0f;
    btnSearch.layer.masksToBounds = YES;
    [btnSearch setTitle:@"搜索" forState:UIControlStateNormal];
    btnSearch.titleLabel.font = [UIFont systemFontOfSize:14];
    btnSearch.backgroundColor = [HelperUtil colorWithHexString:@"FF6271"];
    [btnSearch addTarget:self action:@selector(sureClick:) forControlEvents:UIControlEventTouchUpInside];
    [_searchView addSubview:btnSearch];
    
    // 给左边视图添加约束
    [btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        //添加上边距约束
        make.top.equalTo(_tfStart.mas_bottom).offset(15);
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
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tfPhoneChanged:) name:UITextFieldTextDidChangeNotification object:_tfTel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tfCarChanged:) name:UITextFieldTextDidChangeNotification object:_tfCar];

}

- (void)tfPhoneChanged:(NSNotification *)sender {
    if (_tfTel.text.length >= 11) {
        _tfTel.text = [_tfTel.text substringToIndex:11];
    }
    
}

- (void)tfCarChanged:(NSNotification *)sender {
    if (_tfCar.text.length >= 7) {
        _tfCar.text = [_tfCar.text substringToIndex:7];
    }
    
}
/**
 *  取消搜索
 *
 *  @param sender
 */
- (void)cancelClick:(UIButton *)sender {
    [[FireData sharedInstance] eventWithCategory:@"订单搜索" action:@"取消搜索" evar:nil attributes:nil];
    [self upMenu];

}
/**
 *  确定搜索
 *
 *  @param sender
 */

- (void)sureClick:(UIButton *)sender {
    [[FireData sharedInstance] eventWithCategory:@"订单搜索" action:@"确定搜索" evar:nil attributes:nil];
    [self upMenu];
    [self.tableView.mj_header beginRefreshing];
}
/** 结束码下拉*/
-  (void)codeClick:(UITapGestureRecognizer *)tap {
    [[FireData sharedInstance] eventWithCategory:@"订单搜索" action:@"选择结束码" evar:nil attributes:nil];
    [HelperUtil resignKeyBoardInView:self.view];
    NSArray *array = [[SingleHandle shareSingleHandle] getEndCodeArray];
    [PellTableViewSelect addPellTableViewSelectWithWindowFrame:CGRectMake(80, 260, 200, 200) selectData:
     
     array
                                                        action:^(NSInteger index) {
                                                            
                                                            _tfCode.text = [array objectAtIndex:index];
                                                            
                                                        } animated:YES];

}

/** 下拉菜单*/
- (void)downMenu {
   isOpen = !isOpen;
    [UIView animateWithDuration:0.5 animations:^{
        _searchView.frame = CGRectMake(0, 0, KWidth, 310);
        _blackBtn.hidden = NO;
    }];
}
/** 收回菜单*/
- (void)upMenu {
    [HelperUtil resignKeyBoardInView:self.view];
    isOpen = !isOpen;
    [UIView animateWithDuration:0.5 animations:^{
        _searchView.frame = CGRectMake(0, -310, KWidth, 310);
        _blackBtn.hidden = YES;
    }];
}
// 开始时间
- (void)startDateClick:(UITapGestureRecognizer *)tap {
    [[FireData sharedInstance] eventWithCategory:@"订单搜索" action:@"起始时间" evar:nil attributes:nil];
    [HelperUtil resignKeyBoardInView:self.view];
    [self setupDateView:DateTypeOfStart];
    
}

// 结束时间
- (void)endDateClick:(UITapGestureRecognizer *)tap {
    [[FireData sharedInstance] eventWithCategory:@"订单搜索" action:@"终止时间" evar:nil attributes:nil];
    [HelperUtil resignKeyBoardInView:self.view];
    [self setupDateView:DateTypeOfEnd];
    
}
#pragma mark HZQDatePickerView
- (void)setupDateView:(DateType)type {
    
    _pickerView = [HZQDatePickerView instanceDatePickerView];
    _pickerView.frame = CGRectMake(0, 0, KWidth, KHeight + 20);
    [_pickerView setBackgroundColor:[UIColor clearColor]];
    _pickerView.delegate = self;
    _pickerView.type = type;
    if (type == DateTypeOfStart) {
  
    }else {
        [_pickerView.datePickerView setMinimumDate:_startDate];
      
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
            _endDate = date;
            break;
            
        default:
            break;
    }
}

#pragma mark - 暂无数据
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
}

#pragma mark - 添加MJ控件

- (void)addMjRefresh {
    
    _pageSize=7;
    __weak typeof(self) weakSelf = self;

    // 下拉刷新
    weakSelf.tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
       
        [weakSelf requestData];
        
    }];
    
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    weakSelf.tableView.mj_header.automaticallyChangeAlpha = YES;
    
    
    // 上拉刷新
    weakSelf.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        
        [weakSelf requestMoreData];
        
    }];
}
- (void)requestData {
    _page=1;
    [self removeNoData];
    
    NSDictionary *paramsDic=@{@"userId":[[SingleHandle shareSingleHandle] getUserInfo].userId,
                              @"pageSize":[NSString stringWithFormat:@"%i",_pageSize],
                              @"pageNo":[NSString stringWithFormat:@"%i",_page],
                              @"startDate":_tfStart.text,
                              @"endDate":_tfEnd.text,
                              @"custName":_tfName.text,
                              @"phoneNo":_tfTel.text,
                              @"licenseNo":_tfCar.text,
                              @"endCode":_tfCode.text};
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseAPI,kfindOrderByCondition];
    
    __weak typeof(self) weakSelf = self;
    [MHNetworkManager postReqeustWithURL:url params:paramsDic successBlock:^(id returnData) {
        AYCLog(@"%@",returnData);
        NSDictionary *dic = returnData;
        if ([[dic objectForKey:@"flag"] isEqualToString:@"success"]) {
            [_orderArray removeAllObjects];
            NSDictionary *dataDic = [dic objectForKey:@"data"];
            //取出总条数
            int totalCount=[[[dataDic objectForKey:@"pageVO"] objectForKey:@"recordCount"] intValue];
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
            [_orderArray addObjectsFromArray:[Order mj_objectArrayWithKeyValuesArray:listArray]];
            AYCLog(@"%@",_orderArray);
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
                              @"endDate":_tfEnd.text,
                              @"custName":_tfName.text,
                              @"phoneNo":_tfTel.text,
                              @"licenseNo":_tfCar.text,
                              @"endCode":_tfCode.text};
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseAPI,kfindOrderByCondition];
    
    __weak typeof(self) weakSelf = self;
    [MHNetworkManager postReqeustWithURL:url params:paramsDic successBlock:^(id returnData) {
        AYCLog(@"%@",returnData);
        
        NSDictionary *dic = returnData;
        NSDictionary *dataDic = [dic objectForKey:@"data"];
        //取出总条数
        int totalCount=[[[dataDic objectForKey:@"pageVO"] objectForKey:@"recordCount"] intValue];
        AYCLog(@"总条数：%i",totalCount);
        if (totalCount-_pageSize*_page<=0) {
            //没有数据，直接提示没有更多数据
            [_tableView.mj_footer endRefreshingWithNoMoreData];
        }else{
            //有数据，则结束刷新状态，以便下次能够刷新
            [_tableView.mj_footer endRefreshing];
        }
        
        NSArray *listArray = [dataDic objectForKey:@"list"];
        [_orderArray addObjectsFromArray:[Order mj_objectArrayWithKeyValuesArray:listArray]];
        AYCLog(@"%@",_orderArray);
        [weakSelf.tableView reloadData];

    } failureBlock:^(NSError *error) {
        AYCLog(@"%@",error);
        [weakSelf.tableView.mj_footer endRefreshing];
    } showHUD:YES];
    
}
#pragma mark tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _orderArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellId=@"cell";
    
    OrderManagerCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"OrderManagerCell" owner:self options:nil];
        cell = [array objectAtIndex:0];
    }
    Order *order = [_orderArray objectAtIndex:indexPath.row];
    cell.lbLicenseNo.text = [NSString stringWithFormat:@"车牌号：%@",order.licenseNo];
    [cell.btnOrderStatus setTitle:order.orderStatus forState:UIControlStateNormal];
    cell.lbCustomerName.text = [NSString stringWithFormat:@"客户姓名：%@",order.customerName];
    cell.lbBiPremium.text = order.biPremium;
    cell.lbCiPremium.text = order.ciPremium;
    cell.lbVehicleTaxPremium.text = order.vehicleTaxPremium;

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 155;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [[FireData sharedInstance] eventWithCategory:@"订单搜索" action:@"订单详情" evar:nil attributes:nil];
    _order = [_orderArray objectAtIndex:indexPath.row];
    
    [self performSegueWithIdentifier:@"searchOrderInfo" sender:self];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // segue.identifier：获取连线的ID
    
    if ([segue.identifier isEqualToString:@"searchOrderInfo"]) {
        // segue.destinationViewController：获取连线时所指的界面（VC）
        OrderInfoViewController *receive = segue.destinationViewController;
        receive.order = _order;
        AYCLog(@"%@",receive.order);
    }

}


-(void)dealloc {
    AYCLog(@"搜索界面已销毁");
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
