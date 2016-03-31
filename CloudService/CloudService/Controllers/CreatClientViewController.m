//
//  CreatClientViewController.m
//  CloudService
//
//  Created by 安永超 on 16/3/1.
//  Copyright © 2016年 zhangqiang. All rights reserved.
//

#import "CreatClientViewController.h"
#import "OfferViewController.h"
#import "ZQCityPickerView.h"
#import "Order.h"
#import "ButelHandle.h"
#import "MyClientViewController.h"

@interface CreatClientViewController ()<UITextFieldDelegate>
{
    NSString *_cityCode;
}
@property (weak, nonatomic)IBOutlet UITextField *tfName;
@property (weak, nonatomic)IBOutlet UITextField *tfPhone;
@property (weak, nonatomic)IBOutlet UITextField *tfLicenseNo;
@property (weak, nonatomic) IBOutlet UIButton *isNewCarBtn;
@property (weak, nonatomic)IBOutlet UITextField *tfCarCity;

@end

@implementation CreatClientViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self) weakSelf = self;
    self.tfLicenseNo.delegate = self;
    self.tfPhone.delegate = self;
    self.tfLicenseNo.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    [weakSelf setLeftImageBarButtonItemWithFrame:CGRectMake(0, 0, 35, 35) image:@"title-back" selectImage:@"back" action:^(AYCButton *button) {
        
        [[FireData sharedInstance] eventWithCategory:@"创建客户" action:@"返回" evar:nil attributes:nil];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tfPhoneChanged:) name:UITextFieldTextDidChangeNotification object:self.tfPhone];
    /**
     *  显示青牛拨打页面
     *
     */
    [[ButelHandle shareButelHandle] showCallView];
    // Do any additional setup after loading the view.
}
/**
 *  设置青牛拨打号码
 */
- (void)tfPhoneChanged:(NSNotification *)sender {
    if (self.tfPhone.text.length >= 11) {
        self.tfPhone.text = [self.tfPhone.text substringToIndex:11];
        [[ButelHandle shareButelHandle] setPhoneNo:_tfPhone.text];
    }
    
}
- (IBAction)nextAction:(id)sender {
    
    [[FireData sharedInstance] eventWithCategory:@"创建客户" action:@"下一步" evar:nil attributes:nil];
    if ([_tfName.text isEqualToString:@""]) {
        [MBProgressHUD showMessag:@"请输入客户姓名" toView:self.view];
        return ;
    }
    if ([_tfPhone.text isEqualToString:@""]){
        [MBProgressHUD showMessag:@"请输入客户手机号" toView:self.view];
        return ;
    }
    if (!self.isNewCarBtn.selected && [_tfLicenseNo.text isEqualToString:@""]){
            [MBProgressHUD showMessag:@"请输入车牌号" toView:self.view];
        return ;
    }
    if ([_tfCarCity.text isEqualToString:@""]){
        [MBProgressHUD showMessag:@"请输入汽车所在城市" toView:self.view];
        return ;
    }
    
    
    if (![_tfPhone.text isEqualToString:@""] &&![HelperUtil checkTelNumber:_tfPhone.text]){
        [MBProgressHUD showMessag:@"手机号格式不正确" toView:self.view];
        return ;
    }
    if (!self.isNewCarBtn.selected && ![HelperUtil validateCarNo:_tfLicenseNo.text]){
        self.tfLicenseNo.text = [self.tfLicenseNo.text uppercaseString];
        [MBProgressHUD showMessag:@"车牌号格式不正确" toView:self.view];
        return ;
    }


    [self performSegueWithIdentifier:@"offer" sender:self];
}

- (IBAction)newCarAction:(id)sender {
    
    [[FireData sharedInstance] eventWithCategory:@"创建订单" action:@"新车" evar:nil attributes:nil];
    if (self.isNewCarBtn.selected)
    {
        [self.isNewCarBtn setImage:[UIImage imageNamed:@"checkbox"] forState:(UIControlStateNormal)];
        self.tfLicenseNo.enabled = YES;
        self.tfLicenseNo.text = @"";
        self.tfLicenseNo.placeholder = @"请输入车牌号";
    }else
    {
        [self.isNewCarBtn setImage:[UIImage imageNamed:@"checkbox_"] forState:(UIControlStateNormal)];
        self.tfLicenseNo.enabled = NO;
        self.tfLicenseNo.text = @"新车";
    }
    self.isNewCarBtn.selected = !self.isNewCarBtn.selected;
    
}



- (IBAction)showCityPickerView:(id)sender {
    
    [[FireData sharedInstance] eventWithCategory:@"创建订单" action:@"行驶省市" evar:nil attributes:nil];

    [HelperUtil resignKeyBoardInView:self.view];
    
    __block ZQCityPickerView *cityPickerView = [[ZQCityPickerView alloc] initWithProvincesArray:nil cityArray:nil componentsCount:2];
    
    __weak typeof(self) weakSelf = self;
    [cityPickerView showPickViewAnimated:^(NSString *province, NSString *city,NSString *cityCode,NSString *provinceCode) {
        weakSelf.tfCarCity.text = [NSString stringWithFormat:@"%@ %@",province,city];
        _cityCode = cityCode;
        cityPickerView = nil;
    }];
    
    
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField isEqual:self.tfLicenseNo]) {

        if (![_tfLicenseNo.text isEqualToString:@""] && ![HelperUtil validateCarNo:_tfLicenseNo.text]){
            self.tfLicenseNo.text = [self.tfLicenseNo.text uppercaseString];
            [MBProgressHUD showMessag:@"车牌号格式不正确" toView:self.view];
            return ;
        }
    }
    if ([textField isEqual:self.tfPhone]) {
        if (![_tfPhone.text isEqualToString:@""] &&![HelperUtil checkTelNumber:_tfPhone.text]){
            [MBProgressHUD showMessag:@"手机号格式不正确" toView:self.view];
            return ;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.title = @"创建客户";

    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // segue.identifier：获取连线的ID
    if ([segue.identifier isEqualToString:@"offer"]) {
       
        // segue.destinationViewController：获取连线时所指的界面（VC）
        OfferViewController *offerVC = segue.destinationViewController;
      
        Order *order = [[Order alloc] init];
        if ([_tfLicenseNo.text isEqualToString:@""]) {
           order.licenseNo = @"";
        }else {
           order.licenseNo = _tfLicenseNo.text;
        }
        order.phoneNo = _tfPhone.text;
        order.customerName = _tfName.text;
        order.cityCode = _cityCode;
        offerVC.order = order;
    }
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
