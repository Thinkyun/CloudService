//
//  CreatOrderViewController.m
//  CloudService
//
//  Created by 安永超 on 16/2/24.
//  Copyright © 2016年 zhangqiang. All rights reserved.
//

#import "CreatOrderViewController.h"
#import "ZQCityPickerView.h"
#import "AppDelegate.h"
#import "OrderH5ViewController.h"
#import "ButelHandle.h"
#import "Order.h"
#import "OrderInfoViewController.h"

// baseId 25961588
@interface CreatOrderViewController ()<UITextFieldDelegate>
{
    NSString *_cityCode;
    Order *_order;
}
@property (weak, nonatomic)IBOutlet UITextField *tfName;
@property (weak, nonatomic)IBOutlet UITextField *tfPhone;
@property (weak, nonatomic)IBOutlet UITextField *tfLicenseNo;
@property (weak, nonatomic)IBOutlet UITextField *tfCarCity;
@property (weak, nonatomic)IBOutlet UIButton *isNewCarBtn;

@end

@implementation CreatOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self) weakSelf = self;
    self.tfLicenseNo.delegate = self;
    self.tfLicenseNo.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;

    [weakSelf setLeftImageBarButtonItemWithFrame:CGRectMake(0, 0, 35, 35) image:@"title-back" selectImage:@"back" action:^(AYCButton *button) {
        [[FireData sharedInstance] eventWithCategory:@"创建订单" action:@"返回首页" evar:nil attributes:nil];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    
    [[ButelHandle shareButelHandle] showCallView];

     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tfPhoneChanged:) name:UITextFieldTextDidChangeNotification object:self.tfPhone];
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
    if (![HelperUtil checkTelNumber:self.tfPhone.text]){
        [MBProgressHUD showMessag:@"手机号格式不正确" toView:self.view];
        return ;
    }

    if (!self.isNewCarBtn.selected && ![HelperUtil validateCarNo:self.tfLicenseNo.text]){
        [MBProgressHUD showMessag:@"车牌号格式不正确" toView:self.view];
        return ;
    }
    [[FireData sharedInstance] eventWithCategory:@"创建订单" action:@"下一步" evar:nil attributes:nil];
    User *user = [[SingleHandle shareSingleHandle] getUserInfo];
    NSDictionary *dict = @{@"userId":user.userId,
                           @"custName":self.tfName.text,
                           @"phoneNo":self.tfPhone.text,
                           @"licenseNo":self.tfLicenseNo.text};
    

    __weak typeof(self) weakSelf = self;
    [MHNetworkManager postReqeustWithURL:[RequestEntity urlString:kVerifyCusRepeat] params:dict
                            successBlock:^(id returnData) {
                                AYCLog (@"%@",returnData);
                                if ([[returnData valueForKey:@"flag"] isEqualToString:@"success"]) {
                                    [weakSelf linkZhiKe];
                                    return ;
                                }
                                if ([[returnData valueForKey:@"flag"] isEqualToString:@"conflict"]) {
                                    NSDictionary *dataDic = [returnData valueForKey:@"data"];
                                    _order = [Order mj_objectWithKeyValues:dataDic];
                                    NSString *msgStr = [NSString stringWithFormat:@"您之前有给%@报过价想跳转原单子么?",_order.customerName];
                                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:msgStr delegate:self cancelButtonTitle:@"找原单" otherButtonTitles:@"新建", nil];
                                    [alertView show];
                                }
                                
                                if ([[returnData valueForKey:@"flag"] isEqualToString:@"error"]) {
                                    [MBProgressHUD showMessag:[returnData objectForKey:@"msg"] toView:weakSelf.view];
                                    
                                }
                                
                            } failureBlock:^(NSError *error) {
                                
                            } showHUD:YES];

    
}
/**
 *  直客报价
 */
- (void)linkZhiKe {
            AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
            delegate.isThird=YES;
            /**
             *  dataType 01:创建订单,获取新数据 02:创建客户
             */
            User *user = [[SingleHandle shareSingleHandle] getUserInfo];
        NSString *licenseNo = self.tfLicenseNo.text;
        if ([self.tfLicenseNo.text isEqualToString:@""]) {
            licenseNo = @"新车";
        }
            NSDictionary *params = @{@"operType":@"",
                                     @"msg":@"",
                                     @"sendTime":@"",
                                     @"sign":@"",
                                     @"data":@{@"proportion":user.proportion,
                                               @"customerName":_tfName.text,
                                               @"phoneNo":_tfPhone.text,
                                               @"dataType":@"01",
                                               @"activeType":@"1",
                                               @"macAdress":@"02:00:00:00:00:00",
                                               @"agentCode":agentCode,
                                               @"engineNo":@"",
                                               @"vehicleFrameNo":@"",
                                               @"licenseNo":licenseNo,
                                               @"vehicleModelName":@"",
                                               @"userId":user.userId,
                                               @"accountType":@"3",
                                               @"cityCode":_cityCode}
                                     };
    
            __weak typeof(self) weakSelf = self;
            [MHNetworkManager postReqeustWithURL:kZhiKe params:params successBlock:^(id returnData) {
    
                delegate.isThird=NO;
                if ([returnData[@"state"] isEqualToString:@"0"]) {
                    NSString *url = [returnData[@"data"] valueForKey:@"retPage"];
                    NSString *baseId = [returnData[@"data"] valueForKey:@"baseId"];
                    [weakSelf createOrderWithBaseId:baseId pushUrl:url];
                }else{
                    [MBProgressHUD showMessag:returnData[@"msg"] toView:weakSelf.view];
                }
                
            } failureBlock:^(NSError *error) {
                delegate.isThird=NO;
                
            } showHUD:YES];
}

- (void)createOrderWithBaseId:(NSString *)baseId pushUrl:(NSString *)url{
    
    NSDictionary *params = @{@"baseId":baseId,
                             @"userId":[[SingleHandle shareSingleHandle] getUserInfo].userId,
                             @"custName":_tfName.text,
                             @"phoneNo":_tfPhone.text,
                             @"licenseNo":_tfLicenseNo.text,
                             @"cityCode":_cityCode};
    
    __weak typeof(self) weakSelf = self;
    [MHNetworkManager postReqeustWithURL:[RequestEntity urlString:ksaveOrder] params:params successBlock:^(id returnData) {
        
        if ([[returnData objectForKey:@"flag"] isEqualToString:@"success"]) {
            OrderH5ViewController *orderH5VC = [[OrderH5ViewController alloc] init];
            orderH5VC.url = url;
            [weakSelf.navigationController pushViewController:orderH5VC animated:YES];
        }else {
            [MBProgressHUD showMessag:[returnData objectForKey:@"msg"] toView:weakSelf.view];
        }
        
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}
- (IBAction)newCarAction:(id)sender {
    if (self.isNewCarBtn.selected)
    {
        [[FireData sharedInstance] eventWithCategory:@"创建订单" action:@"不是新车" evar:nil attributes:nil];
        [self.isNewCarBtn setImage:[UIImage imageNamed:@"checkbox"] forState:(UIControlStateNormal)];
        self.tfLicenseNo.enabled = YES;
        self.tfLicenseNo.text = @"";
        self.tfLicenseNo.placeholder = @"请输入车牌号";
    }else
    {
        [[FireData sharedInstance] eventWithCategory:@"创建订单" action:@"新车" evar:nil attributes:nil];
        [self.isNewCarBtn setImage:[UIImage imageNamed:@"checkbox_"] forState:(UIControlStateNormal)];
        self.tfLicenseNo.enabled = NO;
        self.tfLicenseNo.text = @"新车";
    }
    self.isNewCarBtn.selected = !self.isNewCarBtn.selected;
    
}
- (IBAction)showCityPickerView:(id)sender {
    [[FireData sharedInstance] eventWithCategory:@"创建订单" action:@"选择行驶省市" evar:nil attributes:nil];
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
    if ([textField isEqual:self.tfPhone]) {
        if (![self.tfPhone.text isEqualToString:@""] && ![HelperUtil checkTelNumber:self.tfPhone.text]){
            [MBProgressHUD showMessag:@"手机号格式不正确" toView:self.view];
            return ;
        }
    }
    
    if ([textField isEqual:self.tfLicenseNo]) {
        self.tfLicenseNo.text = [self.tfLicenseNo.text uppercaseString];
        if (![self.tfLicenseNo.text isEqualToString:@""] && ![HelperUtil validateCarNo:self.tfLicenseNo.text]){
            [MBProgressHUD showMessag:@"车牌号格式不正确" toView:self.view];
            return ;
        }
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.title=@"创建订单";

}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // segue.identifier：获取连线的ID
    if ([segue.identifier isEqualToString:@"oldOrderInfo"]) {
        
        // segue.destinationViewController：获取连线时所指的界面（VC）
        OrderInfoViewController *orderVC = segue.destinationViewController;
        orderVC.order = _order;
        
        
    }
}

#pragma alertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex NS_DEPRECATED_IOS(2_0, 9_0){
    if(buttonIndex == 0){
        AYCLog(@"找原单");
        
        [self performSegueWithIdentifier:@"oldOrderInfo" sender:self];
    }else {
       
        AYCLog(@"新建");
         [self linkZhiKe];
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
