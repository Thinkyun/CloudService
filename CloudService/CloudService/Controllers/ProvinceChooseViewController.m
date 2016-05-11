//
//  ProvinceChooseViewController.m
//  CloudService
//
//  Created by 安永超 on 16/5/9.
//  Copyright © 2016年 zhangqiang. All rights reserved.
//

#import "ProvinceChooseViewController.h"
#import "CityChooseViewController.h"
#import "UIView+YYAdd.h"

@interface ProvinceChooseViewController ()<UITableViewDataSource,UITableViewDelegate>{
    UIButton *_locationBtn;
}


@end

@implementation ProvinceChooseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    __weak typeof(self) weakSelf = self;
    [weakSelf setLeftImageBarButtonItemWithFrame:CGRectMake(0, 0, 30, 30) image:@"title-back" selectImage:@"back" action:^(AYCButton *button) {
        
        [[FireData sharedInstance] eventWithCategory:@"选择省份" action:@"返回" evar:nil attributes:nil];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    
    [self setupUI];
    // Do any additional setup after loading the view.
}

- (void)setupUI{
//    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KWidth, 164)];
//    topView.backgroundColor =[UIColor colorWithRed:239.0/255 green:239.0/255 blue:239.0/255 alpha:1];
//    [self.view addSubview:topView];
//    
//    //推荐
//    UILabel *topLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, KWidth-20, 20)];
//    topLabel.backgroundColor = [UIColor colorWithRed:239.0/255 green:239.0/255 blue:239.0/255 alpha:1];
//    topLabel.text = @"推荐";
//    [topView addSubview:topLabel];
//    
//    //定位
//    UIButton *locationBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, topLabel.bottom, KWidth, 44)];
//    locationBtn.backgroundColor = [UIColor whiteColor];
//    [locationBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [locationBtn setTitle:_locationCity forState:UIControlStateNormal];
//    [locationBtn setContentEdgeInsets:UIEdgeInsetsMake(0, - 120, 0, 0)];
//    [locationBtn addTarget:self action:@selector(locationAction:) forControlEvents:UIControlEventTouchUpInside];
//    [topView addSubview:locationBtn];
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10,25, 25)];
//    imageView.image = [UIImage imageNamed:@"local"];
//    [locationBtn addSubview:imageView];
//    _locationBtn = locationBtn;
//    
//    if(_isHidenLocation){
//        locationBtn.hidden = YES;
//        locationBtn.bottom = 20;
//    }
//    //推荐的城市
//    NSArray *titles = @[@"北京",@"上海",@"天津",@"重庆",@"杭州",@"广州",@"深圳",@"成都"];
//    for (int i = 0; i<8; i++) {
//        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(i%4*(KWidth/4),locationBtn.bottom+i/4*40, (KWidth/4), 40)];
//        btn.backgroundColor = [UIColor whiteColor];
//        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [btn setTitle:titles[i] forState:UIControlStateNormal];
//        [btn addTarget:self action:@selector(commentCityAction:) forControlEvents:UIControlEventTouchUpInside];
//        btn.tag = 100001+i;
//        [topView addSubview:btn];
//    }
//    
//    for(int i = 1;i<=7;i++){
//        UIView *lineView = [self lineView];
//        lineView.frame = CGRectMake(i%4*(KWidth/4), locationBtn.bottom+i/4*40+5, 0.5, 30);
//        [topView addSubview:lineView];
//    }
// 
//    //省
//    UILabel *bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, locationBtn.bottom+80, 35, 20)];
//    bottomLabel.backgroundColor = [UIColor colorWithRed:239.0/255 green:239.0/255 blue:239.0/255 alpha:1];
//    bottomLabel.font = [UIFont systemFontOfSize:16];
//    bottomLabel.text = @"省";
//    [topView addSubview:bottomLabel];
//    
//    UILabel *rightBottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 0, KWidth-45, 20)];
//    rightBottomLabel.textColor = [UIColor lightGrayColor];
//    rightBottomLabel.font = [UIFont systemFontOfSize:14];
//    rightBottomLabel.text = @"推荐的不合适？从选择省份开始吧";
//    rightBottomLabel.backgroundColor = [UIColor colorWithRed:239.0/255 green:239.0/255 blue:239.0/255 alpha:1];
//    [bottomLabel addSubview:rightBottomLabel];
//    
//    {
//        //划线
//        UIView *lineView = [self lineView];
//        lineView.frame = CGRectMake(0, 20, KWidth, 0.5);
//        [topView addSubview:lineView];
//        
//        UIView *lineView1 = [self lineView];
//        lineView1.frame = CGRectMake(0, 64, KWidth, 0.5);
//        [topView addSubview:lineView1];
//        if (_isHidenLocation) {
//            lineView1.hidden = YES;
//        }
//        
//        UIView *lineView2 = [self lineView];
//        lineView2.frame = CGRectMake(0, locationBtn.bottom+40, KWidth, 0.5);
//        [topView addSubview:lineView2];
//        
//        UIView *lineView3 = [self lineView];
//        lineView3.frame = CGRectMake(0, locationBtn.bottom+80, KWidth, 0.5);
//        [topView addSubview:lineView3];
//    }
    
    //tableView
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,/*locationBtn.bottom+100*/0, KWidth, KHeight - 64 /*- (locationBtn.bottom+100)*/) style:UITableViewStylePlain];
    tableView.showsHorizontalScrollIndicator = NO;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
}

#pragma mark - setter



#pragma mark - tableViewDelegate Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.proviceList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont systemFontOfSize:14];
    }


    cell.textLabel.text = [_proviceList[indexPath.row] objectForKey:@"name"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CityChooseViewController *cityVC = [[CityChooseViewController alloc] init];
    cityVC.cityblock = [_cityblock copy];
    cityVC.title = self.title;
    cityVC.provinceName = [_proviceList[indexPath.row] objectForKey:@"name"];
    cityVC.cityList = [_proviceList[indexPath.row] objectForKey:@"city"];
    [self.navigationController pushViewController:cityVC animated:YES];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - BtnAction

- (void)locationAction:(UIButton *)btn{
    //取定位信息
    AYCLog(@"dinwei");
    [[FireData sharedInstance] eventWithCategory:self.navigationItem.title action:@"取定位地点" evar:nil attributes:nil];
    NSString *str = [btn titleForState:UIControlStateNormal];
    if ([str isEqualToString:@"获取不到定位信息"]) {
        return;
    }
    _popBlock(str);
    [self.navigationController popViewControllerAnimated:YES];
//    _cityblock(self,);
}

- (void)commentCityAction:(UIButton *)btn{
    //推荐城市信息
    AYCLog(@"%@",[btn titleForState:UIControlStateNormal]);
    if (btn.tag<=100001+3) {
        CityChooseViewController *cityVC = [[CityChooseViewController alloc] init];
        cityVC.cityblock = [_cityblock copy];
        cityVC.provinceName = [NSString stringWithFormat:@"%@市",[btn titleForState:UIControlStateNormal]];
        __block NSArray *tem;
        [_proviceList enumerateObjectsUsingBlock:^(NSDictionary  *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if([[obj objectForKey:@"name"] isEqualToString:cityVC.provinceName]){
                tem = [obj objectForKey:@"city"];
                *stop = YES;
            }
        }];
        cityVC.cityList = tem;
        [self.navigationController pushViewController:cityVC animated:YES];
    }else{
        NSString *proviceStr = [self proviceStrByCityStr:[btn titleForState:UIControlStateNormal]];
        _cityblock(self,[NSString stringWithFormat:@"%@市",[btn titleForState:UIControlStateNormal]],proviceStr,@"");
    }
}

- (UIView *)lineView{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor grayColor];
    return view;
}

- (NSString *)proviceStrByCityStr:(NSString *)city{
    if ([city isEqualToString:@"杭州"]) {
        return @"浙江省";
    }else if ([city isEqualToString:@"广州"]){
        return @"广东省";

    }else if ([city isEqualToString:@"深圳"]){
        return @"广东省";

    }else if ([city isEqualToString:@"成都"]){
        return @"四川省";
    }
    return @"";
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
