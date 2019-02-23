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
// 描述
@property (weak, nonatomic) IBOutlet UILabel *exContentLb;
// 位置
@property (weak, nonatomic) IBOutlet UILabel *exPositionLb;
// 售票状态
@property (weak, nonatomic) IBOutlet UILabel *exSellStatusLb;
// 收藏
@property (weak, nonatomic) IBOutlet UILabel *exCollectionLb;
// 时间状态
@property (weak, nonatomic) IBOutlet UILabel *exTimeStatusLb;

@end

@implementation MUExhibitionTableCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.exImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.exImageView.layer.cornerRadius = 8.0f;
    self.exImageView.layer.masksToBounds = YES;
    
}

- (void)bindCellWithExhibition:(MUExhibitionModel *)exhibition {
    
    [self.exImageView sd_setImageWithURL:[NSURL URLWithString:exhibition.imageUrl] placeholderImage:[UIImage imageNamed:@"加载占位"]];
    self.exNameLb.text = exhibition.name;
    self.exContentLb.text = exhibition.introduce;
    self.exDistanceLb.text = [NSString stringWithFormat:@"距离:%@km",exhibition.distance];
    self.exPositionLb.text = [NSString stringWithFormat:@"%@ %@",exhibition.position,exhibition.address];
    
    switch (exhibition.sell) {
        case MUExhibitionTicketTypeFree:
            self.exSellStatusLb.text = @"售票状态:免费";
            break;
        case MUExhibitionTicketTypeSell:
            self.exSellStatusLb.text = @"售票状态:在售";
            break;
        case MUExhibitionTicketTypeUnSell:
            self.exSellStatusLb.text = @"售票状态:停售";
            
        default:
            break;
    }
    self.exCollectionLb.text = [NSString stringWithFormat:@"%@收藏",exhibition.loveCount];
    self.exTimeStatusLb.text = exhibition.time;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
