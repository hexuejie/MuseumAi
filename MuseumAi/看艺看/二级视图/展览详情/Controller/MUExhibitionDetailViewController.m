//
//  MUExhibitionDetailViewController.m
//  MuseumAi
//
//  Created by 魏宙辉 on 2018/9/21.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUExhibitionDetailViewController.h"
#import "MUHotGuideViewController.h"
#import "MUExhibitionCellDelegate.h"
#import "MUExhibitionTitleCell.h"
#import "MUExhibitionDescripeCell.h"
#import "MUProductorCell.h"
#import "MUMapCell.h"
#import "MUHomeCommentTitleCell.h"
#import "MUCommentCell.h"
#import "MJRefresh.h"

#import "SDPhotoBrowser.h"
#import "MUExhibitionDetailModel.h"

#import "MUCommentViewController.h"

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface MUExhibitionDetailViewController ()<UITableViewDelegate,UITableViewDataSource, MUExhibitionCellDelegate, SDPhotoBrowserDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabTopConstraint;

@property (weak, nonatomic) IBOutlet UIButton *returnBt;

@property (weak, nonatomic) IBOutlet UIButton *collectBt;

@property (weak, nonatomic) IBOutlet UIButton *shareBt;

@property (weak, nonatomic) IBOutlet UIButton *commentBt;

@property (weak, nonatomic) IBOutlet UITableView *exhibitionTableView;

@property (weak, nonatomic) IBOutlet UIButton *buyTicketsButton;


/** 展览对象 */
@property (nonatomic , strong) MUExhibitionDetailModel *exhibition;
/** 展品列表 */
@property (nonatomic , strong) NSArray<MUExhibitModel *> *exhibits;
/** 展品页数 */
@property (nonatomic , assign) NSInteger exhibitPage;
/** 是否已加载完 */
@property (nonatomic , assign) BOOL isExhibitMax;
/** 评论页数 */
@property (assign, nonatomic) NSInteger commentPage;
/** 评论数组 */
@property (strong, nonatomic) NSArray<MUCommentModel *> *comments;

/** 评分弹窗 */
@property (strong, nonatomic) IBOutlet UIView *scoreAlertBgView;
@property (weak, nonatomic) IBOutlet UIView *scoreAlert;
@property (weak, nonatomic) IBOutlet UIButton *start1Bt;
@property (weak, nonatomic) IBOutlet UIButton *start2Bt;
@property (weak, nonatomic) IBOutlet UIButton *start3Bt;
@property (weak, nonatomic) IBOutlet UIButton *start4Bt;
@property (weak, nonatomic) IBOutlet UIButton *start5Bt;
/** 分数 */
@property (assign, nonatomic) NSInteger score;

/** 图片弹出 */
@property (strong, nonatomic) IBOutlet UIView *imageAlertView;
@property (weak, nonatomic) IBOutlet UIImageView *alertImageView;

/** 图片预览 */
@property (nonatomic , strong) SDPhotoBrowser *browser;

@end

@implementation MUExhibitionDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self viewInit];

    [self dataInit];
}

- (void)viewInit {
    
    self.topConstraint.constant = SafeAreaTopHeight-44.0f;
    self.tabTopConstraint.constant = -SafeAreaTopHeight+44;
    
    [self.returnBt setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [self.exhibitionTableView registerNib:[UINib nibWithNibName:@"MUExhibitionTitleCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MUExhibitionTitleCell"];
    [self.exhibitionTableView registerNib:[UINib nibWithNibName:@"MUExhibitionDescripeCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MUExhibitionDescripeCell"];
    [self.exhibitionTableView registerNib:[UINib nibWithNibName:@"MUProductorCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MUProductorCell"];
    [self.exhibitionTableView registerNib:[UINib nibWithNibName:@"MUMapCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MUMapCell"];
    [self.exhibitionTableView registerNib:[UINib nibWithNibName:@"MUHomeCommentTitleCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MUHomeCommentTitleCell"];
    [self.exhibitionTableView registerNib:[UINib nibWithNibName:@"MUCommentCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MUCommentCell"];
    self.exhibitionTableView.estimatedRowHeight = 0;
    self.exhibitionTableView.tableFooterView = [UIView new];
    self.exhibitionTableView.allowsSelection = NO;
    
    __weak typeof (self) weakSelf = self;
    self.exhibitionTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        weakSelf.commentPage = 1;
        [weakSelf.exhibitionTableView.mj_footer resetNoMoreData];
        [weakSelf loadComments];
    }];
    self.exhibitionTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        weakSelf.commentPage++;
        [weakSelf loadComments];
    }];
    
    self.imageAlertView.frame = SCREEN_BOUNDS;
    self.imageAlertView.backgroundColor = [UIColor blackColor];
    self.alertImageView.backgroundColor = [UIColor blackColor];
    self.alertImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.alertImageView addTapTarget:self action:@selector(imageAlertHidden:)];
    [self.view addSubview:self.imageAlertView];
    self.imageAlertView.hidden = YES;
    
    self.scoreAlertBgView.frame = SCREEN_BOUNDS;
    self.scoreAlertBgView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
    [self.view addSubview:self.scoreAlertBgView];
//    [self.scoreAlertBgView addTapTarget:self action:@selector(scoreAlertHidden:)];
    [self.scoreAlert addTapTarget:self action:@selector(none_fun)];
    self.scoreAlertBgView.hidden = YES;

    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.scoreAlert.bounds byRoundingCorners:UIRectCornerTopRight|UIRectCornerBottomLeft cornerRadii:CGSizeMake(20, 20)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc]init];
    maskLayer.frame = self.scoreAlert.bounds;
    maskLayer.path = maskPath.CGPath;
    self.scoreAlert.layer.mask = maskLayer;

}

- (void)dataInit {
    
    [MUHttpDataAccess statisticFootprint:MUFOOTPRINTTYPEEXHIBITION statisticID:self.exhibitionId];
    
    [self getExhibtionBaseInfo];
    
    self.exhibitPage = 1;
    self.isExhibitMax = NO;
    [self loadProductions];
    
    [self.exhibitionTableView.mj_header beginRefreshing];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddNewComment:) name:kSubmitCommentOKNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogin:) name:kDidLoginSuccessNotification object:nil];
    
}

// 登录后，重新请求展览信息
- (void)didLogin:(id)sender {
    [self getExhibtionBaseInfo];
}

- (void)getExhibtionBaseInfo {
    __weak typeof(self) weakSelf = self;
    [[MUMapHandler getInstance]fetchPositionAsyn:^(CLLocation *location, BMKLocationReGeocode *regeo) {
        [MUHttpDataAccess getExhibitionsWithLong:location.coordinate.longitude
                                             lat:location.coordinate.latitude
                                            page:1
                                           state:MUEXHIBITIONTYPEDEFAULT
                                  exhibitionName:@""
                                    exhibitionId:self.exhibitionId success:^(id result) {
                                        
                                        if ([result[@"state"]integerValue] == 10001) {
                                            weakSelf.exhibition = [MUExhibitionDetailModel exhibitionWithDic:result[@"data"]];
                                            if (weakSelf.exhibits.count > 0) {
                                                weakSelf.exhibition.exhibits = weakSelf.exhibits;
                                            }
                                            if (weakSelf.exhibition.buyUrl) {
                                                weakSelf.buyTicketsButton.hidden = NO;
                                            } else {
                                                weakSelf.buyTicketsButton.hidden = YES;
                                            }
                                            weakSelf.collectBt.selected = weakSelf.exhibition.isLove;
                                            [weakSelf.exhibitionTableView reloadData];
                                        }else {
                                            [weakSelf alertWithMsg:result[@"msg"] handler:nil];
                                        }
                                        
                                    } failed:^(NSError *error) {
                                        [weakSelf alertWithMsg:kFailedTips handler:nil];
                                    }];
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)didAddNewComment:(id)sender {
    [self.exhibitionTableView.mj_header beginRefreshing];
}

/** 加载评论 */
- (void)loadComments {
    
    __weak typeof(self) weakSelf = self;
    [MUHttpDataAccess getCommentsWithType:MUEXHIBITIONCOMMENT page:self.commentPage exhibitId:self.exhibitionId success:^(id result) {
        if([weakSelf.exhibitionTableView.mj_header isRefreshing]) {
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
            [weakSelf.exhibitionTableView.mj_header endRefreshing];
            if(list.count < 10) {
                [weakSelf.exhibitionTableView.mj_footer endRefreshingWithNoMoreData];
            } else {
                [weakSelf.exhibitionTableView.mj_footer endRefreshing];
            }
        } else {
            [weakSelf.exhibitionTableView.mj_header endRefreshing];
            [weakSelf.exhibitionTableView.mj_footer endRefreshing];
        }
        [weakSelf.exhibitionTableView reloadData];
    } failed:^(NSError *error) {
        [weakSelf alertWithMsg:kFailedTips handler:nil];
    }];
}

/** 加载展览展品 */
- (void)loadProductions {
    
    __weak typeof(self) weakSelf = self;
    [MUHttpDataAccess getExhibitsFromExhition:self.exhibitionId isHot:YES page:self.exhibitPage success:^(id result) {
        if ([result[@"state"]integerValue] == 10001) {
            
            NSMutableArray *mutExhibits = [NSMutableArray array];
            for (NSDictionary *dic in result[@"data"][@"list"]) {
                MUExhibitModel *exhibit = [MUExhibitModel exhibitWithDic:dic];
                [mutExhibits addObject:exhibit];
            }
            weakSelf.exhibits = [NSArray arrayWithArray:mutExhibits];
            if (weakSelf.exhibition != nil) {
                weakSelf.exhibition.exhibits = weakSelf.exhibits;
                [weakSelf.exhibitionTableView reloadData];
            }
            
        }else {
//            [weakSelf alertWithMsg:result[@"msg"] handler:nil];
        }
    } failed:^(NSError *error) {
        [weakSelf alertWithMsg:kFailedTips handler:nil];
    }];
}

#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.comments.count == 0) {
        return 4;
    }else {
        return 5+self.comments.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case 0: {
            MUExhibitionTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MUExhibitionTitleCell"];
            [cell bindCellWithModel:self.exhibition delegate:self];
            return cell;
            break;
        }
        case 1: {
            MUExhibitionDescripeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MUExhibitionDescripeCell"];
            [cell bindCellWithModel:self.exhibition delegate:self];
            return cell;
            break;
        }
        case 2: {
            MUProductorCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MUProductorCell"];
            [cell bindCellWithModel:self.exhibition delegate:self];
            return cell;
            break;
        }
        case 3: {
            MUMapCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MUMapCell"];
            [cell bindCellWithModel:self.exhibition delegate:self];
            return cell;
            break;
        }
        case 4: {
            MUHomeCommentTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MUHomeCommentTitleCell"];
            return cell;
            break;
        }
            
        default: {
            __weak typeof(self) weakSelf = self;
            MUCommentModel *comment = self.comments[indexPath.row-5];
            MUCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MUCommentCell"];
            [cell bindCellWithModel:comment];
            return cell;
            break;
        }
    }
    return nil;
}

/*

- (void)agreeComment:(MUCommentModel *)comment {
    
    if (![MUUserModel currentUser].isLogin) {
        [self.navigationController pushViewController:[MULoginViewController new] animated:YES];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [MUHttpDataAccess agreeComment:comment.commentId success:^(id result) {
        if ([result[@"state"]integerValue] == 10001) {
            comment.count++;
            [weakSelf.exhibitionTableView reloadData];
            NSLog(@"result:%@",result);
        }else {
            [weakSelf alertWithMsg:result[@"msg"] handler:nil];
        }
    } failed:^(NSError *error) {
        [weakSelf alertWithMsg:kFailedTips handler:nil];
    }];
}
 */

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            return 330.0f;
            break;
        case 1:
            return self.exhibition.introduceHeight;
            break;
        case 2:
            if (self.exhibition.exhibits.count == 0) {
                return 0.01;
            }
            return 200.0f;
            break;
        case 3:
            return 280.0f;
            break;
        case 4:
            return 58.0f;
            break;
        default: {
            MUCommentModel *comment = self.comments[indexPath.row-5];
            return [comment commentTotalHeight];
            break;
        }
    }
}

#pragma mark -
- (void)didImageTappedInCell:(UITableViewCell *)cell {
    self.imageAlertView.hidden = NO;
    [self.alertImageView sd_setImageWithURL:[NSURL URLWithString:self.exhibition.imageUrl] placeholderImage:kPlaceHolderImage];
}
- (void)didScoreTappedInCell:(UITableViewCell *)cell {
    if (![MUUserModel currentUser].isLogin) {
        [self.navigationController pushViewController:[MULoginViewController new] animated:YES];
        return;
    }
    if (self.exhibition.isScore) {
        [self alertWithMsg:@"您已经评过分了哟" handler:nil];
        return;
    }
    self.score = 0;
    NSArray *stars = @[self.start1Bt,self.start2Bt,self.start3Bt,self.start4Bt,self.start5Bt];
    for (UIButton *star in stars) {
        star.selected = NO;
    }
    self.scoreAlertBgView.hidden = NO;
}

- (void)didOperationClickedInCell:(UITableViewCell *)cell {
    self.exhibition.fold = !self.exhibition.fold;
    [self.exhibitionTableView reloadData];
}

- (void)didProduction:(NSInteger)productionIndex tappedInCell:(MUProductorCell *)cell {
    
    if (productionIndex >= self.exhibits.count) {
        return;
    }
    // 进入照片预览
    self.browser = [[SDPhotoBrowser alloc]init];
    self.browser.currentImageIndex = productionIndex;
    self.browser.sourceImagesContainerView = cell.productorCollectionView;
    self.browser.imageCount = self.exhibits.count;
    self.browser.delegate = self;
    [self.browser show];
}
- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index {
    NSString *url = self.exhibits[index].exhibitUrl;
    UIImageView *imageView = [[UIImageView alloc]init];
    [imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:kPlaceHolderImage];
    return imageView.image;
}

- (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index {
    if (index < self.exhibits.count) {
        NSString *urlStr = self.exhibits[index].exhibitUrl;
        NSURL *url = [NSURL URLWithString:urlStr];
        if (url != nil) {
            return url;
        }
    }
    return nil;
}


- (void)didNaviClicked:(UITableViewCell *)cell {
    
    UIAlertController *mapAlert = [UIAlertController alertControllerWithTitle:@"选择地图" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    UIAlertAction *aMapAction = [UIAlertAction actionWithTitle:@"高德地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf toAMap];
    }];
    UIAlertAction *baiduMapAction = [UIAlertAction actionWithTitle:@"百度地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf toBaiduMap];
    }];
    UIAlertAction *appleAction = [UIAlertAction actionWithTitle:@"自带地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf toAppleMap];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [mapAlert addAction:aMapAction];
    [mapAlert addAction:baiduMapAction];
    [mapAlert addAction:appleAction];
    [mapAlert addAction:cancelAction];
    
    [self presentViewController:mapAlert animated:YES completion:nil];
}
- (void)toAMap {
    // 判断是否安装了高德地图
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
        NSString *urlsting =[[NSString stringWithFormat:@"iosamap://navi?sourceApplication= &backScheme= &lat=%f&lon=%f&dev=0&style=2",self.exhibition.locationCoordinate.latitude,self.exhibition.locationCoordinate.longitude]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication  sharedApplication]openURL:[NSURL URLWithString:urlsting]];
    }else {
        NSString *urlStr = @"itms-apps://itunes.apple.com/cn/app/gao-tu-zhuan-ye-shou-ji-tu/id461703208?mt=8";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
//        [self alertWithMsg:@"您的手机尚未安装高德地图,请前往AppStore安装高德地图" handler:nil];
    }

}
- (void)toBaiduMap {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]) {
        NSString *urlsting =[[NSString stringWithFormat:@"baidumap://map/direction?origin={{我的位置}}&destination=latlng:%f,%f|name=目的地&mode=driving&coord_type=gcj02",self.exhibition.locationCoordinate.latitude,self.exhibition.locationCoordinate.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlsting]];
    }else {
        NSString *urlStr = @"itms-apps://itunes.apple.com/cn/app/bai-du-tu-shou-ji-tu-lu-xian/id452186370?mt=8";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
//        [self alertWithMsg:@"您的手机尚未安装百度地图,请前往AppStore安装百度地图" handler:nil];
    }
}
- (void)toAppleMap {
    //当前的位置
    MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
    //目的地的位置
    MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:self.exhibition.locationCoordinate addressDictionary:nil]];
    toLocation.name = @"目的地";
    NSArray *items = [NSArray arrayWithObjects:currentLocation, toLocation, nil];
    NSDictionary *options = @{ MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving, MKLaunchOptionsMapTypeKey: [NSNumber numberWithInteger:MKMapTypeStandard], MKLaunchOptionsShowsTrafficKey:@YES };
    //打开苹果自身地图应用，并呈现特定的item
    [MKMapItem openMapsWithItems:items launchOptions:options];
}

#pragma mark -

- (IBAction)didReturnClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)didCollectionClicked:(id)sender {
    if (![MUUserModel currentUser].isLogin) {
        [self.navigationController pushViewController:[MULoginViewController new] animated:YES];
        return;
    }
    [self loveExhibition];
}

- (void)loveExhibition {
    __weak typeof(self) weakSelf = self;
    [MUHttpDataAccess loveExhibtion:self.exhibition.exhibitionId exhibitionName:self.exhibition.exhibitionName success:^(id result) {
        if ([result[@"state"]integerValue] == 10001) {
            weakSelf.exhibition.isLove = [result[@"data"][@"islove"] boolValue];
            weakSelf.collectBt.selected = weakSelf.exhibition.isLove;
        }
    } failed:^(NSError *error) {
        [weakSelf alertWithMsg:kFailedTips handler:nil];
    }];
}

- (IBAction)didShareClicked:(id)sender {
    
    __weak typeof(self) weakSelf = self;
    [[MUMapHandler getInstance] fetchPositionAsyn:^(CLLocation *location, BMKLocationReGeocode *regeo) {
        
        UIImageView *iv = [UIImageView new];
        [iv sd_setImageWithURL:[NSURL URLWithString:weakSelf.exhibition.imageUrl] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            NSString *userId = [MUUserModel currentUser].userId;
            if (userId.length == 0) {
                userId = @"un_login";
            }
            NSString *urlStr = [NSString stringWithFormat:@"https://www.airart.com.cn/museumai2/#/exhibitionDetail/%@/%@/%f/%f",self.exhibition.exhibitionId,userId,location.coordinate.longitude,location.coordinate.latitude];
            NSLog(@"url:%@",urlStr);
//            [MUCustomUtils shareByWechatWith:weakSelf.exhibition.exhibitionName content:weakSelf.exhibition.exhibitionIntroduce image:image url:urlStr type:0];
            NSURL *url = [NSURL URLWithString:urlStr];
            UIActivityViewController *vc = [MUCustomUtils shareWeixinWithText:weakSelf.exhibition.exhibitionName content:weakSelf.exhibition.exhibitionIntroduce image:image url:url];
            [weakSelf presentViewController:vc animated:YES completion:nil];
            [vc setCompletionWithItemsHandler:^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
                if (completed) {
                    [weakSelf alertWithMsg:@"分享成功" handler:nil];
                }else {
                    [weakSelf alertWithMsg:@"已取消分享" handler:nil];
                }
            }];
        }];
    }];
}

- (IBAction)didCommentClicked:(id)sender {
    if (![MUUserModel currentUser].isLogin) {
        [self.navigationController pushViewController:[MULoginViewController new] animated:YES];
        return;
    }
    MUCommentViewController *vc = [MUCommentViewController new];
    vc.type = MUEXHIBITIONCOMMENT;
    vc.exhibitId = self.exhibitionId;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)imageAlertHidden:(id)sender {
    self.imageAlertView.hidden = YES;
}

- (void)none_fun{}

- (void)scoreAlertHidden:(id)sender {
    self.scoreAlertBgView.hidden = YES;
}
- (IBAction)closeCommentStar:(id)sender {
    self.scoreAlertBgView.hidden = YES;
}
#pragma mark ---- 评分

- (IBAction)didScoreOkClicked:(id)sender {
    self.scoreAlertBgView.hidden = YES;
    if (self.score <= 0 || self.score > 5) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    [MUHttpDataAccess submitScoreToExhibition:self.exhibition.exhibitionId name:self.exhibition.exhibitionName count:self.score success:^(id result) {
        if ([result[@"state"]integerValue] == 10001) {
            weakSelf.exhibition.isScore = YES;
            [weakSelf refreshScore];
        }else {
            [weakSelf alertWithMsg:result[@"msg"] handler:nil];
        }
    } failed:^(NSError *error) {
        [weakSelf alertWithMsg:kFailedTips handler:nil];
    }];
}
- (void)refreshScore {
    __weak typeof(self) weakSelf = self;
    [MUHttpDataAccess getScoreByExhibtionId:self.exhibitionId success:^(id result) {
        if ([result[@"state"]integerValue] == 10001) {
            weakSelf.exhibition.userCount = result[@"data"][@"userCount"];
            weakSelf.exhibition.score = [NSString stringWithFormat:@"%.2f",[result[@"data"][@"score"] doubleValue]*2];
            [weakSelf.exhibitionTableView reloadData];
        }else {
            [weakSelf alertWithMsg:result[@"msg"] handler:nil];
        }
    } failed:^(NSError *error) {
        [weakSelf alertWithMsg:kFailedTips handler:nil];
    }];
}

- (IBAction)didStartClicked:(id)sender {
    NSArray *stars = @[self.start1Bt,self.start2Bt,self.start3Bt,self.start4Bt,self.start5Bt];
    self.score = [stars indexOfObject:sender]+1;
    if (self.score > stars.count) {
        return;
    }
    for (int i=0; i<stars.count; i++) {
        UIButton *star = stars[i];
        if (i<self.score) {
            star.selected = YES;
        }else {
            star.selected = NO;
        }
    }
}

- (IBAction)didBuyTicketsButtonClicked:(id)sender {
    
    if (self.exhibition.buyUrl != nil) {
        MUHotGuideViewController *vc = [MUHotGuideViewController new];
        vc.url = self.exhibition.buyUrl;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
