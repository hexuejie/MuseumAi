//
//  MUClassTableCell.h
//  MuseumAi
//
//  Created by Kingo on 2018/9/19.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MUClassModel.h"

@interface MUClassTableCell : UITableViewCell

- (void)bindCellWithClass:(MUClassModel *)classModel;

@end
