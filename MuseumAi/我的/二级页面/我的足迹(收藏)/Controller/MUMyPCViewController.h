//
//  MUMyPCViewController.h
//  MuseumAi
//
//  Created by 魏宙辉 on 2018/9/25.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MURootViewController.h"

typedef NS_ENUM(NSInteger, MUPCTYPE) {
    MUPCTYPECOLLECT = 0,    // 收藏
    MUPCTYPEFOOTPRINT = 1,  // 足迹
    MUPCTYPECOMMENT = 2,    // 评论
};

@interface MUMyPCViewController : MURootViewController

/** 类型 */
@property (assign, nonatomic) MUPCTYPE type;

@end
