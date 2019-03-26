//
//  MULookExhibitionTableViewCell.h
//  MuseumAi
//
//  Created by 何学杰 on 2019/2/25.
//  Copyright © 2019 Weizh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MUExhibitionModel.h"

NS_ASSUME_NONNULL_BEGIN

@class MULookExhibitionTableViewCell;

@protocol MULookExhibitionTableViewCellDelegate <NSObject>

-(void)lookExhibitionTableViewCellHeaderMore:(MULookExhibitionTableViewCell *)cell;
-(void)lookExhibitionTableViewCellClick:(MULookExhibitionTableViewCell *)cell withExhibitionId:(NSString *)exhibitionId;


@end

@interface MULookExhibitionTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *segmentTitleLabel;

@property (weak, nonatomic) IBOutlet UIView *backViewOne;
@property (weak, nonatomic) IBOutlet UILabel *collectLabelOne;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewOne;
@property (weak, nonatomic) IBOutlet UILabel *titleLabelOne;
@property (weak, nonatomic) IBOutlet UILabel *localLabelOne;
@property (weak, nonatomic) IBOutlet UILabel *freeLabelOne;
@property (weak, nonatomic) IBOutlet UILabel *statusLabelOne;

@property (weak, nonatomic) IBOutlet UIView *backViewTwo;
@property (weak, nonatomic) IBOutlet UILabel *collectLabelTwo;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewTwo;
@property (weak, nonatomic) IBOutlet UILabel *titleLabelTwo;
@property (weak, nonatomic) IBOutlet UILabel *localLabelTwo;
@property (weak, nonatomic) IBOutlet UILabel *freeLabelTwo;
@property (weak, nonatomic) IBOutlet UILabel *statusLabelTwo;


@property (weak, nonatomic) IBOutlet UIView *backViewThree;
@property (weak, nonatomic) IBOutlet UILabel *collectLabelThree;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewThree;
@property (weak, nonatomic) IBOutlet UILabel *titleLabelThree;
@property (weak, nonatomic) IBOutlet UILabel *localLabelThree;
@property (weak, nonatomic) IBOutlet UILabel *freeLabelThree;
@property (weak, nonatomic) IBOutlet UILabel *statusLabelThree;

@property (weak, nonatomic) IBOutlet UIView *backViewFour;
@property (weak, nonatomic) IBOutlet UILabel *collectLabelFour;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewFour;
@property (weak, nonatomic) IBOutlet UILabel *titleLabelFour;
@property (weak, nonatomic) IBOutlet UILabel *localLabelFour;
@property (weak, nonatomic) IBOutlet UILabel *freeLabelFour;
@property (weak, nonatomic) IBOutlet UILabel *statusLabelFour;

@property (weak, nonatomic) IBOutlet UIView *backViewFive;
@property (weak, nonatomic) IBOutlet UILabel *collectLabelFive;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewFive;
@property (weak, nonatomic) IBOutlet UILabel *titleLabelFive;
@property (weak, nonatomic) IBOutlet UILabel *localLabelFive;
@property (weak, nonatomic) IBOutlet UILabel *freeLabelFive;
@property (weak, nonatomic) IBOutlet UILabel *statusLabelFive;



@property (nonatomic, weak)id<MULookExhibitionTableViewCellDelegate> delegate;
@property (strong, nonatomic) NSArray *exhibitionModels;
- (void)bindCellWithExhibition:(NSArray *)exhibitions;

@end

NS_ASSUME_NONNULL_END
