//
//  MUCourseDetailViewController.m
//  MuseumAi
//
//  Created by Kingo on 2018/9/21.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUCourseDetailViewController.h"
#import "MUVideoTabBar.h"
#import <AVFoundation/AVFoundation.h>

@interface MUCourseDetailViewController ()<MUVideoTabBarDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;

@property (weak, nonatomic) IBOutlet UIButton *returnBt;

@property (weak, nonatomic) IBOutlet UIButton *collectBt;

@property (weak, nonatomic) IBOutlet UIButton *playBt;
@property (weak, nonatomic) IBOutlet UIButton *bigPlayBt;


@property (weak, nonatomic) IBOutlet UIView *playBgView;
@property (strong, nonatomic) IBOutlet UIView *bigPlayBgView;
@property (strong, nonatomic) MUVideoTabBar *videoBar;

@property (weak, nonatomic) IBOutlet UILabel *authorLb;

@property (weak, nonatomic) IBOutlet UILabel *dateLb;

@property (weak, nonatomic) IBOutlet UILabel *courseNameLb;

@property (weak, nonatomic) IBOutlet UITextView *courseContentTV;

/**********视频播放 start**********/
/** 播放图 */
@property (nonatomic , strong) UIImageView *playImageView;

@property (strong, nonatomic) AVPlayer *myPlayer;           //播放器
@property (strong, nonatomic) AVAsset *asset;
@property (strong, nonatomic) AVPlayerItem *item;           //播放单元
@property (strong, nonatomic) AVPlayerLayer *playerLayer;   //播放界面（layer）

/**********视频播放 end**********/

/** 作者 */
@property (nonatomic , copy) NSString *author;
/** 日期 */
@property (nonatomic , copy) NSString *courseDate;
/** 课程标题 */
@property (nonatomic , copy) NSString *courseTitle;
/** 课程介绍 */
@property (nonatomic , copy) NSString *courseIntroduce;
/** 音视频路径 */
@property (nonatomic , copy) NSString *videoPath;
/** 视频启动画面 */
@property (nonatomic , copy) NSString *couserImage;
/** 是否准备好播放 */
@property (assign, nonatomic) BOOL isReadToPlay;

/** 计时器 */
@property (strong, nonatomic) NSTimer *timer;
/** 总秒数 */
@property (assign, nonatomic) NSInteger totalSecs;
/** 隐藏计数 */
@property (assign, nonatomic) NSInteger hideCount;

@end

@implementation MUCourseDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self viewInit];
    
    [self dataInit];
}

- (void)viewInit {
    
    self.topConstraint.constant = SafeAreaTopHeight-44.0f;
    
    self.courseContentTV.editable = NO;
    self.courseContentTV.selectable = NO;
    
    self.courseNameLb.font = [UIFont boldSystemFontOfSize:15.0f];
    
    [self.returnBt setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    self.playBgView.backgroundColor = [UIColor blackColor];
    self.playImageView = [[UIImageView alloc]init];
    self.playImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.playImageView.layer.masksToBounds = YES;
    [self.playBgView addSubview:self.playImageView];
    [self.playImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.mas_equalTo(0);
    }];
    self.bigPlayBgView.frame = CGRectMake(0, 0, SCREEN_HEIGHT, SCREEN_WIDTH);
    [self.view addSubview:self.bigPlayBgView];
    self.bigPlayBgView.hidden = YES;
    [self.playBgView addTapTarget:self action:@selector(didVideoScreenTap:)];
    [self.bigPlayBgView addTapTarget:self action:@selector(didVideoScreenTap:)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didVideoPlayOver:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    self.videoBar = [MUVideoTabBar videoTabBarWithDelegate:self];
    [self.playBgView addSubview:self.videoBar];
    self.videoBar.hidden = YES;
    [self.videoBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(30.0f);
    }];
    self.hideCount = 0;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                  target:self
                                                selector:@selector(timerAction:)
                                                userInfo:nil
                                                 repeats:YES];
    
    [self.playBgView bringSubviewToFront:self.returnBt];
    [self.playBgView bringSubviewToFront:self.collectBt];
    [self.playBgView bringSubviewToFront:self.playBt];
}

- (void)didVideoPlayOver:(id)sender {
    self.playBt.hidden = NO;
    self.bigPlayBt.hidden = NO;
    self.playImageView.hidden = NO;
    self.playerLayer.hidden = YES;
    [self.myPlayer pause];
    [self.myPlayer seekToTime:kCMTimeZero];
    [self.videoBar setStatus:VIDEOSTATUSPAUSE];
    [self.videoBar setCurrentTime:0.0 totalTime:self.totalSecs refreshSlider:YES];
}
- (void)timerAction:(id)sender {
    if (self.playImageView.hidden == NO) {
        return;
    }
    NSInteger currentTime = self.myPlayer.currentTime.value/self.myPlayer.currentTime.timescale;
    [self.videoBar setCurrentTime:currentTime totalTime:self.totalSecs refreshSlider:YES];
    if (self.hideCount <= 0) {
        return;
    }else {
        self.hideCount--;
        if (self.hideCount == 0) {
            self.videoBar.hidden = YES;
        }
    }
}

- (void)didVideoScreenTap:(id)sender {
    self.videoBar.hidden = !self.videoBar.hidden;
    if (self.videoBar.hidden) {
        self.hideCount = 0;
    }else {
        self.hideCount = 3;
    }
}

- (void)dataInit {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak typeof(self) weakSelf = self;
    [MUHttpDataAccess getCourseDetailWithId:self.courseId success:^(id result) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        
        if ([result[@"state"] integerValue] == 10001) {
            weakSelf.author = result[@"data"][@"authorName"];
            NSString *dateStr = result[@"data"][@"classDate"];
            dateStr = dateStr.length<10?dateStr:[dateStr substringToIndex:10];
            weakSelf.courseDate = dateStr;
            weakSelf.courseTitle = result[@"data"][@"classTitle"];
            weakSelf.courseIntroduce = result[@"data"][@"classDescribe"];
            weakSelf.videoPath = result[@"data"][@"vedioPath"];
            weakSelf.couserImage = result[@"data"][@"mclassPicUrl"];
            [weakSelf reloadView];
        }
        
    } failed:^(NSError *error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf alertWithMsg:kFailedTips handler:nil];
    }];
}

- (void)reloadView {
    
    self.authorLb.text = self.author;
    self.dateLb.text = self.courseDate;
    self.courseNameLb.text = self.courseTitle;
    self.courseContentTV.text = [NSString stringWithFormat:@"　　%@",self.courseIntroduce];
    
    [self.playImageView sd_setImageWithURL:[NSURL URLWithString:self.couserImage]];
    
    NSLog(@"VideoPath:%@",self.videoPath);
    NSURL *mediaURL = [NSURL URLWithString:self.videoPath];
    self.asset = [AVAsset assetWithURL:mediaURL];
    self.item = [AVPlayerItem playerItemWithAsset:self.asset];
    self.myPlayer = [AVPlayer playerWithPlayerItem:self.item];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.myPlayer];
    self.playerLayer.frame = CGRectMake(0, 0, self.playBgView.bounds.size.width, self.playBgView.bounds.size.height);
    [self.playBgView.layer addSublayer:self.playerLayer];
    self.playerLayer.hidden = YES;
    
    self.isReadToPlay = NO;
    [self.item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
}

#pragma mark -
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:
(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {
        //取出status的新值
        AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey]intValue];
        switch (status) {
            case AVPlayerStatusFailed:
                NSLog(@"item 有误");
                [self alertWithMsg:@"视频加载失败" handler:nil];
                self.isReadToPlay = NO;
                break;
            case AVPlayerStatusReadyToPlay:
                NSLog(@"准好播放了");
                self.isReadToPlay = YES;
                self.totalSecs = self.item.duration.value / self.item.duration.timescale;
                [self.videoBar setCurrentTime:0 totalTime:self.totalSecs refreshSlider:YES];
                break;
            case AVPlayerStatusUnknown:
                NSLog(@"视频资源出现未知错误");
                [self alertWithMsg:@"视频加载失败" handler:nil];
                self.isReadToPlay = NO;
                break;
            default:
                break;
        }
    }
}

- (void)dealloc {
    
    //移除监听（观察者）
    [self.item removeObserver:self forKeyPath:@"status"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.timer isValid];
    self.timer = nil;
}

#pragma mark ---- 播放条
/** 播放按钮 */
- (void)videoBar:(MUVideoTabBar *)videoBar isPlay:(BOOL)isPlay {
    self.hideCount = 3;
    [self.playBgView bringSubviewToFront:self.returnBt];
    [self.playBgView bringSubviewToFront:self.collectBt];
    [self.playBgView bringSubviewToFront:self.playBt];
    [self.playBgView bringSubviewToFront:self.videoBar];
    [self.bigPlayBgView bringSubviewToFront:self.bigPlayBt];
    if (isPlay) {
        self.playBt.hidden = YES;
        self.bigPlayBt.hidden = YES;
        self.playImageView.hidden = YES;
        self.playerLayer.hidden = NO;
        [self.myPlayer play];
        [self.myPlayer setVolume:0.6];
    }else {
        self.playBt.hidden = NO;
        self.bigPlayBt.hidden = NO;
        [self.myPlayer pause];
    }
}
/** 进度条被拖动 */
- (void)videoBar:(MUVideoTabBar *)videoBar didSlideBarChanged:(CGFloat)value {
    self.hideCount = 3;
    if (value > 1) {
        value = 1;
    }
    NSInteger currentTime = self.totalSecs*value;
    [self.videoBar setCurrentTime:currentTime totalTime:self.totalSecs refreshSlider:NO];
    [self.myPlayer seekToTime:CMTimeMake(currentTime, 1)] ;
    
}
/** 音量键被按下 */
- (void)videoBar:(MUVideoTabBar *)videoBar isSlilence:(BOOL)isSlilence {
    self.hideCount = 3;
    if (isSlilence) {
        [self.myPlayer setVolume:0.0];
    }else {
        [self.myPlayer setVolume:0.6];
    }
}
/** 最大最小化被按下 */
- (void)didSizeBtClicked:(MUVideoTabBar *)videoBar {
    if (self.bigPlayBgView.hidden) {
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.25 animations:^{
            weakSelf.view.bounds = CGRectMake(0, 0, SCREEN_HEIGHT, SCREEN_WIDTH);
            weakSelf.view.transform = CGAffineTransformMakeRotation(M_PI*0.5);
        } completion:^(BOOL finished) {
            [weakSelf.playerLayer removeFromSuperlayer];
            weakSelf.playerLayer.frame = weakSelf.bigPlayBgView.frame;
            [weakSelf.bigPlayBgView.layer addSublayer:weakSelf.playerLayer];
            weakSelf.bigPlayBgView.hidden = NO;
            [weakSelf.videoBar removeFromSuperview];
            weakSelf.videoBar.type = VIDEOSCREENTYPEBIG;
            [weakSelf.bigPlayBgView addSubview:weakSelf.videoBar];
            [weakSelf.videoBar mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.bottom.right.mas_equalTo(0);
                make.height.mas_equalTo(30.0f);
            }];
            weakSelf.videoBar.hidden = NO;
            weakSelf.hideCount = 3;
            [weakSelf.bigPlayBgView bringSubviewToFront:weakSelf.bigPlayBt];
        }];
    }else {
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.25 animations:^{
            weakSelf.view.bounds = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
            weakSelf.view.transform = CGAffineTransformMakeRotation(0);
        } completion:^(BOOL finished) {
            [weakSelf.playerLayer removeFromSuperlayer];
            weakSelf.playerLayer.frame = weakSelf.playBgView.bounds;
            [weakSelf.playBgView.layer addSublayer:weakSelf.playerLayer];
            weakSelf.bigPlayBgView.hidden = YES;
            [weakSelf.videoBar removeFromSuperview];
            weakSelf.videoBar.type = VIDEOSCREENTYPESMALL;
            [weakSelf.playBgView addSubview:weakSelf.videoBar];
            [weakSelf.videoBar mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.bottom.right.mas_equalTo(0);
                make.height.mas_equalTo(30.0f);
            }];
            weakSelf.videoBar.hidden = NO;
            weakSelf.hideCount = 3;
            [weakSelf.playBgView bringSubviewToFront:weakSelf.returnBt];
            [weakSelf.playBgView bringSubviewToFront:weakSelf.collectBt];
            [weakSelf.playBgView bringSubviewToFront:weakSelf.playBt];
            [weakSelf.playBgView bringSubviewToFront:weakSelf.videoBar];
        }];
        
    }
}

#pragma mark -

- (IBAction)didReturnClicked:(id)sender {
    [self.myPlayer pause];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)didCollectClicked:(id)sender {
    /// FIXME: 课堂收藏
}

- (IBAction)didPlayClicked:(id)sender {
    [self.playBgView bringSubviewToFront:self.returnBt];
    [self.playBgView bringSubviewToFront:self.collectBt];
    [self.playBgView bringSubviewToFront:self.playBt];
    [self.playBgView bringSubviewToFront:self.videoBar];
    [self.bigPlayBgView bringSubviewToFront:self.bigPlayBt];
    self.playBt.hidden = YES;
    self.bigPlayBt.hidden = YES;
    self.playImageView.hidden = YES;
    self.playerLayer.hidden = NO;
    [self.myPlayer play];
    [self.videoBar setStatus:VIDEOSTATUSPLAY];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
