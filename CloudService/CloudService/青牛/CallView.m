//
//  CallView.m
//  CloudService
//
//  Created by zhangqiang on 16/3/4.
//  Copyright © 2016年 zhangqiang. All rights reserved.
//

#import "CallView.h"
#import "ButelHandle.h"
#import "MHNetwrok.h"
#import "AppDelegate.h"
@interface CallView()
{
    UIButton *_button;
    
    BOOL isSpeaker; // 是否开启扬声器
    BOOL isMute;//是否静音
    BOOL _isPop;//是否弹出拨打视图
    // 通话时长
    NSInteger _callDuration;
    UIButton *_btnCall;//拨号按钮
    UIImageView *_imgCall;//电话图标
    UILabel *_labelCallDuration;//通话计时
    UILabel *_lbCall;//拨号显示
    UIImageView *_imgSpeaker;//扬声器图片
    UIImageView *_imgMute;//静音图片
    UILabel *_lbSpeaker;//扬声器
    UILabel *_lbMute;//静音
    UIButton *_btnSpeaker;//扬声器按钮
    UIButton *_btnMute;//静音按钮
     BOOL _isOnConnect;//是否收到OnConnect回调
}
@property (nonatomic, strong) NSTimer *timerForDuration;
@end

@implementation CallView

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [HelperUtil colorWithHexString:@"2E2D2F"];
        self.layer.cornerRadius = 40;
        self.layer.masksToBounds = YES;
        [self setContentView];
    }
    return self;
}

- (void)dismissCallView {
    [self removeFromSuperview];
}

- (void)setContentView {

    /** 拨号、挂断按钮*/
    _btnCall = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnCall.frame = CGRectMake(0, 0, 80, 80);
    _btnCall.layer.cornerRadius = 40;
    _btnCall.layer.masksToBounds = YES;
    _btnCall.clipsToBounds = YES;
    [_btnCall addTarget:self action:@selector(callNum:) forControlEvents:UIControlEventTouchUpInside];
    [_btnCall setBackgroundImage:[UIImage imageNamed:@"pop2-btn1"] forState:UIControlStateNormal];
    _btnCall.userInteractionEnabled = NO;
    
    
    /** 电话图标*/
    _imgCall = [[UIImageView alloc] initWithFrame:CGRectMake(25, 20, 27, 27)];
    _imgCall.image = [UIImage imageNamed:@"pop2-icon1"];
    
    /** 通话时长*/
    _labelCallDuration = [[UILabel alloc] initWithFrame:CGRectMake(20, 22, 40, 20)];
    _labelCallDuration.textColor = [UIColor whiteColor];
    _labelCallDuration.textAlignment = NSTextAlignmentCenter;
    _labelCallDuration.font = [UIFont systemFontOfSize:12];
    _labelCallDuration.hidden = YES;
  
    
    /** 拨号*/
    _lbCall = [[UILabel alloc] initWithFrame:CGRectMake(25, 43, 40, 20)];
    _lbCall.textColor = [UIColor whiteColor];
    _lbCall.font = [UIFont systemFontOfSize:12];
    _lbCall.text = @"拨号";
    
    /** 扬声器按钮*/
    _btnSpeaker = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnSpeaker.frame = CGRectMake(80, 3, 90, 35);
    [_btnSpeaker addTarget:self action:@selector(speaker) forControlEvents:UIControlEventTouchUpInside];
    
    /** 扬声器icon*/
    _imgSpeaker = [[UIImageView alloc] initWithFrame:CGRectMake(85, 7, 27, 27)];
    _imgSpeaker.image = [UIImage imageNamed:@"pop2-icon2"];
    
    
    /** 扬声器*/
    _lbSpeaker = [[UILabel alloc] initWithFrame:CGRectMake(115, 10, 50, 20)];
    _lbSpeaker.textColor = [UIColor whiteColor];
    _lbSpeaker.font = [UIFont systemFontOfSize:12];
    _lbSpeaker.text = @"扬声器";
    
    /** 分割线*/
    UIImageView *lineImg = [[UIImageView alloc] initWithFrame:CGRectMake(77, 40, 123, 1)];
    lineImg.image = [UIImage imageNamed:@"login-input-line"];
    
    /** 静音按钮*/
    _btnMute = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnMute.frame = CGRectMake(80, 43, 90, 35);
    [_btnMute addTarget:self action:@selector(mute) forControlEvents:UIControlEventTouchUpInside];
    
    
    /** 静音icon*/
    _imgMute = [[UIImageView alloc] initWithFrame:CGRectMake(85, 47, 27, 27)];
    _imgMute.image = [UIImage imageNamed:@"pop2-icon3"];
    
    /** 静音*/
    _lbMute = [[UILabel alloc] initWithFrame:CGRectMake(115, 50, 50, 20)];
    _lbMute.textColor = [UIColor whiteColor];
    _lbMute.font = [UIFont systemFontOfSize:12];
    _lbMute.text = @"静音";
    
    
    /** 拖拽手势*/
    UIPanGestureRecognizer *oneFingerSwipeleft =
    
    [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(oneFingerSwipeUp:)];
    [self addSubview:_button];
    [self addSubview:_btnCall];
    [self addSubview:_imgCall];
    [self addSubview:_labelCallDuration];
    [self addSubview:_lbCall];
    [self addSubview:_btnSpeaker];
    [self addSubview:_imgSpeaker];
    [self addSubview:_lbSpeaker];
    [self addSubview:lineImg];
    [self addSubview:_btnMute];
    [self addSubview:_imgMute];
    [self addSubview:_lbMute];
    [self addGestureRecognizer:oneFingerSwipeleft];
//    self.hidden = YES;
//    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    UIWindow *keyWindow = [[[UIApplication sharedApplication] delegate] window];
    
    [keyWindow addSubview:self];
    
}
//拨打电话
- (void)callNum:(UIButton *)sender {

    User *user = [SingleHandle shareSingleHandle].user;
    if (![user.sign isEqualToString:@"1"]) {
        [MBProgressHUD showMessag:@"当前未签到,不能拨打电话" toView:nil];
        return;
    }
    [[ButelHandle shareButelHandle] makeCallWithPhoneNo:self.telNumStr];
      
}
- (void)callPhoneOrHangUp {
    [_btnCall setBackgroundImage:[UIImage imageNamed:@"pop2-btn1_"] forState:UIControlStateNormal];
    _imgCall.hidden = NO;
    _lbCall.text = @"挂断";
}

//扬声器
- (void)speaker {
    if (isSpeaker) {
        [[ButelHandle shareButelHandle] openSpeaker:NO];
        _imgSpeaker.image = [UIImage imageNamed:@"pop2-icon2"];
        _lbSpeaker.textColor = [UIColor whiteColor];
    }else {
        [[ButelHandle shareButelHandle] openSpeaker:YES];
        _imgSpeaker.image = [UIImage imageNamed:@"pop2-icon2_"];
        _lbSpeaker.textColor = [HelperUtil colorWithHexString:@"1FAAF2"];
    }
    isSpeaker = !isSpeaker;
}
//静音
- (void)mute {
    if (isMute) {
        [[ButelHandle shareButelHandle] enableMute:NO];
        _imgMute.image = [UIImage imageNamed:@"pop2-icon3"];
        _lbMute.textColor = [UIColor whiteColor];
    }else {
        [[ButelHandle shareButelHandle] enableMute:YES];
        _imgMute.image = [UIImage imageNamed:@"pop2-icon3_"];
        _lbMute.textColor = [HelperUtil colorWithHexString:@"1FAAF2"];
    }
    isMute = !isMute;
}

- (void)oneFingerSwipeUp:(UIPanGestureRecognizer *)recognizer{
    CGPoint translatedPoint = [recognizer translationInView:self];
    _isPop = !_isPop;
    
    __weak typeof(self) weakSelf = self;
    if (translatedPoint.x>0) {
        [UIView animateWithDuration:.5 animations:^{
            weakSelf.frame = CGRectMake(KWidth-20, KHeight/2, 220, 80);
        } completion:^(BOOL finished) {
            _btnCall.userInteractionEnabled = NO;
        }];
    }else{
        [UIView animateWithDuration:.5 animations:^{
            weakSelf.frame = CGRectMake(KWidth-170, KHeight/2, 220, 80);
        } completion:^(BOOL finished) {
            _btnCall.userInteractionEnabled = YES;
        }];
    }
    
}

- (void)popCallView {
    
    __weak typeof(self) weakSelf = self;
    if (_isPop) {
        _isPop = !_isPop;
        
        [UIView animateWithDuration:.5 animations:^{
            weakSelf.frame = CGRectMake(KWidth-20, KHeight/2, 220, 80);
        } completion:^(BOOL finished) {
            _btnCall.userInteractionEnabled = NO;
        }];
    }else {
        _isPop = !_isPop;
        [UIView animateWithDuration:.5 animations:^{
            weakSelf.frame = CGRectMake(KWidth-170, KHeight/2, 220, 80);
        } completion:^(BOOL finished) {
            _btnCall.userInteractionEnabled = YES;
        }];
    }
    
}
#pragma mark 回调入口

//打电话成功回调
- (void)OnConnectSuccess{
    _labelCallDuration.hidden = NO;
    _imgCall.hidden = YES;
    self.timerForDuration =nil;
    if (!self.timerForDuration) {
        self.timerForDuration = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(setCallDurationDisp) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.timerForDuration forMode:NSDefaultRunLoopMode];
    }

}
/**
 *  设置通话时长显示
 */
- (void)setCallDurationDisp
{
//    [_btnCall setBackgroundImage:[UIImage imageNamed:@"pop2-btn1_"] forState:UIControlStateNormal];
//    _imgCall.hidden = NO;
//    _lbCall.text = @"挂断";
    
    NSString *timeStr = @"00:00";
    NSInteger hour = 0;
    NSInteger minute = 0;
    NSInteger second = 0;
    _callDuration ++;
    if (_callDuration > 0){
        minute = _callDuration / 60;
        if (minute < 60) {
            second = _callDuration % 60;
            timeStr = [NSString stringWithFormat:@"%@:%@", [self unitFormat:minute], [self unitFormat:second]];
        } else {
            hour = minute / 60;
            if (hour > 99) { // 最大值
                timeStr =  @"99:59:59";
            } else {
                minute = minute % 60;
                second = _callDuration - hour * 3600 - minute * 60;
                timeStr = [NSString stringWithFormat:@"%@:%@:%@", [self unitFormat:hour], [self unitFormat:minute], [self unitFormat:second]];
            }
        }
    }
    [_labelCallDuration setText:timeStr];
}

/**
 *  格式化分秒
 */
- (NSString *)unitFormat:(NSInteger)i
{
    NSString *retStr;
    if (i >= 0 && i < 10){
        retStr = [NSString stringWithFormat:@"0%ld", (long)i];
    } else {
        retStr = [NSString stringWithFormat:@"%ld", (long)i];
    }
    return retStr;
}

//挂断回调
- (void)OnDisconnect{
    _labelCallDuration.hidden = YES;
    _imgCall.hidden = NO;
    [_btnCall setBackgroundImage:[UIImage imageNamed:@"pop2-btn1"] forState:UIControlStateNormal];
    _lbCall.text = @"拨号";
    //恢复原始状态
    if (isMute) {
        [self mute];
    }
    if (isSpeaker) {
        [self speaker];
    }
    
    
    if (self.timerForDuration) {
      
        _callDuration = 0;
        
        _labelCallDuration.text = @"00:00";
        [self.timerForDuration invalidate];
        self.timerForDuration = nil;
    }
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
