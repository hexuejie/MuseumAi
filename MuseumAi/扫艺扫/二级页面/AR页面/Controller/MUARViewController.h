//
//  MUARViewController.h
//  MuseumAi
//
//  Created by 魏宙辉 on 2018/9/22.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import <GLKit/GLKViewController.h>
#import "MUHallModel.h"
#import "MUARModel.h"

@interface MUARViewController : GLKViewController

/** 展馆 */
@property (strong, nonatomic) MUHallModel *hall;
/** ARModel */
@property (strong, nonatomic) NSArray<MUARModel *> *ars;

@end
