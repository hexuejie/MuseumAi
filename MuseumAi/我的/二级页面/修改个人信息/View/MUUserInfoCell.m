//
//  MUUserInfoCell.m
//  MuseumAi
//
//  Created by Kingo on 2018/9/26.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUUserInfoCell.h"

@implementation MUUserInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
   [self.manButton setTitleColor:kUIColorFromRGB(0xDCDCDC) forState:UIControlStateNormal];
    [self.manButton setTitleColor:kMainColor forState:UIControlStateSelected];
    self.manButton.layer.borderWidth = 1.0;
//    self.manButton.layer.borderColor = self.manButton.titleLabel.textColor.CGColor;
    [self.womanButton setTitleColor:kUIColorFromRGB(0xDCDCDC) forState:UIControlStateNormal];
    [self.womanButton setTitleColor:kMainColor forState:UIControlStateSelected];
    self.womanButton.layer.borderWidth = 1.0;
//    self.womanButton.layer.borderColor = self.womanButton.titleLabel.textColor.CGColor;
    self.womanButton.backgroundColor = [UIColor clearColor];
    self.manButton.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
