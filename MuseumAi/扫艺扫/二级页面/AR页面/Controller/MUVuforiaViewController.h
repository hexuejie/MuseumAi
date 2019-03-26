//
//  MUVuforiaViewController.h
//  MuseumAi
//
//  Created by 魏宙辉 on 2019/2/25.
//  Copyright © 2019年 Weizh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MUHallModel.h"
#import "MUARModel.h"
#import "UIViewController+MUExtension.h"

#define kDiscoverTargetNotification @"kDiscoverTargetNotification"

@interface MUVuforiaViewController : UIViewController

/* 当前展馆 */
@property(nonatomic, strong) MUHallModel *hall;
/* ARModels */
@property(nonatomic, strong) NSArray<MUARModel *> *ars;

/* 测试显示 */
@property(nonatomic, strong) UILabel *ibeaconLabel;

#ifndef MUSimulatorTest
/** 到展品详情页 */
- (void)toExhibitsDetail:(NSString *)exhibitsID;
#endif

@end

