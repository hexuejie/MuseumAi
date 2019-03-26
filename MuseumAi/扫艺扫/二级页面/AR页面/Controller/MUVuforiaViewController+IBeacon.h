//
//  MUVuforiaViewController+IBeacon.h
//  MuseumAi
//
//  Created by 魏宙辉 on 2019/3/4.
//  Copyright © 2019年 Weizh. All rights reserved.
//

#import "MUVuforiaViewController.h"
#import "MUBlueToothModel.h"
#import "ZACIBeaconClient.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#import "MUIbeaconAlertView.h"

@interface MUVuforiaViewController ()<ZACIBeaconClientDelegate>

/* AR初始化 */
@property(nonatomic, assign) BOOL isInitAR;
/* AR是否正在播放 */
@property(nonatomic, assign) BOOL isPlayAR;

@property (strong, nonatomic) AVPlayer *myPlayer;           //播放器
@property (strong, nonatomic) AVAsset *asset;
@property (strong, nonatomic) AVPlayerItem *item;           //播放单元

/** iBeacon搜索器 */
@property (nonatomic , strong) ZACIBeaconClient *iBeaconClient;
/** 蓝牙设备数组 */
@property (nonatomic , strong) NSArray<MUBlueToothModel *> *blueToothes;

/* 弹窗 */
@property(nonatomic, strong) MUIbeaconAlertView *alertView;

@end

@interface MUVuforiaViewController (IBeacon)

- (void)ibeaconInit;
- (void)finishIbeacon;

/** 发现新的蓝牙设备 */
- (void)didFoundNewBlueTooth:(MUBlueToothModel *)blueTooth;
/** 蓝牙状态有改变 */
- (void)didChangeBlueToothStatus:(BOOL)isOn;

@end

