//
//  MUVuforiaViewController+IBeacon.m
//  MuseumAi
//
//  Created by 魏宙辉 on 2019/3/4.
//  Copyright © 2019年 Weizh. All rights reserved.
//

#import "MUVuforiaViewController+IBeacon.h"
#import "MUHttpDataAccess.h"
#import "MUExhibitDetailViewController.h"

@implementation MUVuforiaViewController (IBeacon)

- (void)ibeaconInit {
    [self ibeaconDataInit];
    [self ibeaconViewInit];
}
- (void)finishIbeacon {
    [self.iBeaconClient closeClient];
}

- (void)ibeaconViewInit {
    
    if (self.alertView) {
        [self.alertView removeFromSuperview];
    }
    self.alertView = [MUIbeaconAlertView ibeaconAlertWithImageUrl:@""];
    [self.alertView addTapTarget:self action:@selector(hideIBeaconAlertView:)];
    self.alertView.hidden = YES;
    [self.view addSubview:self.alertView];
    
    
    if (self.ibeaconLabel) {
        [self.ibeaconLabel removeFromSuperview];
        self.ibeaconLabel = nil;
    }
    /*
    self.ibeaconLabel = [[UILabel alloc] init];
    self.ibeaconLabel.textAlignment = NSTextAlignmentCenter;
    self.ibeaconLabel.textColor = kMainColor;
    [self.view addSubview:self.ibeaconLabel];
    [self.ibeaconLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(200);
        make.height.mas_equalTo(30);
    }];
     */
     
}

- (void)hideIBeaconAlertView:(id)sender {
    self.alertView.hidden = YES;
    [self.myPlayer pause];
}

- (void)ibeaconDataInit {
    self.isPlayAR = NO;
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    __weak typeof(self) weakSelf = self;
    [MUHttpDataAccess getBluetoothInfoWithHallId:self.hall.hallId success:^(id result) {
        
//        result = [self readJSONFileWithName:@"ibeacon"];
        
        if ([result[@"state"]integerValue] == 10001) {
            NSMutableArray *mutBlueToothes = [NSMutableArray array];
            for (NSDictionary *dic in [result[@"data"] firstObject][@"hallExhibitsList"]) {
                [mutBlueToothes addObject:[MUBlueToothModel blueToothModelWithDic:dic]];
            }
            weakSelf.blueToothes = [NSArray arrayWithArray:mutBlueToothes];
            [weakSelf loadBlueFoundDistance];
        }
    } failed:^(NSError *error) {
        [weakSelf alertWithMsg:kFailedTips handler:nil];
    }];
}
- (void)loadBlueFoundDistance {
    __weak typeof(self) weakSelf = self;
    [MUHttpDataAccess getBlueToothParameterWithHallId:self.hall.hallId success:^(id result) {
        
        if ([result[@"state"]integerValue] == 10001) {
            for (MUBlueToothModel *blueTooth in weakSelf.blueToothes) {
                blueTooth.valueA = [result[@"data"][@"bluetoothOmisa"]doubleValue];
                blueTooth.valueN = [result[@"data"][@"attenuationFctor"]doubleValue];
                blueTooth.foundDistance = [result[@"data"][@"bluetoothDistance"] doubleValue];
            }
            if (weakSelf.blueToothes.count > 0) {
                weakSelf.iBeaconClient = [[ZACIBeaconClient alloc]initWithBlueToothes:weakSelf.blueToothes];
                weakSelf.iBeaconClient.delegate = self;
                if (weakSelf.isInitAR) {
                    [weakSelf.iBeaconClient openClient];
                } else {
                    [weakSelf.iBeaconClient closeClient];
                }
            }
        }
    } failed:^(NSError *error) {
        [weakSelf alertWithMsg:kFailedTips handler:nil];
    }];
}

/** 蓝牙状态有改变 */
- (void)didChangeBlueToothStatus:(BOOL)isOn {
    if (!isOn) {
        [self.iBeaconClient closeClient];
        
        [self alertWithMsg:@"请前往设置打开蓝牙" leftTitle:@"确定" leftHandler:nil rightTitle:@"设置" rightHandler:^{
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication
                  sharedApplication] openURL:url];
            }
        }];
    }else {
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.iBeaconClient openClient];
        });
    }
}
/** 发现新的蓝牙设备 */
- (void)didFoundNewBlueTooth:(MUBlueToothModel *)blueTooth {
    NSLog(@"更新设备：%@",blueTooth.blueToothName);
    
    NSString *info = [NSString stringWithFormat:@"%@:%.2f米",blueTooth.blueToothName,blueTooth.distance];
    self.ibeaconLabel.text = info;
    
    if (blueTooth == nil || self.isPlayAR) {
        return;
    }
    
    [MUHttpDataAccess recoganizerExhibitWithExhibitId:blueTooth.exhibitionId method:2];
    if (blueTooth.scan) {
        if (![self.navigationController.topViewController isEqual:self]) {
            MUExhibitDetailViewController *vc = (MUExhibitDetailViewController *)self.navigationController.topViewController;
            if ([vc isKindOfClass:[MUExhibitDetailViewController class]]) {
                [vc stopPlayer];
            }
            [vc.navigationController popToViewController:self animated:YES];
        }
        
        self.alertView.imageUrl = blueTooth.exhibitionUrl;
        self.alertView.hidden = NO;
        [self.view bringSubviewToFront:self.alertView];
        
        NSURL *mediaURL = [NSURL URLWithString:blueTooth.audio];
        self.asset = [AVAsset assetWithURL:mediaURL];
        self.item = [AVPlayerItem playerItemWithAsset:self.asset];
        self.myPlayer = [AVPlayer playerWithPlayerItem:self.item];
        [self.item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        [self.myPlayer play];
    } else {
        [self.myPlayer pause];
        if ([self.navigationController.topViewController isKindOfClass:[MUExhibitDetailViewController class]]) {
            MUExhibitDetailViewController *vc = (MUExhibitDetailViewController *)self.navigationController.topViewController;
            [vc reloadWithExhibitId:blueTooth.exhibitionId audioUrl:blueTooth.audio];
        } else {
            MUExhibitDetailViewController *vc = [MUExhibitDetailViewController new];
            vc.exhibitId = blueTooth.exhibitionId;
            vc.audioUrl = blueTooth.audio;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:
(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {
        //取出status的新值
        AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey]intValue];
        switch (status) {
            case AVPlayerStatusFailed:
                NSLog(@"item 有误");
                break;
            case AVPlayerStatusReadyToPlay: {
                NSLog(@"准好播放了");
                [self.myPlayer play];
                break;
            }
            case AVPlayerStatusUnknown:
                NSLog(@"视频资源出现未知错误");
                break;
            default:
                break;
        }
        [self.item removeObserver:self forKeyPath:@"status"];
    }
}

@end
