//
//  MUMineIconCell.m
//  MuseumAi
//
//  Created by Kingo on 2018/9/25.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUMineIconCell.h"

@implementation MUMineIconCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.levelLb.layer.masksToBounds = YES;
    self.levelLb.layer.cornerRadius = 10.0f;
    self.levelLb.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.2];
    
    self.iconImageView.layer.masksToBounds = YES;
    self.iconImageView.layer.cornerRadius = 22.0f;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
