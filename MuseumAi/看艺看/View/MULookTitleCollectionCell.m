//
//  MULookTitleCollectionCell.m
//  MuseumAi
//
//  Created by Kingo on 2018/9/19.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MULookTitleCollectionCell.h"

@implementation MULookTitleCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.tagLineView.layer.cornerRadius = 1.0;
    self.tagLineView.layer.masksToBounds = YES;
}

@end
