//
//  InviteFriendTableViewCell.m
//  cutPhoto
//
//  Created by mac on 16/5/3.
//  Copyright © 2016年 DJ. All rights reserved.
//

#define kWidth [UIScreen mainScreen].bounds.size.width

#import "InviteFriendListTableViewCell.h"

@implementation InviteFriendListTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setup];
    }
    return self;
}

- (void)setup{
    NSString *nameStr = @"fda";
    NSString *phoneStr = @"343424324314";
    NSString *statusStr = @"未出单";
    BOOL isIntegral = NO;
    UILabel *nameLable = [[UILabel alloc] initWithFrame:CGRectMake(30, 15, 150, 30)];
    nameLable.textColor = [UIColor blackColor];
    nameLable.font = [UIFont systemFontOfSize:16];
    nameLable.text = [NSString stringWithFormat:@"姓名: %@",nameStr];
    [self.contentView addSubview:nameLable];
    
    UILabel *phoneLable = [[UILabel alloc] initWithFrame:CGRectMake(30, 10+30+10, 200, 30)];
    phoneLable.textColor = [UIColor blackColor];
    phoneLable.font = [UIFont systemFontOfSize:16];
    phoneLable.text = [NSString stringWithFormat:@"号码: %@",phoneStr];
    [self.contentView addSubview:phoneLable];
    
    UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(kWidth-100-30, 15, 100, 30)];
    statusLabel.textColor = [statusStr isEqualToString:@"未出单"]?[UIColor greenColor]:[UIColor redColor];
    statusLabel.textAlignment = NSTextAlignmentRight;
    statusLabel.font = [UIFont systemFontOfSize:14];
    statusLabel.text = statusStr;
    [self.contentView addSubview:statusLabel];
    
    UILabel *integralLable = [[UILabel alloc] initWithFrame:CGRectMake(kWidth-100-30, 10+30+10, 100, 30)];
    integralLable.font = [UIFont systemFontOfSize:14];
    integralLable.textColor = [UIColor lightGrayColor];
    integralLable.text = isIntegral? @"积分已发":@"";
    integralLable.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:integralLable];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
