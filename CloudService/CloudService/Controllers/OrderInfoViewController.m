//
//  OrderInfoViewController.m
//  CloudService
//
//  Created by 安永超 on 16/2/25.
//  Copyright © 2016年 zhangqiang. All rights reserved.
//

#import "OrderInfoViewController.h"
#import "OrderInfoTableViewCell.h"
#import "Order.h"
#import "AppointmentViewController.h"
#import "AppDelegate.h"
#import "OrderH5ViewController.h"
#import "ButelHandle.h"


@interface OrderInfoViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic,strong) UIView *footView;

@end

@implementation OrderInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /**
     *  显示青牛拨打页面,并设置手机号
     */
    [[ButelHandle shareButelHandle] showCallView];
    [[ButelHandle shareButelHandle] setPhoneNo:self.order.phoneNo];
    
    self.tableView.backgroundColor = [HelperUtil colorWithHexString:@"F4F4F4"];
    __weak typeof(self) weakSelf = self;
    [weakSelf setLeftImageBarButtonItemWithFrame:CGRectMake(0, 0, 35, 35) image:@"title-back" selectImage:@"back" action:^(AYCButton *button) {
      [[FireData sharedInstance] eventWithCategory:@"订单搜索" action:@"返回上一页" evar:nil attributes:nil];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.title=@"订单详情";
    
}

#pragma mark tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellId=@"cell";
    OrderInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"OrderInfoTableViewCell" owner:self options:nil];
        cell = [array objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.lbOrderNum.text = [NSString stringWithFormat:@"订单号:%@",self.order.baseId];
    cell.lbCustName.text = self.order.customerName;
    cell.lbPhoneNo.text = self.order.phoneNo;
    cell.lbLicenseNo.text = self.order.licenseNo;
    cell.lbEndCode.text = self.order.endCode;
    if ([self.order.comment isEqualToString:@""]) {
        cell.lbComment.text = @"暂无备注";
    }else{
        cell.lbComment.text = self.order.comment;
    }
    
    [cell.callBtn addTarget:self action:@selector(callClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.priceBtn addTarget:self action:@selector(priceClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.appointmentBtn addTarget:self action:@selector(appointmentClick:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 293;
}
/** 拨打电话*/
- (void)callClick:(UIButton *)sender {
    [[FireData sharedInstance] eventWithCategory:@"订单详情" action:@"拨打电话" evar:nil attributes:nil];
    [[ButelHandle shareButelHandle] popCallView];

}
/** 报价*/
- (void)priceClick:(UIButton *)sender {
    [[FireData sharedInstance] eventWithCategory:@"订单详情" action:@"报价按钮" evar:nil attributes:nil];

    OrderH5ViewController *orderH5VC = [[OrderH5ViewController alloc] init];
    orderH5VC.url = [NSString stringWithFormat:@"%@%@",kZhiKeInfo,self.order.baseId];
    NSLog(@"%@",[NSString stringWithFormat:@"%@%@",kZhiKeInfo,self.order.baseId]);
    [self.navigationController pushViewController:orderH5VC animated:YES];
//    User *user = [[SingleHandle shareSingleHandle] getUserInfo];
//    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
//    delegate.isThird=YES;
//    /**
//     *  dataType 01:创建订单,获取新数据 02:创建客户
//     */
//    NSDictionary *params = @{@"operType":@"",
//                             @"msg":@"",
//                             @"sendTime":@"",
//                             @"sign":@"",
//                             @"data":@{@"proportion":@"0.8",
//                                       @"customerName":self.order.customerName,
//                                       @"phoneNo":self.order.phoneNo,
//                                       @"dataType":@"01",
//                                       @"activeType":@"1",
//                                       @"macAdress":@"02:00:00:00:00:00",
//                                       @"agentCode":agentCode,
//                                       @"engineNo":self.order.engineNo,
//                                       @"vehicleFrameNo":self.order.frameNo,
//                                       @"licenseNo":self.order.licenseNo,
//                                       @"vehicleModelName":self.order.vehicleModelName,
//                                       @"userId":user.userId,
//                                       @"accountType":@"3",
//                                       @"cityCode":self.order.cityCode}
//                             };
//    
//    __weak typeof(self) weakSelf = self;
//    [MHNetworkManager postReqeustWithURL:kZhiKe params:params successBlock:^(id returnData) {
//        
//        delegate.isThird=NO;
//        if ([returnData[@"state"] isEqualToString:@"0"]) {
//            NSString *url = [returnData[@"data"] valueForKey:@"retPage"];
//            OrderH5ViewController *orderH5VC = [[OrderH5ViewController alloc] init];
//            orderH5VC.url = url;
//            [weakSelf.navigationController pushViewController:orderH5VC animated:YES];
//            
//        }else {
//            [MBProgressHUD showMessag:returnData[@"msg"] toView:self.view];
//        }
//        
//    } failureBlock:^(NSError *error) {
//        delegate.isThird=NO;
//        
//    } showHUD:YES];
}


/** 预约*/
- (void)appointmentClick:(UIButton *)sender {
    [[FireData sharedInstance] eventWithCategory:@"订单详情" action:@"预约按钮" evar:nil attributes:nil];
    [self performSegueWithIdentifier:@"appointment" sender:self];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // segue.identifier：获取连线的ID
    if ([segue.identifier isEqualToString:@"appointment"]) {
        // segue.destinationViewController：获取连线时所指的界面（VC）
        AppointmentViewController *receive = segue.destinationViewController;
        receive.customerId = self.order.customerId;
        receive.baseId = self.order.baseId;
    }
}

/** */
/** */
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
