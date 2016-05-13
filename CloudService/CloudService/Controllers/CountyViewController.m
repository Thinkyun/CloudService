//
//  CountyViewController.m
//  CloudService
//
//  Created by 安永超 on 16/5/12.
//  Copyright © 2016年 zhangqiang. All rights reserved.
//

#import "CountyViewController.h"
#import "UIView+YYAdd.h"

@interface CountyViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation CountyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    __weak typeof(self) weakSelf = self;
    
    [weakSelf setLeftTextBarButtonItemWithFrame:CGRectMake(0, 0, 30, 30) title:@"取消" titleColor:[UIColor whiteColor] backImage:@"" selectBackImage:@"" action:^(AYCButton *button) {
        
        [[FireData sharedInstance] eventWithCategory:@"选择县" action:@"取消" evar:nil attributes:nil];
        NSInteger count = weakSelf.navigationController.viewControllers.count;
        UIViewController *VC = weakSelf.navigationController.viewControllers[count-4];
        [weakSelf.navigationController popToViewController:VC animated:YES];
    }];
    
    [self setupUI];
    
    
    // Do any additional setup after loading the view.
}

- (void)setupUI{
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KWidth, 44)];
    topView.backgroundColor = [UIColor colorWithRed:239.0/255 green:239.0/255 blue:239.0/255 alpha:1];
    [self.view addSubview:topView];
    
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, KWidth, 44)];
//    label.text = _provinceName;
//    label.font = [UIFont systemFontOfSize:18];
//    [topView addSubview:label];
    UIButton *provinceBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 0, 80, 44)];
    [provinceBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [provinceBtn setTitle:_provinceName forState:UIControlStateNormal];
    [provinceBtn.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [provinceBtn addTarget:self action:@selector(provinceBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    CGRect rect = [_provinceName boundingRectWithSize:CGSizeMake(1000, 44) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18]} context:NULL];
    provinceBtn.frame = CGRectMake(20, 0, rect.size.width, 44);
    [topView addSubview:provinceBtn];
    
    UIButton *cityBtn = [[UIButton alloc] initWithFrame:CGRectMake(provinceBtn.right+50, 0, 100, 44)];
    [cityBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cityBtn setTitle:_cityName forState:UIControlStateNormal];
    [cityBtn.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [cityBtn addTarget:self action:@selector(cityBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:cityBtn];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(provinceBtn.right+26, 10, 17, 23)];
    imageView.image = [UIImage imageNamed:@"WeChat_1463034780"];
    [topView addSubview:imageView];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, KWidth, KHeight - 64 - 44) style:UITableViewStylePlain];
    tableView.showsHorizontalScrollIndicator = NO;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tableFooterView = [UIView new];
    [self.view addSubview:tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([_countyList isKindOfClass:[NSArray class]]) {
        return [_countyList count];
    }else{
        NSArray *array = [_countyList objectForKey:@"countyName"];
        return array.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
    }
    if ([_countyList isKindOfClass:[NSArray class]]) {
        cell.textLabel.text = [_countyList[indexPath.row] objectForKey:@"name"];
    }else{
        cell.textLabel.text = [[_countyList objectForKey:@"countyName"] objectAtIndex:indexPath.row];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_cityblock) {
        NSString *code = @"";
        if ([_countyList isKindOfClass:[NSArray class]]) {
            
            _cityblock(self,[_countyList[indexPath.row] objectForKey:@"name"],_cityName,_provinceName,code);
        }else{
            NSArray *array = [_countyList objectForKey:@"countyCode"];
            code = array[indexPath.row];
            NSString *countyStr = [[_countyList objectForKey:@"countyName"] objectAtIndex:indexPath.row];
            _cityblock(self, countyStr,_cityName,_provinceName,code);
        }
    }else{
        [MBProgressHUD showMessag:@"未知错误" toView:nil];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)provinceBtnAction:(UIButton *)btn{
    NSInteger count = self.navigationController.viewControllers.count;
    UIViewController *VC = self.navigationController.viewControllers[count-3];
    [self.navigationController popToViewController:VC animated:YES];
}

- (void)cityBtnAction:(UIButton *)btn{
    [self.navigationController popViewControllerAnimated:YES];
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
