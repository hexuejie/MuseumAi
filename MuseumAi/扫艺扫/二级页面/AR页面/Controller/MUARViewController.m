//
//  MUARViewController.m
//  MuseumAi
//
//  Created by 魏宙辉 on 2018/9/22.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUARViewController.h"
#import "OpenGLView.h"
#import "MUExhibitCell.h"
#import "MUHttpDataAccess.h"
#import "MUExhibitModel.h"
#import "UIImageView+WebCache.h"
#import "MUGuideViewController.h"
#import "MUExhibitDetailViewController.h"
#import "MUHelpVideoViewController.h"
#import "MUBlueToothModel.h"
#import "ZACAnimationView.h"
#import "ZACIBeaconClient.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface MUARViewController ()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,ZACIBeaconClientDelegate>
{
//    UILabel *distanceLb;
    NSURL *_hideUrl;     // 隐藏在后面的url
    BOOL _isPlayAR;
    UIView *_btBgView;
}
/** OpenGL */
@property (strong, nonatomic) OpenGLView *glView;

@property (strong, nonatomic) UILabel *museumLb;

@property (strong, nonatomic) UIButton *shareBt;

@property (strong, nonatomic) UIButton *exitBt;

@property (strong, nonatomic) UIButton *detailBt;

@property (strong, nonatomic) UILabel *tipsLb;

@property (strong, nonatomic) UILabel *exhibitsLb;

@property (strong, nonatomic) UILabel *hotLb;
@property (strong, nonatomic) UICollectionView *imageCollectionView;

@property (strong, nonatomic) UIButton *helpImageBt;
@property (strong, nonatomic) UIButton *helpBt;

@property (strong, nonatomic) UIButton *guideImageBt;
@property (strong, nonatomic) UIButton *guideBt;

@property (strong, nonatomic) UIButton *mainImageBt;
@property (strong, nonatomic) UIButton *mainBt;

/** 帮助 */
@property (nonatomic , strong) ZACAnimationView *helpView;
@property (nonatomic , strong) UIView *helpBgView;

/** 展品列表 */
@property (strong, nonatomic) NSArray *exhibits;
/** 扫描到的展品id */
@property (strong, nonatomic) NSString *arExhibitId;
/** 扫描到的展品类型 */
@property (assign, nonatomic) NSInteger arExhibitType;

@property (strong, nonatomic) UIView *iBeaconBgView;
@property (strong, nonatomic) UIView *iBeaconAlertView;
@property (strong, nonatomic) UIImageView *iBeaconImageView;

@property (strong, nonatomic) UIView *guideView;

@property (strong, nonatomic) AVPlayer *myPlayer;           //播放器
@property (strong, nonatomic) AVAsset *asset;
@property (strong, nonatomic) AVPlayerItem *item;           //播放单元

/** iBeacon搜索器 */
@property (nonatomic , strong) ZACIBeaconClient *iBeaconClient;
/** 蓝牙设备数组 */
@property (nonatomic , strong) NSArray<MUBlueToothModel *> *blueToothes;

@end

@implementation MUARViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self iBeaconViewInit];
    [self blueToothInit];
    
}

- (void)iBeaconViewInit {
    
    self.iBeaconBgView = [[UIView alloc]initWithFrame:SCREEN_BOUNDS];
    self.iBeaconBgView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.2];
    [self.iBeaconBgView addTapTarget:self action:@selector(hideIBeaconBgView:)];
    self.iBeaconBgView.hidden = YES;
    
    self.iBeaconAlertView = [UIView new];
    self.iBeaconAlertView.backgroundColor = [UIColor whiteColor];
    [self.iBeaconBgView addSubview:self.iBeaconAlertView];
    [self.iBeaconAlertView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(300.0f);
        make.height.mas_equalTo(200.0f);
        make.centerX.centerY.mas_equalTo(0);
    }];
    self.iBeaconAlertView.layer.masksToBounds = YES;
    self.iBeaconAlertView.layer.cornerRadius = 5.0f;
    [self.iBeaconAlertView addTapTarget:self action:@selector(nullFun:)];
    
    UILabel *tipsLb = [UILabel new];
    tipsLb.textAlignment = NSTextAlignmentCenter;
    tipsLb.textColor = kUIColorFromRGB(0x333333);
    tipsLb.text = @"附近发现支持扫一扫的展品哦";
    tipsLb.font = [UIFont systemFontOfSize:15.0f];
    [self.iBeaconAlertView addSubview:tipsLb];
    [tipsLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(5.0f);
        make.height.mas_equalTo(21.0f);
    }];
    
    self.iBeaconImageView = [UIImageView new];
    [self.iBeaconAlertView addSubview:self.iBeaconImageView];
    [self.iBeaconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.top.equalTo(tipsLb.mas_bottom).offset(5.0f);
    }];
    
}

- (void)viewInit {
    [self.glView setOrientation:self.interfaceOrientation];
    
    __weak typeof(self) weakSelf = self;
    
    self.museumLb = [UILabel new];
    self.museumLb.textColor = [UIColor whiteColor];
    self.museumLb.text = self.hall.hallName;
    self.museumLb.font = [UIFont systemFontOfSize:15.0f];
    [self.glView addSubview:self.museumLb];
    [self.museumLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.0f);
        make.top.mas_equalTo(30.0f);
        make.right.mas_equalTo(-60.0f);
        make.height.mas_equalTo(30.0f);
    }];
    
    self.shareBt = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.shareBt setImage:[UIImage imageNamed:@"分享"] forState:UIControlStateNormal];
    [self.shareBt setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [self.shareBt addTarget:self action:@selector(didShareButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.glView addSubview:self.shareBt];
    [self.shareBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0.0f);
        make.top.mas_equalTo(20.0f);
        make.width.height.mas_equalTo(50.0f);
    }];
    
    self.exitBt = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.exitBt setImage:[UIImage imageNamed:@"关闭"] forState:UIControlStateNormal];
    [self.exitBt setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [self.exitBt addTarget:self action:@selector(didExistButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.glView addSubview:self.exitBt];
    [self.exitBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.top.equalTo(weakSelf.shareBt.mas_bottom);
        make.width.height.mas_equalTo(50.0f);
    }];
    
    self.detailBt = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.detailBt setTitle:@"展品详情" forState:UIControlStateNormal];
    [self.detailBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.detailBt.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.3];
    self.detailBt.layer.masksToBounds = YES;
    self.detailBt.layer.cornerRadius = 5.0f;
    [self.detailBt addTarget:self action:@selector(didExhibitsDetailsClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.glView addSubview:self.detailBt];
    [self.detailBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-30.0f);
        make.top.equalTo(weakSelf.exitBt.mas_bottom);
        make.height.mas_equalTo(30.0f);
        make.width.mas_equalTo(80.0f);
    }];
    
    self.tipsLb = [UILabel new];
    self.tipsLb.backgroundColor = [UIColor clearColor];
    self.tipsLb.font = [UIFont systemFontOfSize:13.0f];
    self.tipsLb.textColor = [UIColor whiteColor];
    self.tipsLb.text = @"[ 请正对展品扫描 ]";
    self.tipsLb.textAlignment = NSTextAlignmentCenter;
    [self.glView addSubview:self.tipsLb];
    [self.tipsLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(21.0f);
        make.centerY.mas_equalTo(0);
    }];
    
    self.helpBt = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.helpBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.helpBt setTitle:@"帮助" forState:UIControlStateNormal];
    self.helpBt.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    [self.helpBt addTarget:self action:@selector(didHelpClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.glView addSubview:self.helpBt];
    [self.helpBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30.0f);
        make.bottom.mas_equalTo(-20.0f);
        make.width.mas_equalTo(60.0f);
        make.height.mas_equalTo(21.0f);
    }];
    self.helpImageBt = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.helpImageBt setImage:[UIImage imageNamed:@"帮助"] forState:UIControlStateNormal];
    [self.helpImageBt addTarget:self action:@selector(didHelpClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.glView addSubview:self.helpImageBt];
    [self.helpImageBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.helpBt);
        make.bottom.equalTo(weakSelf.helpBt.mas_top);
        make.width.height.mas_equalTo(30.0f);
    }];
    
    UIView *btBgView = [UIView new];
    btBgView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.3f];
    [self.glView addSubview:btBgView];
    [btBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0.0f);
        make.height.mas_equalTo(80.0f);
    }];
    _btBgView = btBgView;
    
    self.guideBt = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.guideBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.guideBt setTitle:@"导览" forState:UIControlStateNormal];
    self.guideBt.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    [self.guideBt addTarget:self action:@selector(didGuideClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.glView addSubview:self.guideBt];
    [self.guideBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.bottom.mas_equalTo(-20.0f);
        make.width.mas_equalTo(60.0f);
        make.height.mas_equalTo(21.0f);
    }];
    self.guideImageBt = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.guideImageBt setImage:[UIImage imageNamed:@"导览"] forState:UIControlStateNormal];
    [self.guideImageBt addTarget:self action:@selector(didGuideClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.glView addSubview:self.guideImageBt];
    [self.guideImageBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.guideBt);
        make.bottom.equalTo(weakSelf.guideBt.mas_top);
        make.width.height.mas_equalTo(30.0f);
    }];
    
    self.mainBt = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.mainBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.mainBt setTitle:@"首页" forState:UIControlStateNormal];
    self.mainBt.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    [self.mainBt addTarget:self action:@selector(didMainClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.glView addSubview:self.mainBt];
    [self.mainBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-30.0f);
        make.bottom.mas_equalTo(-20.0f);
        make.width.mas_equalTo(60.0f);
        make.height.mas_equalTo(21.0f);
    }];
    self.mainImageBt = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.mainImageBt setImage:[UIImage imageNamed:@"首页"] forState:UIControlStateNormal];
    [self.mainImageBt addTarget:self action:@selector(didMainClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.glView addSubview:self.mainImageBt];
    [self.mainImageBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.mainBt);
        make.bottom.equalTo(weakSelf.mainBt.mas_top);
        make.width.height.mas_equalTo(30.0f);
    }];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.minimumLineSpacing = 10.0f;
    layout.minimumInteritemSpacing = 10.0f;
    layout.itemSize = CGSizeMake(100, 100);
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.imageCollectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
    self.imageCollectionView.delegate = self;
    self.imageCollectionView.dataSource = self;
    self.imageCollectionView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.3];
    [self.imageCollectionView registerNib:[UINib nibWithNibName:@"MUExhibitCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"MUExhibitCell"];
    [self.glView addSubview:self.imageCollectionView];
    [self.imageCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf.helpImageBt.mas_top).offset(-20);
        make.height.mas_equalTo(120.0f);
        make.left.right.mas_equalTo(0);
    }];
    
    self.hotLb = [UILabel new];
    self.hotLb.textColor = [UIColor whiteColor];
    self.hotLb.font = [UIFont systemFontOfSize:13.0f];
    self.hotLb.textAlignment = NSTextAlignmentCenter;
    self.hotLb.text = @"热门展品";
    self.hotLb.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.3];
    [self.glView addSubview:self.hotLb];
    [self.hotLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.width.mas_equalTo(100.0f);
        make.bottom.equalTo(weakSelf.imageCollectionView.mas_top).offset(0.0f);
        make.height.mas_equalTo(30.0f);
    }];
    CGRect bounds = CGRectMake(0, 0, 100.0f, 30.0f);
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10.0,10.0)];
    //创建 layer
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = bounds;
    maskLayer.path = maskPath.CGPath;
    self.hotLb.layer.mask = maskLayer;
    
    self.exitBt.hidden = YES;
    self.detailBt.hidden = YES;
    
    self.helpBgView = [[UIView alloc]initWithFrame:SCREEN_BOUNDS];
    [self.view addSubview:self.helpBgView];
    self.helpBgView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.2];
    [self.helpBgView addTapTarget:self action:@selector(hideHelpBgView:)];
    self.helpView = [[ZACAnimationView alloc]initWithImageUrls:@[[NSURL URLWithString:@"https://down.airart.com.cn/arsjimage/shopGood/201809121737427816.jpg"],[NSURL URLWithString:@"https://down.airart.com.cn/arsjimage/shopGood/201809121738037960.jpg"]]];
    [self.helpBgView addSubview:self.helpView];
    [self.helpView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(100.0f);
        make.bottom.mas_equalTo(-100.0f);
        make.left.mas_equalTo(50.0f);
        make.right.mas_equalTo(-50.0f);
    }];
    [self.helpView addTapTarget:self action:@selector(nullFun:)];
    self.helpBgView.hidden = YES;
    
    [self.glView sendSubviewToBack:btBgView];

    [self.glView addSubview:self.iBeaconBgView];
    [self.glView bringSubviewToFront:self.iBeaconBgView];
    
    NSString *helpGuide = [[NSUserDefaults standardUserDefaults] objectForKey:@"help_guide"];
    if (![helpGuide boolValue]) {
        [self addHelpGuideMask];
    } else {
        NSString *guideGuide = [[NSUserDefaults standardUserDefaults] objectForKey:@"guide_guide"];
        if (![guideGuide boolValue]) {
            [self addGuideGuideMask];
        }
    }
    
}

- (void)hideHelpBgView:(id)sender {
    self.helpBgView.hidden = YES;
}
- (void)nullFun:(id)sender {}

- (void)blueToothInit {
    
    __weak typeof(self) weakSelf = self;
    [MUHttpDataAccess getBluetoothInfoWithHallId:self.hall.hallId success:^(id result) {
        
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
                [weakSelf.iBeaconClient openClient];
            }
        }
    } failed:^(NSError *error) {
        [weakSelf alertWithMsg:kFailedTips handler:nil];
    }];
}

// 读取本地JSON文件
- (id)readJSONFileWithName:(NSString *)name {
    // 获取文件路径
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"json"];
    // 将文件数据化
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    // 对数据进行JSON格式化并返回字典形式
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}

#pragma mark -
/** 蓝牙状态有改变 */
- (void)ibeacon:(ZACIBeaconClient *)ibeacon didChangeBlueToothStatus:(BOOL)isOn {
    if (!isOn) {
        [self.iBeaconClient closeClient];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请前往设置打开蓝牙" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        UIAlertAction *setting = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // @"App-Prefs:root=Bluetooth"
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication
                  sharedApplication] openURL:url];
            }
        }];
        [alert addAction:setting];
        [alert addAction:ok];
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf presentViewController:alert animated:YES completion:nil];
        });
    }else {
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.iBeaconClient openClient];
        });
    }
}
/** 发现新的蓝牙设备 */
- (void)ibeacon:(ZACIBeaconClient *)ibeacon didFoundNewBlueTooth:(MUBlueToothModel *)blueTooth {
    NSLog(@"更新设备：%@",blueTooth.blueToothName);
    if (blueTooth == nil || _isPlayAR) {
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
        __weak typeof(self) weakSelf = self;
        [self.iBeaconImageView sd_setImageWithURL:[NSURL URLWithString:blueTooth.exhibitionUrl] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            weakSelf.iBeaconBgView.hidden = NO;
            CGFloat alertHeight = image.size.height * 300.0f/image.size.width + 21.0f;
            [weakSelf.iBeaconAlertView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(alertHeight);
            }];
        }];
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"help" ofType:@"mp4"];
//        NSURL *mediaURL = [NSURL fileURLWithPath:path];
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
    }
}

- (void)hideIBeaconBgView:(id)sender {
    self.iBeaconBgView.hidden = YES;
    [self.myPlayer pause];
}

- (void)dealloc {
    [self.iBeaconClient closeClient];
//    [self.glView stop];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.exhibits.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MUExhibitModel *exhibit = self.exhibits[indexPath.item];
    MUExhibitCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MUExhibitCell" forIndexPath:indexPath];
    [cell.exhibitImageView sd_setImageWithURL:[NSURL URLWithString:exhibit.exhibitUrl]];
    cell.exhibitNameLb.text = exhibit.exhibitName;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MUGuideViewController *guideVC = [[MUGuideViewController alloc]init];
    guideVC.selectExhibit = self.exhibits[indexPath.item];
    guideVC.hall = self.hall;
    guideVC.hotExhibits = self.exhibits;
    [self.navigationController pushViewController:guideVC animated:YES];
}

#pragma mark ---- AR相关

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.tabBarController.tabBar.hidden = YES;
    self.glView = nil;
    self.glView = [[OpenGLView alloc] initWithFrame:CGRectZero];
    self.view = self.glView;
    [self viewInit];
    [self dataInit];
    [self.glView start:[self ARFilesPathWithHallId:self.hall.hallId]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didExhibitsRecognized:)
                                                 name:kARFoundTargetNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didExhibitsLeaved:)
                                                 name:kARLoseTargetNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didExhibitsVideoComplete:)
                                                 name:kARPlayCompleteNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackground:)
                                                 name:kEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterForeground:)
                                                 name:kEnterForegroundNotification
                                               object:nil];

}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.glView stop];
    self.glView = nil;
    _isPlayAR = NO;
    self.view = [UIView new];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didEnterForeground:(NSNotification *)notification {
    self.tabBarController.tabBar.hidden = YES;
    self.glView = nil;
    self.glView = [[OpenGLView alloc] initWithFrame:CGRectZero];
    self.view = self.glView;
    [self viewInit];
    [self dataInit];
    [self.glView start:[self ARFilesPathWithHallId:self.hall.hallId]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didExhibitsRecognized:)
                                                 name:kARFoundTargetNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didExhibitsLeaved:)
                                                 name:kARLoseTargetNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didExhibitsVideoComplete:)
                                                 name:kARPlayCompleteNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackground:)
                                                 name:kEnterBackgroundNotification
                                               object:nil];
}
- (void)didEnterBackground:(NSNotification *)notification {
    self.glView = nil;
    self.view = [UIView new];
    [self.glView stop];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterForeground:)
                                                 name:kEnterForegroundNotification
                                               object:nil];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    [self.glView resize:self.view.bounds orientation:self.interfaceOrientation];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.glView setOrientation:toInterfaceOrientation];
}

- (NSArray *)ARFilesPathWithHallId:(NSString *)hallId {
    NSString *path = [NSString stringWithFormat:@"%@/Library/Caches/%@/%@.json",NSHomeDirectory(), hallId,hallId];
    NSArray *ary = [NSArray arrayWithContentsOfFile:path];
    return ary;
}

#pragma mark -
- (void)dataInit {
    
    _isPlayAR = NO;
    __weak typeof(self) weakSelf = self;
    [MUHttpDataAccess getExhibitsWithHallId:self.hall.hallId page:1 isHot:YES success:^(id result) {
        
        if ([result[@"state"] integerValue] == 10001) {
            
            NSMutableArray *mutExhibits = [NSMutableArray array];
            for (NSDictionary *dic in result[@"data"][@"list"]) {
                MUExhibitModel *exhibit = [MUExhibitModel exhibitWithDic:dic];
                [mutExhibits addObject:exhibit];
            }
            weakSelf.exhibits = [NSArray arrayWithArray:mutExhibits];
            [weakSelf.imageCollectionView reloadData];
            if(weakSelf.exhibits.count == 0) {
                weakSelf.hotLb.hidden = YES;
                weakSelf.imageCollectionView.hidden = YES;
            }
        }else {
            weakSelf.hotLb.hidden = YES;
            weakSelf.imageCollectionView.hidden = YES;
        }
        
    } failed:^(NSError *error) {
        NSLog(@"网络请求失败");
    }];
}
/** 有展品被识别 */
- (void)didExhibitsRecognized:(NSNotification *)notification {
    /// FIXME: 提示音
    AudioServicesPlaySystemSound(1000);
    _isPlayAR = YES;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kARFoundTargetNotification object:nil];
    NSLog(@"MUARVC---有展品被识别:%@",notification.object);
    self.exitBt.hidden = NO;
    self.detailBt.hidden = NO;
    
    self.tipsLb.hidden = YES;
    self.hotLb.hidden = YES;
    self.imageCollectionView.hidden = YES;
    self.helpBt.hidden = YES;
    _btBgView.hidden = YES;
    self.helpImageBt.hidden = YES;
    self.mainBt.hidden = YES;
    self.mainImageBt.hidden = YES;
    self.guideBt.hidden = YES;
    self.guideImageBt.hidden = YES;
    
    NSString *targetName = (NSString *)notification.object;
    NSArray *names = [targetName componentsSeparatedByString:@"_"];
    if (names.count != 3) {
        return;
    }
    self.arExhibitId = names[1];
    self.arExhibitType = [names[2] integerValue];
    switch (self.arExhibitType) {
        case 0:
            [self toExhibitDetail:self.arExhibitId];
            break;
        default:
            break;
    }
    [MUHttpDataAccess recoganizerExhibitWithExhibitId:self.arExhibitId method:1];
}

- (void)toExhibitDetail:(NSString *)exhibitId {
    
    NSLog(@"push push push");
    MUExhibitDetailViewController *detailVC = [MUExhibitDetailViewController new];
    detailVC.exhibitId = exhibitId;
    [self.navigationController pushViewController:detailVC animated:YES];
    
}
/** 展品移开 */
- (void)didExhibitsLeaved:(id)sender {
    NSLog(@"MUARVC---展品移开");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kARLoseTargetNotification object:nil];
    if (self.arExhibitType == 1) {  // 跟随类型
        [self toExhibitDetail:self.arExhibitId];
    }
}
/** 展品视频播放完毕 */
- (void)didExhibitsVideoComplete:(id)sender {
    NSLog(@"MUARVC---展品视频播放完毕");
    _isPlayAR = NO;
    [self toExhibitDetail:self.arExhibitId];
}

- (void)didExhibitsDetailsClicked:(id)sender {
    [self toExhibitDetail:self.arExhibitId];
}

#pragma mark -
- (void)didShareButtonClicked:(id)sender {
    
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

- (void)alertWithMsg:(NSString *)msg handler:(void (^)())handler {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:msg message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (handler != nil) {
            handler();
        }
    }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)didExistButtonClicked:(id)sender {
    [self toExhibitDetail:self.arExhibitId];
}

- (void)didHelpClicked:(id)sender {
//    self.helpBgView.hidden = NO;
    MUHelpVideoViewController *vc = [MUHelpVideoViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didGuideClicked:(id)sender {
    MUGuideViewController *guideVC = [[MUGuideViewController alloc]init];
    guideVC.hall = self.hall;
    guideVC.hotExhibits = self.exhibits;
    [self.navigationController pushViewController:guideVC animated:YES];
}

- (void)didMainClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
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
    
    CGRect rect = CGRectMake(30, SCREEN_HEIGHT-71.0f, 60.0f, 51.0f);
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
    [self didHelpClicked:self];
}

- (void)addGuideGuideMask {
    
    CGRect rect = CGRectMake((SCREEN_WIDTH-60.0f)/2.0f, SCREEN_HEIGHT-71.0f, 60.0f, 51.0f);
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
    [self didGuideClicked:self];
}

@end






















