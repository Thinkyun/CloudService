//
//  SetUserInfoViewController.m
//  CloudService
//
//  Created by zhangqiang on 16/2/23.
//  Copyright © 2016年 zhangqiang. All rights reserved.
//

#import "SetUserInfoViewController.h"
#import "SetUserInfoCell.h"
#import "SetUserInfoHeaderView.h"
#import "HZQDatePickerView.h"
#import "HelperUtil.h"
#import "DataSource.h"
#import "Utility.h"
#import "LoginViewController.h"
#import "CodeNameModel.h"
#import "ResetPhonePopView.h"
#import "SetUserInfoCell2.h"
#import "PellTableViewSelect.h"
#import "ChooseCompanyViewController.h"
#import "CityPickerView.h"
#import "ProvinceChooseViewController.h"

static NSString *const cell_id = @"setUserInfoCell";
static NSString *const cell_Id2 = @"setUserInfoCell2";
static NSString *const header_id = @"setUserInfoHeader";
static CGFloat headerHeight = 30;
static NSString *const select_CellID = @"selectCell";

@interface SetUserInfoViewController ()<SetUserInfoCell2Delegate,SetUserInfoCellDelegate,HZQDatePickerViewDelegate,UITableViewDelegate,UITableViewDataSource>
{
    NSArray *_keyArray_User;
    NSArray *_keyArray_Bank;
    NSMutableArray *_valueArray_User;   // 需要填写的个人信息
    NSMutableArray *_valueArray_Bank;   // 需要填写的银行信息
    NSMutableArray *_companyArray;      // 申请销售数据公司,数据处理数组
    NSMutableArray *_saleCityArray;     // 销售城市数据处理数组
    
    NSIndexPath *_indexPath;            // 正在编辑某一Cell的Indexpath
    
}

@property (weak, nonatomic) IBOutlet UIButton *rightBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic,strong) NSArray *selectArray;               // 下拉框数据存储数组,多套数据公用一个数组
@property (nonatomic,strong)HZQDatePickerView *pickerView;      // 城市选择

@end

@implementation SetUserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupTableView];
    [self initData];
    self.title = @"个人信息";
    if (self.notEnable) {
        [self.rightBtn setTitle:@"修改" forState:(UIControlStateNormal)];
        return;
    }
    if (self.rightBtnTitle) {
        [self.rightBtn setTitle:self.rightBtnTitle forState:(UIControlStateNormal)];
    }else {
        [self.rightBtn setTitle:@"提交" forState:(UIControlStateNormal)];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
}

-(void)setSelectArray:(NSArray *)selectArray {
    
    if (_selectArray != selectArray) {
        _selectArray = [selectArray copy];
    }
}

- (IBAction)saveAction:(id)sender {
    
    [[FireData sharedInstance] eventWithCategory:@"个人信息" action:@"保存" evar:nil attributes:nil];

    // 编辑
    if (self.notEnable) {
        self.notEnable = NO;
        if (self.rightBtnTitle) {
            [self.rightBtn setTitle:self.rightBtnTitle forState:(UIControlStateNormal)];
        }else {
            [self.rightBtn setTitle:@"提交" forState:(UIControlStateNormal)];
        }
        [self.tableView reloadData];
        return;
    }
    [HelperUtil resignKeyBoardInView:self.view];
    NSDictionary *dict = [self getParam];
    if (!dict) {
        return ;
    }
    //保存填写的用户信息
    [self saveUserInfo:dict];
    
    __weak typeof(self) weakSelf = self;
    [MHNetworkManager postReqeustWithURL:[RequestEntity urlString:kResetUserInfoAPI] params:dict successBlock:^(id returnData) {
        
        if ([[returnData valueForKey:@"flag"] isEqualToString:@"success"]) {
            
            if ([weakSelf.rightBtn.titleLabel.text isEqualToString:@"提交"]) {
                
                [MBProgressHUD showMessag:@"提交成功,一个小时后生效" toView:nil];
            }else {
                [MBProgressHUD showMessag:@"修改成功" toView:nil];
            }
            UIViewController *VC = [weakSelf.navigationController.viewControllers firstObject];
            if ([[VC class] isSubclassOfClass:[LoginViewController class]]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:LoginToMenuViewNotice object:nil];
                return ;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:ReloadHomeData object:nil];

            [weakSelf.navigationController popToRootViewControllerAnimated:YES];
        }else {
            [MBProgressHUD showMessag:[returnData valueForKey:@"msg"] toView:self.view];
        }
        
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
    
}

// 设置tableView样式
- (void)setupTableView {
    
    self.title = @"填写个人资料";
    __weak typeof(self) weakSelf = self;
    [self setLeftImageBarButtonItemWithFrame:CGRectMake(0, 0, 30, 30) image:@"title-back" selectImage:@"" action:^(AYCButton *button) {
        
        [[FireData sharedInstance] eventWithCategory:@"个人信息" action:@"返回" evar:nil attributes:nil];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SetUserInfoCell" bundle:nil] forCellReuseIdentifier:cell_id];
    [self.tableView registerNib:[UINib nibWithNibName:@"SetUserInfoCell2" bundle:nil] forCellReuseIdentifier:cell_Id2];
    [self.tableView registerClass:[SetUserInfoHeaderView class] forHeaderFooterViewReuseIdentifier:header_id];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardDidHidden) name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView) name:ChooseSaleCompany object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadSaleCity) name:ChooseSaleCity object:nil];
}

- (void)initData {
    
    _keyArray_User = @[@"真实姓名",
                       @"证件号码",@"用户类型",
                       @"原离职公司",@"原职位",
                       @"现任公司",
                       @"从业时间",
                       @"微信号",@"申请销售保险公司",
                       @"销售数据城市"];
    
    _keyArray_Bank = @[@"开户人姓名",@"银行账号",
                       @"开户银行",@"支行名称",
                       @"开户省份",@"开户城市"];
    
    _valueArray_User = [NSMutableArray arrayWithArray:@[@"",@"",@"",@"",@"",@"",@"",@"",@""]];
    User *user = [[SingleHandle shareSingleHandle] getUserInfo];
    _valueArray_User[0] = user.realName;
    _valueArray_User[1] = user.idCard;
    _valueArray_User[2] = user.roleName.length <= 0 ? @"普通用户" : user.roleName;
    
    _valueArray_User[3] = [DataSource changeCompanyCodeToText:user.oldCompany];
    _valueArray_User[4] = user.oldPost.length > 0 ? user.oldPost : @"";
    _valueArray_User[5] = user.currentCompany.length >0 ? user.currentCompany : @"";
    NSString *workDate = user.workStartDate.length > 0 ? [HelperUtil timeFormat:user.workStartDate format:@"yyyy-MM-dd"] : @"";
    _valueArray_User[6] = workDate;
    _valueArray_User[7] = user.chatName;
    // 编码汉字
    _valueArray_User[8] = [DataSource changeSaleCompanyWithCodeString:user.applySaleCompany];
    _valueArray_User[9] = user.saleCityValue;
    
    _valueArray_Bank = [NSMutableArray arrayWithArray:@[@"",@"",@"",@"",@"",@""]];
    _valueArray_Bank[0] = user.bankAccountName;
    _valueArray_Bank[1] = user.bankNum;
    _valueArray_Bank[2] = user.bankName;
    _valueArray_Bank[3] = user.subbranchName;
    _valueArray_Bank[4] = user.accountProvinces;
    _valueArray_Bank[5] = user.accountCity;
    
    _companyArray = [NSMutableArray array];
    int i = 0;
    for (NSString *companyCode in [DataSource changeSaleCompanyWithString:user.applySaleCompany]) {
        CodeNameModel *model = [[CodeNameModel alloc] init];
        model.companyName = [DataSource changeCompanyCodeToText:companyCode];
        model.companyCode = companyCode;
        [_companyArray addObject:model];
    }
    _saleCityArray = [NSMutableArray array];
    i = 0;
    // saleCityValue 是城市名,不是编码,对应后台传了saleCity编码
    for (NSString *provinceName in [DataSource changeSaleCompanyWithString:user.saleCityValue]) {
        CodeNameModel *model = [[CodeNameModel alloc] init];
        model.provinceName = provinceName;
        
        AYCLog(@"%@",[DataSource provinceArray]);
        for (NSDictionary *dic in [DataSource provinceArray]) {
            if ([[dic objectForKey:@"provinceName"] isEqualToString:provinceName]) {
                model.provinceCode = [dic objectForKey:@"provinceId"];
            }
        }
//        model.provinceCode = [[DataSource provinceArray] valueForKey:provinceName];
        [_saleCityArray addObject:model];
        i ++;
    }
}
    
- (void)reloadTableView {
    _valueArray_User[_indexPath.row] = [self changeStrArraytoTextString:_companyArray];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:_indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)reloadSaleCity {
    AYCLog(@"%@",_saleCityArray);
    _valueArray_User[_indexPath.row] = [self changeStrArraytoTextString:_saleCityArray];

    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:_indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
    
}

#pragma mark -- HZQDatePickerViewDelegate
- (void)getSelectDate:(NSDate *)date type:(DateType)type {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *currentOlderOneDateStr = [dateFormatter stringFromDate:date];
    _valueArray_User[_indexPath.row] = currentOlderOneDateStr;
    [self.tableView reloadData];
    _pickerView = nil;
}

#pragma mark -- SetUserInfoCell2Delegate
-(void)didDeleteTextForCompany:(SetUserInfoCell2 *)cell {
    [HelperUtil resignKeyBoardInView:self.view];
    _indexPath = [self.tableView indexPathForCell:cell];
    if (_indexPath.row == 7)
    {
        [_companyArray removeAllObjects];
    }
    else if(_indexPath.row == 8)
    {
        [_saleCityArray removeAllObjects];
    }
    _valueArray_User[_indexPath.row] = @"";
    [self.tableView reloadData];
}

#pragma mark -- SetUserInfoCellDelegate
// 确定编辑在哪个cell上
-(void)textFiledShouldBeginEditAtCell:(SetUserInfoCell *)cell {
    
    _indexPath = [self.tableView indexPathForCell:cell];
    
}

-(void)textFiledDidEndEdit:(NSString *)text {
    
    if (_indexPath.section == 0) {
        _valueArray_User[_indexPath.row] = text;
        if (_indexPath.row == 1) {
            if (![HelperUtil checkUserIdCard:_valueArray_User[1]]) {
                [MBProgressHUD showMessag:@"身份证号输入不正确" toView:self.view];
                return ;
            }
        }
    }else {
        _valueArray_Bank[_indexPath.row] = text;
    }
    if (_indexPath.section == 1 && (_indexPath.row == 1)) {
        if (![HelperUtil checkBankCard:text]) {
            [MBProgressHUD showMessag:@"你输入的银行卡号无效,请重新输入" toView:self.view];
        }else {
            NSString *bankBin = [text substringToIndex:6];
            if ([self getBankNameWithBankbin:bankBin].length <= 0) {
                [MBProgressHUD showMessag:@"查不到你的银行卡信息,请手动输入开户银行" toView:self.view];
            }else {
                _valueArray_Bank[2] = [self getBankNameWithBankbin:bankBin];
            }
        }
        _valueArray_Bank[_indexPath.row] = text;
        
    }
    _indexPath = nil;
}

#pragma mark -- UITableViewDelegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [HelperUtil resignKeyBoardInView:self.view];
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([tableView isEqual:self.tableView]) {
        return 2;
    }else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (section == 0) {
        return _valueArray_User.count;
    }else {
        return 6;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BOOL isCell2 = (indexPath.row == 3 || indexPath.row == 4 || indexPath.row == 8 || indexPath.row == 9) ? 1 : 0;
    // 个人信息,带下拉框
    if (indexPath.section == 0 && isCell2) {

        SetUserInfoCell2 *cell2 = [tableView dequeueReusableCellWithIdentifier:cell_Id2 ];
        if (cell2 == nil) {
            cell2 = [[SetUserInfoCell2 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_Id2];
        }
        cell2.titleLabelWidth.constant = 80;
        cell2.titleLabel.text = _keyArray_User[indexPath.row];
        cell2.delegate = self;
        cell2.contentLabel.text = _valueArray_User[indexPath.row];
        [cell2 isPullDown:NO];
            
        if (self.notEnable) {
            if(indexPath.row == 9 || indexPath.row == 8) {
                cell2.titleLabelWidth.constant = 120;
            }
            return cell2;
        }
        [cell2 isPullDown:YES];
        if (indexPath.row == 9) {
            cell2.titleLabelWidth.constant = 120;
            if (cell2.contentLabel.text.length > 0) {
                [cell2 setDeleteImage:NO];
            }else{
                [cell2 setDeleteImage:NO];
            }
        }
        if (indexPath.row == 8) {
            cell2.titleLabelWidth.constant = 120;
            cell2.imgView.image = [UIImage imageNamed:@"details-arrow1"];
        }
        return cell2;
    }
    // 个人信息，不带下拉框
    SetUserInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
    if (cell == nil) {
        cell = [[SetUserInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
    }
    cell.label.text = indexPath.section == 0 ? _keyArray_User[indexPath.row] : _keyArray_Bank[indexPath.row];
    cell.textFiled.text = indexPath.section == 0 ? _valueArray_User[indexPath.row] : _valueArray_Bank[indexPath.row];
    cell.delegate = self;
    cell.textFiled.enabled = YES;
    cell.textFiled.keyboardType = UIKeyboardTypeDefault;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self];
    if (self.notEnable) {
        cell.textFiled.enabled = NO;
        return cell;
    }
    
    if (indexPath.section == 0) {
        if (indexPath.row == 1) {
            cell.textFiled.keyboardType = UIKeyboardTypeDefault;
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(carUserCardChanged:) name:UITextFieldTextDidChangeNotification object:cell.textFiled];
        }else if(indexPath.row == 2 || indexPath.row == 6)
        {
            cell.textFiled.enabled = NO;
        }
    }
    
//  银行信息
    if (indexPath.section == 1)
    {
        if(indexPath.row == 1){
            cell.textFiled.keyboardType = UIKeyboardTypePhonePad;
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bankCardChanged:) name:UITextFieldTextDidChangeNotification object:cell.textFiled];
        }
        if (indexPath.row == 4 || indexPath.row == 5)
        {
            cell.textFiled.enabled = NO;
        }
    }
    return cell;
}

- (void)carUserCardChanged:(NSNotification *)sender {
    UITextField *tfUserCard = (UITextField *)sender.object;
        if (tfUserCard.text.length >=18) {
        tfUserCard.text = [tfUserCard.text substringToIndex:18];
    }
}
- (void)bankCardChanged:(NSNotification *)sender {
    UITextField *tfUserCard = (UITextField *)sender.object;
    if (tfUserCard.text.length >=21) {
        tfUserCard.text = [tfUserCard.text substringToIndex:21];
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.notEnable) {
        return ;
    }
    [HelperUtil resignKeyBoardInView:self.view];
    _indexPath = indexPath;
    BOOL isCell2 = (indexPath.section == 0) && (indexPath.row == 3 || indexPath.row == 4 || indexPath.row == 8 || indexPath.row == 9) ? 1 : 0;
    CGRect tempRect = CGRectZero;
    CGRect cellFrame = CGRectZero;
    if (!isCell2 || indexPath.section == 1) {
        SetUserInfoCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        tempRect = [cell.contentView convertRect:cell.textFiled.frame fromView:self.view];
        cellFrame = cell.frame;
    }else {
        SetUserInfoCell2 *cell = [tableView cellForRowAtIndexPath:indexPath];
        tempRect = [cell.contentView convertRect:cell.contentLabel.frame fromView:self.view];
        cellFrame = cell.frame;
    }
    if (indexPath.section == 0)
    {
        switch (indexPath.row)
        {
            case 3:{
                        _selectArray = [DataSource insureCommpanyNameArray];
                        CGRect rect3 = CGRectMake(tempRect.origin.x, CGRectGetMaxY(cellFrame) - self.tableView.contentOffset.y + 64, tempRect.size.width, 4 * 40);
//                        [self showPullDownViewWithRect:rect3];
                
                [[FireData sharedInstance] eventWithCategory:@"个人信息" action:@"原离职公司" evar:nil attributes:nil];
                
                        __weak typeof(self) weakSelf = self;
                        [PellTableViewSelect addPellTableViewSelectWithWindowFrame:rect3 selectData:_selectArray action:^(NSInteger index) {
                            _valueArray_User[_indexPath.row] = _selectArray[index];
                            [weakSelf.tableView reloadData];
                        } animated:YES];
                    }
                        break;
            case 6:
                
                [[FireData sharedInstance] eventWithCategory:@"个人信息" action:@"从业时间" evar:nil attributes:nil];
                        [self showDataPickerView];
                        break;
            case 4:{
                        _selectArray = @[@"销售职",@"销售管理职",@"其他"];
                        CGRect rect4 = CGRectMake(tempRect.origin.x, CGRectGetMaxY(cellFrame) - self.tableView.contentOffset.y + 64, tempRect.size.width, 3 * 40);

                __weak typeof(self) weakSelf = self;
                [[FireData sharedInstance] eventWithCategory:@"个人信息" action:@"原职位" evar:nil attributes:nil];
                            [PellTableViewSelect addPellTableViewSelectWithWindowFrame:rect4 selectData:_selectArray action:^(NSInteger index) {
                                _valueArray_User[_indexPath.row] = _selectArray[index];
                                [weakSelf.tableView reloadData];
                            } animated:YES];
                    }
                        break;
            case 8:{
                
                ChooseCompanyViewController *chooseVC = [[ChooseCompanyViewController alloc] init];
                chooseVC.type = chooseCompany;
                chooseVC.selectArray = _companyArray;
                for (CodeNameModel *code in _companyArray) {
                    NSLog(@"--------selectArray-------------%@",code.companyName);
                }
                chooseVC.dataArray = [NSMutableArray arrayWithArray:[self getChooseDataArray]];
                
                [[FireData sharedInstance] eventWithCategory:@"个人信息" action:@"申请销售保险公司" evar:nil attributes:nil];
                [self.navigationController pushViewController:chooseVC animated:YES];
                
                        break;
                    }
            case 9:{
                ChooseCompanyViewController *chooseVC = [[ChooseCompanyViewController alloc] init];
                chooseVC.type = chooseCity;
                chooseVC.selectArray = _saleCityArray;
                
                chooseVC.dataArray = [NSMutableArray arrayWithArray:[self getChooseCityArray]];
                
                [[FireData sharedInstance] eventWithCategory:@"个人信息" action:@"销售数据城市" evar:nil attributes:nil];
                [self.navigationController pushViewController:chooseVC animated:YES];
//                [[FireData sharedInstance] eventWithCategory:@"个人信息" action:@"销售数据城市" evar:nil attributes:nil];
//                [self showCityPickerViewWithCount:1];
                //                [self performSegueWithIdentifier:@"selectCity" sender:self];
                break;
            }
 
            default:
                break;
        }
    }
    if (indexPath.section == 1) {
        if (indexPath.row == 4 || indexPath.row == 5)
        {
            [[FireData sharedInstance] eventWithCategory:@"个人信息" action:@"开户城市" evar:nil attributes:nil];
//            [self showCityPickerViewWithCount:2];
            
            __weak typeof(self) weakSelf = self;
            NSString *location = [Utility location];
            ProvinceChooseViewController *provinceVC = [ProvinceChooseViewController new];
            provinceVC.title = @"开户城市";
                provinceVC.isHidenLocation = YES;
            if (location) {
                provinceVC.locationCity = location;
            }else{
                provinceVC.locationCity = @"获取不到定位信息";
            }
            provinceVC.proviceList = [self proviceList];
            provinceVC.popBlock = ^(NSString *str){
//                [weakSelf.locateBtn setTitle:str forState:(UIControlStateNormal)];
                
            };
            provinceVC.cityblock = ^(UIViewController *VC,NSString *county,NSString *city,NSString *province,NSString *code){
                __strong typeof(self) strongSelf = weakSelf;
                strongSelf->_valueArray_Bank[4] = province;
                strongSelf->_valueArray_Bank[5] = [NSString stringWithFormat:@"%@ %@",city,county];
                [VC.navigationController popToViewController:weakSelf animated:YES];
                [weakSelf.tableView reloadData];
            };
            [self.navigationController pushViewController:provinceVC animated:YES];
            
        }
       
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    SetUserInfoHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:header_id];
    headerView.titleLabel.text = section == 0 ? @"个人信息" : @"银行信息";
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0 && indexPath.row == 7) {
        return 50;
    }else {
        return 50;
    }
}

- (CGFloat )tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

    return headerHeight;
}

#pragma mark -- 私有方法
- (NSDictionary *)getParam {
    
    if ([_valueArray_User[3] length] <= 0 && [_valueArray_User[5] length] <= 0) {
        [MBProgressHUD showMessag:[NSString stringWithFormat:@"原离职公司或现任公司至少填写一个"] toView:self.view];
        return nil;
    }
    if ([_valueArray_User[3] length] >0) {
        if ([_valueArray_User[4] length] <=0 ) {
            [MBProgressHUD showMessag:[NSString stringWithFormat:@"%@不能为空",_keyArray_User[4]] toView:self.view];
            return nil;
        }
    }
    
    for (int i = 0; i < _valueArray_User.count; i ++) {
        
        if ([_valueArray_User[i] length] <= 0) {
            if (i != 3 ) {
                if (i != 5) {
                    [MBProgressHUD showMessag:[NSString stringWithFormat:@"%@不能为空",_keyArray_User[i]] toView:self.view];
                    return nil;
                }
                
            }
            
        }
    }
    
//    for (int i = 0; i < _valueArray_Bank.count; i ++) {
//        if ([_valueArray_Bank[i] length] <= 0) {
//            [MBProgressHUD showMessag:[NSString stringWithFormat:@"%@不能为空",_keyArray_Bank[i]] toView:self.view];
//            return nil;
//        }
//    }
    
    if (![HelperUtil checkUserIdCard:_valueArray_User[1]]) {
        [MBProgressHUD showMessag:@"身份证号输入不正确" toView:self.view];
        return nil;
    }
    User *user = [[SingleHandle shareSingleHandle] getUserInfo];
    NSString *idCord = _valueArray_User[1];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:user.userId forKey:@"userId"];
    [dict setValue:user.userName forKey:@"userName"];
    [dict setValue:user.phoneNo forKey:@"phoneNo"];
    [dict setValue:[HelperUtil getSexWithIdcord:idCord] forKey:@"sex"];
    [dict setValue:[HelperUtil getBorthDayWithIdCord:idCord] forKey:@"age"];
    [dict setValue:_valueArray_User[0] forKey:@"realName"];
    [dict setValue:_valueArray_User[4] forKey:@"oldPost"];
    [dict setValue:_valueArray_User[5] forKey:@"currentCompany"];
    [dict setValue:_valueArray_User[6] forKey:@"workStartDate"];
    [dict setValue:_valueArray_User[7] forKey:@"chatName"];
//
    if ([_valueArray_User[3] length] >0) {
        [dict setValue:[DataSource changeCompanyTextToCode:_valueArray_User[3]] forKey:@"oldCompany"];

    }
    
    NSString *saleCity = _saleCityArray.count > 0 ? [self changeStrArraytoCodeString:_saleCityArray] : user.saleCity;
    [dict setValue:saleCity forKey:@"saleCity"];
    [dict setValue:[self changeStrArraytoCodeString:_companyArray] forKey:@"applySaleCompany"];
    [dict setValue:idCord forKey:@"idCard"];

    // 银行信息
    [dict setValue:_valueArray_Bank[0] forKey:@"bankAccountName"];
    [dict setValue:_valueArray_Bank[2] forKey:@"bankName"];
    [dict setValue:_valueArray_Bank[1] forKey:@"bankNum"];
    [dict setValue:_valueArray_Bank[3] forKey:@"subbranchName"];
    [dict setValue:_valueArray_Bank[4] forKey:@"accountProvinces"];
    [dict setValue:_valueArray_Bank[5] forKey:@"accountCity"];
    
    return dict;
}


/**
 *  获取未选中的销售公司
 */
- (NSArray *)getChooseDataArray {
    
    NSMutableArray *dataArray = [NSMutableArray array];
    for (NSString *companyName in [DataSource insureCommpanyNameArray]) {
        
        if ([_valueArray_User[8] containsString:companyName]) {
            continue;
        }
        CodeNameModel *model = [[CodeNameModel alloc] init];
        model.companyCode = [DataSource changeCompanyTextToCode:companyName];
        model.companyName = companyName;
        [dataArray addObject:model];
    }
    return dataArray;
}

/**
 *  获取未选中的销售城市
 */
- (NSArray *)getChooseCityArray {
    
    NSMutableArray *dataArray = [NSMutableArray array];
    for (NSDictionary *provinceDic in [DataSource provinceArray]) {
        
        if ([_valueArray_User[9] containsString:[provinceDic valueForKey:@"provinceName"]]) {
            continue;
        }
        CodeNameModel *model = [[CodeNameModel alloc] init];
        model.provinceCode = [provinceDic valueForKey:@"provinceId"];
        model.provinceName = [provinceDic valueForKey:@"provinceName"];
        [dataArray addObject:model];
    }
    return dataArray;
}

// 二分查找卡户银行
- (NSString *)getBankNameWithBankbin:(NSString *)bankBin {
    
    NSArray *bankBinArray = [DataSource bankBin];
    NSArray *bankNameArray = [DataSource bankNameArray];
    int low = 0;
    int high = (int)(bankBinArray.count-1);
    while(low <= high)
    {
        int middle = (low + high) / 2;
        if([bankBin isEqualToString:bankBinArray[middle]])
        {
            return bankNameArray[middle];
        }
        else if([bankBin compare:bankBinArray[middle]] == NSOrderedAscending)
        {
            high = middle - 1;
        }
        else
        {
            low = middle + 1;
        }
    }
    return nil;
}

- (void)showCityPickerViewWithCount:(NSInteger )count {
    
    [HelperUtil resignKeyBoardInView:self.view];
    __block CityPickerView *cityPickerView = [[CityPickerView alloc] initWithCount:count];
    
    __weak typeof(self) weakSelf = self;
    [cityPickerView showPickViewAnimated:^(NSString *province, NSString *city) {
        _valueArray_Bank[4] = province;
        _valueArray_Bank[5] = city;
        [weakSelf.tableView reloadData];
        cityPickerView = nil;
    }];
   
    
}

/**
 *  时间选择
 */
- (void)showDataPickerView {
    
    _pickerView = [HZQDatePickerView instanceDatePickerView];
    [_pickerView.datePickerView setMaximumDate:[NSDate date]];
    [_pickerView showDateViewWithDelegate:self];
    
}



// 填写银行卡号后,自动显示银行卡信息
- (void)keyBoardDidHidden {
    if ([_valueArray_Bank[2] length] <= 0) {
        return;
    }
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

// 通过数组模型得到城市或公司字符串
- (NSString *)changeStrArraytoTextString:(NSArray *)array {
    
    if (array.count <= 0) {
        return @"";
    }
    NSMutableString *resultStr = [NSMutableString string];
    for (CodeNameModel *model in array) {
        if (model.provinceName.length > 0)
        {
            [resultStr appendString:model.provinceName];
        }else
        {
            [resultStr appendString:model.companyName];
        }
        [resultStr appendString:@","];
    }
    return [resultStr substringToIndex:resultStr.length - 1];
}

// 通过数组模型得到城市或公司编码
- (NSString *)changeStrArraytoCodeString:(NSArray *)array {
    
    if (array.count <= 0) {
        return @"";
    }
    NSMutableString *resultStr = [NSMutableString string];
    for (CodeNameModel *model in array) {
        if (model.provinceName.length > 0)
        {
            
            if (model.provinceCode.length>0) {
                [resultStr appendString:model.provinceCode];
            }else{
                [MBProgressHUD showMessag:@"当前城市未上线" toView:nil];
            }
        }else
        {
            if (model.companyCode.length>0) {
                [resultStr appendString:model.companyCode];
            }else{
                [MBProgressHUD showMessag:@"当前城市未上线" toView:nil];
            }
        }
        [resultStr appendString:@","];
    }
    return [resultStr substringToIndex:resultStr.length - 1];
}

// 提交后保存用户信息到本地
- (void)saveUserInfo:(NSDictionary *)dict {
    User *user = [[SingleHandle shareSingleHandle] getUserInfo];
    [user setValuesForKeysWithDictionary:dict];
    user.workStartDate = [HelperUtil getDateWithDateStr:user.workStartDate dateFormatter:@"yyyy-MM-dd"];
    user.saleCityValue = [self changeStrArraytoTextString:_saleCityArray];
    [[SingleHandle shareSingleHandle] saveUserInfo:user];
}

- (NSMutableArray *)proviceList{
    NSMutableArray *_proviceList = [NSMutableArray array];
    
    NSString *path =[[NSString alloc]initWithString:[[NSBundle mainBundle] pathForResource:@"province"ofType:@"plist"]];
    
    NSDictionary *rootDic = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSDictionary *provinceDic = [rootDic valueForKey:@"root"];
    _proviceList = [provinceDic valueForKey:@"province"];
    
    return _proviceList;
}

/*
 [[SingleHandle shareSingleHandle] saveUserInfo:user];
 user.realName = _valueArray_User[0];
 user.workStartDate = _valueArray_User[5];
 user.oldPost = _valueArray_User[4];
 user.oldCompany = _valueArray_User[3];
 user.saleCityValue =   _valueArray_User[8];
 if (_saleCityArray.count > 0) {
 user.saleCity = [self changeStrArraytoCodeString:_saleCityArray];
 }
 user.chatName  = _valueArray_User[6];
 if (_companyArray.count > 0) {
 // 用户显示汉字
 user.applySaleCompany = [self changeStrArraytoTextString:_companyArray];
 }
 user.bankAccountName = _valueArray_Bank[0];
 user.bankNum = _valueArray_Bank[1];
 user.bankName = _valueArray_Bank[2];
 user.subbranchName = _valueArray_Bank[3];
 user.accountProvinces = _valueArray_Bank[4];
 user.accountCity = _valueArray_Bank[5];

 */

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
