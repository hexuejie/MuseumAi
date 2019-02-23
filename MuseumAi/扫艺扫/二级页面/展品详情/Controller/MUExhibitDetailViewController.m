//
//  MUExhibitDetailViewController.m
//  MuseumAi
//
//  Created by 魏宙辉 on 2018/9/23.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUExhibitDetailViewController.h"
#import "MJRefresh.h"
#import "MUExhibitModel.h"
#import "UIImageView+WebCache.h"
#import "MUExhibitIntroduceCell.h"
#import "MUCommentCell.h"
#import "MUCommentTitleCell.h"
#import "MUVideoTabBar.h"
#import <AVFoundation/AVFoundation.h>
#import "MUCommentViewController.h"
#import "MUHotGuideViewController.h"

@interface MUExhibitDetailViewController ()<UITableViewDataSource,UITableViewDelegate,AVAudioPlayerDelegate,MUVideoTabBarDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;

/** 大图 */
@property (strong, nonatomic) UIImageView *bigImageView;

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *collectButton;
@property (weak, nonatomic) IBOutlet UIButton *modelButton;

@property (strong, nonatomic) IBOutlet UIView *bigPlayBgView;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *exhibitImageHeightConstraint;
@property (strong, nonatomic) UIImageView *exhibitImageView;

@property (weak, nonatomic) IBOutlet UIView *exhibitBgView;

@property (weak, nonatomic) IBOutlet UILabel *exhibitNameLb;

@property (weak, nonatomic) IBOutlet UITableView *exhibitDetailTableView;

@property (weak, nonatomic) IBOutlet UIButton *playBt;
@property (weak, nonatomic) IBOutlet UIButton *bigPlayBt;

@property (weak, nonatomic) IBOutlet UIView *voiceBgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *voiceTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *voiceHeightConstraint;

@property (weak, nonatomic) IBOutlet UIButton *voiceBt;
@property (weak, nonatomic) IBOutlet UIProgressView *voiceProgress;
@property (weak, nonatomic) IBOutlet UILabel *voiceTimeLb;

/** 当前展品信息 */
@property (strong, nonatomic) MUExhibitModel *exhibit;
/** 评论页数 */
@property (assign, nonatomic) NSInteger commentPage;
/** 评论数组 */
@property (strong, nonatomic) NSArray<MUCommentModel *> *comments;

/** 视频操作条 */
@property (strong, nonatomic) MUVideoTabBar *videoBar;
@property (strong, nonatomic) AVPlayer *myPlayer;           //播放器
@property (strong, nonatomic) AVAsset *asset;
@property (strong, nonatomic) AVPlayerItem *item;           //播放单元
@property (strong, nonatomic) AVPlayerLayer *playerLayer;   //播放界面（layer）
/** 是否准备好播放 */
@property (assign, nonatomic) BOOL isReadToPlay;

/** 音频播放 */
//@property (strong, nonatomic) AVAudioPlayer *musicPlayer;
//@property (assign, nonatomic) BOOL isVoiceReadToPlay;

/** 计时器 */
@property (strong, nonatomic) NSTimer *timer;
/** 总秒数 */
@property (assign, nonatomic) NSInteger totalSecs;
/** 隐藏计数 */
@property (assign, nonatomic) NSInteger hideCount;

/** 是否收藏 */
@property (assign, nonatomic) BOOL isCollect;


@end

@implementation MUExhibitDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self viewInit];
    
    [self dataInit];
}

- (void)viewInit {
    
    self.topConstraint.constant = SafeAreaTopHeight-44.0f;
    
    self.bigPlayBgView.frame = CGRectMake(0, 0, SCREEN_HEIGHT, SCREEN_WIDTH);;
    [self.view addSubview:self.bigPlayBgView];
    self.bigPlayBgView.hidden = YES;
    
    [self.backButton setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    self.bigImageView = [[UIImageView alloc]init];
    self.bigImageView.backgroundColor = [UIColor blackColor];
    self.bigImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.bigImageView];
    [self.bigImageView addTapTarget:self action:@selector(didImageTapped:)];
    self.bigImageView.hidden = YES;
    [self.bigImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.mas_equalTo(0);
    }];
    
    self.exhibitImageView = [[UIImageView alloc]init];
    self.exhibitImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.exhibitImageView.layer.masksToBounds = YES;
    [self.exhibitBgView addSubview:self.exhibitImageView];
    [self.exhibitBgView sendSubviewToBack:self.exhibitImageView];
    [self.exhibitImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.mas_equalTo(0);
    }];
    self.playBt.hidden = YES;
    self.bigPlayBt.hidden = YES;
    
    self.exhibitNameLb.font = [UIFont boldSystemFontOfSize:15.0f];
    
    [self.voiceBt setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    self.voiceBgView.hidden = YES;
    self.voiceTopConstraint.constant = 0.0f;
    self.voiceHeightConstraint.constant = 0.0f;
    
    self.exhibitDetailTableView.estimatedRowHeight = 0;
    self.exhibitDetailTableView.estimatedSectionHeaderHeight = 0;
    self.exhibitDetailTableView.estimatedSectionFooterHeight = 0;
    self.exhibitDetailTableView.tableFooterView = [UIView new];
    self.exhibitDetailTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.exhibitDetailTableView.allowsSelection = NO;
    [self.exhibitDetailTableView registerNib:[UINib nibWithNibName:@"MUExhibitIntroduceCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MUExhibitIntroduceCell"];
    [self.exhibitDetailTableView registerNib:[UINib nibWithNibName:@"MUCommentTitleCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MUCommentTitleCell"];
    [self.exhibitDetailTableView registerNib:[UINib nibWithNibName:@"MUCommentCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MUCommentCell"];
    __weak typeof (self) weakSelf = self;
    self.exhibitDetailTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        weakSelf.commentPage = 1;
        [weakSelf.exhibitDetailTableView.mj_footer resetNoMoreData];
        [weakSelf loadComments];
    }];
    self.exhibitDetailTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        weakSelf.commentPage++;
        [weakSelf loadComments];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)reloadWithExhibitId:(NSString *)exhibitId audioUrl:(NSString *)audioUrl {
    [self.myPlayer pause];
    _exhibitId = exhibitId;
    self.audioUrl = audioUrl;
    [self dataInit];
}
- (void)stopPlayer {
    [self.myPlayer pause];
    self.voiceBt.selected = NO;
}

- (void)dataInit {
    __weak typeof(self) weakSelf = self;
    [MUHttpDataAccess getExhibitDetailWithId:self.exhibitId success:^(id result) {
        if ([result[@"state"]integerValue] == 10001) {
            weakSelf.exhibit = [MUExhibitModel exhibitDetailWithDic:result[@"data"]];
            [weakSelf reloadExhibitInfo];
        }
    } failed:^(NSError *error) {
        [weakSelf alertWithMsg:kFailedTips handler:nil];
    }];
    
    /** 收藏状态 */
    [MUHttpDataAccess getCollectState:self.exhibitId success:^(id result) {
        
        if ([result[@"state"]integerValue] == 10001) {
            
            NSString *resultStr = result[@"data"][@"collectState"];
            if ([resultStr boolValue]) {
                weakSelf.isCollect = YES;
                weakSelf.collectButton.selected = YES;
            }else {
                weakSelf.isCollect = NO;
                weakSelf.collectButton.selected = NO;
            }
            
        }
        
    } failed: nil];
    
    [self.exhibitDetailTableView.mj_header beginRefreshing];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddNewComment:) name:kSubmitCommentOKNotification object:nil];
}

- (void)didAddNewComment:(id)sender {
    [self.exhibitDetailTableView.mj_header beginRefreshing];
}

- (void)setAudioUrl:(NSString *)audioUrl {
    _audioUrl = audioUrl;
    [self loadVoiceWithURL:audioUrl];
    NSLog(@"加载音频");
}

- (void)reloadExhibitInfo {
    if (self.exhibit.exhibit3DUrl.length == 0) {
        self.modelButton.hidden = YES;
    } else {
        self.modelButton.hidden = NO;
    }
    if (self.audioUrl != nil) {
        self.exhibit.mediaType = MUEXHIBITMEDIATYPEVOICE;
        self.exhibit.mediaUrl = self.audioUrl;
    }
    [self.bigImageView sd_setImageWithURL:[NSURL URLWithString:self.exhibit.exhibitUrl]];
    [self.exhibitImageView sd_setImageWithURL:[NSURL URLWithString:self.exhibit.exhibitUrl]];
    self.exhibitNameLb.text = [NSString stringWithFormat:@"　%@",self.exhibit.exhibitName];
    switch (self.exhibit.mediaType) {
        case MUEXHIBITMEDIATYPENONE: {
            [self.exhibitImageView addTapTarget:self action:@selector(didImageTapped:)];
            break;
        }
        case MUEXHIBITMEDIATYPEVOICE: {
            self.voiceBgView.hidden = NO;
            self.voiceTopConstraint.constant = 10.0f;
            self.voiceHeightConstraint.constant = 44.0f;
            if (self.audioUrl == nil) {
                [self loadVoiceWithURL:self.exhibit.mediaUrl];
            } else {
                [self.exhibitImageView addTapTarget:self action:@selector(didImageTapped:)];
                [self.voiceProgress setProgress:0.0f];
                self.voiceTimeLb.text = @"00:00";
                self.voiceBt.selected = YES;
            }
            break;
        }
        case MUEXHIBITMEDIATYPEVIDEO: {
            self.playBt.hidden = NO;
            self.bigPlayBt.hidden = NO;
            [self loadVideoWithURL:self.exhibit.mediaUrl];
            break;
        }
        default:
            break;
    }
    
    [self.exhibitDetailTableView reloadData];
}

- (void)loadVoiceWithURL:(NSString *)urlStr {
    
    // 音频加载
    [self.exhibitImageView addTapTarget:self action:@selector(didImageTapped:)];
    [self.voiceProgress setProgress:0.0f];
    self.voiceTimeLb.text = @"00:00";
    
    NSURL *url = [NSURL URLWithString:urlStr];
    self.item = [[AVPlayerItem alloc]initWithURL:url];
    self.isReadToPlay = NO;
    [self.item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didVideoPlayOver:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    self.myPlayer = [[AVPlayer alloc]initWithPlayerItem:self.item];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
    if (self.audioUrl != nil) {
        [self.myPlayer play];
    }
}

- (void)loadVideoWithURL:(NSString *)url {
    // 视频加载
    NSURL *mediaURL = [NSURL URLWithString:url];
    self.asset = [AVAsset assetWithURL:mediaURL];
    self.item = [AVPlayerItem playerItemWithAsset:self.asset];
    self.myPlayer = [AVPlayer playerWithPlayerItem:self.item];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.myPlayer];
    self.playerLayer.frame = CGRectMake(0, 0, self.exhibitBgView.bounds.size.width, self.exhibitBgView.bounds.size.height);
    [self.exhibitBgView.layer addSublayer:self.playerLayer];
    self.playerLayer.hidden = YES;
    self.exhibitBgView.backgroundColor = [UIColor blackColor];
    self.isReadToPlay = NO;
    [self.item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didVideoPlayOver:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    self.videoBar = [MUVideoTabBar videoTabBarWithDelegate:self];
    [self.exhibitBgView addSubview:self.videoBar];
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
    [self.exhibitBgView addTapTarget:self action:@selector(didVideoScreenTap:)];
    [self.bigPlayBgView addTapTarget:self action:@selector(didVideoScreenTap:)];
    
}

- (void)loadComments {
   
    __weak typeof(self) weakSelf = self;
    [MUHttpDataAccess getCommentsWithType:MUEXHIBITSCOMMENT page:self.commentPage exhibitId:self.exhibitId success:^(id result) {
        if([weakSelf.exhibitDetailTableView.mj_header isRefreshing]) {
            weakSelf.comments = @[];
        }
        if ([result[@"state"]integerValue] == 10001) {
            NSArray *list = result[@"data"][@"commentList"];
            NSMutableArray *mutComments = [NSMutableArray arrayWithArray:weakSelf.comments];
            for (NSDictionary *dic in list) {
                MUCommentModel *model = [MUCommentModel commentWithDic:dic];
                [mutComments addObject:model];
            }
            weakSelf.comments = [NSArray arrayWithArray:mutComments];
            [weakSelf.exhibitDetailTableView.mj_header endRefreshing];
            if(list.count < 10) {
                [weakSelf.exhibitDetailTableView.mj_footer endRefreshingWithNoMoreData];
            } else {
                [weakSelf.exhibitDetailTableView.mj_footer endRefreshing];
            }
        } else {
            [weakSelf.exhibitDetailTableView.mj_header endRefreshing];
            [weakSelf.exhibitDetailTableView.mj_footer endRefreshing];
        }
        [weakSelf.exhibitDetailTableView reloadData];
    } failed:^(NSError *error) {
        [weakSelf alertWithMsg:kFailedTips handler:nil];
    }];
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
                self.isReadToPlay = NO;
                break;
            default:
                break;
        }
    }
}

- (void)dealloc {
    //移除监听（观察者）
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self.item removeObserver:self forKeyPath:@"status"];
    [self.timer isValid];
    self.timer = nil;
}

- (void)timerAction:(id)sender {
    if (self.exhibit.mediaType == MUEXHIBITMEDIATYPENONE) {
        return;
    } else if (self.exhibit.mediaType == MUEXHIBITMEDIATYPEVOICE) {
        // 音频
        NSInteger currentTime = self.myPlayer.currentTime.value/self.myPlayer.currentTime.timescale;
        NSInteger restSecs = self.totalSecs - currentTime;
        if (restSecs < 0) {
            restSecs = 0;
        }
        NSInteger min = restSecs/60;
        NSInteger sec = restSecs%60;
        self.voiceTimeLb.text = [NSString stringWithFormat:@"%02ld:%02ld",min,sec];
        [self.voiceProgress setProgress:currentTime/(CGFloat)self.totalSecs ];
        
    } else if (self.exhibit.mediaType == MUEXHIBITMEDIATYPEVIDEO) {
        // 视频
        if (self.exhibitImageView.hidden == NO) {
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
}

#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2+self.comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: {
            MUExhibitIntroduceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MUExhibitIntroduceCell"];
            [cell bindCellWithModel:self.exhibit];
            return cell;
            break;
        }
        case 1: {
            MUCommentTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MUCommentTitleCell"];
            return cell;
            break;
        }
        default: {
            __weak typeof(self) weakSelf = self;
            MUCommentModel *comment = self.comments[indexPath.row-2];
            MUCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MUCommentCell"];
            [cell bindCellWithModel:comment loveClicked:^{
                [weakSelf agreeComment:comment];
            }];
            return cell;
            break;
        }
    }
}

- (void)agreeComment:(MUCommentModel *)comment {
    
    if (![MUUserModel currentUser].isLogin) {
        [self.navigationController pushViewController:[MULoginViewController new] animated:YES];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [MUHttpDataAccess agreeComment:comment.commentId success:^(id result) {
        if ([result[@"state"]integerValue] == 10001) {
            comment.count++;
            [weakSelf.exhibitDetailTableView reloadData];
            NSLog(@"result:%@",result);
        }else {
            [weakSelf alertWithMsg:result[@"msg"] handler:nil];
        }
    } failed:^(NSError *error) {
        [weakSelf alertWithMsg:kFailedTips handler:nil];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: {
            CGFloat contentHeight = [MULayoutHandler caculateHeightWithContent:self.exhibit.exhibitIntroduce width:SCREEN_WIDTH-25];
            return contentHeight+kExhibitIntroduceBaseHeight;
            break;
        }
        case 1: {
            return 45.0f;
            break;
        }
        default: {
            MUCommentModel *comment = self.comments[indexPath.row-2];
            return [comment commentTotalHeight];
            break;
        }
    }
}

#pragma mark ---- 按钮操作

/** 大小屏幕切换 */
- (void)didVideoScreenTap:(id)sender {
    self.videoBar.hidden = !self.videoBar.hidden;
    if (self.videoBar.hidden) {
        self.hideCount = 0;
    }else {
        self.hideCount = 3;
    }
}

- (void)didVideoPlayOver:(id)sender {
    switch (self.exhibit.mediaType) {
        case MUEXHIBITMEDIATYPEVIDEO: {
            self.playBt.hidden = NO;
            self.bigPlayBt.hidden = NO;
            self.exhibitImageView.hidden = NO;
            self.playerLayer.hidden = YES;
            [self.myPlayer pause];
            [self.myPlayer seekToTime:kCMTimeZero];
            [self.videoBar setStatus:VIDEOSTATUSPAUSE];
            [self.videoBar setCurrentTime:0 totalTime:self.totalSecs refreshSlider:YES];
            break;
        }
        case MUEXHIBITMEDIATYPEVOICE: {
            self.voiceBt.selected = NO;
            break;
        }
        default:
            break;
    }
}

- (IBAction)didCommentClicked:(id)sender {
    if (![MUUserModel currentUser].isLogin) {
        [self.navigationController pushViewController:[MULoginViewController new] animated:YES];
        return;
    }
    
    MUCommentViewController *vc = [MUCommentViewController new];
    vc.type = MUEXHIBITSCOMMENT;
    vc.exhibitId = self.exhibitId;
    [self.navigationController pushViewController:vc animated:YES];
}

/** 展示大图 */
- (void)didImageTapped:(id)sender {
    self.bigImageView.hidden = !self.bigImageView.hidden;
}

- (IBAction)didBackClicked:(id)sender {
    [self.myPlayer pause];
//    [self.musicPlayer pause];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)didPlayBtClicked:(id)sender {
    [self.exhibitBgView bringSubviewToFront:self.backButton];
    [self.exhibitBgView bringSubviewToFront:self.collectButton];
    [self.exhibitBgView bringSubviewToFront:self.modelButton];
    [self.exhibitBgView bringSubviewToFront:self.playBt];
    [self.exhibitBgView bringSubviewToFront:self.videoBar];
    [self.bigPlayBgView bringSubviewToFront:self.bigPlayBt];
    self.playBt.hidden = YES;
    self.bigPlayBt.hidden = YES;
    self.exhibitImageView.hidden = YES;
    self.playerLayer.hidden = NO;
    [self.myPlayer play];
    [self.videoBar setStatus:VIDEOSTATUSPLAY];
}

- (IBAction)didVoiceButtonClicked:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.myPlayer play];
    }else {
        [self.myPlayer pause];
    }
}


- (IBAction)didCollectClicked:(id)sender {
    
    if (![MUUserModel currentUser].isLogin) {
        [self.navigationController pushViewController:[MULoginViewController new] animated:YES];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [MUHttpDataAccess collectExhibitBy:self.exhibitId success:^(id result) {
        if ([result[@"state"]integerValue] == 10001) {
            NSInteger resultValue = [result[@"data"]integerValue];
            if (resultValue == 1) { // 收藏成功
                weakSelf.isCollect = YES;
                weakSelf.collectButton.selected = YES;
            }else if(resultValue == 2) { // 取消收藏成功
                weakSelf.isCollect = NO;
                weakSelf.collectButton.selected = NO;
            }
        }
    } failed:^(NSError *error) {
        [weakSelf alertWithMsg:kFailedTips handler:nil];
    }];
}



#pragma mark ---- 播放条
/** 播放按钮 */
- (void)videoBar:(MUVideoTabBar *)videoBar isPlay:(BOOL)isPlay {
    self.hideCount = 3;
    [self.exhibitBgView bringSubviewToFront:self.backButton];
    [self.exhibitBgView bringSubviewToFront:self.collectButton];
    [self.exhibitBgView bringSubviewToFront:self.modelButton];
    [self.exhibitBgView bringSubviewToFront:self.playBt];
    [self.exhibitBgView bringSubviewToFront:self.videoBar];
    [self.bigPlayBgView bringSubviewToFront:self.bigPlayBt];
    if (isPlay) {
        self.playBt.hidden = YES;
        self.bigPlayBt.hidden = YES;
        self.exhibitImageView.hidden = YES;
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
            weakSelf.playerLayer.frame = weakSelf.exhibitBgView.bounds;
            [weakSelf.exhibitBgView.layer addSublayer:weakSelf.playerLayer];
            weakSelf.bigPlayBgView.hidden = YES;
            [weakSelf.videoBar removeFromSuperview];
            weakSelf.videoBar.type = VIDEOSCREENTYPESMALL;
            [weakSelf.exhibitBgView addSubview:weakSelf.videoBar];
            [weakSelf.videoBar mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.bottom.right.mas_equalTo(0);
                make.height.mas_equalTo(30.0f);
            }];
            weakSelf.videoBar.hidden = NO;
            weakSelf.hideCount = 3;
            [weakSelf.exhibitBgView bringSubviewToFront:weakSelf.backButton];
            [weakSelf.exhibitBgView bringSubviewToFront:weakSelf.collectButton];
            [weakSelf.exhibitBgView bringSubviewToFront:weakSelf.modelButton];
            [weakSelf.exhibitBgView bringSubviewToFront:weakSelf.playBt];
            [weakSelf.exhibitBgView bringSubviewToFront:weakSelf.videoBar];
        }];
        
    }
}

- (IBAction)didModelButtonClicked:(id)sender {
    MUHotGuideViewController *vc = [MUHotGuideViewController new];
    vc.url = [NSURL URLWithString:self.exhibit.exhibit3DUrl];
    vc.hidesBottomBarWhenPushed = YES;
    if (vc.url != nil) {
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
