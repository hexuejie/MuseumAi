//
//  MUHallCell.m
//  MuseumAi
//
//  Created by Kingo on 2018/9/21.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUHallCell.h"
#import "UIImageView+WebCache.h"

typedef void (^kPositionTappedBlock)(void);

@interface MUHallCell()

@property (weak, nonatomic) IBOutlet UIImageView *hallImageView;

@property (weak, nonatomic) IBOutlet UILabel *hallNameLb;

@property (weak, nonatomic) IBOutlet UILabel *hallAddressLb;

@property (weak, nonatomic) IBOutlet UILabel *hallOpenTimeLb;

@property (weak, nonatomic) IBOutlet UILabel *hallDistanceLb;

/** tapped */
@property (nonatomic , copy) kPositionTappedBlock block;
/** downLoad */
@property (nonatomic , copy) kPositionTappedBlock downloadBlock;

@end

@implementation MUHallCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.hallImageView.layer.masksToBounds = YES;
    self.hallImageView.layer.cornerRadius = 10.0f;
    self.hallImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.hallOpenTimeLb.textColor = kMainColor;
    self.hallOpenTimeLb.layer.masksToBounds = YES;
    self.hallOpenTimeLb.layer.cornerRadius = 5.0f;
    self.hallOpenTimeLb.layer.borderColor = kMainColor.CGColor;
    self.hallOpenTimeLb.layer.borderWidth = 1.0f;
    
    [self.hallAddressLb addTapTarget:self action:@selector(didAddressTapped:)];
    
}

- (void)bindCellWith:(MUHallModel *)hall
     positionHandler:(void(^)(void))positionHandler
     downloadHandler:(void(^)(void))downloadHandler {
    
    self.block = positionHandler;
    self.downloadBlock = downloadHandler;
    
    /** 16:9 */
    [self.hallImageView sd_setImageWithURL:[NSURL URLWithString:hall.hallPicUrl] placeholderImage:[UIImage imageNamed:@"加载占位"]];
    self.hallNameLb.text = hall.hallName;
    self.hallAddressLb.text = hall.hallAddress;
    self.hallOpenTimeLb.text = [NSString stringWithFormat:@" %@    ",hall.hallOpenTime];
    self.hallDistanceLb.text = [NSString stringWithFormat:@"%.2fkm",[hall.distance doubleValue]];
}

- (void)didAddressTapped:(id)sender {
    if (self.block != nil) {
        self.block();
    }
}

- (IBAction)didDownloadClicked:(id)sender {
    if (self.downloadBlock) {
        self.downloadBlock();
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
