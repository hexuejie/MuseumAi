//
//  MUExhibitIntroduceCell.m
//  MuseumAi
//
//  Created by 魏宙辉 on 2018/9/24.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUExhibitIntroduceCell.h"
#import "YYLabel.h"

@interface MUExhibitIntroduceCell()

@property (weak, nonatomic) IBOutlet UILabel *introduceTitleLb;

@property (weak, nonatomic) IBOutlet YYLabel *introduceLb;

@end

@implementation MUExhibitIntroduceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.introduceTitleLb.font = [UIFont boldSystemFontOfSize:15.0f];
    self.introduceLb.numberOfLines = 0;
}

- (void)bindCellWithModel:(MUExhibitModel *)model {
    
    self.introduceLb.attributedText = model.exhibitIntroduce;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
