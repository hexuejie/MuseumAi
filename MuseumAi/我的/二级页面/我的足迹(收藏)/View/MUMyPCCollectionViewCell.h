//
//  MUMyPCCollectionViewCell.h
//  MuseumAi
//
//  Created by 何学杰 on 2019/3/7.
//  Copyright © 2019 Weizh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MUExhibitModel.h"
#import "MUExhibitionModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MUMyPCCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *exhibitImageView;
@property (weak, nonatomic) IBOutlet UILabel *exhibitNameLb;
@property (weak, nonatomic) IBOutlet UILabel *exhibitDescriptLb;


@property (weak, nonatomic) IBOutlet UILabel *collectLabel;
@property (weak, nonatomic) IBOutlet UILabel *freeLabel;


- (void)bindCellWithExhibitModel:(MUExhibitModel *)model;

- (void)bindCellWithExhibitionModel:(MUExhibitionModel *)model;
@end

NS_ASSUME_NONNULL_END
