//
//  MUStartViewController.m
//  MuseumAi
//
//  Created by Kingo on 2018/11/21.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUStartViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"

@interface MUStartViewController ()

/** 活动网址 */
@property (nonatomic , copy) NSString *urlStr;

@property (strong, nonatomic) AVPlayer *myPlayer;           //播放器
@property (strong, nonatomic) AVAsset *asset;
@property (strong, nonatomic) AVPlayerItem *item;           //播放单元
@property (strong, nonatomic) AVPlayerLayer *playerLayer;   //播放界面（layer）

/** 播放标志 */
@property (nonatomic , assign) BOOL isPlay;

@end

@implementation MUStartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self getData];
    [self loadVideo];
}

- (void)loadVideo {
    // 视频加载
    NSURL *mediaURL = [NSURL URLWithString:@"https://down.airart.com.cn/kjdh/kcdh.mp4"];
    self.asset = [AVAsset assetWithURL:mediaURL];
    self.item = [AVPlayerItem playerItemWithAsset:self.asset];
    [self.item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    self.myPlayer = [AVPlayer playerWithPlayerItem:self.item];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.myPlayer];
    self.playerLayer.frame = SCREEN_BOUNDS;
    [self.view.layer addSublayer:self.playerLayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didVideoPlayOver:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
}

- (void)getData {
    __weak typeof(self) weakSelf = self;
    self.urlStr = nil;
    self.isPlay = YES;
    [MUHttpDataAccess getActivityStateSuccess:^(id result) {
        
        if ([result[@"state"] integerValue] == 10001) {
            NSDictionary *dic = result[@"data"];
            NSString *state = dic[@"state"];
            if ([state boolValue]) {
                weakSelf.urlStr = dic[@"url"];
            } else {
                weakSelf.urlStr = @"";
            }
        } else {
            weakSelf.urlStr = @"";
        }
        [weakSelf switchController];
    } failed:^(NSError *error) {
        weakSelf.urlStr = @"";
        [weakSelf switchController];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.myPlayer pause];
}

- (void)dealloc {
    [self.item removeObserver:self forKeyPath:@"status"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:
(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {
        //取出status的新值
        AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey]intValue];
        switch (status) {
            case AVPlayerStatusFailed: {
                self.isPlay = NO;
                [self switchController];
                NSLog(@"item 有误");
                break;
            }
            case AVPlayerStatusReadyToPlay: {
                NSLog(@"准好播放了");
                /// FIXME:延时跳转
                __weak typeof(self) weakSelf = self;
                CGFloat totalSecs = (CGFloat)self.item.duration.value / self.item.duration.timescale;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(totalSecs * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    weakSelf.isPlay = NO;
                    [weakSelf switchController];
                });
                [self.myPlayer play];
                self.view.backgroundColor = [UIColor blackColor];
                self.isPlay = YES;
                break;
            }
            case AVPlayerStatusUnknown: {
                self.isPlay = NO;
                [self switchController];
                NSLog(@"视频资源出现未知错误");
                break;
            }
            default:
                break;
        }
    }
}

- (void)didVideoPlayOver:(id)sender {
    self.isPlay = NO;
//    [self switchController];
}

- (void)switchController {
    if (self.isPlay) {
        return;
    }
    if (self.urlStr == nil) {
        return;
    }
    if (self.urlStr.length == 0) {
        [self toMainController];
    } else {
        [self toActivityController];
    }
}

- (void)toMainController {
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate tabBarInit];
}

- (void)toActivityController {
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSURL *url = [NSURL URLWithString:self.urlStr];
    if (url != nil) {
        [delegate toActivityPage:url];
    } else {
        [delegate tabBarInit];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
