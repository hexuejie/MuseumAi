//
//  MUCommentViewController.h
//  MuseumAi
//
//  Created by 魏宙辉 on 2018/9/26.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MURootViewController.h"

#define kSubmitCommentOKNotification @"kSubmitCommentOKNotification"

@interface MUCommentViewController : MURootViewController

/** 评论类型 */
@property (assign, nonatomic) MUCOMMENTTYPE type;

/** id */
@property (copy, nonatomic) NSString *exhibitId;

@end
