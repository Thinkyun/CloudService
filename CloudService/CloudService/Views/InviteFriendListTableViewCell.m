//
//  InviteFriendTableViewCell.m
//  cutPhoto
//
//  Created by mac on 16/5/3.
//  Copyright © 2016年 DJ. All rights reserved.
//


#import "InviteFriendListTableViewCell.h"

@implementation InviteFriendListTableViewCell{
    UILabel *_nameLabel;
    UILabel *_phoneLabel;
    UILabel *_statusLabel;
    UILabel *_integralLable;
}

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

    UILabel *nameLable = [[UILabel alloc] initWithFrame:CGRectMake(30, 15, 150, 30)];
    _nameLabel = nameLable;
    nameLable.textColor = [UIColor blackColor];
    nameLable.font = [UIFont systemFontOfSize:16];
    [self.contentView addSubview:nameLable];
    
    UILabel *phoneLable = [[UILabel alloc] initWithFrame:CGRectMake(30, 10+30+10, 200, 30)];
    _phoneLabel = phoneLable;
    phoneLable.textColor = [UIColor blackColor];
    phoneLable.font = [UIFont systemFontOfSize:16];
    [self.contentView addSubview:phoneLable];
    
    UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(KWidth-100-30, 15, 100, 30)];
    _statusLabel = statusLabel;
    statusLabel.textAlignment = NSTextAlignmentRight;
    statusLabel.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:statusLabel];
    
    UILabel *integralLable = [[UILabel alloc] initWithFrame:CGRectMake(KWidth-100-30, 10+30+10, 100, 30)];
    _integralLable = integralLable;
    integralLable.font = [UIFont systemFontOfSize:14];
    integralLable.textColor = [UIColor lightGrayColor];
    integralLable.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:integralLable];
}

- (void)setDataDict:(NSDictionary *)dataDict{
    if (_dataDict != dataDict) {
        _dataDict = dataDict;
        NSString *nameStr = [dataDict[@"realName"] length]>0? dataDict[@"realName"]:dataDict[@"userName"];
        NSString *phoneStr = dataDict[@"phoneNo"];
        BOOL isIntegral = [dataDict[@"completeOrder"] boolValue];
        NSString *statusStr =  !isIntegral?@"未出单":@"已出单";
        _nameLabel.text = [NSString stringWithFormat:@"姓名: %@",nameStr];
        _phoneLabel.text = [NSString stringWithFormat:@"号码: %@",phoneStr];
        _integralLable.text = isIntegral? @"积分已发":@"";
        _statusLabel.text = statusStr;
        _statusLabel.textColor = [statusStr isEqualToString:@"未出单"]?[UIColor greenColor]:[UIColor redColor];

    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
