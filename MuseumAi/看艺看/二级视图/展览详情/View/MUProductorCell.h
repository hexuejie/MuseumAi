//
//  MUProductorCell.h
//  MuseumAi
//
//  Created by Kingo on 2018/9/27.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MUExhibitionCellDelegate.h"

@interface MUProductorCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UICollectionView *productorCollectionView;

/** 代理 */
@property (nonatomic , weak) id<MUExhibitionCellDelegate> delegate;

- (void)bindCellWithModel:(MUExhibitionDetailModel *)exhibition delegate:(id<MUExhibitionCellDelegate>)delegate;

@end
