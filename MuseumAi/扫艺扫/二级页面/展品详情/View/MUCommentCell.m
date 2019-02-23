//
//  MUCommentCell.m
//  MuseumAi
//
//  Created by 魏宙辉 on 2018/9/24.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUCommentCell.h"
#import "NotesPhotoContainerView.h"

@interface MUCommentCell()
{
    LOVECLICKEDBLOCK _loveBlock;
}

@property (weak, nonatomic) IBOutlet UILabel *authorNameLb;

@property (weak, nonatomic) IBOutlet UILabel *contentHeightLb;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentHeightConstraint;

@property (weak, nonatomic) IBOutlet NotesPhotoContainerView *photoContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *photoTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *photoHeightConstraint;

@property (weak, nonatomic) IBOutlet UILabel *timeLb;

@property (weak, nonatomic) IBOutlet UIButton *loveNumBt;
@property (weak, nonatomic) IBOutlet UIButton *loveImageBt;

@end

@implementation MUCommentCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    [self.loveImageBt setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    self.photoContainer.backgroundColor = [UIColor clearColor];
    self.contentHeightLb.numberOfLines = 0;
}

- (void)bindCellWithModel:(MUCommentModel *)model loveClicked:(LOVECLICKEDBLOCK)loveBlock{
    
    _loveBlock = loveBlock;
    self.authorNameLb.text = model.authorName;
    
    self.contentHeightConstraint.constant = model.contentHeight;
    if (self.contentHeightConstraint.constant == 0) {
        self.contentTopConstraint.constant = 0;
        self.contentHeightLb.hidden = YES;
        self.contentHeightLb.text = @"";
    }else {
        self.contentTopConstraint.constant = 5;
        self.contentHeightLb.hidden = NO;
        self.contentHeightLb.text = model.content;
    }
    
    if ([model photoHeight] == 0) {
        self.photoTopConstraint.constant = 0.0f;
        self.photoHeightConstraint.constant = 0.0f;
        self.photoContainer.hidden = YES;
    }else {
        self.photoTopConstraint.constant = 5.0f;
        self.photoHeightConstraint.constant = [model photoHeight];
        self.photoContainer.hidden = NO;
        self.photoContainer.photoContainerWidth = SCREEN_WIDTH-30.0f;
        self.photoContainer.picPathStringsArray = model.images;
        self.photoContainer.bigPicPathStringArray = model.images;
    }
    
    self.timeLb.text = model.createDate;
    [self.loveNumBt setTitle:[NSString stringWithFormat:@"%ld",model.count] forState:UIControlStateNormal];
}

- (IBAction)didLoveBtClicked:(id)sender {
    if (_loveBlock != nil) {
        _loveBlock();
    }
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
