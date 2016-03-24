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

@interface SelectCityViewController ()

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
    
    
    [self setupProvinceTableView];
    
    [self setupCityTableView];
    // Do any additional setup after loading the view.
}
/**
 *  初始化省份表格
 */
- (void)setupProvinceTableView{
    

    self.provinceTableView.tag = TAG_PROVINCE;
    self.provinceTableView.showsVerticalScrollIndicator = NO;
    self.provinceTableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.provinceTableView.sectionIndexColor = [UIColor grayColor];
    
    
    // 头部view
    UIView *viewHead = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PROVINCE_WIDTH, 44)];
    [viewHead setBackgroundColor:[HelperUtil colorWithHexString:@"#F4F4F4"]];
    [self.provinceTableView setTableHeaderView:viewHead];
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 70, 44)];
    [lbl setText:@"省份"];
    [lbl setBackgroundColor:[UIColor whiteColor]];
    [lbl setFont:TGSystemFontContent];
    [viewHead addSubview:lbl];
    
    UILabel *lblLine2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 43, PROVINCE_WIDTH, 1)];
    [lblLine2 setBackgroundColor:[UIColor darkGrayColor]];
    [viewHead addSubview:lblLine2];
    
    UILabel *lblLine1 = [[UILabel alloc] initWithFrame:CGRectMake(99, 0, 1, 44)];
    [lblLine1 setBackgroundColor:[UIColor purpleColor]];
    [viewHead addSubview:lblLine1];

    
}
/**
 *  初始化城市表格
 */
- (void)setupCityTableView{


    self.cityTableView.tag = TAG_CITY;
    self.cityTableView.showsVerticalScrollIndicator = NO;
    self.cityTableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.cityTableView.sectionIndexColor = [UIColor grayColor];

    
    // 头部view
    UIView *viewHead = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PROVINCE_WIDTH, 44)];
    [viewHead setBackgroundColor:[HelperUtil colorWithHexString:@"#F4F4F4"]];
    [self.cityTableView setTableHeaderView:viewHead];

    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 70, 44)];
    [lbl setText:@"城市"];
    [lbl setBackgroundColor:[UIColor darkGrayColor]];
    [lbl setFont:TGSystemFontContent];
    [viewHead addSubview:lbl];
    
    UILabel *lblLine2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 43, self.view.frame.size.width - PROVINCE_WIDTH, 1)];
    [lblLine2 setBackgroundColor:[UIColor redColor]];
    [viewHead addSubview:lblLine2];
    
}
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    switch (tableView.tag) {
            // 省份
        case TAG_PROVINCE:
            return 20;
            break;
            
            // 城市
        case TAG_CITY:
        {
//            // 当前选中省份的城市
//            FTYProvinceModel *province = self.provinces[self.isSelectProvince];
            return 20;
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
            

            
            return cell;
        }
            break;
            
        default:
            break;
    }
    return nil;
    
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
