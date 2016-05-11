//
//  CityChooseViewController.m
//  CloudService
//
//  Created by 安永超 on 16/5/9.
//  Copyright © 2016年 zhangqiang. All rights reserved.
//

#import "CityChooseViewController.h"

@interface CityChooseViewController ()<UITableViewDelegate,UITableViewDataSource>



@end

@implementation CityChooseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    __weak typeof(self) weakSelf = self;
    [weakSelf setLeftImageBarButtonItemWithFrame:CGRectMake(0, 0, 30, 30) image:@"title-back" selectImage:@"back" action:^(AYCButton *button) {
        
        [[FireData sharedInstance] eventWithCategory:@"选择城市" action:@"返回" evar:nil attributes:nil];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    
    [self setupUI];

    
    // Do any additional setup after loading the view.
}

- (void)setupUI{
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KWidth, 44)];
    topView.backgroundColor = [UIColor colorWithRed:239.0/255 green:239.0/255 blue:239.0/255 alpha:1];
    [self.view addSubview:topView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, KWidth, 44)];
    label.text = _provinceName;
    label.font = [UIFont systemFontOfSize:18];
    [topView addSubview:label];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, KWidth, KHeight - 64 - 44) style:UITableViewStylePlain];
    tableView.showsHorizontalScrollIndicator = NO;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([_cityList isKindOfClass:[NSArray class]]) {
        return [_cityList count];
    }else{
        NSArray *array = [_cityList objectForKey:@"cityName"];
        return array.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
    }
    if ([_cityList isKindOfClass:[NSArray class]]) {
        cell.textLabel.text = [_cityList[indexPath.row] objectForKey:@"name"];
    }else{
        NSArray *array = [_cityList objectForKey:@"cityName"];
        cell.textLabel.text = array[indexPath.row];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if (_cityblock) {
        NSString *code = @"";
        if ([_cityList isKindOfClass:[NSArray class]]) {
            
            _cityblock(self,[_cityList[indexPath.row] objectForKey:@"name"],_provinceName,code);
        }else{
            NSArray *array = [_cityList objectForKey:@"cityCode"];
            code = array[indexPath.row];
            _cityblock(self,[[_cityList objectForKey:@"cityName"] objectAtIndex:indexPath.row],_provinceName,code);
        }
    }else{
        [MBProgressHUD showMessag:@"未知错误" toView:nil];
    }

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
