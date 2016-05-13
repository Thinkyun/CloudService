//
//  ZhiKeInfoInputViewController.m
//  CloudService
//
//  Created by 安永超 on 16/5/11.
//  Copyright © 2016年 zhangqiang. All rights reserved.
//

#import "ZhiKeInfoInputViewController.h"
#import "InputButton.h"
#import "UIView+YYAdd.h"

@interface ZhiKeInfoInputViewController ()

@end

@implementation ZhiKeInfoInputViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.title = @"信息录入";
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear: animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    __weak typeof(self) weakSelf = self;
    [weakSelf setLeftImageBarButtonItemWithFrame:CGRectMake(0, 0, 30, 30) image:@"title-back" selectImage:@"back" action:^(AYCButton *button) {
        
        [[FireData sharedInstance] eventWithCategory:@"信息录入" action:@"返回" evar:nil attributes:nil];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];

    [self setupUI];
    // Do any additional setup after loading the view.
}

- (void)setupUI{
    InputButton *inputBtn = [[InputButton alloc] initWithFrame:CGRectMake(20, 20, KWidth-40, 44) title:@"车架号" text:@"233322" image:nil isKeyBoardEdit:YES];
    inputBtn.backgroundColor = [UIColor orangeColor];
    [inputBtn addTarget:self action:@selector(inputAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:inputBtn];
}

- (void)inputAction:(InputButton *)btn{
//    NSLog(@"hah");
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
