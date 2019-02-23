//
//  MUExhibitIntroduceCell.h
//  MuseumAi
//
//  Created by 魏宙辉 on 2018/9/24.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MUExhibitModel.h"

#define kExhibitIntroduceBaseHeight 50.0f

@interface MUExhibitIntroduceCell : UITableViewCell

- (void)bindCellWithModel:(MUExhibitModel *)model;

@end
