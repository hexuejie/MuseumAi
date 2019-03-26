//
//  MUCommentTitleCell.m
//  MuseumAi
//
//  Created by 魏宙辉 on 2018/9/24.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUCommentTitleCell.h"

@interface MUCommentTitleCell()
@property (weak, nonatomic) IBOutlet UILabel *commentTitleLb;

@end

@implementation MUCommentTitleCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
//    self.separatorInset = UIEdgeInsetsMake(0, SCREEN_WIDTH, 0, 0);
//    self.commentTitleLb.font = [UIFont boldSystemFontOfSize:15.0f];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
