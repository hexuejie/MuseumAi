//
//  MUExhibitionTableCell.m
//  MuseumAi
//
//  Created by Kingo on 2018/9/19.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUExhibitionTableCell.h"
#import "UIImageView+WebCache.h"

@interface MUExhibitionTableCell()

// 图片
@property (weak, nonatomic) IBOutlet UIImageView *exImageView;
// 展览名
@property (weak, nonatomic) IBOutlet UILabel *exNameLb;
// 距离
@property (weak, nonatomic) IBOutlet UILabel *exDistanceLb;
// 位置
@property (weak, nonatomic) IBOutlet UILabel *exPositionLb;

@property (weak, nonatomic) IBOutlet UILabel *freeLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (weak, nonatomic) IBOutlet UILabel *collectLabel;

@end
@implementation MUExhibitionTableCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.exImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.exImageView.layer.cornerRadius = 5.0f;
    self.exImageView.layer.masksToBounds = YES;
    
    self.freeLabel.layer.borderWidth = 1.0;
    self.freeLabel.layer.borderColor = self.freeLabel.textColor.CGColor;
    self.statusLabel.layer.borderWidth = 1.0;
    self.statusLabel.layer.borderColor = self.freeLabel.textColor.CGColor;
    self.freeLabel.layer.masksToBounds = YES;
    self.freeLabel.layer.cornerRadius = 4.0;
    self.statusLabel.layer.masksToBounds = YES;
    self.statusLabel.layer.cornerRadius = 4.0;
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.collectLabel.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(5, 5)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.collectLabel.bounds;
    maskLayer.path = maskPath.CGPath;
    self.collectLabel.layer.mask = maskLayer;
}

- (void)bindCellWithExhibition:(MUExhibitionModel *)exhibition {
    
    [self.exImageView sd_setImageWithURL:[NSURL URLWithString:exhibition.imageUrl] placeholderImage:[UIImage imageNamed:@"加载占位"]];
    self.exNameLb.text = exhibition.name;

    self.exDistanceLb.text = [NSString stringWithFormat:@"%@/km",exhibition.distance];
//    self.exPositionLb.text = [NSString stringWithFormat:@"%@ %@",exhibition.position,exhibition.address];
    
    switch (exhibition.sell) {
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
    self.collectLabel.text = [NSString stringWithFormat:@"%@人收藏",exhibition.loveCount];
    self.statusLabel.text = exhibition.time;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
