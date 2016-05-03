//
//  InviteFriendListViewController.m
//  cutPhoto
//
//  Created by mac on 16/5/3.
//  Copyright © 2016年 DJ. All rights reserved.
//

#import "InviteFriendListViewController.h"
#import "InviteFriendListTableViewCell.h"

@interface InviteFriendListViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UILabel *_label;
}

@property (nonatomic,strong)NSArray *dataList;

@end

@implementation InviteFriendListViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.navigationItem.title = @"好友邀请列表";
    __weak typeof(self) weakSelf = self;
    [self setLeftImageBarButtonItemWithFrame:CGRectMake(0, 0, 30, 30) image:@"title-back" selectImage:@"" action:^(AYCButton *button) {
        
        [[FireData sharedInstance] eventWithCategory:@"好友邀请列表" action:@"返回" evar:nil attributes:nil];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    
    [self loadData];
    [self setupUI];
    // Do any additional setup after loading the view.
}

- (void)setupUI{
    //tableView 初始化
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 375, 667) style:UITableViewStylePlain];
    tableView.showsHorizontalScrollIndicator = NO;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.tableFooterView = [UIView new];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    
    //底下的View
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, KHeight-49-64, KWidth, 49)];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, KWidth, 49)];
    label.font = [UIFont systemFontOfSize:16];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor grayColor];
    label.text = [NSString stringWithFormat:@"共邀请%ld个好友",_dataList.count];
    _label = label;
    [bottomView addSubview:label];
}

- (void)loadData{
    
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    InviteFriendListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[InviteFriendListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.dataDict = _dataList[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 85;
}

- (UIImage *)cutPhoot:(UIImage *)oldImage{
    UIGraphicsBeginImageContextWithOptions(oldImage.size, 0, 0);
    [oldImage drawInRect:CGRectMake(-7, -5, oldImage.size.width, oldImage.size.height)];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClipToRect(context, CGRectMake(0, 0, 74, 74));
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
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
