//
//  MULookViewController.m
//  MuseumAi
//
//  Created by Kingo on 2018/9/18.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MULookViewController.h"
#import "MUMapHandler.h"
#import "MJRefresh.h"

#import "KGOCarouselView.h"
#import "MULookTitleCollectionCell.h"
#import "MULookExhibitionTableViewCell.h"
#import "MUClassTableCell.h"

#import "MUExhibitionModel.h"
#import "MUResultListViewController.h"
#import "MUSearchViewController.h"
#import "MUCourseDetailViewController.h"
#import "MUExhibitionDetailViewController.h"
#import "MUHotGuideViewController.h"
#import "JQIndexBannerSubview.h"
#import "JQFlowView.h"

typedef NS_ENUM(NSInteger, MULOOKTYPE) {
    MULOOKTYPEEXHIBITION = 0,   // 展览
    MULOOKTYPECLASS             // 课堂
};

@interface MULookViewController ()<UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,JQFlowViewDelegate,JQFlowViewDataSource,MULookExhibitionTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UIView *headerBackView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@property (weak, nonatomic) IBOutlet UIButton *exhibitionButton;
@property (weak, nonatomic) IBOutlet UIButton *classButton;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;

@property (strong, nonatomic) IBOutlet UIView *exhibtionHeaderView;
@property (weak, nonatomic) IBOutlet UIView *carouselView;//轮播图


@property (nonatomic, strong) NSArray *idArray;
@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic, strong) JQFlowView *pageFlowView;

@property (strong, nonatomic) UICollectionView *titleCollectionView;//选择器
@property (weak, nonatomic) IBOutlet UITableView *contentTableView;

/** 当前展示的类型 */
@property (nonatomic , assign) MULOOKTYPE type;
/** 当前展览的类型 */
@property (nonatomic , assign) MUEXHIBITIONTYPE exhibitionType;
/** 当前page */
@property (nonatomic , assign) NSInteger page;
/** 展览列表 */
@property (nonatomic , strong) NSArray *exhibitions;
/** 课程列表 */
@property (nonatomic , strong) NSArray *classes;


@end


#define CarouselH (9.0f*SCREEN_WIDTH/16.0f-30)

#define SingleCellHeigh (303+362*CustomScreenFit)     //178+92*2 = 362
@implementation MULookViewController

- (NSArray *)titles {
    return @[@"附近展览",@"线上展览",@"热门展览",@"即将展览"];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self viewInit];
    
    [self dataInit];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewInit {
    
    self.topConstraint.constant = SafeAreaTopHeight-44.0f;
    self.bottomConstraint.constant = SafeAreaBottomHeight + 49.0f;
    
    self.searchButton.layer.masksToBounds = YES;
    self.searchButton.layer.cornerRadius = 17;
    self.exhibitionButton.selected = YES;
    self.classButton.selected = NO;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    CGFloat iWidth = SCREEN_WIDTH/(CGFloat)([self titles].count);
    layout.itemSize = CGSizeMake(iWidth, 44.0f);
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.titleCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44.0) collectionViewLayout:layout];
    self.titleCollectionView.backgroundColor = [UIColor whiteColor];
    self.titleCollectionView.delegate = self;
    self.titleCollectionView.dataSource = self;
    [self.titleCollectionView registerNib:[UINib nibWithNibName:@"MULookTitleCollectionCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"MULookTitleCollectionCell"];
    self.exhibtionHeaderView.frame = CGRectMake(0, 0, SCREEN_WIDTH, CarouselH);
    
    self.contentTableView.tableHeaderView = self.exhibtionHeaderView;
    self.contentTableView.tableFooterView = [UIView new];
    [self.contentTableView registerNib:[UINib nibWithNibName:@"MULookExhibitionTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MULookExhibitionTableViewCell"];
    [self.contentTableView registerNib:[UINib nibWithNibName:@"MUClassTableCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MUClassTableCell"];
    
    __weak typeof (self) weakSelf = self;
    
    self.contentTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        weakSelf.page = 1;
        [weakSelf.contentTableView.mj_footer resetNoMoreData];
        [weakSelf reloadData];
    }];
    self.contentTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        weakSelf.page++;
        [weakSelf reloadData];
    }];
}


- (void)dataInit {
    
    self.type = MULOOKTYPEEXHIBITION;
    self.exhibitionType = MUEXHIBITIONTYPEDEFAULT;
    self.exhibitions = [NSArray array];
    self.classes = [NSArray array];
    [self.contentTableView.mj_header beginRefreshing];
}

- (void)reloadData {
    __weak typeof(self) weakSelf = self;
    
//    if (self.type == MULOOKTYPEEXHIBITION) {
        // 展览列表
  
        self.exhibtionHeaderView.frame = CGRectMake(0, 0, SCREEN_WIDTH, CarouselH);
        self.contentTableView.tableHeaderView = self.exhibtionHeaderView;
        [[MUMapHandler getInstance]fetchPositionAsyn:^(CLLocation *location, BMKLocationReGeocode *regeo) {
            [MUHttpDataAccess getExhibitionsHomeWithLong:location.coordinate.longitude
                                                 lat:location.coordinate.latitude
                                                page:self.page
//                                               state:self.exhibitionType
                                      exhibitionName:@""
                                        exhibitionId:@"" success:^(id result) {
                if([weakSelf.contentTableView.mj_header isRefreshing]) {
                    weakSelf.exhibitions = @[];
                }
                if ([result[@"state"]integerValue] == 10001) {
                    
                    NSArray *list = result[@"data"][@"list"];
                    
                    NSMutableArray *mutExhibitions = [NSMutableArray array];
                    NSMutableArray *tempAllExhibitions = [NSMutableArray array];
                    
                    for (int i = 0; i<list.count; i++) {
                        NSDictionary *dic = list[i];
                        MUExhibitionModel *model = [MUExhibitionModel exhibitionWithDic:dic];
                        if (i%5 == 0 && mutExhibitions.count>0) {
                            [tempAllExhibitions addObject:mutExhibitions];
                            mutExhibitions = [NSMutableArray array];
                        }
                        [mutExhibitions addObject:model];
                        
                        if (list.count == i+1) {//最后一个没加进去的
                            [tempAllExhibitions addObject:mutExhibitions];
                            mutExhibitions = [NSMutableArray array];
                        }
                    }
                    weakSelf.exhibitions = [NSArray arrayWithArray:tempAllExhibitions];
                    
                    [weakSelf.contentTableView reloadData];
                    [weakSelf.contentTableView.mj_header endRefreshing];
                    [weakSelf.contentTableView.mj_footer endRefreshingWithNoMoreData];
                } else {
                    [weakSelf.contentTableView.mj_header endRefreshing];
                    [weakSelf.contentTableView.mj_footer endRefreshing];
                }
            } failed:^(NSError *error) {
                [weakSelf.contentTableView.mj_header endRefreshing];
                [weakSelf alertWithMsg:kFailedTips handler:nil];
            }];
        }];
//    } else {
//        // 课堂列表
//        self.titleCollectionView.hidden = YES;
//        CGFloat carouselH = 9.0f*SCREEN_WIDTH/16.0f;
//        self.exhibtionHeaderView.frame = CGRectMake(0, 0, SCREEN_WIDTH, carouselH);
//        self.contentTableView.tableHeaderView = self.exhibtionHeaderView;
//        [MUHttpDataAccess getClassesWithPage:self.page success:^(id result) {
//            if([weakSelf.contentTableView.mj_header isRefreshing]) {
//                weakSelf.classes = @[];
//            }
//            if ([result[@"state"]integerValue] == 10001) {
//                NSLog(@"result:%@",result);
//                NSArray *list = result[@"data"][@"masterClassView"];
//                NSMutableArray *muClasses = [NSMutableArray arrayWithArray:weakSelf.classes];
//                for (NSDictionary *dic in list) {
//                    MUClassModel *model = [MUClassModel classWithDic:dic];
//                    [muClasses addObject:model];
//                }
//                weakSelf.classes = [NSArray arrayWithArray:muClasses];
//                [weakSelf.contentTableView reloadData];
//                [weakSelf.contentTableView.mj_header endRefreshing];
//                if(list.count < 10) {
//                    [weakSelf.contentTableView.mj_footer endRefreshingWithNoMoreData];
//                } else {
//                    [weakSelf.contentTableView.mj_footer endRefreshing];
//                }
//            } else {
//                [weakSelf.contentTableView.mj_header endRefreshing];
//                [weakSelf.contentTableView.mj_footer endRefreshing];
//            }
//        } failed:^(NSError *error) {
//            [weakSelf.contentTableView.mj_header endRefreshing];
//            [weakSelf alertWithMsg:kFailedTips handler:nil];
//        }];
//    }
}

- (void)reloadCarouselView {
    
    __weak typeof(self) weakSelf = self;
//    if (self.type == MULOOKTYPEEXHIBITION) {
    
        /// FIXME: 获取图片标题
        [MUHttpDataAccess getHotsWithSize:4 type:MUHOTTYPEEXHIBITION success:^(id result) {
//            NSLog(@"result:%@",result);
            if ([result[@"state"]integerValue] == 10001) {
                NSArray *list = result[@"data"][@"list"];
                NSArray *urls = [list valueForKey:@"url"];
                NSArray *ids = [list valueForKey:@"id"];
//                NSArray *titles = [list valueForKey:@"title"];
                
                weakSelf.idArray = ids;
                weakSelf.imageArray = urls;

            }
        } failed:nil];
        
//    } else {
//
//        [MUHttpDataAccess getHotsWithSize:4 type:MUHOTTYPECLASS success:^(id result) {
//            if ([result[@"state"]integerValue] == 10001) {
//                NSArray *list = result[@"data"][@"list"];
//                NSArray *urls = [list valueForKey:@"url"];
//                NSArray *ids = [list valueForKey:@"id"];
//                NSArray *titles = @[];  // [list valueForKey:@""];
//                weakSelf.carouselView.placeholderImage = [UIImage imageNamed:@"加载占位"];
//                weakSelf.carouselView.contentMode = UIViewContentModeScaleAspectFill;
//                weakSelf.carouselView.titleArray = titles;
//                weakSelf.carouselView.imageArray = urls;
//                [self.carouselView setImageClickBlock:^(NSInteger index) {
//                    NSString *idStr = ids[index];
//                    MUCourseDetailViewController *vc = [MUCourseDetailViewController new];
//                    vc.courseId = idStr;
//                    [weakSelf.navigationController pushViewController:vc animated:YES];
//                }];
//            }
//        } failed:nil];
//    }
}


#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.type == MULOOKTYPEEXHIBITION) {
        return self.exhibitions.count;
    }else {
        return self.classes.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.type == MULOOKTYPEEXHIBITION) {
        NSArray *models = nil;
        if (indexPath.row < self.exhibitions.count) {
            models = self.exhibitions[indexPath.row];
        }
        MULookExhibitionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MULookExhibitionTableViewCell"];
        cell.delegate = self;
        if (models != nil) {
            [cell bindCellWithExhibition:models];
        }
        if (indexPath.row < self.titles.count) {
            cell.segmentTitleLabel.text = self.titles[indexPath.row];
        }
        cell.tag = indexPath.row;
        return cell;
    }else {
        MUClassModel *model = nil;
        if (indexPath.row < self.classes.count) {
            model = self.classes[indexPath.row];
        }
        MUClassTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MUClassTableCell"];
        if (model != nil) {
            [cell bindCellWithClass:model];
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.type == MULOOKTYPEEXHIBITION) {
        return SingleCellHeigh;
    }else {
        return 113.0f+120.0f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44.0f;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return self.titleCollectionView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == self.contentTableView) {
        CGFloat contentOffsetY = scrollView.contentOffset.y-CarouselH;
       NSInteger scrollExhibitionType = contentOffsetY/SingleCellHeigh;
        
//        NSLog(@"scrollExhibitionType %ld",scrollExhibitionType);
        if (scrollExhibitionType != self.exhibitionType) {
            self.exhibitionType =scrollExhibitionType;
            [self.titleCollectionView reloadData];
        }
    }
}

#pragma mark -
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self titles].count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MULookTitleCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MULookTitleCollectionCell" forIndexPath:indexPath];
    cell.titleNameLabel.text = [self titles][indexPath.item];
    if (indexPath.item == self.exhibitionType) {
        cell.titleNameLabel.textColor = kMainColor;
        cell.titleNameLabel.font = [UIFont boldSystemFontOfSize:18];
        cell.tagLineView.backgroundColor = kMainColor;
    }else {
        cell.titleNameLabel.textColor = kUIColorFromRGB(0x333333);
        cell.titleNameLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        cell.tagLineView.backgroundColor = [UIColor clearColor];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.contentTableView.mj_header.isRefreshing) {
        NSLog(@"请勿频繁操作");
        return;
    }
//    self.exhibitionType = indexPath.item;
    [self.contentTableView setContentOffset:CGPointMake(0, indexPath.item* SingleCellHeigh+CarouselH+5) animated:YES];
//    [self.titleCollectionView reloadData];
//    [self.contentTableView.mj_header beginRefreshing];
}

#pragma mark - Click

- (void)setType:(MULOOKTYPE)type {
    _type = type;
    [self reloadCarouselView];
}
- (IBAction)didExhibitionClicked:(id)sender {
    self.type = MULOOKTYPEEXHIBITION;
    self.exhibitions = [NSArray array];
    [self.contentTableView reloadData];
    self.exhibitionButton.selected = YES;
    self.classButton.selected = NO;
    [self.contentTableView.mj_header beginRefreshing];
}

- (IBAction)didClassClicked:(id)sender {
    self.type = MULOOKTYPECLASS;
    self.classes = [NSArray array];
    [self.contentTableView reloadData];
    self.exhibitionButton.selected = NO;
    self.classButton.selected = YES;
    [self.contentTableView.mj_header beginRefreshing];
}

- (IBAction)didSearchClicked:(id)sender {
    
    MUSearchViewController *searchVC = [MUSearchViewController new];
    [self.navigationController pushViewController:searchVC animated:YES];
    
}

#pragma mark - 轮播图
- (void)setImageArray:(NSArray *)imageArray{
    _imageArray = imageArray;
    [self setupUI];
}

- (void)setupUI{
    
    _pageFlowView = [[JQFlowView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, CarouselH)];
    _pageFlowView.backgroundColor = [UIColor clearColor];
    _pageFlowView.delegate = self;
    _pageFlowView.dataSource = self;
    _pageFlowView.minimumPageAlpha = 0.4;
    _pageFlowView.minimumPageScale = 0.85;
    _pageFlowView.orginPageCount = _imageArray.count;
    _pageFlowView.isOpenAutoScroll = YES;
    _pageFlowView.autoTime = 3.0;
    _pageFlowView.orientation = JQFlowViewOrientationHorizontal;
    //初始化pageControl
    UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, _pageFlowView.frame.size.height - 24 - 8, SCREEN_WIDTH, 8)];
    _pageFlowView.pageControl = pageControl;
    [_pageFlowView addSubview:pageControl];
    
    
    UIScrollView *bottomScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, CarouselH)];
    bottomScrollView.backgroundColor = [UIColor clearColor];
    [_pageFlowView reloadData];
    [bottomScrollView addSubview:_pageFlowView];
    [self.exhibtionHeaderView addSubview:bottomScrollView];
    
    [bottomScrollView addSubview:_pageFlowView];
}
#pragma mark - Delegate
- (CGSize)sizeForPageInFlowView:(JQFlowView *)flowView
{
    return CGSizeMake(SCREEN_WIDTH - 84, (SCREEN_WIDTH - 84) * 9 / 16);
}

- (void)didSelectCell:(UIView *)subView withSubViewIndex:(NSInteger)subIndex
{
    NSLog(@"点击了第%ld张图",(long)subIndex + 1);
    
    MUExhibitionDetailViewController *vc = [MUExhibitionDetailViewController new];
    vc.hidesBottomBarWhenPushed = YES;
    vc.exhibitionId = self.idArray[subIndex];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.navigationController pushViewController:vc animated:YES];
    });
}

-(void)lookExhibitionTableViewCellHeaderMore:(MULookExhibitionTableViewCell *)cell{
    NSLog(@"点击跳入列表页");
    
    MUResultListViewController *moreVC = [MUResultListViewController new];
    moreVC.hidesBottomBarWhenPushed = YES;
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        moreVC.exhibitionType = cell.tag;
        [weakSelf.navigationController pushViewController:moreVC animated:YES];
    });
}

-(void)lookExhibitionTableViewCellClick:(MULookExhibitionTableViewCell *)cell withExhibitionId:(NSString *)exhibitionId {
    
    NSIndexPath *indexPath = [self.contentTableView indexPathForCell:cell];
    if (indexPath.row == 1) {
        // 线上展览
        MUHotGuideViewController *vc = [MUHotGuideViewController new];
        vc.hidesBottomBarWhenPushed = YES;
        vc.exhibitionId = exhibitionId;
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.navigationController pushViewController:vc animated:YES];
        });
    } else {
        // 其他展览
        MUExhibitionDetailViewController *vc = [MUExhibitionDetailViewController new];
        vc.hidesBottomBarWhenPushed = YES;
        vc.exhibitionId = exhibitionId;
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.navigationController pushViewController:vc animated:YES];
        });
    }
}

#pragma mark Datasource
- (NSInteger)numberOfPagesInFlowView:(JQFlowView *)flowView
{
    return self.imageArray.count;
}

- (UIView *)flowView:(JQFlowView *)flowView cellForPageAtIndex:(NSInteger)index
{
    JQIndexBannerSubview *bannerView = (JQIndexBannerSubview *)[flowView dequeueReusableCell];
    if (!bannerView) {
        bannerView = [[JQIndexBannerSubview alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 84, (SCREEN_WIDTH - 84) * 9 / 16)];
        bannerView.layer.cornerRadius = 4;
        bannerView.layer.masksToBounds = YES;
        //        bannerView.mainImageView.image = [bannerView.mainImageView.image stretchableImageWithLeftCapWidth:30 topCapHeight:30];
    }
    //在这里下载网络图片
    [bannerView.mainImageView sd_setImageWithURL:[NSURL URLWithString:self.imageArray[index]] placeholderImage:[UIImage imageNamed:@"加载占位"]];
    
    return bannerView;
}
#pragma mark --旋转屏幕改变JQFlowView大小之后实现该方法
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id)coordinator
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
        [coordinator animateAlongsideTransition:^(id context) { [self.pageFlowView reloadData];
        } completion:NULL];
    }
}

- (void)dealloc
{
    [self.pageFlowView stopTimer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}




@end
