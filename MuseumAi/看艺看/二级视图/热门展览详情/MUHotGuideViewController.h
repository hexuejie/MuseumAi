//
//  MUHotGuideViewController.h
//  MuseumAi
//
//  Created by Kingo on 2018/11/12.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MURootViewController.h"

@interface MUHotGuideViewController : MURootViewController

/** 展览id */
@property (nonatomic , copy) NSString *exhibitionId;
/** url */
@property (nonatomic , strong) NSURL *url;

@end
