//
//  MUExhibitionDescripeCell.m
//  MuseumAi
//
//  Created by Kingo on 2018/9/27.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUExhibitionDescripeCell.h"

@interface MUExhibitionDescripeCell()

@property (weak, nonatomic) IBOutlet UILabel *contentLb;

@property (weak, nonatomic) IBOutlet UIButton *operationTextBt;
@property (weak, nonatomic) IBOutlet UIButton *operationImageBt;
@property (weak, nonatomic) IBOutlet UIView *operationBgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *operationBgHeight;


@end

@implementation MUExhibitionDescripeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.separatorInset = UIEdgeInsetsMake(0, SCREEN_WIDTH, 0, 0);
}

- (void)bindCellWithModel:(MUExhibitionDetailModel *)exhibition delegate:(id<MUExhibitionCellDelegate>)delegate {
    
    self.delegate = delegate;
    self.contentLb.text = exhibition.exhibitionIntroduce;
    if (exhibition.foldEnable) {
        self.operationBgView.hidden = NO;
        self.operationBgHeight.constant = 20.0f;
        if (exhibition.fold) {
            self.operationTextBt.selected = YES;
            self.operationImageBt.selected = YES;
        }else {
            self.operationTextBt.selected = NO;
            self.operationImageBt.selected = NO;
        }
    }else {
        self.operationBgView.hidden = YES;
        self.operationBgHeight.constant = 0.0f;
    }
    
}

#pragma mark -

- (IBAction)didOperationClicked:(id)sender {
    if (_delegate != nil &&
        [_delegate respondsToSelector:@selector(didOperationClickedInCell:)]) {
        [_delegate didOperationClickedInCell:self];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
