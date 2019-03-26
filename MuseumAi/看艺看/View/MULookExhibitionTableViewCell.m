//
//  MULookExhibitionTableViewCell.m
//  MuseumAi
//
//  Created by 何学杰 on 2019/2/25.
//  Copyright © 2019 Weizh. All rights reserved.
//

#import "MULookExhibitionTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "MUExhibitionDetailViewController.h"

@interface MULookExhibitionTableViewCell ()


@end

@implementation MULookExhibitionTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self customLayout];
    

}

- (void)backViewClick:(UITapGestureRecognizer *)tap{
    NSInteger index = tap.view.tag-100;
    if (index < self.exhibitionModels.count) {
        
        MUExhibitionModel *model = self.exhibitionModels[index];
        if ([self.delegate respondsToSelector:@selector(lookExhibitionTableViewCellClick:withExhibitionId:)]){
            [self.delegate lookExhibitionTableViewCellClick:self withExhibitionId:model.hallId];
        }
    }
}

- (void)bindCellWithExhibition:(NSArray *)exhibitions {
    if (exhibitions.count<4) {
        return;
    }
    self.exhibitionModels = exhibitions;
    MUExhibitionModel *exhibition = exhibitions[0];
    [self.imageViewOne sd_setImageWithURL:[NSURL URLWithString:exhibition.imageUrl] placeholderImage:[UIImage imageNamed:@"加载占位"]];
    self.titleLabelOne.text = exhibition.name;
    self.localLabelOne.text = [NSString stringWithFormat:@"%@/km",exhibition.distance];
    switch (exhibition.sell) {
        case MUExhibitionTicketTypeFree:
            self.freeLabelOne.text = @"免费";
            break;
        case MUExhibitionTicketTypeSell:
            self.freeLabelOne.text = @"在售";
            break;
        case MUExhibitionTicketTypeUnSell:
            self.freeLabelOne.text = @"停售";
            
        default:
            break;
    }
    self.collectLabelOne.text = [NSString stringWithFormat:@"%@人收藏",exhibition.loveCount];
    self.statusLabelOne.text = exhibition.time;
    
    
    exhibition = exhibitions[1];
    [self.imageViewTwo sd_setImageWithURL:[NSURL URLWithString:exhibition.imageUrl] placeholderImage:[UIImage imageNamed:@"加载占位"]];
    self.titleLabelTwo.text = exhibition.name;
    self.localLabelTwo.text = [NSString stringWithFormat:@"%@/km",exhibition.distance];
    switch (exhibition.sell) {
        case MUExhibitionTicketTypeFree:
            self.freeLabelTwo.text = @"免费";
            break;
        case MUExhibitionTicketTypeSell:
            self.freeLabelTwo.text = @"在售";
            break;
        case MUExhibitionTicketTypeUnSell:
            self.freeLabelTwo.text = @"停售";
            
        default:
            break;
    }
    self.collectLabelTwo.text = [NSString stringWithFormat:@"%@人收藏",exhibition.loveCount];
    self.statusLabelTwo.text = exhibition.time;
    
    exhibition = exhibitions[2];
    [self.imageViewThree sd_setImageWithURL:[NSURL URLWithString:exhibition.imageUrl] placeholderImage:[UIImage imageNamed:@"加载占位"]];
    self.titleLabelThree.text = exhibition.name;
    self.localLabelThree.text = [NSString stringWithFormat:@"%@/km",exhibition.distance];
    switch (exhibition.sell) {
        case MUExhibitionTicketTypeFree:
            self.freeLabelThree.text = @"免费";
            break;
        case MUExhibitionTicketTypeSell:
            self.freeLabelThree.text = @"在售";
            break;
        case MUExhibitionTicketTypeUnSell:
            self.freeLabelThree.text = @"停售";
            
        default:
            break;
    }
    self.collectLabelThree.text = [NSString stringWithFormat:@"%@人收藏",exhibition.loveCount];
    self.statusLabelThree.text = exhibition.time;
    
    exhibition = exhibitions[3];
    [self.imageViewFour sd_setImageWithURL:[NSURL URLWithString:exhibition.imageUrl] placeholderImage:[UIImage imageNamed:@"加载占位"]];
    self.titleLabelFour.text = exhibition.name;
    self.localLabelFour.text = [NSString stringWithFormat:@"%@/km",exhibition.distance];
    switch (exhibition.sell) {
        case MUExhibitionTicketTypeFree:
            self.freeLabelFour.text = @"免费";
            break;
        case MUExhibitionTicketTypeSell:
            self.freeLabelFour.text = @"在售";
            break;
        case MUExhibitionTicketTypeUnSell:
            self.freeLabelFour.text = @"停售";
            
        default:
            break;
    }
    self.collectLabelFour.text = [NSString stringWithFormat:@"%@人收藏",exhibition.loveCount];
    self.statusLabelFour.text = exhibition.time;
    
    
    exhibition = exhibitions[4];
    [self.imageViewFive sd_setImageWithURL:[NSURL URLWithString:exhibition.imageUrl] placeholderImage:[UIImage imageNamed:@"加载占位"]];
    self.titleLabelFive.text = exhibition.name;
    self.localLabelFive.text = [NSString stringWithFormat:@"%@/km",exhibition.distance];
    switch (exhibition.sell) {
        case MUExhibitionTicketTypeFree:
            self.freeLabelFive.text = @"免费";
            break;
        case MUExhibitionTicketTypeSell:
            self.freeLabelFive.text = @"在售";
            break;
        case MUExhibitionTicketTypeUnSell:
            self.freeLabelFive.text = @"停售";
            
        default:
            break;
    }
    self.collectLabelFive.text = [NSString stringWithFormat:@"%@人收藏",exhibition.loveCount];
    self.statusLabelFive.text = exhibition.time;
    
}



- (IBAction)moreClick:(id)sender {
    //查看更多
    if ([self.delegate respondsToSelector:@selector(lookExhibitionTableViewCellHeaderMore:)]){
        [self.delegate lookExhibitionTableViewCellHeaderMore:self];
    }
}



- (void)customLayout{
    self.imageViewFive.layer.masksToBounds = YES;
    self.imageViewFive.layer.cornerRadius = 5.0;
    self.freeLabelFive.layer.borderWidth = 1.0;
    self.freeLabelFive.layer.borderColor = self.freeLabelFive.textColor.CGColor;
    self.statusLabelFive.layer.borderWidth = 1.0;
    self.statusLabelFive.layer.borderColor = self.freeLabelFive.textColor.CGColor;
    self.statusLabelFive.layer.masksToBounds = YES;
    self.statusLabelFive.layer.cornerRadius = 4.0;
    self.freeLabelFive.layer.masksToBounds = YES;
    self.freeLabelFive.layer.cornerRadius = 4.0;
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.collectLabelFive.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(5, 5)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.collectLabelFive.bounds;
    maskLayer.path = maskPath.CGPath;
    self.collectLabelFive.layer.mask = maskLayer;
    
    
    self.imageViewOne.layer.masksToBounds = YES;
    self.imageViewOne.layer.cornerRadius = 5.0;
    self.freeLabelOne.layer.borderWidth = 1.0;
    self.freeLabelOne.layer.borderColor = self.freeLabelOne.textColor.CGColor;
    self.statusLabelOne.layer.borderWidth = 1.0;
    self.statusLabelOne.layer.borderColor = self.freeLabelOne.textColor.CGColor;
    self.freeLabelOne.layer.masksToBounds = YES;
    self.freeLabelOne.layer.cornerRadius = 4.0;
    self.statusLabelOne.layer.masksToBounds = YES;
    self.statusLabelOne.layer.cornerRadius = 4.0;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.collectLabelOne.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(5, 5)];
    maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.collectLabelOne.bounds;
    maskLayer.path = maskPath.CGPath;
    self.collectLabelOne.layer.mask = maskLayer;
    
    self.imageViewTwo.layer.masksToBounds = YES;
    self.imageViewTwo.layer.cornerRadius = 5.0;
    self.freeLabelTwo.layer.borderWidth = 1.0;
    self.freeLabelTwo.layer.borderColor = self.freeLabelTwo.textColor.CGColor;
    self.statusLabelTwo.layer.borderWidth = 1.0;
    self.statusLabelTwo.layer.borderColor = self.freeLabelTwo.textColor.CGColor;
    self.freeLabelTwo.layer.masksToBounds = YES;
    self.freeLabelTwo.layer.cornerRadius = 4.0;
    self.statusLabelTwo.layer.masksToBounds = YES;
    self.statusLabelTwo.layer.cornerRadius = 4.0;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.collectLabelTwo.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(5, 5)];
    maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.collectLabelTwo.bounds;
    maskLayer.path = maskPath.CGPath;
    self.collectLabelTwo.layer.mask = maskLayer;
    
    self.imageViewThree.layer.masksToBounds = YES;
    self.imageViewThree.layer.cornerRadius = 5.0;
    self.freeLabelThree.layer.borderWidth = 1.0;
    self.freeLabelThree.layer.borderColor = self.freeLabelThree.textColor.CGColor;
    self.statusLabelThree.layer.borderWidth = 1.0;
    self.statusLabelThree.layer.borderColor = self.freeLabelThree.textColor.CGColor;
    self.freeLabelThree.layer.masksToBounds = YES;
    self.freeLabelThree.layer.cornerRadius = 4.0;
    self.statusLabelThree.layer.masksToBounds = YES;
    self.statusLabelThree.layer.cornerRadius = 4.0;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.collectLabelThree.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(5, 5)];
    maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.collectLabelThree.bounds;
    maskLayer.path = maskPath.CGPath;
    self.collectLabelThree.layer.mask = maskLayer;
    
    self.imageViewFour.layer.masksToBounds = YES;
    self.imageViewFour.layer.cornerRadius = 5.0;
    self.freeLabelFour.layer.borderWidth = 1.0;
    self.freeLabelFour.layer.borderColor = self.freeLabelFour.textColor.CGColor;
    self.statusLabelFour.layer.borderWidth = 1.0;
    self.statusLabelFour.layer.borderColor = self.freeLabelFour.textColor.CGColor;
    self.freeLabelFour.layer.masksToBounds = YES;
    self.freeLabelFour.layer.cornerRadius = 4.0;
    self.statusLabelFour.layer.masksToBounds = YES;
    self.statusLabelFour.layer.cornerRadius = 4.0;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.collectLabelFour.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(5, 5)];
    maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.collectLabelFour.bounds;
    maskLayer.path = maskPath.CGPath;
    self.collectLabelFour.layer.mask = maskLayer;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backViewClick:)];
    [self.backViewOne addGestureRecognizer:tap];
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backViewClick:)];
    [self.backViewTwo addGestureRecognizer:tap2];
    UITapGestureRecognizer *tap3 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backViewClick:)];
    [self.backViewThree addGestureRecognizer:tap3];
    UITapGestureRecognizer *tap4 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backViewClick:)];
    [self.backViewFour addGestureRecognizer:tap4];
    UITapGestureRecognizer *tap5 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backViewClick:)];
    [self.backViewFive addGestureRecognizer:tap5];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
