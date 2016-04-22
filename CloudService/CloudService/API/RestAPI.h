//
//  RestAPI.h
//  美食厨房
//
//  Created by zhangqiang on 15/8/7.
//  Copyright (c) 2015年 zhangqiang. All rights reserved.
//

#ifndef _____RestAPI_h
#define _____RestAPI_h
#import <UIKit/UIKit.h>


//#define BaseAPI                 @"http://192.168.4.114:8080/cloudSales-action"  // 11服务器
//#define BaseAPI                 @"http://192.168.4.117:8889/cloudSales-action"  // 测试服务器
#define BaseAPI                     @"http://www.eyunkf.com" //测试服务器
//#define BaseAPI                     @"http://www.ddyunf.com" //生产服务器

#define kRegisterAPI            @"/app/user/register"                     //注册

#define kLoginAPI               @"/app/user/login"                     //登录

#define kGetCodeAPI             @"/app/user/getCode"                     //获取验证码

#define kGetuserInfoAPI         @"/app/user/findUserInfo"                     //个人信息

#define kGetuserIntergralAPI    @"/app/credits/findUserCredits"                     //我的积分

#define kGetExchangeIntergralAPI  @"/app/credits/exchangeMoney"                    //积分兑换

#define kResetUserInfoAPI       @"/app/user/changeUserInfo"                     //修改个人信息

#define kForgetPwdAPI            @"/app/user/forgetPassword"                     //忘记密码

#define kResetPwdAPI            @"/app/user/changePassword"                     // 登陆后修改密码

#define kSignedAPI              @"/app/sign/signed"                     //签到

#define kCheckPhoneNumAPI       @"/app/user/verifyPhoneNo"                     //验证手机

#define kUserCouponsList        @"/app/coupon/findUserCouponsList"                 //个人优惠券查询

#define kTeamCouponsList        @"/app/coupon/findTeamCouponsList"                 //团队优惠券查询

#define kfindUserAchievement        @"/app/order/findUserAchievement"               //个人业绩查询

#define kfindTeamAchievement        @"/app/order/findTeamAchievement"               //团队业绩查询

#define kfindUserCreditsRecord    @"/app/credits/findUserCreditsRecord"             //积分历史查询

#define kapplyCustomerData     @"/app/customerData/applyCustomerData"             //客户数据申请

#define kfindPersonCustList     @"/app/customerData/findPersonCustList"          //历史客户数据列表

#define kaddReserve              @"/app/reserve/addReserve"                      //保存预约

#define kgetEndCode           @"/app/dic/getEndCode"                    //获取结束码

#define kfindTeamMember           @"/app/team/findTeamMember"                    //查询团队成员

#define kfindTeamInfoByMemberId          @"/app/team/findTeamInfoByMemberId"                 //查询团队信息

#define ksaveOrder           @"/app/order/saveOrder"                    //同步至可数据

#define kfindInviteLink           @"/app/dic/findInviteLink"                    //邀请链接

#define kEstablishCustBySelf      @"/app/customerData/establishCustBySelf"   //创建客户,保存信息

#define kapplyTeamLeader      @"/app/team/applyTeamLeader"                 //申请团队长

#define kassignTeamCoupon      @"/app/coupon/assignTeamCoupon"                 //团队优惠券下发


//#define kZhiKe      @"http://139.198.1.73:8081/zkyq-web/platform/getInfo"              //直客测试
//
//#define kZhiKeUnfinishInfo      @"http://139.198.1.73:8081/zkyq-web/unfinishedOrder/returnPage?baseId="   //直客测试订单详情
//
//#define kZhiKeFinishInfo      @"http://139.198.1.73:8081/zkyq-web/insure/returnPage?baseId="   //直客测试订单详情
#define kZhiKe      @"http://139.198.0.29:80/zkyq-web/platform/getInfo"              //直客

#define kZhiKeUnfinishInfo      @"http://139.198.0.29:80/zkyq-web/unfinishedOrder/returnPage?baseId="   //直客订单详情

#define kZhiKeFinishInfo      @"http://139.198.0.29:80/zkyq-web/insure/returnPage?baseId="   //直客订单详情

#define kfindOrderByCondition     @"/app/order/findOrderByCondition"             //订单条件查询

#define kfindMainOrder     @"/app/order/findMainOrder"             //订单列表查询

#define kActifityInfoAPI     @"/app/activity/findUserActivity"       // 查看活动信息

#define kActifityCouponAPI      @"/app/activity/assignActivityCoupon"   // 下发活动优惠券

#define kCheckVersionAPI        @"/app/system/getVersion"                         // 版本检测

#define agentCode               @"CLOUD_SERVICE"                         //agentCode

#define kSaveTape             @"/app/tape/saveTape"                         // 保存录音流水号

#define kSendPayMessage        @"/app/order/sendPayMessage"                         // 下发支付短信

#define kSaveOrderGift        @"/app/order/saveOrderGift"                         // 保存投保礼


#define kGetAreas            @"/app/area/getOnlineProvince"                             // 获取机构省份列表

#define ksharePayMessage        @"/app/order/sharePayMessage"                         // 分享支付链接

#define kVerifyCusRepeat        @"/app/customerData/verifyCustRepeat"                         // 客户信息重复校验


#define kButelUrl       @"http://221.4.250.108:8088/apHttpService/agent/login4Butel"           // 青牛登陆


#define kButelMakeCall     @"http://221.4.250.108:8088/apHttpService/agent/makeCall"           // 青牛拨打电话

#define kButelLogOut     @"http://221.4.250.108:8088/apHttpService/agent/logout"           // 青牛http退出登陆

//   常量
/**************************************************************************************/

static NSString *const ZQdidChangeLoginStateNotication = @"didChangeLoginNotication";    // 登录成功

/**
 *  StoryboardSugerID
 */
static NSString *const LoginToMenuView = @"loginToMenu";

static NSString *const RegisterSuccess = @"registerSuccess";

static NSString *const RegisterToMenuView = @"registerToMenuView";

/**
 *  通知
 */
static NSString *const LoginToMenuViewNotice = @"loginToMenu";

static NSString *const LogOutViewNotice = @"logOut";

static NSString *const ExchangeIntegralSuccess = @"ExchangeIntegralSuccess";

static NSString *const ReloadHomeData = @"ReloadHomeData";

static NSString *const ChooseSaleCompany = @"ChooseSaleCompany";

static NSString *const ChooseSaleCity = @"ChooseSaleCity";


/**************************************************************************************/

#endif
