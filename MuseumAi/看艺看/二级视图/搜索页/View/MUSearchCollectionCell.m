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
        self.searchIcon = [[UIImageView alloc]init];
        self.searchIcon.image = [UIImage imageNamed:@"搜索"];
        [self.contentView addSubview:self.searchIcon];
        
        // 用约束来初始化控件:
        self.textLabel = [[UILabel alloc] init];
        self.textLabel.font = [UIFont systemFontOfSize:14.0f];
        self.textLabel.textColor = kUIColorFromRGB(0x333333);
//        self.textLabel.textAlignment =NSTextAlignmentCenter;
//        self.textLabel.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.1];
        [self.contentView addSubview:self.textLabel];
        
        [self.searchIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(15);
            make.centerY.equalTo(self.contentView);
            make.size.mas_equalTo(CGSizeMake(17, 17));
        }];
        [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.searchIcon.mas_right).offset(5);
            make.centerY.equalTo(self.contentView);
        }];
        
        UIView *lineView = [[UIView alloc]init];
        lineView.backgroundColor = kUIColorFromRGB(0xDEDEDE);
        [self.contentView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.contentView);
            make.height.mas_equalTo(1);
        }];
        
    }
    return self;
}

@end

