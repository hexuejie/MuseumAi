//
//  MUExhibitionTableCell.h
//  MuseumAi
//
//  Created by Kingo on 2018/9/19.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MUExhibitionModel.h"

@interface MUExhibitionTableCell : UITableViewCell

- (void)bindCellWithExhibition:(MUExhibitionModel *)exhibition;

@end
