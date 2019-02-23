//
//  MUFloorCell.m
//  MuseumAi
//
//  Created by Kingo on 2018/9/28.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUFloorCell.h"

@implementation MUFloorCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.floorLb.layer.cornerRadius = 15.0f;
    self.floorLb.layer.masksToBounds = YES;
}

@end
