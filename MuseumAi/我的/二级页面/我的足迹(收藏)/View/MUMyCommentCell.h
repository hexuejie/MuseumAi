//
//  MUMyCommentCell.h
//  MuseumAi
//
//  Created by 魏宙辉 on 2018/10/23.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MUComment.h"

@interface MUMyCommentCell : UITableViewCell

- (void)bindCellWithModel:(MUComment *)comment;

@end
