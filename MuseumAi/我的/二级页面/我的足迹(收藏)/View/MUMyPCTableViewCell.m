//
//  MUMyPCTableViewCell.m
//  MuseumAi
//
//  Created by Kingo on 2018/11/16.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUMyPCTableViewCell.h"

@interface MUMyPCTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *exhibitImageView;
@property (weak, nonatomic) IBOutlet UILabel *exhibitNameLb;
@property (weak, nonatomic) IBOutlet UILabel *exhibitDescriptLb;

@end

@implementation MUMyPCTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.exhibitImageView.layer.masksToBounds = YES;
    self.exhibitImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)bindCellWithExhibitModel:(MUExhibitModel *)model {
    [self.exhibitImageView sd_setImageWithURL:[NSURL URLWithString:model.exhibitUrl]];
    self.exhibitNameLb.text = model.exhibitName;
    self.exhibitDescriptLb.text = model.exhibitsDescribe;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
