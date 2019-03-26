//
//  MUMyCommentCollectionViewCell.h
//  MuseumAi
//
//  Created by 何学杰 on 2019/3/7.
//  Copyright © 2019 Weizh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MUComment.h"

NS_ASSUME_NONNULL_BEGIN

@interface MUMyCommentCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *VIPLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLb;

@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UILabel *originalLabel;



- (void)bindCellWithModel:(MUComment *)comment;
@end

NS_ASSUME_NONNULL_END
