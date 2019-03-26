//
//  MUCommentCell.h
//  MuseumAi
//
//  Created by 魏宙辉 on 2018/9/24.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MUCommentModel.h"

typedef void(^LOVECLICKEDBLOCK)(void);

@interface MUCommentCell : UITableViewCell

- (void)bindCellWithModel:(MUCommentModel *)model;
// loveClicked:(LOVECLICKEDBLOCK)loveBlock;

@end
