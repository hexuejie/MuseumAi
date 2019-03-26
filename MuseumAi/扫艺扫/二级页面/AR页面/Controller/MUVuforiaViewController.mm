//
//  MUVuforiaViewController.m
//  MuseumAi
//
//  Created by 魏宙辉 on 2019/2/25.
//  Copyright © 2019年 Weizh. All rights reserved.
//

#import "MUVuforiaViewController.h"

#ifndef MUSimulatorTest
#import "MUVuforiaViewController+IBeacon.h"
#import "VideoPlaybackEAGLView.h"
#import "SampleApplicationSession.h"
#import "AppDelegate.h"
#import "MUARUtils.h"
#import "MUExhibitDetailViewController.h"
#import "MUHelpVideoViewController.h"
#import "MUGuideViewController.h"

#import "MUScanBackView.h"
#import "MUExhibitModel.h"
#import "MUARExitButton.h"

#import <Vuforia/DataSet.h>
#import <Vuforia/Vuforia.h>
#import <Vuforia/TrackerManager.h>
#import <Vuforia/ObjectTracker.h>
#import <Vuforia/Trackable.h>
#import <Vuforia/DataSet.h>
#import <Vuforia/CameraDevice.h>


@interface MUVuforiaViewController ()<SampleApplicationControl> {
    Vuforia::DataSet*  mDataSet;
}

@property (nonatomic, strong) VideoPlaybackEAGLView* eaglView;
@property (nonatomic, strong) SampleApplicationSession* vapp;

/* 扫描背景 */
@property(nonatomic, strong) MUScanBackView *scanBackView;
/* 扫描动画 */
@property(nonatomic, strong) UIImageView *scanImageView;
/* 热门展品 */
@property(nonatomic, strong) NSArray<MUExhibitModel *> *exhibits;

/* 发现目标后停止播放按钮 */
@property(nonatomic, strong) MUARExitButton *exitButton;

/* 发现的目标 */
@property(nonatomic, strong) MUARModel *discoverExhibit;

/* 引导页 */
@property(nonatomic, strong) UIView *guideView;

@end

#endif

@implementation MUVuforiaViewController

#ifndef MUSimulatorTest
@synthesize vapp, eaglView;

- (void)dealloc {
    NSLog(@"AR dealloc");
}

- (void)loadView {
    // Custom initialization
    self.title = @"AR扫描";
    
    vapp = [[SampleApplicationSession alloc] initWithDelegate:self];
    CGRect viewFrame = [vapp getCurrentARViewBounds];
    eaglView = [[VideoPlaybackEAGLView alloc] initWithFrame:viewFrame
                                                        ars:self.ars
                                         rootViewController:self
                                                 appSession:vapp];
    eaglView.hallID = self.hall.hallId;
    [eaglView setBackgroundColor:UIColor.clearColor];
    [self setView:eaglView];
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.glResourceHandler = eaglView;
    
//    [self setView:[UIView new]];
    
    // we use the iOS notification to pause/resume the AR when the application goes (or come back from) background
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(pauseAR)
     name:UIApplicationWillResignActiveNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(resumeAR)
     name:UIApplicationDidBecomeActiveNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(didDiscoverTarget:)
     name:kDiscoverTargetNotification
     object:nil];
    
    __weak typeof(self) weakSelf = self;
    self.scanBackView = [MUScanBackView scanBackViewShareCallback:^(id  _Nonnull sender) {
        [weakSelf shareExhibitsHall];
    } helpCallback:^(id  _Nonnull sender) {
        [weakSelf help];
    } guideCallback:^(id  _Nonnull sender) {
        [weakSelf guide:nil];
    } mainCallback:^(id  _Nonnull sender) {
        [weakSelf main];
    } exhibitSelectHandler:^(MUExhibitModel * _Nonnull exhibit) {
        [weakSelf guide:exhibit];
    }];
    self.scanBackView.hallNameLabel.text = self.hall.hallName;
    [self.view addSubview:self.scanBackView];
    [self.scanBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.mas_equalTo(0);
    }];
    
    self.scanImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"扫描动画"]];
    [self.view addSubview:self.scanImageView];
    self.scanImageView.frame = CGRectMake(0, -100, SCREEN_WIDTH, 100.0f);
    self.scanImageView.hidden = YES;
    [self scanAnimation];
    [self.view sendSubviewToBack:self.scanImageView];
    
    self.exitButton = [MUARExitButton buttonWithTarget:self selector:@selector(didStopPlayClicked:)];
    [self.view addSubview:self.exitButton];
    [self.exitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.0f);
        make.width.mas_equalTo(100.0f);
        make.height.mas_equalTo(70.0f);
        make.top.mas_equalTo(60.0f);
    }];
    self.exitButton.hidden = YES;
}

- (void)scanAnimation {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:1 animations:^{
        weakSelf.scanImageView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 100.0f);
    } completion:^(BOOL finished) {
        weakSelf.scanImageView.frame = CGRectMake(0, -100, SCREEN_WIDTH, 100.0f);
        [weakSelf scanAnimation];
    }];
}

- (void)viewInit {
    
    // initialize AR
    [vapp initAR:Vuforia::GL_20
     orientation:[[UIApplication sharedApplication] statusBarOrientation]
      deviceMode:Vuforia::Device::MODE_AR
          stereo:false];
    
    // show loading animation while AR is being initialized
    [self showLoadingAnimation];
    
    NSString *helpGuide = [[NSUserDefaults standardUserDefaults] objectForKey:@"help_guide"];
    if (![helpGuide boolValue]) {
        [self pauseAR];
        [self addHelpGuideMask];
    } else {
        NSString *guideGuide = [[NSUserDefaults standardUserDefaults] objectForKey:@"guide_guide"];
        if (![guideGuide boolValue]) {
            [self pauseAR];
            [self addGuideGuideMask];
        }
    }
    
    [self dataInit];
    [self ibeaconInit];
}

- (void) pauseAR {
    self.scanImageView.hidden = YES;
    [eaglView dismissPlayers];
    NSError * error = nil;
    if (![vapp pauseAR:&error]) {
        NSLog(@"Error pausing AR:%@", [error description]);
    }
}

- (void)resumeAR {
    [self resumeAR:YES];
}
- (void) resumeAR:(BOOL)showScan {
    [eaglView preparePlayers];
    NSError * error = nil;
    if(![vapp resumeAR:&error]) {
        NSLog(@"Error resuming AR:%@", [error description]);
    }
    if (showScan) {
        self.scanImageView.hidden = NO;
    }
    [eaglView updateRenderingPrimitives];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    [self.iBeaconClient closeClient];
    self.isInitAR = NO;
    [self viewInit];
    [self resumeAR:NO];
    self.scanBackView.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden = NO;
    [self pauseAR];
    [eaglView dismiss];
    [vapp stopAR:nil];
    [eaglView finishOpenGLESCommands];
    [eaglView freeOpenGLESResources];
}

#pragma mark - SampleApplicationControl

// Initialize the application trackers
- (bool) doInitTrackers {
    // Initialize the image tracker
    Vuforia::TrackerManager& trackerManager = Vuforia::TrackerManager::getInstance();
    Vuforia::Tracker* trackerBase = trackerManager.initTracker(Vuforia::ObjectTracker::getClassType());
    if (trackerBase == nil)
    {
        NSLog(@"Failed to initialize ObjectTracker.");
        return false;
    }
    return true;
}

// load the data associated to the trackers
- (bool) doLoadTrackersData {
    return [self loadAndActivateImageTrackerDataSet:self.hall.hallId];;
}

// start the application trackers
- (bool) doStartTrackers {
    // Set the number of simultaneous targets to two
    Vuforia::setHint(Vuforia::HINT_MAX_SIMULTANEOUS_IMAGE_TARGETS, (int)self.ars.count);
    
    Vuforia::TrackerManager& trackerManager = Vuforia::TrackerManager::getInstance();
    Vuforia::Tracker* tracker = trackerManager.getTracker(Vuforia::ObjectTracker::getClassType());
    if(tracker == nullptr) {
        return false;
    }
    tracker->start();
    return true;
}

// callback called when the initailization of the AR is done
- (void)onInitARDone:(NSError *)initError {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIActivityIndicatorView *loadingIndicator = (UIActivityIndicatorView *)[self->eaglView viewWithTag:1];
        [loadingIndicator removeFromSuperview];
        if (weakSelf.iBeaconClient) {
            [weakSelf.iBeaconClient openClient];
        }
        weakSelf.isInitAR = YES;
        weakSelf.scanBackView.hidden = NO;
        weakSelf.scanImageView.hidden = NO;
    });
    
    if (initError == nil) {
        NSError * error = nil;
        [vapp startAR:Vuforia::CameraDevice::CAMERA_DIRECTION_BACK error:&error];
        
        [eaglView updateRenderingPrimitives];
        
        // by default, we try to set the continuous auto focus mode
        Vuforia::CameraDevice::getInstance().setFocusMode(Vuforia::CameraDevice::FOCUS_MODE_CONTINUOUSAUTO);
        
    } else {
        // 初始化AR错误
        __weak typeof(self) weakSelf = self;
        dispatch_async( dispatch_get_main_queue(), ^{
            
            UIAlertController *uiAlertController =
            [UIAlertController alertControllerWithTitle:@"Error"
                                                message:[initError localizedDescription]
                                         preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *defaultAction =
            [UIAlertAction actionWithTitle:@"确定"
                                     style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action) {
                                       [weakSelf.navigationController popViewControllerAnimated:YES];
                                   }];
            
            [uiAlertController addAction:defaultAction];
            [weakSelf presentViewController:uiAlertController animated:YES completion:nil];
            
        });
    }
}


- (void)configureVideoBackgroundWithViewWidth:(float)viewWidth
                                    andHeight:(float)viewHeight {
    [eaglView configureVideoBackgroundWithViewWidth:(float)viewWidth andHeight:(float)viewHeight];
}

// update from the Vuforia loop
- (void) onVuforiaUpdate: (Vuforia::State *) state {
    
}

// stop your trackerts
- (bool) doStopTrackers {
    Vuforia::TrackerManager& trackerManager = Vuforia::TrackerManager::getInstance();
    Vuforia::Tracker* tracker = trackerManager.getTracker(Vuforia::ObjectTracker::getClassType());
    
    if (tracker == nullptr) {
        NSLog(@"ERROR: failed to get the tracker from the tracker manager");
        return false;
    }
    
    tracker->stop();
    return true;
}

// unload the data associated to your trackers
- (bool) doUnloadTrackersData {
    if (mDataSet != nullptr)
    {
        // Get the image tracker:
        Vuforia::TrackerManager& trackerManager = Vuforia::TrackerManager::getInstance();
        Vuforia::ObjectTracker* objectTracker = static_cast<Vuforia::ObjectTracker*>(trackerManager.getTracker(Vuforia::ObjectTracker::getClassType()));
        
        if (objectTracker == nullptr)
        {
            NSLog(@"Failed to unload tracking data set because the ImageTracker has not been initialized.");
            return false;
        }
        
        // Activate the data set:
        if (!objectTracker->deactivateDataSet(mDataSet))
        {
            NSLog(@"Failed to deactivate data set.");
            return false;
        }
        
        // Activate the data set:
        if (!objectTracker->destroyDataSet(mDataSet))
        {
            NSLog(@"Failed to destroy data set.");
            return false;
        }
        
        mDataSet = nullptr;
    }
    return true;
}

// deinitialize your trackers
- (bool) doDeinitTrackers
{
    Vuforia::TrackerManager& trackerManager = Vuforia::TrackerManager::getInstance();
    trackerManager.deinitTracker(Vuforia::ObjectTracker::getClassType());
    return true;
}

- (void)cameraPerformAutoFocus
{
    Vuforia::CameraDevice::getInstance().setFocusMode(Vuforia::CameraDevice::FOCUS_MODE_TRIGGERAUTO);
    
    // After triggering an autofocus event,
    // we must restore the previous focus mode
    [self performSelector:@selector(restoreContinuousAutoFocus) withObject:nil afterDelay:2.0];
}

- (void)restoreContinuousAutoFocus {
    Vuforia::CameraDevice::getInstance().setFocusMode(Vuforia::CameraDevice::FOCUS_MODE_CONTINUOUSAUTO);
}

// Load the image tracker data set
- (BOOL)loadAndActivateImageTrackerDataSet:(NSString*)hallID {
    
    NSString *dataFile = [NSString stringWithFormat:@"%@hall.xml",[MUARUtils vuforiaPathWithHallId:hallID]];
    NSLog(@"loadAndActivateImageTrackerDataSet (%@)", dataFile);
    BOOL ret = YES;
    mDataSet = nullptr;
    
    // Get the Vuforia tracker manager image tracker
    Vuforia::TrackerManager& trackerManager = Vuforia::TrackerManager::getInstance();
    Vuforia::ObjectTracker* objectTracker = static_cast<Vuforia::ObjectTracker*>(trackerManager.getTracker(Vuforia::ObjectTracker::getClassType()));
    
    if (objectTracker == nullptr)
    {
        NSLog(@"ERROR: failed to get the ImageTracker from the tracker manager");
        ret = NO;
    }
    else
    {
        mDataSet = objectTracker->createDataSet();
        
        if (mDataSet != nullptr)
        {
            // Load the data set from the app's resources location
            if (!mDataSet->load([dataFile cStringUsingEncoding:NSASCIIStringEncoding], Vuforia::STORAGE_ABSOLUTE))
//            if (!mDataSet->load([@"StonesAndChips.xml" cStringUsingEncoding:NSASCIIStringEncoding], Vuforia::STORAGE_APPRESOURCE))
            {
                NSLog(@"ERROR: failed to load data set");
                objectTracker->destroyDataSet(mDataSet);
                mDataSet = nullptr;
                ret = NO;
            }
            else
            {
                // Activate the data set
                if (objectTracker->activateDataSet(mDataSet))
                {
                    NSLog(@"INFO: successfully activated data set");
                }
                else
                {
                    NSLog(@"ERROR: failed to activate data set");
                    ret = NO;
                }
            }
        }
        else
        {
            NSLog(@"ERROR: failed to create data set");
            ret = NO;
        }
        
    }
    return ret;
}

- (void)toExhibitsDetail:(NSString *)exhibitId {
    MUExhibitDetailViewController *detailVC = [MUExhibitDetailViewController new];
    detailVC.exhibitId = exhibitId;
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark ----
- (void)didDiscoverTarget:(NSNotification *)notification {
    NSObject *obj = notification.object;
    if (![obj isKindOfClass:[MUARModel class]]) {
        return;
    }
    self.discoverExhibit = (MUARModel *)obj;
    self.scanImageView.hidden = YES;
    self.scanBackView.hidden = YES;
    self.exitButton.hidden = NO;
    self.isPlayAR = YES;
}

- (void)didStopPlayClicked:(id)sender {
    if (self.discoverExhibit) {
        [eaglView stopPlay];
        self.isPlayAR = NO;
        self.scanBackView.hidden = NO;
        self.scanImageView.hidden = NO;
        self.exitButton.hidden = YES;
        [self toExhibitsDetail:self.discoverExhibit.exhibitsId];
        [MUHttpDataAccess recoganizerExhibitWithExhibitId:self.discoverExhibit.exhibitsId method:1];
        self.discoverExhibit = nil;
    }
}

#pragma mark ----

- (void)dataInit {
    __weak typeof(self) weakSelf = self;
    [MUHttpDataAccess getExhibitsWithHallId:self.hall.hallId page:1 isHot:YES success:^(id result) {
        
        if ([result[@"state"] integerValue] == 10001) {
            
            NSMutableArray *mutExhibits = [NSMutableArray array];
            for (NSDictionary *dic in result[@"data"][@"list"]) {
                MUExhibitModel *exhibit = [MUExhibitModel exhibitWithDic:dic];
                [mutExhibits addObject:exhibit];
            }
            weakSelf.exhibits = [NSArray arrayWithArray:mutExhibits];
            weakSelf.scanBackView.exhibits = weakSelf.exhibits;
        } else {
            weakSelf.scanBackView.exhibits = @[];
        }
        
    } failed:^(NSError *error) {
        NSLog(@"网络请求失败");
    }];
}

- (void)shareExhibitsHall {
    UIImageView *iv = [UIImageView new];
    __weak typeof(self) weakSelf = self;
    [iv sd_setImageWithURL:[NSURL URLWithString:self.hall.hallPicUrl] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        
        NSString *urlStr = [NSString stringWithFormat:@"https://www.airart.com.cn/museumai2/#/exhibtionHallDetail/%@",self.hall.hallId];
        NSLog(@"url:%@",urlStr);
        NSURL *url = [NSURL URLWithString:urlStr];
        UIActivityViewController *vc = [MUCustomUtils shareWeixinWithText:weakSelf.hall.hallName content:weakSelf.hall.hallAddress image:image url:url];
        [weakSelf presentViewController:vc animated:YES completion:nil];
        [vc setCompletionWithItemsHandler:^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
            if (completed) {
                [weakSelf alertWithMsg:@"分享成功" handler:nil];
            }else {
                [weakSelf alertWithMsg:@"已取消分享" handler:nil];
            }
        }];
    }];
}

- (void)help {
    MUHelpVideoViewController *vc = [MUHelpVideoViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)guide:(MUExhibitModel *)exhibit {
    MUGuideViewController *guideVC = [[MUGuideViewController alloc]init];
    guideVC.hall = self.hall;
    guideVC.hotExhibits = self.exhibits;
    guideVC.selectExhibit = exhibit;
    [self.navigationController pushViewController:guideVC animated:YES];
}

- (void)main {
    [eaglView dismiss];
    [vapp stopAR:nil];
    [eaglView finishOpenGLESCommands];
    [eaglView freeOpenGLESResources];
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.glResourceHandler = nil;
    vapp = nil;
    eaglView = nil;
    [self finishIbeacon];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (eaglView == nil) {
        [self setView:nil];
    }
}

#pragma mark ---- ibeacon回调，类别中实现
/** 蓝牙状态有改变 */
- (void)ibeacon:(ZACIBeaconClient *)ibeacon didChangeBlueToothStatus:(BOOL)isOn {
    [self didChangeBlueToothStatus:isOn];
}
/** 发现新的蓝牙设备 */
- (void)ibeacon:(ZACIBeaconClient *)ibeacon didFoundNewBlueTooth:(MUBlueToothModel *)blueTooth {
    [self didFoundNewBlueTooth:blueTooth];
}


#pragma mark ----
- (CAShapeLayer *)addTransparencyViewWith:(UIBezierPath *)tempPath{
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:SCREEN_BOUNDS];
    [path appendPath:tempPath];
    path.usesEvenOddFillRule = YES;
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = path.CGPath;
    shapeLayer.fillColor= [UIColor blackColor].CGColor;  // 其他颜色都可以，只要不是透明的
    shapeLayer.fillRule = kCAFillRuleEvenOdd;
    return shapeLayer;
}

- (void)addHelpGuideMask {
    
    CGRect rect = CGRectMake(21, SCREEN_HEIGHT-53.0f, 40.0f, 50.0f);
    UIBezierPath *tempPath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:(UIRectCornerTopLeft |UIRectCornerTopRight |UIRectCornerBottomRight|UIRectCornerBottomLeft) cornerRadii:CGSizeMake(4, 4)];
    UIView *guideView = [[UIView alloc] initWithFrame:SCREEN_BOUNDS];
    guideView.backgroundColor = [UIColor blackColor];
    guideView.alpha = 0.8;
    guideView.layer.mask = [self addTransparencyViewWith:tempPath];
    [[UIApplication sharedApplication].keyWindow addSubview:guideView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = rect;
    button.backgroundColor = [UIColor clearColor];
    [button addTapTarget:self action:@selector(didMaskHelpClicked:)];
    [guideView addSubview:button];;
    
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"引导下箭头"]];
    [guideView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(button.mas_top).offset(-5.0f);
        make.centerX.equalTo(button);
        make.width.height.mas_equalTo(30.0f);
    }];
    
    UILabel *tipsLb = [[UILabel alloc]init];
    tipsLb.textColor = [UIColor whiteColor];
    tipsLb.font = [UIFont systemFontOfSize:14.0f];
    tipsLb.text = @"点击查看帮助";
    [guideView addSubview:tipsLb];
    [tipsLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20.0f);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(30.0f);
        make.bottom.equalTo(imageView.mas_top).offset(-5.0f);
    }];
    
    self.guideView = guideView;
}

- (void)didMaskHelpClicked:(id)sender {
    self.guideView.hidden = YES;
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"help_guide"];
    [self help];
}

- (void)addGuideGuideMask {
    
    CGRect rect = CGRectMake((SCREEN_WIDTH-40.0f)/2.0f, SCREEN_HEIGHT-53.0f, 40.0f, 50.0f);
    UIBezierPath *tempPath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:(UIRectCornerTopLeft |UIRectCornerTopRight |UIRectCornerBottomRight|UIRectCornerBottomLeft) cornerRadii:CGSizeMake(4, 4)];
    UIView *guideView = [[UIView alloc] initWithFrame:SCREEN_BOUNDS];
    guideView.backgroundColor = [UIColor blackColor];
    guideView.alpha = 0.8;
    guideView.layer.mask = [self addTransparencyViewWith:tempPath];
    [[UIApplication sharedApplication].keyWindow addSubview:guideView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = rect;
    button.backgroundColor = [UIColor clearColor];
    [button addTapTarget:self action:@selector(didMaskGuideClicked:)];
    [guideView addSubview:button];;
    
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"引导下箭头"]];
    [guideView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(button.mas_top).offset(-5.0f);
        make.centerX.equalTo(button).offset(3.0f);
        make.width.height.mas_equalTo(30.0f);
    }];
    
    UILabel *tipsLb = [[UILabel alloc]init];
    tipsLb.textColor = [UIColor whiteColor];
    tipsLb.textAlignment = NSTextAlignmentCenter;
    tipsLb.font = [UIFont systemFontOfSize:14.0f];
    tipsLb.text = @"来看看该馆都有啥展品吧";
    [guideView addSubview:tipsLb];
    [tipsLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(30.0f);
        make.bottom.equalTo(imageView.mas_top).offset(-5.0f);
    }];
    
    self.guideView = guideView;
}

- (void)didMaskGuideClicked:(id)sender {
    self.guideView.hidden = YES;
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"guide_guide"];
    [self guide:nil];
}
#endif

@end
