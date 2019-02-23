//
//  MUClassTableCell.m
//  MuseumAi
//
//  Created by Kingo on 2018/9/19.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUClassTableCell.h"
#import "UIImageView+WebCache.h"

@interface MUClassTableCell()

@property (weak, nonatomic) IBOutlet UIImageView *titleImageView;

@property (weak, nonatomic) IBOutlet UILabel *authorLb;

@property (weak, nonatomic) IBOutlet UILabel *dateLb;

@property (weak, nonatomic) IBOutlet UILabel *classNameLb;

@property (weak, nonatomic) IBOutlet UILabel *classDescriptionLb;


@end

@implementation MUClassTableCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.titleImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.titleImageView.layer.masksToBounds = YES;
    
    self.classNameLb.font = [UIFont boldSystemFontOfSize:15.0f];
}

- (void)bindCellWithClass:(MUClassModel *)classModel {
    
    [self.titleImageView sd_setImageWithURL:[NSURL URLWithString:classModel.imageUrl] placeholderImage:[UIImage imageNamed:@"加载占位"]];
    
    self.authorLb.text = classModel.classAuthor;
    self.dateLb.text = (classModel.classDate.length > 10)?[classModel.classDate substringToIndex:10]:classModel.classDate;
    self.classNameLb.text = [NSString stringWithFormat:@"%@ %@",classModel.classTitle,classModel.classSubTitle];
    self.classDescriptionLb.text = classModel.classDesctiption;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
