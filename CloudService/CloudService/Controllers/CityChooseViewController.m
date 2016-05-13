//
//  CityChooseViewController.m
//  CloudService
//
//  Created by 安永超 on 16/5/9.
//  Copyright © 2016年 zhangqiang. All rights reserved.
//

#import "CityChooseViewController.h"
#import "CountyViewController.h"
#import "CityView.h"

@interface CityChooseViewController ()<UITableViewDelegate,UITableViewDataSource>



@end

@implementation CityChooseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    __weak typeof(self) weakSelf = self;
    [weakSelf setLeftTextBarButtonItemWithFrame:CGRectMake(0, 0, 30, 30) title:@"取消" titleColor:[UIColor whiteColor] backImage:@"" selectBackImage:@"" action:^(AYCButton *button) {
        [[FireData sharedInstance] eventWithCategory:@"选择城市" action:@"取消" evar:nil attributes:nil];
        NSInteger count = weakSelf.navigationController.viewControllers.count;
        UIViewController *VC = weakSelf.navigationController.viewControllers[count-3];
        [weakSelf.navigationController popToViewController:VC animated:YES];
    }];
    
    [self setupUI];

    
    // Do any additional setup after loading the view.
}

- (void)setupUI{
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KWidth, 44)];
    topView.backgroundColor = [UIColor colorWithRed:239.0/255 green:239.0/255 blue:239.0/255 alpha:1];
    [self.view addSubview:topView];
    
    UIButton *provinceBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, KWidth, 44)];
    [provinceBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [provinceBtn setTitle:_provinceName forState:UIControlStateNormal];
    [provinceBtn.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [provinceBtn addTarget:self action:@selector(provinceBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    CGRect rect = [_provinceName boundingRectWithSize:CGSizeMake(1000, 44) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18]} context:NULL];
    provinceBtn.frame = CGRectMake(20, 0, rect.size.width, 44);
    [topView addSubview:provinceBtn];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, KWidth, KHeight - 64 - 44) style:UITableViewStylePlain];
    tableView.showsHorizontalScrollIndicator = NO;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tableFooterView = [UIView new];
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
        cell.textLabel.font = [UIFont systemFontOfSize:16];
    }
    CityView *view = [[CityView alloc] initWithFrame:CGRectMake(KWidth-10-80, 0, 90, 44)];
    view.indexPath = indexPath;
    view.backgroundColor =[ UIColor clearColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [view addGestureRecognizer:tap];
    [cell.contentView addSubview:view];
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 70, 44)];
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor lightGrayColor];
    label.text = @"| 查询下级";
    [view addSubview:label];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(72, 10, 25, 25)];
    imageView.image = [UIImage imageNamed:@"details-arrow1"];
    [view addSubview:imageView];
    
    cell.accessoryView = view;
    
    if ([_cityList isKindOfClass:[NSArray class]]) {
        cell.textLabel.text = [_cityList[indexPath.row] objectForKey:@"name"];
        if ([_provinceName isEqualToString:@"北京市"] ||[_provinceName isEqualToString:@"上海市"] ||[_provinceName isEqualToString:@"天津市"] ||[_provinceName isEqualToString:@"重庆市"] ) {
            cell.accessoryView = [UIView new];
        }
    }else{
        NSArray *array = [_cityList objectForKey:@"cityName"];
        cell.textLabel.text = array[indexPath.row];
//        NSDictionary *dict =[[_cityList objectForKey:@"county"] objectAtIndex:indexPath.row];
//        if ([dict count]>0) {

//        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if (_cityblock) {
        NSString *code = @"";
        if ([_cityList isKindOfClass:[NSArray class]]) {
            NSString *cityName = [_cityList[indexPath.row] objectForKey:@"name"];
            id countyArray = [_cityList[indexPath.row] objectForKey:@"district"];
            if ((!countyArray)||([countyArray isKindOfClass:[NSDictionary class]])) {
                _cityblock(self,@"",cityName,_provinceName,code);
                return;
            }
            CountyViewController *countyVC = [CountyViewController new];
            countyVC.title = self.title;
            countyVC.cityName = cityName;
            countyVC.provinceName = _provinceName;
            countyVC.cityblock = _cityblock;
            countyVC.countyList = countyArray;
            [self.navigationController pushViewController:countyVC animated:YES];

        }else{
            NSArray *array = [_cityList objectForKey:@"cityCode"];
            code = array[indexPath.row];
            NSString *cityName = [[_cityList objectForKey:@"cityName"] objectAtIndex:indexPath.row];
            NSDictionary *dict =[[_cityList objectForKey:@"county"] objectAtIndex:indexPath.row];
//            if ([dict count]<=0) {
                _cityblock(self,@"",cityName,_provinceName,code);
//                return;
//            }
//            CountyViewController *countyVC = [CountyViewController new];
//            countyVC.title = self.title;
//            countyVC.cityName = cityName;
//            countyVC.provinceName = _provinceName;
//            countyVC.cityblock = _cityblock;
//            countyVC.countyList = dict;
//            [self.navigationController pushViewController:countyVC animated:YES];

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
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tapAction:(UITapGestureRecognizer *)tap{
    CityView *view = (CityView *)tap.view;
    NSIndexPath *indexPath = view.indexPath;
    NSArray *array = [_cityList objectForKey:@"cityCode"];
    NSString *code = array[indexPath.row];
    NSString *cityName = [[_cityList objectForKey:@"cityName"] objectAtIndex:indexPath.row];
    NSDictionary *dict =[[_cityList objectForKey:@"county"] objectAtIndex:indexPath.row];
    if ([dict count]<=0) {
        _cityblock(self,@"",cityName,_provinceName,code);
        return;
    }
    CountyViewController *countyVC = [CountyViewController new];
    countyVC.title = self.title;
    countyVC.cityName = cityName;
    countyVC.provinceName = _provinceName;
    countyVC.cityblock = _cityblock;
    countyVC.countyList = dict;
    [self.navigationController pushViewController:countyVC animated:YES];
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
