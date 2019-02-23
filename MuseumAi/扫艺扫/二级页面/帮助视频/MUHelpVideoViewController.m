//
//  MUHelpVideoViewController.m
//  MuseumAi
//
//  Created by Kingo on 2018/11/14.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUHelpVideoViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface MUHelpVideoViewController ()

@property (strong, nonatomic) AVPlayer *myPlayer;           //播放器
@property (strong, nonatomic) AVAsset *asset;
@property (strong, nonatomic) AVPlayerItem *item;           //播放单元
@property (strong, nonatomic) AVPlayerLayer *playerLayer;   //播放界面（layer）

/** 按钮 */
@property (nonatomic , strong) UIButton *backButton;

@end

@implementation MUHelpVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadVideo];
}

- (void)loadVideo {
    // 视频加载
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"help" ofType:@"mp4"];
//    NSURL *mediaURL = [NSURL fileURLWithPath:path];
    NSURL *mediaURL = [NSURL URLWithString:@"https://down.airart.com.cn/kjdh/kjdh.mp4"];
    self.asset = [AVAsset assetWithURL:mediaURL];
    self.item = [AVPlayerItem playerItemWithAsset:self.asset];
    [self.item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    self.myPlayer = [AVPlayer playerWithPlayerItem:self.item];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.myPlayer];
    self.playerLayer.frame = SCREEN_BOUNDS;
    [self.view.layer addSublayer:self.playerLayer];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didVideoPlayOver:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:@"视频返回"];
    [self.backButton setImage:image forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(didBackClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backButton];
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0.0f);
        make.top.mas_equalTo(SafeAreaTopHeight-60.0f);
        make.width.height.mas_equalTo(60.0f);
    }];
    [self.backButton setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.myPlayer pause];
}

- (void)dealloc {
    [self.item removeObserver:self forKeyPath:@"status"];
}

- (void)didBackClicked:(id)sender {
    [self.myPlayer pause];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:
(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {
        //取出status的新值
        AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey]intValue];
        switch (status) {
            case AVPlayerStatusFailed:
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                NSLog(@"item 有误");
                break;
            case AVPlayerStatusReadyToPlay:
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                NSLog(@"准好播放了");
                [self.myPlayer play];
                break;
            case AVPlayerStatusUnknown:
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                NSLog(@"视频资源出现未知错误");
                break;
            default:
                break;
        }
    }
}

- (void)didVideoPlayOver:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
