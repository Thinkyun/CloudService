//
//  CreatOrderViewController.m
//  CloudService
//
//  Created by 安永超 on 16/2/24.
//  Copyright © 2016年 zhangqiang. All rights reserved.
//

#import "CreatOrderViewController.h"
#import "ProvinceChooseViewController.h"
#import "ZQCityPickerView.h"
#import "AppDelegate.h"
#import "OrderH5ViewController.h"
#import "ButelHandle.h"
#import "Order.h"
#import "OrderInfoViewController.h"
#import "DataSource.h"
#import "EYPopupViewHeader.h"
#import <FMDB.h>
#import "MyFile.h"

// baseId 25961588
@interface CreatOrderViewController ()<UITextFieldDelegate>
{
    NSString *_cityCode;
    Order *_order;
}
@property (weak, nonatomic) IBOutlet UIButton *provinceBtn;
@property (weak, nonatomic)IBOutlet UITextField *tfName;
@property (weak, nonatomic)IBOutlet UITextField *tfPhone;
@property (weak, nonatomic)IBOutlet UITextField *tfLicenseNo;
@property (weak, nonatomic)IBOutlet UITextField *tfCarCity;
@property (weak, nonatomic)IBOutlet UIButton *isNewCarBtn;

@end

@implementation CreatOrderViewController

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.title=@"创建订单";
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
    self.tfLicenseNo.delegate = self;
    self.tfLicenseNo.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;

    [weakSelf setLeftImageBarButtonItemWithFrame:CGRectMake(0, 0, 30, 30) image:@"title-back" selectImage:@"back" action:^(AYCButton *button) {
        [[FireData sharedInstance] eventWithCategory:@"创建订单" action:@"返回首页" evar:nil attributes:nil];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    


     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tfPhoneChanged:) name:UITextFieldTextDidChangeNotification object:self.tfPhone];
    // Do any additional setup after loading the view.
}

/**
 *  设置青牛拨打号码
 */
- (void)tfPhoneChanged:(NSNotification *)sender {
    if (self.tfPhone.text.length >= 11) {
        self.tfPhone.text = [self.tfPhone.text substringToIndex:11];
        [[ButelHandle shareButelHandle] setPhoneNo:_tfPhone.text phoneWithBaseId:@""];
        AYCLog(@"%@",_tfPhone);
    }
    
}
/**
 *  下一步报价
 */
- (IBAction)nextAction:(id)sender {

    if ([_tfName.text isEqualToString:@""]) {
        [MBProgressHUD showMessag:@"车主姓名不能为空" toView:self.view];
        return ;
    }
    if ([_tfPhone.text isEqualToString:@""]){
        [MBProgressHUD showMessag:@"车主手机号不能为空" toView:self.view];
        return ;
    }
    if (!self.isNewCarBtn.selected && [_tfLicenseNo.text isEqualToString:@""]){
        [MBProgressHUD showMessag:@"车牌号不能为空" toView:self.view];
        return ;
    }
    if ([_tfCarCity.text isEqualToString:@""]){
        [MBProgressHUD showMessag:@"汽车所在城市不能为空" toView:self.view];
        return ;
    }
    if (![HelperUtil checkName:_tfName.text]) {
        [MBProgressHUD showMessag:@"车主姓名不合法" toView:nil];
        return;
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
//                                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:msgStr delegate:self cancelButtonTitle:@"找原单" otherButtonTitles:@"新建", nil];
//                                    [alertView show];
                                    
                                    __weak typeof(self) weakSelf = self;
                                    [EYTextPopupView popViewWithTitle:@"温馨提示" contentText:msgStr
                                                      leftButtonTitle:EYLOCALSTRING(@"找原单")
                                                     rightButtonTitle:EYLOCALSTRING(@"新建")
                                                            leftBlock:^() {
                                                                 [weakSelf performSegueWithIdentifier:@"oldOrderInfo" sender:self];
                                                            }
                                                           rightBlock:^() {
                                                              [weakSelf linkZhiKe];
                                                           }
                                                         dismissBlock:^() {
                                                             
                                                         }];
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
    NSString *path = [MyFile fileLibraryPath:PROVINCE_LIMIT];
    NSArray *codeArray = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    BOOL limit = YES;
    if (_cityCode.length>0) {
        for (NSString *proviceId in codeArray) {
            
            if([_cityCode hasPrefix:proviceId]){
                limit = NO;
                break;
            }
        }
    }
    
    NSMutableDictionary *dict = [@{@"proportion":user.proportion,
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
                                  @"cityCode":_cityCode} mutableCopy];
    if (limit) {

        [dict setObject:user.phoneNo forKey:@"userPhoneNo"];
    }else{
        [dict setObject:@"" forKey:@"userPhoneNo"];
    }
            NSDictionary *params = @{@"operType":@"",
                                     @"msg":@"",
                                     @"sendTime":@"",
                                     @"sign":@"",
                                     @"data": dict
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
/**
 *  将获取到直客的数据传给后台
 *
 *  @param baseId 该订单号
 *  @param url    跳转至报价的URL
 */
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
            [[FireData sharedInstance] eventWithCategory:@"创建订单" action:@"直客报价" evar:@{@"url":url} attributes:nil];
            OrderH5ViewController *orderH5VC = [[OrderH5ViewController alloc] init];
            orderH5VC.url = url;
            [weakSelf.navigationController pushViewController:orderH5VC animated:YES];
        }else {
            [MBProgressHUD showMessag:[returnData objectForKey:@"msg"] toView:weakSelf.view];
        }
        
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

/**
 *  是否选择新车
 */
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
/**
 *  选择城市的pickerView
 */
- (IBAction)showCityPickerView:(id)sender {
    NSString *path =[[NSString alloc]initWithString:[[NSBundle mainBundle] pathForResource:@"province"ofType:@"plist"]];
    
    NSDictionary *rootDic = [NSDictionary dictionaryWithContentsOfFile:path];
    if (!rootDic) {
        [MBProgressHUD showMessag:@"获取省份列表失败，正在重新获取，请稍候！" toView:nil];
        /**
         *  获取省份列表
         *
         */
        
        [[SingleHandle shareSingleHandle] getAreas];
       
    }else{
        [[FireData sharedInstance] eventWithCategory:@"创建订单" action:@"选择行驶省市" evar:nil attributes:nil];
        [HelperUtil resignKeyBoardInView:self.view];
        
        __weak typeof(self) weakSelf = self;
        
//        __block ZQCityPickerView *cityPickerView = [[ZQCityPickerView alloc] initWithCount:2];
//        [cityPickerView showPickViewAnimated:^(NSString *province, NSString *city,NSString *cityCode,NSString *provinceCode,BOOL limit) {
//            weakSelf.tfCarCity.text = [NSString stringWithFormat:@"%@ %@",province,city];
//            _cityCode = cityCode;
//            cityPickerView = nil;
//        }];

        ProvinceChooseViewController *provinceVC = [ProvinceChooseViewController new];
        provinceVC.title = @"投保城市";
        provinceVC.isHidenLocation = YES;
        provinceVC.locationCity = @"";
        provinceVC.proviceList = [self proviceList];
        provinceVC.popBlock = ^(NSString *str){
            [weakSelf.provinceBtn setTitle:str forState:(UIControlStateNormal)];
        };
        provinceVC.cityblock = ^(UIViewController *VC,NSString *countyStr,NSString *city,NSString *province,NSString *code){
            __strong typeof(self) strongSelf = weakSelf;
            strongSelf->_cityCode = code;
            NSString *cityStr = (!countyStr&&(countyStr.length<=0))?[NSString stringWithFormat:@"%@ %@",province,city]:[NSString stringWithFormat:@"%@ %@ %@",province,city,countyStr];
            strongSelf->_tfCarCity.text = cityStr;
            [VC.navigationController popToViewController:weakSelf animated:YES];
        };
        [self.navigationController pushViewController:provinceVC animated:YES];

        
    }
}

/**
 *  textfiled结束编辑时判断格式是否正确
 */
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


/**
 *  storyboard即将跳转页面时传值
 *
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // segue.identifier：获取连线的ID
    if ([segue.identifier isEqualToString:@"oldOrderInfo"]) {
        
        // segue.destinationViewController：获取连线时所指的界面（VC）
        OrderInfoViewController *orderVC = segue.destinationViewController;
        orderVC.order = _order;
        
        
    }
}

#pragma alertView
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex NS_DEPRECATED_IOS(2_0, 9_0){
//    if(buttonIndex == 0){
//        AYCLog(@"找原单");
//        
//        [self performSegueWithIdentifier:@"oldOrderInfo" sender:self];
//    }else {
//       
//        AYCLog(@"新建");
//         [self linkZhiKe];
//    }
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)proviceList{
    NSMutableArray *proviceList = [NSMutableArray array];
    NSString *provincePath = [MyFile fileDocumentPath:PROVINCE_LIST];
    
    NSArray *provinceArray = [NSKeyedUnarchiver unarchiveObjectWithFile:provincePath];
    for (NSDictionary *dic in provinceArray) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        NSString *provinceName = dic[@"provinceName"];
        NSString *provinceCode = dic[@"provinceId"];
        NSDictionary *cityDic = [self cityListByProvinceCode:provinceCode];
        [dict setObject:provinceName forKey:@"name"];
        [dict setObject:cityDic forKey:@"city"];
        [proviceList addObject:dict];
    }
    
    return proviceList;
}

- (NSDictionary *)cityListByProvinceCode:(NSString *)code{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Province" ofType:@"sqlite"];
    FMDatabase *db = [FMDatabase databaseWithPath:path];
    if (![db open]) {
        AYCLog(@"数据库打开失败!");
        return nil;
    }
    NSString *sqlStr = [NSString stringWithFormat:@"SELECT * FROM t_se_city where parent = '%@' ORDER BY spelling_acronym",code];
    FMResultSet *result = [db executeQuery:sqlStr];
    NSMutableArray *_cityArray = [NSMutableArray array];
    NSMutableArray *_cityCodeArray = [NSMutableArray array];
    NSMutableArray *_countyArray = [NSMutableArray array];
    while ([result next]) {
        AYCLog(@"%@",[result stringForColumn:@"city"]);
        [_cityArray addObject:[result stringForColumn:@"city"]];
        [_cityCodeArray addObject:[result stringForColumn:@"org_id"]];
        [_countyArray addObject:[self countyByparentCode:[result stringForColumn:@"org_id"] FMDatabase:db]];
    }
    [dict setObject:_cityArray forKey:@"cityName"];
    [dict setObject:_cityCodeArray forKey:@"cityCode"];
    [dict setObject:_countyArray forKey:@"county"];
    return dict;

}

- (NSDictionary *)countyByparentCode:(NSString *)code FMDatabase:(FMDatabase *)db{
    NSMutableDictionary *mutableDic = [NSMutableDictionary dictionary];
    NSString *sqlStr = [NSString stringWithFormat:@"SELECT * FROM t_se_city where parent = '%@' ORDER BY spelling_acronym",code];
    FMResultSet *result = [db executeQuery:sqlStr];
    NSMutableArray *_cityArray = [NSMutableArray array];
    NSMutableArray *_cityCodeArray = [NSMutableArray array];
    while ([result next]) {
        AYCLog(@"%@",[result stringForColumn:@"city"]);
        NSString *cityName = [result stringForColumn:@"city"];
        NSString *cityCode = [result stringForColumn:@"org_id"];
        if (cityName&&(cityName.length>0)) {
            [_cityArray addObject:cityName];
            [_cityCodeArray addObject:cityCode];
        }
        
    }
    if (([_cityArray count]>0)&&([_cityCodeArray count]>0)) {
        [mutableDic setObject:_cityArray forKey:@"countyName"];
        [mutableDic setObject:_cityCodeArray forKey:@"countyCode"];
    }
    return mutableDic;
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
