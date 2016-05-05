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
#import "ShareManager.h"

@interface OrderInfoViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>
{
    Order *_getOrderInfo;
    UIActionSheet *_shareActionSheet;
}
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
    
    [[ButelHandle shareButelHandle] setPhoneNo:self.order.phoneNo phoneWithBaseId:self.order.baseId];
    self.tableView.backgroundColor = [HelperUtil colorWithHexString:@"F4F4F4"];
    __weak typeof(self) weakSelf = self;
    [weakSelf setLeftImageBarButtonItemWithFrame:CGRectMake(0, 0, 30, 30) image:@"title-back" selectImage:@"back" action:^(AYCButton *button) {
      [[FireData sharedInstance] eventWithCategory:@"订单搜索" action:@"返回上一页" evar:nil attributes:nil];

        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    
  
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated {
    
//    [super viewWillAppear:animated];
    [[FireData sharedInstance] beginLogPageView:@"订单详情" attributes:nil cvar:nil];
    
    
    NSDictionary *params ;
    if([_order.orderStatus isEqualToString:@"未完成"]){
        
    }else if ([_order.orderStatus isEqualToString:@"待支付"]){
        params =  @{@"订单号":_order.baseId,@"交强险投保单号":_order.ciProposalNo,@"商业险投保单号":_order.proposalNo};
    }else if ([_order.orderStatus isEqualToString:@"已支付"]){
        params = @{@"订单号":_order.baseId,@"交强险保单号":_order.ciPolicyNo,@"商业险保单号":_order.policyNo};
    }
    
    [[FireData sharedInstance] eventWithCategory:@"订单详情" action:_order.orderStatus evar:params attributes:nil];
    self.title=@"订单详情";
   
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

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
    
    if (self.order) {
        cell.lbOrderNum.text = [NSString stringWithFormat:@"订单号:%@",self.order.baseId];
        cell.lbCustName.text = self.order.customerName;
        if ([self.order.type isEqualToString:@"自建"]) {
            cell.lbPhoneNo.text = self.order.phoneNo;
        }else{
            if (self.order.phoneNo.length>10) {
                NSMutableString *phone = [[NSMutableString alloc] initWithString:self.order.phoneNo];
                [phone replaceCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
                cell.lbPhoneNo.text = phone;
            }
            
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
        cell.lbAgentName.text = self.order.agentName;
        cell.lbInsureComName.text = self.order.insureComName;
        cell.lbPolicyNo.text = self.order.policyNo;
        cell.lbProposalNo.text = self.order.proposalNo;
        cell.lbCiPolicyNo.text = self.order.ciPolicyNo;
        cell.lbCiProposalNo.text = self.order.ciProposalNo;

    }
    
    [cell.callBtn addTarget:self action:@selector(callClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.priceBtn addTarget:self action:@selector(priceClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.appointmentBtn addTarget:self action:@selector(appointmentClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.sendPayBtn addTarget:self action:@selector(sendPayMessageClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.giftBtn addTarget:self action:@selector(giftClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.shareBtn addTarget:self action:@selector(shareClick:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.order.orderStatus isEqualToString:@"待支付"]) {
        return 483;
    }else if ([self.order.orderStatus isEqualToString:@"已支付"]){
        return 402;
    }else{
        return 382;
    }
    
}
#pragma mark - 订单详情按钮事件
/** 拨打电话*/
- (void)callClick:(UIButton *)sender {
    [[FireData sharedInstance] eventWithCategory:@"订单详情" action:@"拨打电话" evar:nil attributes:nil];
    [[ButelHandle shareButelHandle] popCallView];

}
/** 报价*/
- (void)priceClick:(UIButton *)sender {
    [[FireData sharedInstance] eventWithCategory:@"订单详情" action:@"报价按钮" evar:nil attributes:nil];
    NSString *url = @"";
    if ([self.order.orderStatus isEqualToString:@"未完成"]||[self.order.orderStatus isEqualToString:@""]) {
        url = [NSString stringWithFormat:@"%@%@&isCloud=%i",kZhiKeUnfinishInfo,self.order.baseId,1];
    }else{
        url = [NSString stringWithFormat:@"%@%@&isCloud=%i",kZhiKeFinishInfo,self.order.baseId,1];
    }
    
    AYCLog(@"%@",[NSString stringWithFormat:@"%@",url]);
    
    OrderH5ViewController *orderH5VC = [[OrderH5ViewController alloc] init];
    orderH5VC.url = url;
    
    [self.navigationController pushViewController:orderH5VC animated:YES];

}

- (void)shareClick:(UIButton *)sender{
    [[FireData sharedInstance] eventWithCategory:@"订单详情" action:@"报价分享" evar:nil attributes:nil];
    
    _shareActionSheet=[[UIActionSheet alloc] initWithTitle:@"请选择支付方式" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"短信报价分享",@"微信报价分享", nil];
    [_shareActionSheet showInView:[UIApplication sharedApplication].keyWindow];

}


/** 预约*/
- (void)appointmentClick:(UIButton *)sender {
    [[FireData sharedInstance] eventWithCategory:@"订单详情" action:@"预约按钮" evar:nil attributes:nil];
    [self performSegueWithIdentifier:@"appointment" sender:self];
}


/**
 *  下发支付短信
 */
- (void)sendPayMessageClick:(UIButton *)sender {
    [[FireData sharedInstance] eventWithCategory:@"订单详情" action:@"找人代付按钮" evar:nil attributes:nil];
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
 *  投保礼
 */
- (void)giftClick:(UIButton *)sender {
    [[FireData sharedInstance] eventWithCategory:@"订单详情" action:@"投保礼按钮" evar:nil attributes:nil];
    [EYInputPopupView popViewWithTitle:@"请填写投保礼"
                           contentText:self.order.gift
                                  type:EYInputPopupView_Type_multi_line
                           cancelBlock:^{
                               
                           } confirmBlock:^(UIView *view, NSString *text) {
                               
                               [self saveOrderGift:text];
                           } dismissBlock:^{
                               
                           }];

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



#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (actionSheet == _shareActionSheet) {
        if (buttonIndex==0) {
            AYCLog(@"短信报价分享");
//            [[FireData sharedInstance] eventWithCategory:@"订单详情" action:@"订单短信分享" evar:nil attributes:nil];
//            [EYInputPopupView popViewWithTitle:@"请填写分享的手机号"
//                                   contentText:self.order.phoneNo
//                                          type:EYInputPopupView_Type_multi_line
//                                   cancelBlock:^{
//                                       
//                                   } confirmBlock:^(UIView *view, NSString *text) {
                                       [self sendShareSMS];
//                                   } dismissBlock:^{
//                                       
//                                   }];
            
        }
        if (buttonIndex==1) {
            AYCLog(@"微信报价分享");
            [[FireData sharedInstance] eventWithCategory:@"订单详情" action:@"订单微信分享" evar:nil attributes:nil];
            [self weixinPriceShare];
        }
    }else{
        
        if (buttonIndex==0) {
            AYCLog(@"短信支付");
            [[FireData sharedInstance] eventWithCategory:@"订单详情" action:@"短信支付" evar:nil attributes:nil];
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
            AYCLog(@"微信支付");
            [[FireData sharedInstance] eventWithCategory:@"订单详情" action:@"微信支付" evar:nil attributes:nil];
            [self sharePayMessage];
        }
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

//短信报价分享
- (void)sendShareSMS{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseAPI,kSMSShareOrderInfo];
    User *user = [SingleHandle shareSingleHandle].user;
    [MHNetworkManager postReqeustWithURL:url params:@{@"baseId":_order.baseId,@"userNum":user.userNum} successBlock:^(id returnData) {
        if ([returnData[@"flag"] isEqualToString:@"success"]) {
            [MBProgressHUD showMessag:@"短信发送成功" toView:nil];
        }else{
            [MBProgressHUD showMessag:@"短信发送失败，请稍后再试" toView:nil];
        }
    } failureBlock:^(NSError *error) {
        [MBProgressHUD showMessag:@"短信发送失败，请稍后再试" toView:nil];
    } showHUD:YES];
}

//微信报价分享

- (void)weixinPriceShare{

    NSString *url = [NSString stringWithFormat:@"%@%@",BaseAPI,kShareOrderInfo];
    [MHNetworkManager postReqeustWithURL:url params:@{@"baseId":self.order.baseId} successBlock:^(id returnData) {
        if ([returnData[@"flag"] isEqualToString:@"success"]) {
            NSString  *contentStr = returnData[@"data"];
            [[ShareManager manager] shareParamsByText:nil images:nil url:[NSURL URLWithString:kCreateQRAPI] title:nil ChatTitle:contentStr];
        }
    } failureBlock:^(NSError *error) {
        [MBProgressHUD showMessag:@"网络繁忙，请稍后再试" toView:nil];
    } showHUD:YES];

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

#pragma mark - 支付功能
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
    /**
     *  微信分享
     */
    [[ShareManager manager] shareParamsByText:payMessage images:nil url:nil title:@"点点云服" WeChatTitle:@""];
    
    
    
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

@end
