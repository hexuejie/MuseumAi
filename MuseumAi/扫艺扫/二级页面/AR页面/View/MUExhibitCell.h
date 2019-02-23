//
//  MUCollectionCell.h
//  MuseumAi
//
//  Created by 魏宙辉 on 2018/9/22.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MUExhibitCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *exhibitImageView;

@property (weak, nonatomic) IBOutlet UILabel *exhibitNameLb;

@property (weak, nonatomic) IBOutlet UIView *detailBgView;
@property (weak, nonatomic) IBOutlet UILabel *detailLb;

@end
