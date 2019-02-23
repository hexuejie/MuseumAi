//
//  MUMyCommentCell.m
//  MuseumAi
//
//  Created by 魏宙辉 on 2018/10/23.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUMyCommentCell.h"

@interface MUMyCommentCell()

@property (weak, nonatomic) IBOutlet UILabel *commentLb;

@property (weak, nonatomic) IBOutlet UILabel *titleLb;
@property (weak, nonatomic) IBOutlet UIView *titleBgView;
@property (weak, nonatomic) IBOutlet UILabel *timeLb;

@end

@implementation MUMyCommentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.titleBgView.backgroundColor = kUIColorFromRGB(0xf5f5f5);
    self.titleBgView.layer.borderColor = kUIColorFromRGB(0xe5e5e5).CGColor;
    self.titleBgView.layer.borderWidth = 1.0f;
    self.titleBgView.layer.masksToBounds = YES;
    self.titleBgView.layer.cornerRadius = 2.0f;
}

- (void)bindCellWithModel:(MUComment *)comment {
    if (comment.content.description.length == 0) {
        self.commentLb.text = @"[图片]";
    }else {
        self.commentLb.text = comment.content.description;
    }
    self.titleLb.text = comment.title.description;
    self.timeLb.text = comment.time.description;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
