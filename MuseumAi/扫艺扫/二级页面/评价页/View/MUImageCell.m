//
//  MUImageCell.m
//  MuseumAi
//
//  Created by 魏宙辉 on 2018/9/26.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUImageCell.h"

@implementation MUImageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.photoImageView.layer.masksToBounds = YES;
    self.photoImageView.contentMode = UIViewContentModeScaleAspectFill;
}

@end
