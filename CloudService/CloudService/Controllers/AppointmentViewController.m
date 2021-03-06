//
//  AppointmentViewController.m
//  CloudService
//
//  Created by 安永超 on 16/2/26.
//  Copyright © 2016年 zhangqiang. All rights reserved.
//

#import "AppointmentViewController.h"
#import "PlaceholderTextView.h"
#import "PellTableViewSelect.h"
#import "HZQDatePickerView.h"
#import "SingleHandle.h"
#import "ButelHandle.h"

#undef  RGBCOLOR
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

@interface AppointmentViewController ()<HZQDatePickerViewDelegate>

@property (nonatomic, strong) PlaceholderTextView * textView;
@property (weak, nonatomic)IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UITextField *tfCode;
@property (weak, nonatomic) IBOutlet UITextField *tfDate;
//字数的限制
@property (nonatomic, strong)UILabel *wordCountLabel;
@property (strong, nonatomic)HZQDatePickerView *pickerView;//时间选择器
@end

@implementation AppointmentViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[ButelHandle shareButelHandle] showCallView];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[ButelHandle shareButelHandle] showCallView];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[ButelHandle shareButelHandle] hideCallView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
    [weakSelf setLeftImageBarButtonItemWithFrame:CGRectMake(0, 0, 30, 30) image:@"title-back" selectImage:@"back" action:^(AYCButton *button) {
        [[FireData sharedInstance] eventWithCategory:@"预约" action:@"返回订单详情" evar:nil attributes:nil];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];

    
    [self.bgView addSubview:self.textView];
    
    self.wordCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.textView.frame.origin.x + 20,  self.textView.frame.origin.y + 80 , [UIScreen mainScreen].bounds.size.width - 40, 20)];
    _wordCountLabel.font = [UIFont systemFontOfSize:14.f];
    _wordCountLabel.textColor = [UIColor lightGrayColor];
    self.wordCountLabel.text = @"0/50";
    self.wordCountLabel.backgroundColor = [UIColor whiteColor];
    self.wordCountLabel.textAlignment = NSTextAlignmentRight;
    [self.bgView addSubview:self.wordCountLabel];
   
    // Do any additional setup after loading the view.
}


- (IBAction)codeAction:(id)sender {
    [[FireData sharedInstance] eventWithCategory:@"预约" action:@"选择结束码" evar:nil attributes:nil];
    [HelperUtil resignKeyBoardInView:self.view];
    
    __weak typeof(self) weakSelf = self;
    [PellTableViewSelect addPellTableViewSelectWithWindowFrame:CGRectMake(110, 135, 200, 200) selectData:

     [[SingleHandle shareSingleHandle] getEndCodeArray]
                                                        action:^(NSInteger index) {
                                                            
                                                            weakSelf.tfCode.text = [[[SingleHandle shareSingleHandle] getEndCodeArray] objectAtIndex:index];
                                                        } animated:YES];
}

- (IBAction)dateAction:(id)sender{
    [[FireData sharedInstance] eventWithCategory:@"预约" action:@"选择预约时间" evar:nil attributes:nil];
    [HelperUtil resignKeyBoardInView:self.view];
    [self setupDateView:DateTypeOfStart];
}

#pragma mark HZQDatePickerView
- (void)setupDateView:(DateType)type {
    
    _pickerView = [HZQDatePickerView instanceDatePickerView];
    _pickerView.frame = CGRectMake(0, 0, KWidth, KHeight + 20);
    [_pickerView setBackgroundColor:[UIColor clearColor]];
    [_pickerView.datePickerView setDatePickerMode:UIDatePickerModeDateAndTime];
    _pickerView.delegate = self;
    _pickerView.type = type;
    [_pickerView.datePickerView setMinimumDate:[NSDate date]];
    [self.view addSubview:_pickerView];
    
}

- (void)getSelectDate:(NSDate *)date type:(DateType)type {

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *currentOlderOneDateStr = [dateFormatter stringFromDate:date];
    switch (type) {
        case DateTypeOfStart:
    
            self.tfDate.text = currentOlderOneDateStr;
            
            break;
            
            
        default:
            break;
    }
}
/**
 *  懒加载textView
 */
-(PlaceholderTextView *)textView{
    
    if (!_textView) {
        _textView = [[PlaceholderTextView alloc]initWithFrame:CGRectMake(15, 155, self.view.frame.size.width - 30, 70)];
        _textView.backgroundColor = [UIColor whiteColor];
        _textView.font = [UIFont systemFontOfSize:15.f];
        _textView.textColor = [UIColor blackColor];
        _textView.textAlignment = NSTextAlignmentLeft;
        _textView.placeholderColor = RGBCOLOR(0x89, 0x89, 0x89);
        _textView.placeholder = @"请输入备注内容";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewChanged:) name:UITextViewTextDidChangeNotification object:self.textView];
    }
    
    return _textView;
}

#pragma mark textField的字数限制


//在这个地方计算输入的字数
- (void)textViewChanged:(NSNotification *)sender
{
    PlaceholderTextView *textView = (PlaceholderTextView *)sender.object;
    NSInteger wordCount = textView.text.length;
    self.wordCountLabel.text = [NSString stringWithFormat:@"%ld/50",(long)wordCount];
    if (wordCount >= 50) {
        self.textView.text=[textView.text substringToIndex:49];
        [MBProgressHUD showMessag:@"最多输入50个字符" toView:self.view];
    }
}

- (IBAction)save:(id)sender {
     [[FireData sharedInstance] eventWithCategory:@"预约" action:@"保存预约" evar:nil attributes:nil];
    if ([self.tfCode.text isEqualToString:@""]) {
        [MBProgressHUD showMessag:@"请输入结束码" toView:nil];
        return;
    }
    if ([self.tfCode.text isEqualToString:@"空错号"]||[self.tfCode.text isEqualToString:@"客户拒绝"]||[self.tfCode.text isEqualToString:@"无效数据"]||[self.tfCode.text isEqualToString:@"成交"]) {
        
    }else {
        if ([self.tfDate.text isEqualToString:@""]) {
            [MBProgressHUD showMessag:@"请选择预约时间" toView:nil];
            return;
        }
    }
    NSString *timeStr = self.tfDate.text.length >0?[NSString stringWithFormat:@"%@:00",self.tfDate.text]:@"";
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseAPI,kaddReserve];
    NSDictionary *params = @{@"userId":[[SingleHandle shareSingleHandle] getUserInfo].userId,
                             @"customerId":self.customerId,
                             @"time":timeStr,
                             @"comment":self.textView.text,
                             @"endCode":self.tfCode.text,
                             @"baseId":self.baseId,
                             @"phoneNo":self.phoneNo};
    
    __weak typeof(self) weakSelf = self;
    [MHNetworkManager postReqeustWithURL:url params:params successBlock:^(id returnData) {
        
        if ([[returnData objectForKey:@"flag"] isEqualToString:@"success"]) {
            [MBProgressHUD showMessag:@"预约成功" toView:nil];
            NSString *time = self.tfDate.text.length <=0 ? @"" : [HelperUtil getDateWithDateStr:self.tfDate.text dateFormatter:@"yyyy-MM-dd HH:mm"];
            self.refreshBlock(self.tfCode.text,time,self.textView.text);
            [weakSelf.navigationController popViewControllerAnimated:YES];
            
        }else {
            [MBProgressHUD showMessag:[returnData objectForKey:@"msg"] toView:weakSelf.view];
        }
        
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];

   
    
}

- (void)refreshTableview:(refreshBlock)block {
    self.refreshBlock = block;
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
