//
//  MUExhibitDetailViewController.h
//  MuseumAi
//
//  Created by 魏宙辉 on 2018/9/23.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MURootViewController.h"

@interface MUExhibitDetailViewController : MURootViewController

/** 展品id */
@property (copy, nonatomic) NSString *exhibitId;
/** 音频播放 */
@property (copy, nonatomic) NSString *audioUrl;

- (void)reloadWithExhibitId:(NSString *)exhibitId audioUrl:(NSString *)audioUrl;

- (void)stopPlayer;

@end
