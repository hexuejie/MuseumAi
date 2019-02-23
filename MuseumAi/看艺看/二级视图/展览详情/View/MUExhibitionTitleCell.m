//
//  MUExhibitionTitleCell.m
//  MuseumAi
//
//  Created by Kingo on 2018/9/27.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUExhibitionTitleCell.h"

@interface MUExhibitionTitleCell()

@property (weak, nonatomic) IBOutlet UIView *scoreBgView;
@property (weak, nonatomic) IBOutlet UILabel *scoreLb;
@property (weak, nonatomic) IBOutlet UILabel *memberLb;
@property (weak, nonatomic) IBOutlet UIImageView *start1IV;
@property (weak, nonatomic) IBOutlet UIImageView *start2IV;
@property (weak, nonatomic) IBOutlet UIImageView *start3IV;
@property (weak, nonatomic) IBOutlet UIImageView *start4IV;
@property (weak, nonatomic) IBOutlet UIImageView *start5IV;

@property (weak, nonatomic) IBOutlet UILabel *exhibitionNameLb;

@property (weak, nonatomic) IBOutlet UILabel *exhibtionTimeLb;

@property (weak, nonatomic) IBOutlet UILabel *exhibitionTicketsLb;

@property (weak, nonatomic) IBOutlet UILabel *exhibitionPositionLb;

@end

@implementation MUExhibitionTitleCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.separatorInset = UIEdgeInsetsMake(0, SCREEN_WIDTH, 0, 0);
    self.exhibitionImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.exhibitionImageView.layer.masksToBounds = YES;
    [self.exhibitionImageView addTapTarget:self action:@selector(didImageTapped:)];
    [self.scoreBgView addTapTarget:self action:@selector(didScoreTapped:)];
    
    self.scoreBgView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.scoreBgView.layer.shadowOpacity = 0.35;
    self.scoreBgView.layer.shadowRadius = 5.0f;
    self.scoreBgView.layer.shadowOffset = CGSizeMake(5.0f, 5.0f);
}

- (void)bindCellWithModel:(MUExhibitionDetailModel *)exhibition delegate:(id<MUExhibitionCellDelegate>)delegate {
    
    self.delegate = delegate;
    NSURL *imageUrl = [NSURL URLWithString:exhibition.imageUrl];
    [self.exhibitionImageView sd_setImageWithURL:imageUrl placeholderImage:kPlaceHolderImage];
    CGFloat score = [exhibition.score doubleValue];
    NSArray *starts = @[self.start1IV,self.start2IV,self.start3IV,self.start4IV,self.start5IV];
    int int_score = ceil(score);
    if (int_score < 0) {
        int_score = 0;
    }
    if (int_score > 10) {
        int_score = 10;
    }
    for (int i=0; i<starts.count; i++) {
        UIImageView *startIV = starts[i];
        if (i < int_score/2) {
            startIV.image = [UIImage imageNamed:@"星星"];
        } else if(i == int_score/2) {
            if (int_score%2 == 0) {
                startIV.image = [UIImage imageNamed:@"空星"];
            }else {
                startIV.image = [UIImage imageNamed:@"半星"];
            }
        } else {
            startIV.image = [UIImage imageNamed:@"空星"];
        }
    }
    self.scoreLb.text = [NSString stringWithFormat:@"%@分",exhibition.score];
    self.memberLb.text = [NSString stringWithFormat:@"(%@点评)",exhibition.userCount];
    
    self.exhibitionNameLb.text = exhibition.exhibitionName;
    self.exhibtionTimeLb.text = exhibition.exhibitionTime;
    switch (exhibition.sellState) {
        case MUExhibitionTicketTypeFree:
            self.exhibitionTicketsLb.text = @"免费";
            break;
        case MUExhibitionTicketTypeSell:
            self.exhibitionTicketsLb.text = @"售票";
            break;
        case MUExhibitionTicketTypeUnSell:
            self.exhibitionTicketsLb.text = @"停售";
            break;
        default:
            break;
    }
    self.exhibitionPositionLb.text = exhibition.exhibitionPosition;
}

- (void)didImageTapped:(id)sender {
    if (_delegate != nil &&
        [_delegate respondsToSelector:@selector(didImageTappedInCell:)]) {
        [_delegate didImageTappedInCell:self];
    }
}
- (void)didScoreTapped:(id)sender {
    if (_delegate != nil &&
        [_delegate respondsToSelector:@selector(didScoreTappedInCell:)]) {
        [_delegate didScoreTappedInCell:self];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
