//
//  CityTableViewCell.m
//  CloudService
//
//  Created by 安永超 on 16/5/12.
//  Copyright © 2016年 zhangqiang. All rights reserved.
//

#import "CityTableViewCell.h"

@implementation CityTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(KWidth-20-80, 0, 80, 44)];
        view.backgroundColor =[ UIColor whiteColor];
        [self.contentView addSubview:view];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 80, 44)];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor darkGrayColor];
        label.text = @"| 查询下级";
        [view addSubview:label];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
