//
//  MUMyCommentCollectionViewCell.m
//  MuseumAi
//
//  Created by 何学杰 on 2019/3/7.
//  Copyright © 2019 Weizh. All rights reserved.
//

#import "MUMyCommentCollectionViewCell.h"

@implementation MUMyCommentCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


- (void)bindCellWithModel:(MUComment *)comment {
    if (comment.content.description.length == 0) {
        self.commentLabel.text = @"[图片]";
    }else {
        self.commentLabel.text = comment.content.description;
    }
//    self.nameLabel.text = comment.title.description;
    self.timeLb.text = comment.time.description;
    
    
    [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:[MUUserModel currentUser].photo] placeholderImage:[UIImage imageNamed:@"加载占位"]];
    self.nameLabel.text = [MUUserModel currentUser].nikeName;
    self.VIPLabel.text = [NSString stringWithFormat:@"Lv.%@",[MUUserModel currentUser].vipGrade];
    
    self.commentLabel.text = comment.content;
    self.originalLabel.text = comment.title;
}
@end
