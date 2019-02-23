//
//  MUHallCell.h
//  MuseumAi
//
//  Created by Kingo on 2018/9/21.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MUHallModel.h"

@interface MUHallCell : UITableViewCell

- (void)bindCellWith:(MUHallModel *)hall positionTappedBlock:(void(^)(void))block;

@end
