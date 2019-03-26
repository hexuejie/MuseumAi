//
//  MUResultListViewController.m
//  MuseumAi
//
//  Created by 何学杰 on 2019/3/11.
//  Copyright © 2019 Weizh. All rights reserved.
//

#import "MUResultListViewController.h"
#import "MUMapHandler.h"
#import "MUExhibitionTableCell.h"
#import "MJRefresh.h"
#import "MUExhibitionDetailViewController.h"
#import "MUMyPCCollectionViewCell.h"
#import "MUHotGuideViewController.h"

@interface MUResultListViewController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property (weak, nonatomic) IBOutlet UILabel *topTlitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *returnBt;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navHeight;

@property (weak, nonatomic) IBOutlet UICollectionView *mainCollection;



/** 页数 */
@property (assign, nonatomic) NSInteger page;
/** 展览列表 */
@property (strong, nonatomic) NSArray *exhibitions;

@end

@implementation MUResultListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self viewInit];
    
    NSString *titleStr;
    switch (_exhibitionType) {
        case 0:
            titleStr = @"附近展览";
            break;
        case 1:
            _exhibitionType = 3;
            titleStr = @"线上展览";
            break;
        case 2:
            _exhibitionType = 1;
            titleStr = @"热门展览";
            
            break;
        case 3:
            _exhibitionType = 2;
            titleStr = @"即将展览";
            
            break;
            
        default:
            break;
    }
    self.topTlitleLabel.text = titleStr;
    self.page = 1;
    [self reloadData];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewInit {
    
    self.topConstraint.constant = SafeAreaTopHeight-44.0f;
    self.navHeight.constant = SafeAreaTopHeight;
    [self.returnBt setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(5, 12, 0, 12);
    
    self.mainCollection.collectionViewLayout = layout;
    self.mainCollection.delegate = self;
    self.mainCollection.dataSource = self;
    self.mainCollection.backgroundColor = [UIColor whiteColor];
    self.mainCollection.scrollEnabled = YES;
    self.mainCollection.showsVerticalScrollIndicator = NO;
    self.mainCollection.showsHorizontalScrollIndicator = NO;
    self.mainCollection.alwaysBounceVertical = YES;
    
    [self.mainCollection registerNib:[UINib nibWithNibName:NSStringFromClass([MUMyPCCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:@"MUMyPCCollectionViewCell"];
    
    __weak typeof (self) weakSelf = self;
    
    self.mainCollection.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        weakSelf.page = 1;
        [weakSelf.mainCollection.mj_footer resetNoMoreData];
        [weakSelf reloadData];
    }];
    self.mainCollection.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        weakSelf.page++;
        [weakSelf reloadData];
    }];
}

- (void)reloadData {
    __weak typeof(self) weakSelf = self;
    [[MUMapHandler getInstance]fetchPositionAsyn:^(CLLocation *location, BMKLocationReGeocode *regeo) {
        [MUHttpDataAccess getExhibitionsWithLong:location.coordinate.longitude lat:location.coordinate.latitude page:self.page state:self.exhibitionType exhibitionName:@"" exhibitionId:@"" success:^(id result) {
            
                                            if([weakSelf.mainCollection.mj_header isRefreshing]) {
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
                                                [weakSelf.mainCollection reloadData];
                                                [weakSelf.mainCollection.mj_header endRefreshing];
                                                if(list.count < 10) {
                                                    [weakSelf.mainCollection.mj_footer endRefreshingWithNoMoreData];
                                                } else {
                                                    [weakSelf.mainCollection.mj_footer endRefreshing];
                                                }

                                            } else {
                                                [weakSelf.mainCollection.mj_header endRefreshing];
                                                [weakSelf.mainCollection.mj_footer endRefreshing];
                                            }
                                        } failed:^(NSError *error) {
                                            [weakSelf.mainCollection.mj_header endRefreshing];
                                            [weakSelf alertWithMsg:kFailedTips handler:nil];
                                        }];
    }];
}


#pragma mark - delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.exhibitions.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    MUMyPCCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MUMyPCCollectionViewCell" forIndexPath:indexPath];
    [cell bindCellWithExhibitionModel:self.exhibitions[indexPath.row]];//MUExhibitionModel
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat width = (SCREEN_WIDTH-40)/2;
    
    return CGSizeMake(width, width/16*9 +65);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.exhibitionType == MUEXHIBITIONTYPEONLINE) {
        // 线上展览
        MUExhibitionModel *model = self.exhibitions[indexPath.row];
        MUHotGuideViewController *vc = [MUHotGuideViewController new];
        vc.hidesBottomBarWhenPushed = YES;
        vc.exhibitionId = model.hallId;
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.navigationController pushViewController:vc animated:YES];
        });
    } else {
        MUExhibitionModel *model = self.exhibitions[indexPath.row];
        MUExhibitionDetailViewController *vc = [MUExhibitionDetailViewController new];
        vc.exhibitionId = model.hallId;
        [self.navigationController pushViewController:vc animated:YES];
    }
}


#pragma mark -
- (IBAction)didReturnClicked:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
