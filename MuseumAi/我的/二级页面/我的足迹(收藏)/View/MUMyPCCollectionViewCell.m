//
//  MUMyPCCollectionViewCell.m
//  MuseumAi
//
//  Created by 何学杰 on 2019/3/7.
//  Copyright © 2019 Weizh. All rights reserved.
//

#import "MUMyPCCollectionViewCell.h"

@implementation MUMyPCCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.exhibitImageView.layer.masksToBounds = YES;
    self.exhibitImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.exhibitImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.exhibitImageView.layer.cornerRadius = 5.0f;
    self.exhibitImageView.layer.masksToBounds = YES;
    
    self.freeLabel.layer.borderWidth = 1.0;
    self.freeLabel.layer.borderColor = self.freeLabel.textColor.CGColor;
    self.freeLabel.layer.masksToBounds = YES;
    self.freeLabel.layer.cornerRadius = 4.0;

    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.collectLabel.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(5, 5)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.collectLabel.bounds;
    maskLayer.path = maskPath.CGPath;
    self.collectLabel.layer.mask = maskLayer;
}

- (void)bindCellWithExhibitModel:(MUExhibitModel *)model {
    if (model.exhibitUrl) {
        [self.exhibitImageView sd_setImageWithURL:[NSURL URLWithString:model.exhibitUrl] placeholderImage:[UIImage imageNamed:@"加载占位"]];
    }
    self.exhibitNameLb.text = model.exhibitName;
    self.exhibitDescriptLb.text = model.exhibitsDescribe;

    self.exhibitDescriptLb.hidden = NO;
    self.freeLabel.hidden = YES;
    self.collectLabel.hidden = YES;
}

- (void)bindCellWithExhibitionModel:(MUExhibitionModel *)model {
    self.exhibitDescriptLb.hidden = YES;
    self.freeLabel.hidden = NO;
    self.collectLabel.hidden = NO;
    if (model.imageUrl) {
        [self.exhibitImageView sd_setImageWithURL:[NSURL URLWithString:model.imageUrl] placeholderImage:[UIImage imageNamed:@"加载占位"]];
    }
        self.exhibitNameLb.text = model.name;
    switch (model.sell) {
        case MUExhibitionTicketTypeFree:
            self.freeLabel.text = @"免费";
            break;
        case MUExhibitionTicketTypeSell:
            self.freeLabel.text = @"在售";
            break;
        case MUExhibitionTicketTypeUnSell:
            self.freeLabel.text = @"停售";
            
        default:
            break;
    }
    self.collectLabel.text = [NSString stringWithFormat:@"%@人收藏",model.loveCount];
}

@end
