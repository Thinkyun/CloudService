//
//  ChooseCompanyViewController.m
//  CloudService
//
//  Created by zhangqiang on 16/3/15.
//  Copyright © 2016年 zhangqiang. All rights reserved.
//

#import "ChooseCompanyViewController.h"
#import "HeaderCompanyView.h"
#import "TagSelectItem.h"
#import "CodeNameModel.h"

static NSString *cell_Id = @"cell_Id";
static NSString *header_Id = @"header_Id";
@interface ChooseCompanyViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>


@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation ChooseCompanyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    switch (self.type) {
        case chooseCompany:
            self.title = @"选择公司";
            break;
        case chooseCity:
            self.title = @"选择销售城市";
            break;
        default:
            break;
    }
    for (CodeNameModel *code in _dataArray) {
        NSLog(@"--dataArray------%@",code.companyName);
    }
    
    for (CodeNameModel *code in _selectArray) {
        NSLog(@"--------selectArray-------------%@",code.companyCode);
    }

    
    __weak typeof(self) weakSelf             = self;
    [self setLeftImageBarButtonItemWithFrame:CGRectMake(0, 0, 25, 25) image:@"title-back" selectImage:@"" action:^(AYCButton *button) {
        [weakSelf.navigationController popViewControllerAnimated:YES];
        switch (weakSelf.type) {
            case chooseCompany:
               [[NSNotificationCenter defaultCenter] postNotificationName:ChooseSaleCompany object:nil];
                break;
            case chooseCity:
                [[NSNotificationCenter defaultCenter] postNotificationName:ChooseSaleCity object:nil];
                break;
            default:
                break;
        }
        
    }];

    CGFloat inset                            = 4;
    UICollectionViewFlowLayout *flowLayOut   = [[UICollectionViewFlowLayout alloc] init];
    flowLayOut.minimumInteritemSpacing       = inset/2;
    flowLayOut.minimumLineSpacing            = inset/2;
    flowLayOut.sectionInset                  = UIEdgeInsetsMake(inset / 2.0, inset, inset / 2.0, inset);
    flowLayOut.itemSize                      = CGSizeMake(100, 55);
    flowLayOut.headerReferenceSize           = CGSizeMake(375, 44);

    [self.collectionView registerNib:[UINib nibWithNibName:@"TagSelectItem" bundle:nil] forCellWithReuseIdentifier:cell_Id];
    self.collectionView.backgroundColor      = [UIColor whiteColor];
    self.collectionView.collectionViewLayout = flowLayOut;
    [self.collectionView registerNib:[UINib nibWithNibName:@"HeaderCompanyView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:header_Id];

}



-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return section == 0 ? _selectArray.count : _dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    TagSelectItem *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cell_Id forIndexPath:indexPath];
    CodeNameModel *model = indexPath.section == 0 ? _selectArray[indexPath.row] : _dataArray[indexPath.row];
    switch (self.type) {
        case chooseCompany:
            cell.titleLabel.text = model.companyName;
            break;
        case chooseCity:
            cell.titleLabel.text = model.provinceName;
            break;
        default:
            break;
    }
    
  
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    HeaderCompanyView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:header_Id forIndexPath:indexPath];
    NSString *str;
    switch (self.type) {
        case chooseCompany:
            str = indexPath.section == 0 ? @"销售保险公司" : @"未添加保险公司";
            break;
        case chooseCity:
            str = indexPath.section == 0 ? @"销售数据城市" : @"未添加销售城市";
            break;
        default:
            break;
    }
    
    headerView.backgroundColor= [HelperUtil colorWithHexString:@"#DBDBDB"];
    headerView.title = str;
    
    return headerView;
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSIndexPath *toIndexPath = nil;
    NSString *selectObject = nil;
    if (indexPath.section == 0) {
        toIndexPath = [NSIndexPath indexPathForItem:_dataArray.count inSection:1];
        selectObject = _selectArray[indexPath.row];
        [_selectArray removeObjectAtIndex:indexPath.row];
        [_dataArray addObject:selectObject];
    }else {
        toIndexPath = [NSIndexPath indexPathForItem:_selectArray.count inSection:0];
        selectObject = _dataArray[indexPath.row];
        [_dataArray removeObjectAtIndex:indexPath.row];
        [_selectArray addObject:selectObject];
    }
    [collectionView moveItemAtIndexPath:indexPath toIndexPath:toIndexPath];
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
