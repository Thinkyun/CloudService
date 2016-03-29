//
//  SelectCityViewController.m
//  CloudService
//
//  Created by 安永超 on 16/3/23.
//  Copyright © 2016年 zhangqiang. All rights reserved.
//


// tableView的tag值（用来区分两个tableView）
#define TAG_PROVINCE    100
#define TAG_CITY        101

#define TGSystemFontContent         [UIFont systemFontOfSize:14]//内容

#define PROVINCE_WIDTH  100

#import "SelectCityViewController.h"
#import "DataSource.h"
#import <FMDB.h>
#import "CodeNameModel.h"

@interface SelectCityViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *_provinceArray;
    NSMutableArray *_cityArray;

}
/**
 *  省份的tableView
 */
@property (nonatomic, weak)IBOutlet UITableView *provinceTableView;
/**
 *  城市的tableView
 */
@property (weak, nonatomic)IBOutlet UITableView *cityTableView;

@end

@implementation SelectCityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _provinceArray = [NSMutableArray array];
    _cityArray = [NSMutableArray array];
    /**
     *  取出省份数组
     */
    NSArray *provinceNameArray = [DataSource provinceArray];
    /**
     *  取出省份code
     */
    NSDictionary *provinceCodeDict = [DataSource provinceCodeDict];
   
    for (int i = 0; i<provinceNameArray.count; i++) {
        CodeNameModel *proviceModel = [CodeNameModel new];
        proviceModel.provinceName = provinceNameArray[i];
        proviceModel.provinceCode = [provinceCodeDict valueForKey:provinceNameArray[i]];
        proviceModel.isCheck = NO;
        [_provinceArray addObject:proviceModel];
    }
    
    CodeNameModel *proviceModel = _provinceArray[0];
    [self searchCityinProvinceCode:proviceModel.provinceCode];
    

    // Do any additional setup after loading the view.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    switch (tableView.tag) {
            // 省份
        case TAG_PROVINCE:
            return _provinceArray.count;
            break;
            
            // 城市
        case TAG_CITY:
        {

            return _cityArray.count;
        }
            break;
            
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (tableView.tag) {
        case TAG_PROVINCE:
        {
            static NSString *ID = @"provice";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
            }
            CodeNameModel *provinceModel = [_provinceArray objectAtIndex:indexPath.row];
            cell.textLabel.text = provinceModel.provinceName;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkProvince:)];
            cell.imageView.tag = indexPath.row;
            cell.imageView.userInteractionEnabled = YES;
            [cell.imageView addGestureRecognizer:tap];
//            UIView *view = [UIView new];
//            view.backgroundColor = [UIColor redColor];
//            cell.selectedBackgroundView  = view;
            if (provinceModel.isCheck) {
                cell.imageView.image = [UIImage imageNamed:@"ico_check_circle"];
            }else {
                cell.imageView.image = [UIImage imageNamed:@"ico_circle_o"];
            }
            
            return cell;
        }
            break;
        case TAG_CITY:
        {
            
            static NSString *ID = @"city";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
            }
            CodeNameModel *cityModel = [_cityArray objectAtIndex:indexPath.row];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = cityModel.cityName;
            if (cityModel.isCheck) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            

            return cell;
        }
            break;
            
        default:
            break;
    }
    return nil;
    
}
- (void)checkProvince:(UITapGestureRecognizer *)sender {
    CodeNameModel *proviceModel = _provinceArray[sender.view.tag];
    proviceModel.isCheck = !proviceModel.isCheck;
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:sender.view.tag inSection:0];
    [self.provinceTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (tableView.tag == TAG_PROVINCE) {
        CodeNameModel *proviceModel = _provinceArray[indexPath.row];
        [self searchCityinProvinceCode:proviceModel.provinceCode];
        [self.cityTableView reloadData];
    }
    if (tableView.tag == TAG_CITY) {
        CodeNameModel *cityModel = _cityArray[indexPath.row];
        cityModel.isCheck = !cityModel.isCheck;
        [self.cityTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
    }
}


/**
 *  搜索城市
 *
 *  @param provinceCode 省编码
 *
 *  @return 市
 */
- (void)searchCityinProvinceCode:(NSString *)provinceCode {
    
    [_cityArray removeAllObjects];

    NSString *path = [[NSBundle mainBundle] pathForResource:@"province" ofType:@"sqlite"];
    FMDatabase *db = [FMDatabase databaseWithPath:path];
    if (![db open]) {
        NSLog(@"数据库打开失败!");
        return;
    }
    NSString *sqlStr = [NSString stringWithFormat:@"SELECT * FROM city where cityCode like '%@%%'",provinceCode];
    FMResultSet *result = [db executeQuery:sqlStr];
    while ([result next]) {

        CodeNameModel *cityModel = [CodeNameModel new];
        cityModel.cityName = [result stringForColumn:@"cityName"];
        cityModel.cityCode = [result stringForColumn:@"cityCode"];
        cityModel.isCheck = NO;
        [_cityArray addObject:cityModel];
    }
    [db close];
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
