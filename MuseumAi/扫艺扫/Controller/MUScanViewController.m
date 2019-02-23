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
#import "MUARViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface MUScanViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;

@property (weak, nonatomic) IBOutlet UITextField *searchTextField;

@property (weak, nonatomic) IBOutlet UIButton *searchBt;

@property (weak, nonatomic) IBOutlet UITableView *museumTbView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

/** 选中的hall */
@property (nonatomic , strong) MUHallModel *selectHall;

// 弹窗
@property (strong, nonatomic) IBOutlet UIView *hallAlertBgView;
@property (weak, nonatomic) IBOutlet UIView *hallAlertView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hallAlertHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageHeightConstraint;

@property (weak, nonatomic) IBOutlet UIImageView *hallImageView;
@property (weak, nonatomic) IBOutlet UILabel *hallTitleLb;
@property (weak, nonatomic) IBOutlet UILabel *hallIntroduceLb;
@property (weak, nonatomic) IBOutlet UIButton *downButton;

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

@end

@implementation MUScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self viewInit];
    
    [self dataInit];
}

- (void)viewInit {
    
    self.topConstraint.constant = SafeAreaTopHeight-44.0f;
    self.bottomConstraint.constant = SafeAreaBottomHeight;
    [self.searchBt setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
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
    self.hallAlertBgView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.4];
    self.hallAlertBgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [self.view addSubview:self.hallAlertBgView];
    self.hallAlertBgView.hidden = YES;
    [self.hallAlertBgView addTapTarget:self action:@selector(hideHallAlert:)];
    
    self.hallAlertView.backgroundColor = [UIColor whiteColor];
    self.hallAlertView.layer.masksToBounds = YES;
    self.hallAlertView.layer.cornerRadius = 10.0f;
    
    self.hallImageView.layer.masksToBounds = YES;
    self.hallImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.hallTitleLb.font = [UIFont boldSystemFontOfSize:15.0f];
    self.downButton.layer.masksToBounds = YES;
    self.downButton.layer.cornerRadius = 8.0f;
    
    [self addGuideMask];
    
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
                [weakSelf.museumTbView.mj_footer endRefreshing];
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.halls.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MUHallCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MUHallCell"];
    __weak typeof(self) weakSelf = self;
    [cell bindCellWith:self.halls[indexPath.row] positionTappedBlock:^{
        [weakSelf navigateToHall:weakSelf.halls[indexPath.row]];
    }];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 93.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectHall = self.halls[indexPath.row];
    [self getHallIntroduce:self.selectHall.hallId];
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
- (void)getHallIntroduce:(NSString *)hallId {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak typeof(self) weakSelf = self;
    [MUHttpDataAccess getHallIntroduceWithHallId:hallId success:^(id result) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        
        if ([result[@"state"] integerValue] == 10001) {
            weakSelf.selectHall.introduce = result[@"data"][@"hallIntroduce"];
            [weakSelf getDownLoadInfoWithId:hallId];
        }
        
    } failed:^(NSError *error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf alertWithMsg:kFailedTips handler:nil];
    }];
}

- (void)showHallAlertViewWidth:(NSString *)name
                           url:(NSString *)url
                       content:(NSString *)content {
    
    self.isDownload = NO;
    self.hallAlertBgView.hidden = NO;
    self.downButton.hidden = NO;
    self.downloadProgress.hidden = YES;
    self.progressLb.hidden = YES;
    
    CGFloat contentHeight = [MULayoutHandler caculateHeightWithContent:content font:12.0f width:SCREEN_WIDTH-110.0f];
    self.hallAlertHeightConstraint.constant = 151.0f+contentHeight;
    
    __weak typeof(self) weakSelf = self;
    [self.hallImageView sd_setImageWithURL:[NSURL URLWithString:url] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        weakSelf.imageHeightConstraint.constant = image.size.height * (SCREEN_WIDTH-100.0f)/image.size.width;
        weakSelf.hallAlertHeightConstraint.constant = weakSelf.hallAlertHeightConstraint.constant + (weakSelf.imageHeightConstraint.constant - 80.0f);
    }];
    self.hallTitleLb.text = name;
    self.hallIntroduceLb.text = content;
    
    // 直接开始
    self.isDownload = YES;
    self.downButton.hidden = YES;
    self.downloadProgress.hidden = NO;
    self.progressLb.hidden = NO;
    self.progressLb.text = [NSString stringWithFormat:@"等待开始"];
    [self.downloadProgress setProgress:0.0f];
    [self downLoadFiles];
}

- (void)hideHallAlert:(id)sender {
    if(self.isDownload) {
        return;
    }
    self.hallAlertBgView.hidden = YES;
}

- (IBAction)didDownLoadButtonClicked:(id)sender {
    self.isDownload = YES;
    self.downButton.hidden = YES;
    self.downloadProgress.hidden = NO;
    self.progressLb.hidden = NO;
    self.progressLb.text = [NSString stringWithFormat:@"等待开始"];
    [self.downloadProgress setProgress:0.0f];
    [self downLoadFiles];
}

// 获取下载信息
- (void)getDownLoadInfoWithId:(NSString *)hallId {
    
    [MUHttpDataAccess statisticFootprint:MUFOOTPRINTTYPEHALL statisticID:hallId];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak typeof(self) weakSelf = self;
    
    [[MUMapHandler getInstance]fetchPositionAsyn:^(CLLocation *location, BMKLocationReGeocode *regeo) {
        
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [MUHttpDataAccess getArDownLoadInfoWithHallId:hallId lng:location.coordinate.longitude lat:location.coordinate.latitude success:^(id result) {
            
            if ([result[@"state"]integerValue] == 10001) {
                
                NSNumber *updateDate = result[@"data"][@"updateDate"];
                NSLog(@"updateDate:%@",updateDate);
                weakSelf.selectHall.fileUpdate = updateDate;
                NSString *lastDate = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_fileDate",weakSelf.selectHall.hallId]];
                NSString *dirPath = [weakSelf ARFilesPathWithHallId:weakSelf.selectHall.hallId];
                if ([updateDate integerValue] == [lastDate integerValue] &&
                    [[NSFileManager defaultManager]fileExistsAtPath:dirPath]) {
                    [weakSelf toARController];  // 版本号相同，跳入AR界面
                }else {
                    weakSelf.fileSize = [result[@"data"][@"sizeCount"] doubleValue];
                    NSMutableArray *mutArrays = [NSMutableArray array];
                    for (NSDictionary *dic in result[@"data"][@"filelist"]) {
                        [mutArrays addObject:[MUARModel exhibitsARModel:dic]];
                    }
                    weakSelf.ars = [NSArray arrayWithArray:mutArrays];
                    [weakSelf showHallAlertViewWidth:weakSelf.selectHall.hallName url:weakSelf.selectHall.hallPicUrl content:weakSelf.selectHall.introduce];
                }
            }
        } failed:^(NSError *error) {
            [weakSelf alertWithMsg:kFailedTips handler:nil];
        }];
    }];
}

- (void)downLoadFiles {
    __weak typeof(self) weakSelf = self;
    
    NSString *dirPath = [weakSelf ARFilesPathWithHallId:weakSelf.selectHall.hallId];
    [[NSFileManager defaultManager] removeItemAtPath:dirPath error:nil];
    
    dispatch_queue_t t = dispatch_queue_create("download", NULL);
    dispatch_async(t, ^{
        NSUInteger length = 0;
        NSMutableArray *mutExhibits = [NSMutableArray array];
        for (int i=0;i<weakSelf.ars.count;i++) {
            MUARModel *ar = weakSelf.ars[i];
            CGFloat percent = 0.0f;
            for (NSString *imageUrl in ar.imageUrls) {
                NSString *imageName = [NSString stringWithFormat:@"%@_%d.jpg",ar.exhibitsId,(int)[ar.imageUrls indexOfObject:imageUrl]];
                length += [weakSelf downLoadFile:imageUrl storageName:imageName];
                NSDictionary *dic = @{
                                      @"name" : [NSString stringWithFormat:@"%@_%@_%d",weakSelf.selectHall.hallId , ar.exhibitsId, (int)ar.type],
                                      @"image" : [NSString stringWithFormat:@"%@/%@",weakSelf.selectHall.hallId , imageName],
                                      };
                [mutExhibits addObject:dic];
                
                percent = (CGFloat)length/1000.0f/weakSelf.fileSize;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf reloadUISideWithPercent:percent];
                });
            }
            if (ar.type == ExhibitsARTypeNone) {
                continue;
            }
            NSString *videoName = [NSString stringWithFormat:@"%@.mp4",ar.exhibitsId];
            length += [weakSelf downLoadFile:ar.videoUrl storageName:videoName];
            percent = (CGFloat)length/1000.0f/weakSelf.fileSize;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf reloadUISideWithPercent:percent];
            });
        }
        if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSString *jsonPath = [NSString stringWithFormat:@"%@%@.json",dirPath,self.selectHall.hallId];
        NSArray *images = [NSArray arrayWithArray:mutExhibits];
        [images writeToFile:jsonPath atomically:YES];
        NSLog(@"length:%ld,size:%.2f",length,weakSelf.fileSize);
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.isDownload = NO;
            weakSelf.hallAlertBgView.hidden = YES;
            [weakSelf toARController];
            NSString *updateKey = [NSString stringWithFormat:@"%@_fileDate",weakSelf.selectHall.hallId];
            [[NSUserDefaults standardUserDefaults]setObject:weakSelf.selectHall.fileUpdate forKey:updateKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        });
    });
}

- (void)reloadUISideWithPercent:(CGFloat)percent {
    if (percent >= 1) {
        percent = 1;
    }
    self.progressLb.text = [NSString stringWithFormat:@"%.1f%%",percent*100];
    [self.downloadProgress setProgress:percent];
}

- (NSString *)ARFilesPathWithHallId:(NSString *)hallId {
    return [NSString stringWithFormat:@"%@/Library/Caches/%@/",NSHomeDirectory(),hallId];
}

/** 下载单个文件 */
- (NSUInteger)downLoadFile:(NSString *)url
         storageName:(NSString *)name {
    __weak typeof(self) weakSelf = self;
    NSString *filePath = [NSString stringWithFormat:@"%@%@",[self ARFilesPathWithHallId:self.selectHall.hallId],name];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    [weakSelf writeToFile:data path:filePath name:name];
    NSLog(@"data:%ld",data.length);
    return data.length;
}

- (void)writeToFile:(NSData *)data path:(NSString *)path name:(NSString *)name {
    NSString *dirPath = [self ARFilesPathWithHallId:self.selectHall.hallId];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSError *error;
    BOOL writeFg = [data writeToFile:path options:NSDataWritingAtomic error:&error];
    if (writeFg) {
//        NSLog(@"存储成功");
    }else {
        NSLog(@"存储失败:%@",error);
    }
}

/** 到AR页 */
- (void)toARController {
    MUARViewController *arVC = [MUARViewController new];
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
    
    CGRect rect = CGRectMake(10, SafeAreaTopHeight-4.0f, SCREEN_WIDTH-20.0f, 93.0f);
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
        [self getHallIntroduce:self.selectHall.hallId];
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"scan_guide"];
    }
    [self.museumTbView.mj_header beginRefreshing];
}

#pragma mark -

- (IBAction)didSearchButtonClicked:(id)sender {
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
