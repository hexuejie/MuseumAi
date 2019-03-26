//
//  MUScanViewController.m
//  MuseumAi
//
//  Created by Kingo on 2018/9/18.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUScanViewController.h"
#import "MJRefresh.h"
#import "MUHallCell.h"
#import "UIImageView+WebCache.h"
#import "MUARModel.h"
#import "MUVuforiaViewController.h"
#import "MUARUtils.h"
#import "MUAlertView.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

NSString * const kDownloadTips = @"下载离线包体验更佳哦！\n是否现在下载离线包？";
typedef NS_ENUM(NSInteger, MUDownLoadType) {
    MUDownLoadTypeXML = 0x01,       // 只下载XML
    MUDownLoadTypeVideo = 0x02,     // 只下载Video
};


@interface MUScanViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topHeightConstraint;

@property (weak, nonatomic) IBOutlet UIView *searchBgView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;

@property (weak, nonatomic) IBOutlet UITableView *museumTbView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

/** 选中的hall */
@property (nonatomic , strong) MUHallModel *selectHall;

// 弹窗
@property (strong, nonatomic) MUAlertView *hallAlertBgView;
@property (weak, nonatomic) IBOutlet UIView *hallAlertView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hallAlertHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageHeightConstraint;

@property (weak, nonatomic) IBOutlet UIImageView *hallImageView;
@property (weak, nonatomic) IBOutlet UILabel *hallTitleLb;
@property (weak, nonatomic) IBOutlet UILabel *hallIntroduceLb;

@property (weak, nonatomic) IBOutlet UILabel *progressLb;
@property (weak, nonatomic) IBOutlet UIProgressView *downloadProgress;

@property (nonatomic , strong) UIView *guideView;

@property (nonatomic , assign) BOOL isDownload;

/** 页数 */
@property (nonatomic , assign) NSInteger page;
/** 展馆列表 */
@property (nonatomic , strong) NSArray<MUHallModel *> *halls;
/** 搜索框 */
@property (nonatomic , copy) NSString *searchStr;

/** 文件大小 */
@property (nonatomic , assign) CGFloat fileSize;
/** ARModels */
@property (strong, nonatomic) NSArray<MUARModel *> *ars;
/* xml下载地址 */
@property(nonatomic, copy) NSString *xmlUrl;
/* dat下载地越 */
@property(nonatomic, copy) NSString *datUrl;

@end

@implementation MUScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self viewInit];
    
    [self dataInit];
}

- (void)viewInit {
    
    self.bottomConstraint.constant = SafeAreaBottomHeight + 49.0f;
    self.topHeightConstraint.constant = SafeAreaTopHeight - 44.0f + 50.0f;
    
    self.searchBgView.layer.masksToBounds = YES;
    self.searchBgView.layer.cornerRadius = 20.0f;
    
    self.museumTbView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.museumTbView.tableFooterView = [UIView new];
    [self.museumTbView registerNib:[UINib nibWithNibName:@"MUHallCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MUHallCell"];
    __weak typeof (self) weakSelf = self;
    self.museumTbView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        weakSelf.page = 1;
        [weakSelf.museumTbView.mj_footer resetNoMoreData];
        [weakSelf loadMuseumData];
    }];
    self.museumTbView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        weakSelf.page++;
        [weakSelf loadMuseumData];
    }];
    
    self.searchTextField.delegate = self;
    
    // 弹窗初始化
    self.hallAlertBgView = [MUAlertView alertViewWithSize:CGSizeMake(SCREEN_WIDTH - 100.0f, 400.0f)];
    [[UIApplication sharedApplication].delegate.window addSubview:self.hallAlertBgView];
    self.hallAlertBgView.hidden = YES;
    
    [self.hallAlertBgView.contentView addSubview:self.hallAlertView];
    self.hallAlertView.backgroundColor = [UIColor clearColor];
    [self.hallAlertView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(0.0f);
        make.left.mas_equalTo(20.0f);
        make.right.mas_equalTo(-20.0f);
    }];
    
    self.hallImageView.layer.masksToBounds = YES;
    self.hallImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.hallTitleLb.font = [UIFont boldSystemFontOfSize:15.0f];
    
    [self addGuideMask];
    
}

- (void)dealloc {
    [self.hallAlertView removeFromSuperview];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
}

- (void)dataInit {
    self.searchStr = @"";
    self.searchTextField.text = @"";
    [self.museumTbView.mj_header beginRefreshing];
}

- (void)loadMuseumData {
    
    __weak typeof(self) weakSelf = self;
    
    [[MUMapHandler getInstance]fetchPositionAsyn:^(CLLocation *location, BMKLocationReGeocode *regeo) {
        
        [MUHttpDataAccess getMuseumsWithPage:weakSelf.page lng:location.coordinate.longitude lat:location.coordinate.latitude code:@"" hallName:weakSelf.searchStr success:^(id result) {
            
            if([weakSelf.museumTbView.mj_header isRefreshing]) {
                weakSelf.halls = @[];
            }
            if ([result[@"state"]integerValue] == 10001) {
                NSArray *list = result[@"data"][@"list"];
                NSMutableArray *mutHalls = [NSMutableArray arrayWithArray:weakSelf.halls];
                for (NSDictionary *dic in list) {
                    MUHallModel *model = [MUHallModel hallWithDic:dic];
                    [mutHalls addObject:model];
                }
                weakSelf.halls = [NSArray arrayWithArray:mutHalls];
                [weakSelf.museumTbView.mj_header endRefreshing];
                if(list.count < 10) {
                    [weakSelf.museumTbView.mj_footer endRefreshingWithNoMoreData];
                } else {
                    [weakSelf.museumTbView.mj_footer endRefreshing];
                }
            } else {
                [weakSelf.museumTbView.mj_header endRefreshing];
                if ([result[@"state"]integerValue] == 20001) {
                    [weakSelf.museumTbView.mj_footer endRefreshingWithNoMoreData];
                } else {
                    [weakSelf.museumTbView.mj_footer endRefreshing];
                }
            }
            NSString *scanGuide = [[NSUserDefaults standardUserDefaults] objectForKey:@"scan_guide"];
            if (![scanGuide boolValue]) {
                NSPredicate *pre = [NSPredicate predicateWithFormat:@"hallId = 'dc2453af33f3443fae577b9ad1fb7ac9'"];
                weakSelf.halls = [weakSelf.halls filteredArrayUsingPredicate:pre];
                weakSelf.guideView.hidden = NO;
            }
            [weakSelf.museumTbView reloadData];
        } failed:^(NSError *error) {
            [weakSelf.museumTbView.mj_header endRefreshing];
            [weakSelf alertWithMsg:kFailedTips handler:nil];
        }];
        
    }];
}

#pragma mark -
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.halls.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MUHallCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MUHallCell"];
    __weak typeof(self) weakSelf = self;
    MUHallModel *hall = self.halls[indexPath.row];
    [cell bindCellWith:hall positionHandler:^{
        [weakSelf navigateToHall:hall];
    } downloadHandler:^{
        weakSelf.selectHall = hall;
        [weakSelf getDownLoadInfoWithId:hall.hallId downloadDirect:YES];
    }];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
    self.selectHall = self.halls[indexPath.row];
    [self getDownLoadInfoWithId:self.selectHall.hallId downloadDirect:NO];
}

#pragma mark ---- 导航
- (void)navigateToHall:(MUHallModel *)hall {
    
    UIAlertController *mapAlert = [UIAlertController alertControllerWithTitle:@"选择地图" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    UIAlertAction *aMapAction = [UIAlertAction actionWithTitle:@"高德地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf toAMap:hall.location];
    }];
    UIAlertAction *baiduMapAction = [UIAlertAction actionWithTitle:@"百度地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf toBaiduMap:hall.location];
    }];
    UIAlertAction *appleAction = [UIAlertAction actionWithTitle:@"自带地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf toAppleMap:hall.location];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [mapAlert addAction:aMapAction];
    [mapAlert addAction:baiduMapAction];
    [mapAlert addAction:appleAction];
    [mapAlert addAction:cancelAction];
    
    [self presentViewController:mapAlert animated:YES completion:nil];
}
- (void)toAMap:(CLLocationCoordinate2D)location {
    // 判断是否安装了高德地图
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
        NSString *urlsting =[[NSString stringWithFormat:@"iosamap://navi?sourceApplication= &backScheme= &lat=%f&lon=%f&dev=0&style=2",location.latitude,location.longitude]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication  sharedApplication]openURL:[NSURL URLWithString:urlsting]];
    }else {
        NSString *urlStr = @"itms-apps://itunes.apple.com/cn/app/gao-tu-zhuan-ye-shou-ji-tu/id461703208?mt=8";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
    }
    
}
- (void)toBaiduMap:(CLLocationCoordinate2D)location {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]) {
        NSString *urlsting =[[NSString stringWithFormat:@"baidumap://map/direction?origin={{我的位置}}&destination=latlng:%f,%f|name=目的地&mode=driving&coord_type=gcj02",location.latitude,location.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlsting]];
    }else {
        NSString *urlStr = @"itms-apps://itunes.apple.com/cn/app/bai-du-tu-shou-ji-tu-lu-xian/id452186370?mt=8";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
    }
}
- (void)toAppleMap:(CLLocationCoordinate2D)location {
    //当前的位置
    MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
    //目的地的位置
    MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:location addressDictionary:nil]];
    toLocation.name = @"目的地";
    NSArray *items = [NSArray arrayWithObjects:currentLocation, toLocation, nil];
    NSDictionary *options = @{ MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving, MKLaunchOptionsMapTypeKey: [NSNumber numberWithInteger:MKMapTypeStandard], MKLaunchOptionsShowsTrafficKey:@YES };
    //打开苹果自身地图应用，并呈现特定的item
    [MKMapItem openMapsWithItems:items launchOptions:options];
}

#pragma mark ---- 文件的下载和保存
/** 获取下载信息
 * downloadDirect 无需询问，直接下载
 */
- (void)getDownLoadInfoWithId:(NSString *)hallId downloadDirect:(BOOL)downloadDirect {
    
    [MUHttpDataAccess statisticFootprint:MUFOOTPRINTTYPEHALL statisticID:hallId];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak typeof(self) weakSelf = self;
    
    [[MUMapHandler getInstance]fetchPositionAsyn:^(CLLocation *location, BMKLocationReGeocode *regeo) {
        
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [MUHttpDataAccess getVuforiaDownloadInfoWithHallId:hallId lng:location.coordinate.longitude lat:location.coordinate.latitude success:^(id result) {
            
            if ([result[@"state"]integerValue] == 10001) {
                // 扫描的对象模型
                NSMutableArray *mutArrays = [NSMutableArray array];
                for (NSDictionary *dic in result[@"data"][@"filelist"]) {
                    MUARModel *ar = [MUARModel exhibitsARModel:dic];
                    [mutArrays addObject:ar];
                }
                weakSelf.ars = [NSArray arrayWithArray:mutArrays];
                // xml文件和data文件地址
                weakSelf.xmlUrl = result[@"data"][@"exhibitionHall"][@"gtarXmlFile"];
                weakSelf.datUrl = result[@"data"][@"exhibitionHall"][@"gtarDatFile"];
                // 展馆的相关
                weakSelf.selectHall =[MUHallModel hallWithDic:result[@"data"][@"exhibitionHall"]];
                // 更新日期判断
                NSNumber *updateDate = result[@"data"][@"exhibitionHall"][@"gtarUpdateDate"];
                NSLog(@"updateDate:%@",updateDate);
                weakSelf.selectHall.fileUpdate = updateDate;
                NSString *lastDate = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_fileDate",weakSelf.selectHall.hallId]];
                NSString *xmlPath = [MUARUtils vuforiaPathWithHallId:weakSelf.selectHall.hallId];
                NSString *videoPath = [MUARUtils videosPathWithHallId:weakSelf.selectHall.hallId];
                if ([updateDate integerValue] == [lastDate integerValue] &&
                    [[NSFileManager defaultManager]fileExistsAtPath:xmlPath]) {
                    // 获取未下载的AR文件
                    NSArray *unloadARs = [weakSelf getUnLoadARModes];
                    if (unloadARs.count == 0) {
                        // 不用下载直接进入
                        [weakSelf toARController];
                    } else {
                        if (downloadDirect) {
                            [weakSelf showSelectHallAlertView:MUDownLoadTypeVideo];
                        } else {
                            // 询问是否下载video文件
                            [weakSelf alertWithMsg:kDownloadTips leftTitle:@"暂不下载" leftHandler:^{
                                [weakSelf toARController];
                            } rightTitle:@"确定" rightHandler:^{
                                [weakSelf showSelectHallAlertView:MUDownLoadTypeVideo];
                            }];
                        }
                    }
                } else {
                    // 清除之前的数据
                    NSArray *xmlFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:xmlPath error:nil];
                    NSArray *videoFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:videoPath error:nil];
                    for (NSString *fileName in xmlFiles) {
                        NSString *filePath = [NSString stringWithFormat:@"%@%@",xmlPath,fileName];
                        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
                    }
                    for (NSString *fileName in videoFiles) {
                        NSString *filePath = [NSString stringWithFormat:@"%@%@",videoPath,fileName];
                        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
                    }
                    if (downloadDirect) {
                        [weakSelf showSelectHallAlertView:(MUDownLoadTypeXML|MUDownLoadTypeVideo)];
                    } else {
                        // 需要下载xml文件和video文件,询问是否下载video文件
                        [weakSelf alertWithMsg:kDownloadTips leftTitle:@"暂不下载" leftHandler:^{
                            // 只下载XML
                            [weakSelf showSelectHallAlertView:MUDownLoadTypeXML];
                        } rightTitle:@"确定" rightHandler:^{
                            // XML和Video都要下载
                            [weakSelf showSelectHallAlertView:(MUDownLoadTypeXML|MUDownLoadTypeVideo)];
                        }];
                    }
                }
            }
        } failed:^(NSError *error) {
            [weakSelf alertWithMsg:kFailedTips handler:nil];
        }];
    }];
    
}

/** 获取选中展馆还未下载的AR */
- (NSArray<MUARModel *> *)getUnLoadARModes {
    NSMutableArray *mutArs = [NSMutableArray arrayWithArray:self.ars];
    for (MUARModel *ar in self.ars) {
        // 属于无视频的AR
        if (ar.videoUrl == nil || ar.videoUrl.length == 0) {
            [mutArs removeObject:ar];
        }
    }
    NSString *videoPath = [MUARUtils videosPathWithHallId:self.selectHall.hallId];
    NSDirectoryEnumerator *fileEnum = [[NSFileManager defaultManager] enumeratorAtPath:videoPath];
    NSString *fileName = nil;
    while (fileName = [fileEnum nextObject]) {
        for (MUARModel *ar in self.ars) {
            // 已下载了该视频
            NSString *mp4FileName = [NSString stringWithFormat:@"%@.mp4",ar.exhibitsId];
            if ([mp4FileName isEqualToString:fileName]) {
                [mutArs removeObject:ar];
                break;
            }
        }
    }
    return [NSArray arrayWithArray:mutArs];
}

/** 显示选中的展馆信息，下载进度显示 */
- (void)showSelectHallAlertView:(MUDownLoadType)type {
    
    NSString *name = self.selectHall.hallName;
    NSString *url = self.selectHall.hallPicUrl;
    NSString *content = self.selectHall.introduce;
    
    self.hallAlertBgView.hidden = NO;
    
    CGFloat contentHeight = [MULayoutHandler caculateHeightWithContent:content font:12.0f width:SCREEN_WIDTH-150.0f];
    self.hallAlertHeightConstraint.constant = 151.0f+contentHeight;
    self.hallAlertBgView.contentSize = CGSizeMake(SCREEN_WIDTH-100.0f, self.hallAlertHeightConstraint.constant);
    
    __weak typeof(self) weakSelf = self;
    [self.hallImageView sd_setImageWithURL:[NSURL URLWithString:url] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        // 图片下载完成后，计算image的尺寸
        weakSelf.imageHeightConstraint.constant = image.size.height * (SCREEN_WIDTH-100.0f)/image.size.width;
        weakSelf.hallAlertHeightConstraint.constant = weakSelf.hallAlertHeightConstraint.constant + (weakSelf.imageHeightConstraint.constant - 80.0f);
        weakSelf.hallAlertBgView.contentSize = CGSizeMake(SCREEN_WIDTH-100.0f, weakSelf.hallAlertHeightConstraint.constant);
    }];
    self.hallTitleLb.text = name;
    self.hallIntroduceLb.text = content;
    
    // 开始下载
    self.isDownload = YES;
    self.progressLb.text = [NSString stringWithFormat:@"等待开始"];
    [self.downloadProgress setProgress:0.0f];
    [self downLoadFilesForHall:self.selectHall.hallId downloadType:type completeHandler:^(BOOL success, NSError *error) {
        weakSelf.isDownload = NO;
        [weakSelf hideHallAlert:nil];
        if (success) {
            NSString *updateKey = [NSString stringWithFormat:@"%@_fileDate",weakSelf.selectHall.hallId];
            [[NSUserDefaults standardUserDefaults]setObject:weakSelf.selectHall.fileUpdate forKey:updateKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [weakSelf toARController];
        } else {
            [weakSelf alertWithMsg:error.localizedDescription handler:nil];
        }
    }];
}
/** 隐藏展馆信息 */
- (void)hideHallAlert:(id)sender {
    if(self.isDownload) {
        return;
    }
    self.hallAlertBgView.hidden = YES;
}

/** 下载并保存文件 */
- (void)downLoadFilesForHall:(NSString *)hallID
                downloadType:(MUDownLoadType)type
             completeHandler:(void(^)(BOOL success, NSError *error))handler {
    
    __block NSInteger totalFileCount = 0;   // 总文件个数
    __block NSInteger downLoadCount = 0;    // 已下载文件个数
    
    __weak typeof(self) weakSelf = self;
    // 判断是否要下载媒体文件
    if (type & MUDownLoadTypeVideo) {
        // 下载视频文件
        NSArray *unloadArs = [self getUnLoadARModes];
        totalFileCount += unloadArs.count;
        for (MUARModel *ar in unloadArs) {
            NSString *fileName = [NSString stringWithFormat:@"%@.mp4",ar.exhibitsId];
            [MUARUtils downLoadFile:ar.videoUrl name:fileName completeHandler:^(NSData *fileData, NSString *fileName, NSError *error) {
                NSLog(@"下载完成:%@, %ld",ar.exhibitsId,totalFileCount);
                if (fileData.length > 0 &&
                    downLoadCount < totalFileCount) {
                    [MUARUtils writeToFile:fileData fileName:fileName type:MUWriteFileTypeVideo hallID:weakSelf.selectHall.hallId];
                    [weakSelf reloadUISideWithPercent:(downLoadCount*1.0/totalFileCount)];
                    downLoadCount ++;
                    if (downLoadCount == totalFileCount &&
                        handler) {
                        handler(YES, nil);
                    }
                } else if(error) {
                    downLoadCount = NSNotFound;
                    if (handler) {
                        handler(NO, error);
                    }
                }
            }];
        }
        
    }
    // 判断是否要下载XML文件
    if (type & MUDownLoadTypeXML) {
        totalFileCount += 2;
        // 下载xml文件
        [MUARUtils downLoadFile:self.xmlUrl name:@"hall.xml" completeHandler:^(NSData *fileData, NSString *fileName, NSError *error) {
            NSLog(@"下载完成:xml, %ld", totalFileCount);
            if (fileData.length > 0 &&
                downLoadCount < totalFileCount) {
                [MUARUtils writeToFile:fileData fileName:fileName type:MUWriteFileTypeXML hallID:weakSelf.selectHall.hallId];
                [weakSelf reloadUISideWithPercent:(downLoadCount*1.0/totalFileCount)];
                downLoadCount ++;
                if (downLoadCount == totalFileCount &&
                    handler) {
                    handler(YES, nil);
                }
            } else if(error) {
                downLoadCount = NSNotFound;
                if (handler) {
                    handler(NO, error);
                }
            }
        }];
        [MUARUtils downLoadFile:self.datUrl name:@"hall.dat" completeHandler:^(NSData *fileData, NSString *fileName, NSError *error) {
            NSLog(@"下载完成:dat, %ld", totalFileCount);
            if (fileData.length > 0 &&
                downLoadCount < totalFileCount) {
                [MUARUtils writeToFile:fileData fileName:fileName type:MUWriteFileTypeXML hallID:weakSelf.selectHall.hallId];
                [weakSelf reloadUISideWithPercent:(downLoadCount*1.0/totalFileCount)];
                downLoadCount ++;
                if (downLoadCount == totalFileCount &&
                    handler) {
                    handler(YES, nil);
                }
            } else if(error) {
                downLoadCount = NSNotFound;
                if (handler) {
                    handler(NO, error);
                }
            }
        }];
    }
    
}

/** 进度条显示 */
- (void)reloadUISideWithPercent:(CGFloat)percent {
    if (percent >= 1) {
        percent = 1;
    }
    self.progressLb.text = [NSString stringWithFormat:@"%.1f%%",percent*100];
    [self.downloadProgress setProgress:percent];
}

/** 到AR页 */
- (void)toARController {
    MUVuforiaViewController *arVC = [MUVuforiaViewController new];
    arVC.hall = self.selectHall;
    arVC.ars = self.ars;
    [self.navigationController pushViewController:arVC animated:YES];
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

- (void)addGuideMask {
    
    CGFloat cellHeight = 110.0f;
    CGFloat imageHeight = (SCREEN_WIDTH - 30.0f) * 9/16.0f;
    cellHeight += imageHeight;
    
    CGRect rect = CGRectMake(10, self.topHeightConstraint.constant, SCREEN_WIDTH-20.0f, cellHeight);
    UIBezierPath *tempPath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:(UIRectCornerTopLeft |UIRectCornerTopRight |UIRectCornerBottomRight|UIRectCornerBottomLeft) cornerRadii:CGSizeMake(4, 4)];
    UIView *guideView = [[UIView alloc] initWithFrame:SCREEN_BOUNDS];
    guideView.backgroundColor = [UIColor blackColor];
    guideView.alpha = 0.8;
    guideView.layer.mask = [self addTransparencyViewWith:tempPath];
    [[UIApplication sharedApplication].keyWindow addSubview:guideView];
    guideView.hidden = YES;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = rect;
    button.backgroundColor = [UIColor clearColor];
    [button addTapTarget:self action:@selector(didTestMuseumClicked:)];
    [guideView addSubview:button];;
    
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"引导上箭头"]];
    [guideView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(button.mas_bottom).offset(5.0f);
        make.centerX.mas_equalTo(0);
        make.width.height.mas_equalTo(30.0f);
    }];
    
    UILabel *tipsLb = [[UILabel alloc]init];
    tipsLb.textAlignment = NSTextAlignmentCenter;
    tipsLb.textColor = [UIColor whiteColor];
    tipsLb.font = [UIFont systemFontOfSize:14.0f];
    tipsLb.text = @"开始体验AR博物馆";
    [guideView addSubview:tipsLb];
    [tipsLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(30.0f);
        make.top.equalTo(imageView.mas_bottom).offset(5.0f);
    }];
    
    self.guideView = guideView;
}

- (void)didTestMuseumClicked:(id)sender {
    self.selectHall = [self.halls firstObject];
    if (self.selectHall != nil) {
        self.guideView.hidden = YES;
        [self getDownLoadInfoWithId:self.selectHall.hallId downloadDirect:NO];
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"scan_guide"];
    }
    [self.museumTbView.mj_header beginRefreshing];
}

#pragma mark -

- (void)didSearchButtonClicked:(id)sender {
    [self.searchTextField resignFirstResponder];
    self.searchStr = self.searchTextField.text;
    if (self.searchStr.length == 0) {
        self.searchStr = @"";
    }
    [self.museumTbView.mj_header beginRefreshing];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self didSearchButtonClicked:textField];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
