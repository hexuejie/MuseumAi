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
#import "MUExhibitionTableCell.h"
#import "MUClassTableCell.h"

#import "MUExhibitionModel.h"

#import "MUSearchViewController.h"
#import "MUCourseDetailViewController.h"
#import "MUExhibitionDetailViewController.h"
#import "MUHotGuideViewController.h"

typedef NS_ENUM(NSInteger, MULOOKTYPE) {
    MULOOKTYPEEXHIBITION = 0,   // 展览
    MULOOKTYPECLASS             // 课堂
};

@interface MULookViewController ()<UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleHeightConstraint;

@property (weak, nonatomic) IBOutlet UIButton *exhibitionButton;
@property (weak, nonatomic) IBOutlet UIButton *classButton;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;

@property (strong, nonatomic) IBOutlet UIView *exhibtionHeaderView;
@property (weak, nonatomic) IBOutlet KGOCarouselView *carouselView;
@property (weak, nonatomic) IBOutlet UICollectionView *titleCollectionView;
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

@implementation MULookViewController

- (NSArray *)titles {
    return @[@"附近展览",@"热门展览",@"即将展览",@"线上展览"];
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
    self.bottomConstraint.constant = SafeAreaBottomHeight;
    
    [self.searchButton setImageEdgeInsets:UIEdgeInsetsMake(7, 7, 7, 7)];
    self.exhibitionButton.selected = YES;
    self.classButton.selected = NO;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    CGFloat iWidth = SCREEN_WIDTH/(CGFloat)([self titles].count);
    layout.itemSize = CGSizeMake(iWidth, 44.0f);
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [self.titleCollectionView setCollectionViewLayout:layout];
    [self.titleCollectionView registerNib:[UINib nibWithNibName:@"MULookTitleCollectionCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"MULookTitleCollectionCell"];
    
    CGFloat carouselH = 9.0f*SCREEN_WIDTH/16.0f;
    self.exhibtionHeaderView.frame = CGRectMake(0, 0, SCREEN_WIDTH, carouselH+44.0f);
    self.contentTableView.tableHeaderView = self.exhibtionHeaderView;
    self.contentTableView.tableFooterView = [UIView new];
    [self.contentTableView registerNib:[UINib nibWithNibName:@"MUExhibitionTableCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MUExhibitionTableCell"];
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
    
    if (self.type == MULOOKTYPEEXHIBITION) {
        // 展览列表
        self.titleCollectionView.hidden = NO;
        self.titleHeightConstraint.constant = 44.0f;
        CGFloat carouselH = 9.0f*SCREEN_WIDTH/16.0f;
        self.exhibtionHeaderView.frame = CGRectMake(0, 0, SCREEN_WIDTH, carouselH+44.0f);
        self.contentTableView.tableHeaderView = self.exhibtionHeaderView;
        [[MUMapHandler getInstance]fetchPositionAsyn:^(CLLocation *location, BMKLocationReGeocode *regeo) {
            [MUHttpDataAccess getExhibitionsWithLong:location.coordinate.longitude
                                                 lat:location.coordinate.latitude
                                                page:self.page
                                               state:self.exhibitionType
                                      exhibitionName:@""
                                        exhibitionId:@"" success:^(id result) {
                if([weakSelf.contentTableView.mj_header isRefreshing]) {
                    weakSelf.exhibitions = @[];
                }
                if ([result[@"state"]integerValue] == 10001) {
                    NSArray *list = result[@"data"][@"list"];
                    NSMutableArray *mutExhibitions = [NSMutableArray arrayWithArray:weakSelf.exhibitions];
                    for (NSDictionary *dic in list) {
                        MUExhibitionModel *model = [MUExhibitionModel exhibitionWithDic:dic];
                        [mutExhibitions addObject:model];
                    }
                    weakSelf.exhibitions = [NSArray arrayWithArray:mutExhibitions];
                    [weakSelf.contentTableView reloadData];
                    [weakSelf.contentTableView.mj_header endRefreshing];
                    if(list.count < 10) {
                        [weakSelf.contentTableView.mj_footer endRefreshingWithNoMoreData];
                    } else {
                        [weakSelf.contentTableView.mj_footer endRefreshing];
                    }
                } else {
                    [weakSelf.contentTableView.mj_header endRefreshing];
                    [weakSelf.contentTableView.mj_footer endRefreshing];
                }
            } failed:^(NSError *error) {
                [weakSelf.contentTableView.mj_header endRefreshing];
                [weakSelf alertWithMsg:kFailedTips handler:nil];
            }];
        }];
    } else {
        // 课堂列表
        self.titleCollectionView.hidden = YES;
        self.titleHeightConstraint.constant = 0.0f;
        CGFloat carouselH = 9.0f*SCREEN_WIDTH/16.0f;
        self.exhibtionHeaderView.frame = CGRectMake(0, 0, SCREEN_WIDTH, carouselH);
        self.contentTableView.tableHeaderView = self.exhibtionHeaderView;
        [MUHttpDataAccess getClassesWithPage:self.page success:^(id result) {
            if([weakSelf.contentTableView.mj_header isRefreshing]) {
                weakSelf.classes = @[];
            }
            if ([result[@"state"]integerValue] == 10001) {
                NSLog(@"result:%@",result);
                NSArray *list = result[@"data"][@"masterClassView"];
                NSMutableArray *muClasses = [NSMutableArray arrayWithArray:weakSelf.classes];
                for (NSDictionary *dic in list) {
                    MUClassModel *model = [MUClassModel classWithDic:dic];
                    [muClasses addObject:model];
                }
                weakSelf.classes = [NSArray arrayWithArray:muClasses];
                [weakSelf.contentTableView reloadData];
                [weakSelf.contentTableView.mj_header endRefreshing];
                if(list.count < 10) {
                    [weakSelf.contentTableView.mj_footer endRefreshingWithNoMoreData];
                } else {
                    [weakSelf.contentTableView.mj_footer endRefreshing];
                }
            } else {
                [weakSelf.contentTableView.mj_header endRefreshing];
                [weakSelf.contentTableView.mj_footer endRefreshing];
            }
        } failed:^(NSError *error) {
            [weakSelf.contentTableView.mj_header endRefreshing];
            [weakSelf alertWithMsg:kFailedTips handler:nil];
        }];
    }
}

- (void)reloadCarouselView {
    
    __weak typeof(self) weakSelf = self;
    if (self.type == MULOOKTYPEEXHIBITION) {
        
        /// FIXME: 获取图片标题
        [MUHttpDataAccess getHotsWithSize:4 type:MUHOTTYPEEXHIBITION success:^(id result) {
//            NSLog(@"result:%@",result);
            if ([result[@"state"]integerValue] == 10001) {
                NSArray *list = result[@"data"][@"list"];
                NSArray *urls = [list valueForKey:@"url"];
                NSArray *ids = [list valueForKey:@"id"];
                NSArray *titles = [list valueForKey:@"title"];
                weakSelf.carouselView.placeholderImage = [UIImage imageNamed:@"加载占位"];
                weakSelf.carouselView.contentMode = UIViewContentModeScaleAspectFill;
                weakSelf.carouselView.titleArray = titles;
                weakSelf.carouselView.imageArray = urls;
                [self.carouselView setImageClickBlock:^(NSInteger index) {
                    NSString *idStr = ids[index];
                    MUExhibitionDetailViewController *vc = [MUExhibitionDetailViewController new];
                    vc.exhibitionId = idStr;
                    [weakSelf.navigationController pushViewController:vc animated:YES];
                }];
            }
        } failed:nil];
        
    } else {
        
        [MUHttpDataAccess getHotsWithSize:4 type:MUHOTTYPECLASS success:^(id result) {
            if ([result[@"state"]integerValue] == 10001) {
                NSArray *list = result[@"data"][@"list"];
                NSArray *urls = [list valueForKey:@"url"];
                NSArray *ids = [list valueForKey:@"id"];
                NSArray *titles = @[];  // [list valueForKey:@""];
                weakSelf.carouselView.placeholderImage = [UIImage imageNamed:@"加载占位"];
                weakSelf.carouselView.contentMode = UIViewContentModeScaleAspectFill;
                weakSelf.carouselView.titleArray = titles;
                weakSelf.carouselView.imageArray = urls;
                [self.carouselView setImageClickBlock:^(NSInteger index) {
                    NSString *idStr = ids[index];
                    MUCourseDetailViewController *vc = [MUCourseDetailViewController new];
                    vc.courseId = idStr;
                    [weakSelf.navigationController pushViewController:vc animated:YES];
                }];
            }
        } failed:nil];
    }
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
        MUExhibitionModel *model = nil;
        if (indexPath.row < self.exhibitions.count) {
            model = self.exhibitions[indexPath.row];
        }
        MUExhibitionTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MUExhibitionTableCell"];
        if (model != nil) {
            [cell bindCellWithExhibition:model];
        }
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
        return 114.0f;
    }else {
        return 113.0f+120.0f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.type == MULOOKTYPEEXHIBITION) {
        MUExhibitionModel *model = self.exhibitions[indexPath.row];
        
        if (self.exhibitionType == MUEXHIBITIONTYPEONLINE) {
            MUHotGuideViewController *vc = [MUHotGuideViewController new];
            vc.hidesBottomBarWhenPushed = YES;
            vc.exhibitionId = model.hallId;
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.navigationController pushViewController:vc animated:YES];
            });
        } else {
            MUExhibitionDetailViewController *vc = [MUExhibitionDetailViewController new];
            vc.exhibitionId = model.hallId;
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.navigationController pushViewController:vc animated:YES];
            });
        }
    }else {
        MUClassModel *model = self.classes[indexPath.row];
        MUCourseDetailViewController *vc = [MUCourseDetailViewController new];
        vc.courseId = model.classId;
        [self.navigationController pushViewController:vc animated:YES];
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
    }else {
        cell.titleNameLabel.textColor = kUIColorFromRGB(0x333333);
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.contentTableView.mj_header.isRefreshing) {
        NSLog(@"请勿频繁操作");
        return;
    }
    self.exhibitionType = indexPath.item;
    [self.titleCollectionView reloadData];
    [self.contentTableView.mj_header beginRefreshing];
}

#pragma mark -

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}




@end
