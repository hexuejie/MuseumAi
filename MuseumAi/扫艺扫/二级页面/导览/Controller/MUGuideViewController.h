//
//  MUGuideViewController.h
//  MuseumAi
//
//  Created by 魏宙辉 on 2018/9/23.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MURootViewController.h"
#import "MUHallModel.h"
#import "MUExhibitModel.h"

@interface MUGuideViewController : MURootViewController

/** 展馆 */
@property (strong, nonatomic) MUHallModel *hall;
/** 热门展品 */
@property (strong, nonatomic) NSArray<MUExhibitModel *> *hotExhibits;
/** 所有展品 */
@property (strong, nonatomic) NSArray<MUExhibitModel *> *allExhibits;

/** 所选中的展品 */
@property (strong, nonatomic) MUExhibitModel *selectExhibit;

@end
