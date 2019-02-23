//
//  MUMyPCTableViewCell.h
//  MuseumAi
//
//  Created by Kingo on 2018/11/16.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MUExhibitModel.h"

@interface MUMyPCTableViewCell : UITableViewCell

- (void)bindCellWithExhibitModel:(MUExhibitModel *)model;

@end
