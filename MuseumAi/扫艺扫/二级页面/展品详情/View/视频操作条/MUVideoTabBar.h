//
//  MUVideoTabBar.h
//  MuseumAi
//
//  Created by 魏宙辉 on 2018/9/24.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MUVideoTabBar;

@protocol MUVideoTabBarDelegate<NSObject>

@optional
/** 播放按钮 */
- (void)videoBar:(MUVideoTabBar *)videoBar isPlay:(BOOL)isPlay;
/** 进度条被拖动 */
- (void)videoBar:(MUVideoTabBar *)videoBar didSlideBarChanged:(CGFloat)value;
/** 音量键被按下 */
- (void)videoBar:(MUVideoTabBar *)videoBar isSlilence:(BOOL)isSlilence;
/** 最大最小化被按下 */
- (void)didSizeBtClicked:(MUVideoTabBar *)videoBar;

@end

typedef NS_ENUM(NSInteger, VIDEOSCREENTYPE) {
    VIDEOSCREENTYPESMALL = 0,   // 小屏
    VIDEOSCREENTYPEBIG          // 大屏
};
typedef NS_ENUM(NSInteger, VIDEOSTATUS) {
    VIDEOSTATUSPLAY = 0,   // 播放
    VIDEOSTATUSPAUSE       // 暂停
};

@interface MUVideoTabBar : UIView

/** 代理 */
@property (weak, nonatomic) id delegate;

/** 屏幕类型 */
@property (assign, nonatomic) VIDEOSCREENTYPE type;
/** 视频状态 */
@property (assign, nonatomic) VIDEOSTATUS status;

- (void)setCurrentTime:(NSInteger)currentTime
             totalTime:(NSInteger)totalTime
         refreshSlider:(BOOL)refreshSlider;

+ (instancetype)videoTabBarWithDelegate:(id<MUVideoTabBarDelegate>)delegate;

@end
