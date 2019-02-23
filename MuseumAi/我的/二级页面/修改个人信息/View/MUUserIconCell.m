//
//  MUUserIconCell.m
//  MuseumAi
//
//  Created by Kingo on 2018/9/26.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUUserIconCell.h"

@implementation MUUserIconCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.iconImageView.layer.masksToBounds = YES;
    self.iconImageView.layer.cornerRadius = 22.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
