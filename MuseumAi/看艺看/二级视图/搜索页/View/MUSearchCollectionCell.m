//
//  MUSearchCollectionCell.m
//  MuseumAi
//
//  Created by Kingo on 2018/9/20.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUSearchCollectionCell.h"

@implementation MUSearchCollectionCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        // 用约束来初始化控件:
        self.textLabel = [[UILabel alloc] init];
        self.textLabel.font = [UIFont systemFontOfSize:12.0f];
        self.textLabel.textColor = kUIColorFromRGB(0x333333);
        self.textLabel.textAlignment =NSTextAlignmentCenter;
        self.textLabel.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.1];
        [self.contentView addSubview:self.textLabel];
        [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(5);
            make.bottom.mas_equalTo(-5.0f);
            make.left.right.mas_equalTo(0);
        }];
    }
    return self;
}

@end

