//
//  MUCollectionCell.m
//  MuseumAi
//
//  Created by 魏宙辉 on 2018/9/22.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUExhibitCell.h"

@implementation MUExhibitCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.exhibitNameLb.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.2f];
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    
    self.exhibitImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.exhibitImageView.layer.masksToBounds = YES;
    
    self.detailBgView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
    self.detailLb.backgroundColor = [UIColor clearColor];
    self.detailLb.textColor = [UIColor whiteColor];
    self.detailBgView.hidden = YES;
    
}

@end
