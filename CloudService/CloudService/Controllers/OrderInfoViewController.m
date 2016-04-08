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
#import "EYPopupViewHeader.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>


@interface OrderInfoViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>
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
        if ([self.order.orderStatus isEqualToString:@"待支付"]) {
            cell = [array objectAtIndex:2];
        }else if ([self.order.orderStatus isEqualToString:@"已支付"]){
            cell = [array objectAtIndex:1];
        }else{
             cell = [array objectAtIndex:0];
        }
       
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.lbOrderNum.text = [NSString stringWithFormat:@"订单号:%@",self.order.baseId];
    cell.lbCustName.text = self.order.customerName;
    if ([self.order.type isEqualToString:@"自建"]) {
        cell.lbPhoneNo.text = self.order.phoneNo;
    }else{
        NSMutableString *phone = [[NSMutableString alloc] initWithString:self.order.phoneNo];
        [phone replaceCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
        cell.lbPhoneNo.text = phone;
    }
    
    cell.lbLicenseNo.text = self.order.licenseNo;
    cell.lbEndCode.text = self.order.endCode;
    if ([self.order.comment isEqualToString:@""]) {
        cell.lbComment.text = @"暂无备注";
    }else{
        cell.lbComment.text = self.order.comment;
    }
    if ([self.order.reserveTime isEqualToString:@""]) {
        cell.lbReserveTime.text = @"";
    }else{
        cell.lbReserveTime.text = [HelperUtil timeFormat:self.order.reserveTime format:@"yyyy-MM-dd HH:mm"];
    }
    
    [cell.callBtn addTarget:self action:@selector(callClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.priceBtn addTarget:self action:@selector(priceClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.appointmentBtn addTarget:self action:@selector(appointmentClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.sendPayBtn addTarget:self action:@selector(sendPayMessageClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.giftBtn addTarget:self action:@selector(giftClick:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.order.orderStatus isEqualToString:@"待支付"]) {
        return 293;
    }else if ([self.order.orderStatus isEqualToString:@"已支付"]){
        return 364;
    }else{
        return 325;
    }
    
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
    orderH5VC.url = [NSString stringWithFormat:@"%@%@&isCloud=%i",kZhiKeInfo,self.order.baseId,1];
    AYCLog(@"%@",[NSString stringWithFormat:@"%@%@",kZhiKeInfo,self.order.baseId]);
    [self.navigationController pushViewController:orderH5VC animated:YES];

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
        receive.phoneNo = self.order.phoneNo;
        [receive refreshTableview:^(NSString *endCode, NSString *time, NSString *comment) {
            self.order.endCode = endCode;
            self.order.reserveTime = time;
            self.order.comment = comment;
            [self.tableView reloadData];
        }];
    }
}

/**
 *  下发支付短信
 */
- (void)sendPayMessageClick:(UIButton *)sender {
    if ([self.order.gift isEqualToString:@""]) {
        [EYInputPopupView popViewWithTitle:@"请填写投保礼"
                               contentText:self.order.gift
                                      type:EYInputPopupView_Type_multi_line
                               cancelBlock:^{
                                   
                               } confirmBlock:^(UIView *view, NSString *text) {
                                   if ([text isEqualToString:@""]) {
                                       text = @"无";
                                   }
                                   [self saveOrderGift:text];
                               } dismissBlock:^{
                                   
                               }];
    }else {
        UIActionSheet *actionSheet=[[UIActionSheet alloc] initWithTitle:@"请选择支付方式" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"短信支付",@"微信分享", nil];
        [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
       
    }
}
/**
 *  下发支付短信
 */
- (void)sendPayMessage:(NSString *)phoneNo{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseAPI,kSendPayMessage];
    NSDictionary *params = @{@"baseId":self.order.baseId,
                             @"phoneNo":phoneNo,
                             @"userNum":[[SingleHandle shareSingleHandle] getUserInfo].userNum};
    [MHNetworkManager postReqeustWithURL:url params:params successBlock:^(id returnData) {
        if ([[returnData objectForKey:@"flag"] isEqualToString:@"success"]) {
            [MBProgressHUD showMessag:@"下发支付短信成功" toView:nil];
            
        }else {
            [MBProgressHUD showMessag:[returnData objectForKey:@"msg"] toView:nil];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:NO];

}

/**
 *  投保礼
 */
- (void)giftClick:(UIButton *)sender {
    [EYInputPopupView popViewWithTitle:@"请填写投保礼"
                           contentText:self.order.gift
                                  type:EYInputPopupView_Type_multi_line
                           cancelBlock:^{
                               
                           } confirmBlock:^(UIView *view, NSString *text) {
                               
                               [self saveOrderGift:text];
                           } dismissBlock:^{
                               
                           }];

}
/**
 *  保存投保礼
 */
- (void)saveOrderGift:(NSString *)text {
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseAPI,kSaveOrderGift];
    NSDictionary *params = @{@"baseId":self.order.baseId,
                             @"gift":text};
    [MHNetworkManager postReqeustWithURL:url params:params successBlock:^(id returnData) {
        if ([[returnData objectForKey:@"flag"] isEqualToString:@"success"]) {
            
            self.order.gift = text;
           
            
            [MBProgressHUD showMessag:@"保存投保礼成功" toView:nil];
        }else {
            [MBProgressHUD showMessag:[returnData objectForKey:@"msg"] toView:nil];
        }
        
    } failureBlock:^(NSError *error) {
        
    } showHUD:NO];
}
/**
 *  分享支付连接
 */
- (void)sharePayMessage{
    User *user = [[SingleHandle shareSingleHandle] getUserInfo];
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseAPI,ksharePayMessage];
    NSDictionary *params = @{@"baseId":self.order.baseId,
                             @"userNum":user.userNum};
    [MHNetworkManager postReqeustWithURL:url params:params successBlock:^(id returnData) {
        if ([[returnData objectForKey:@"flag"] isEqualToString:@"success"]) {
            NSString *payMessage = [returnData valueForKey:@"data"];
            [self weixinPay:payMessage];
        }else {
            [MBProgressHUD showMessag:[returnData objectForKey:@"msg"] toView:nil];
        }
        
    } failureBlock:^(NSError *error) {
        
    } showHUD:NO];
}
/**
 *  微信分享支付
 */
- (void)weixinPay:(NSString *)payMessage {
    //1、创建分享参数

        
        NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
        [shareParams SSDKSetupShareParamsByText:payMessage
                                         images:nil
                                            url:nil
                                          title:@"点点云服"
                                           type:SSDKContentTypeAuto];
        //2、分享（可以弹出我们的分享菜单和编辑界面）
        [ShareSDK showShareActionSheet:nil //要显示菜单的视图, iPad版中此参数作为弹出菜单的参照视图，只有传这个才可以弹出我们的分享菜单，可以传分享的按钮对象或者自己创建小的view 对象，iPhone可以传nil不会影响
                                 items:nil
                           shareParams:shareParams
                   onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                       
                       switch (state) {
                           case SSDKResponseStateSuccess:
                           {
                               UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
                                                                                   message:nil
                                                                                  delegate:nil
                                                                         cancelButtonTitle:@"确定"
                                                                         otherButtonTitles:nil];
                               [alertView show];
                               break;
                           }
                           case SSDKResponseStateFail:
                           {
                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                               message:[NSString stringWithFormat:@"%@",error]
                                                                              delegate:nil
                                                                     cancelButtonTitle:@"OK"
                                                                     otherButtonTitles:nil, nil];
                               [alert show];
                               break;
                           }
                           default:
                               break;
                       }
                   }];
        
    

}
#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex==0) {
        AYCLog(@"短信支付");
        [EYInputPopupView popViewWithTitle:@"请填写支付手机号"
                               contentText:self.order.phoneNo
                                      type:EYInputPopupView_Type_multi_line
                               cancelBlock:^{
                                   
                               } confirmBlock:^(UIView *view, NSString *text) {
                                   
                                   [self sendPayMessage:text];
                               } dismissBlock:^{
                                   
                               }];
        
    }
    if (buttonIndex==1) {
        AYCLog(@"微信分享");
        
        [self sharePayMessage];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc
{
    AYCLog(@"订单详情销毁");
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
