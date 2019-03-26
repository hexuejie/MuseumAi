//
//  MUMyPCViewController.m
//  MuseumAi
//
//  Created by 魏宙辉 on 2018/9/25.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUMyPCViewController.h"
#import "UIImageView+WebCache.h"
#import "MUMyPCTableViewCell.h"
#import "MUMyCommentCell.h"
#import "MUMyPCCollectionViewCell.h"
#import "MUMyCommentCollectionViewCell.h"

#import "MUExhibitDetailViewController.h"
#import "MUExhibitionDetailViewController.h"
#import "MJRefresh.h"
#import "UICollectionViewFlowLayout+Add.h"
#import "MUExhibitionModel.h"
#import "MUExhibitionDetailViewController.h"

#define SPACE 10.0f

@interface MUMyPCViewController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;


@property (weak, nonatomic) IBOutlet UIButton *returnBt;

@property (weak, nonatomic) IBOutlet UIImageView *titleImageView;

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;

@property (weak, nonatomic) IBOutlet UILabel *nickNameLb;
@property (weak, nonatomic) IBOutlet UILabel *VIPLabel;


@property (weak, nonatomic) IBOutlet UILabel *collectLb;
@property (weak, nonatomic) IBOutlet UIView *collectIndicator;
@property (weak, nonatomic) IBOutlet UIView *collectBgView;

@property (weak, nonatomic) IBOutlet UILabel *footprintLb;
@property (weak, nonatomic) IBOutlet UIView *footprintIndicator;
@property (weak, nonatomic) IBOutlet UIView *footprintBgView;

@property (weak, nonatomic) IBOutlet UILabel *commentLb;
@property (weak, nonatomic) IBOutlet UIView *commentIndicator;
@property (weak, nonatomic) IBOutlet UIView *commentBgView;

@property (weak, nonatomic) IBOutlet UICollectionView *mainCollectionView;
@property (strong, nonatomic) IBOutlet UIView *headerChooseView;
@property (weak, nonatomic) IBOutlet UIButton *chooseExhibitionButton;
@property (weak, nonatomic) IBOutlet UIButton *chooseHallButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chooseHeight;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleWIdthConstraint;

/** 收藏列表 */
@property (strong, nonatomic) NSArray *collectExhibits;
/** 足迹列表 */
@property (strong, nonatomic) NSArray *footPrints;
/** 评论 */
@property (strong, nonatomic) NSArray<MUComment *> *comments;
/** 评论页数 */
@property (assign, nonatomic) NSInteger commentPage;

@property (assign, nonatomic) BOOL chooseExhibition;

@end

@implementation MUMyPCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self dataInit];
    
    [self viewInit];
    
}

- (void)viewInit {
    
    self.chooseExhibition = YES;
    self.topConstraint.constant = SafeAreaTopHeight-36.0f;
    self.bottomConstraint.constant = SafeAreaBottomHeight;
    
    [self.returnBt setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    
    self.titleImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.titleImageView.layer.masksToBounds = YES;
    
    self.userImageView.layer.masksToBounds = YES;
    self.userImageView.layer.cornerRadius = 44.0f;
    self.titleImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.userImageView sd_setImageWithURL:[NSURL URLWithString:[MUUserModel currentUser].photo]];
    
    self.nickNameLb.text = [MUUserModel currentUser].nikeName;
    self.VIPLabel.text = [NSString stringWithFormat:@"Lv.%@",[MUUserModel currentUser].vipGrade];
    
    [self.collectBgView addTapTarget:self action:@selector(didCollectClicked:)];
    [self.footprintBgView addTapTarget:self action:@selector(didFootPrintClicked:)];
    [self.commentBgView addTapTarget:self action:@selector(didCommentClicked:)];
    self.titleWIdthConstraint.constant = SCREEN_WIDTH/3.0f;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(5, 12, 0, 12);
    layout.sectionHeadersPinToVisibleBoundsAll = YES;
    
    self.mainCollectionView.collectionViewLayout = layout;
    self.mainCollectionView.delegate = self;
    self.mainCollectionView.dataSource = self;
    self.mainCollectionView.backgroundColor = [UIColor whiteColor];
    self.mainCollectionView.scrollEnabled = YES;
    self.mainCollectionView.showsVerticalScrollIndicator = NO;
    self.mainCollectionView.showsHorizontalScrollIndicator = NO;
    self.mainCollectionView.alwaysBounceVertical = YES;
    
    [self.mainCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([MUMyPCCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:@"MUMyPCCollectionViewCell"];
    [self.mainCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([MUMyCommentCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:@"MUMyCommentCollectionViewCell"];
    [self reloadView];
}

- (void)dataInit {
    __weak typeof (self) weakSelf = self;
    self.mainCollectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        weakSelf.commentPage = 1;
        [weakSelf.mainCollectionView.mj_footer resetNoMoreData];
        switch (weakSelf.type) {
            case MUPCTYPECOLLECT:
                [weakSelf refreshCollections];
                break;
            case MUPCTYPEFOOTPRINT:
                [weakSelf refreshFootprints];
                break;
            case MUPCTYPECOMMENT:
                [weakSelf refreshComments];
                break;
            default:
                break;
        }
    }];
    self.mainCollectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        weakSelf.commentPage++;
        [weakSelf refreshComments];
    }];
}

- (void)reloadView {
    
    self.collectLb.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    self.footprintLb.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    self.commentLb.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    
    if (self.type == MUPCTYPECOLLECT) {
        self.headerChooseView.hidden = NO;
        self.chooseHeight.constant = 40;
        
        self.collectLb.font = [UIFont systemFontOfSize:17 weight:UIFontWeightBold];
        self.collectLb.textColor = kMainColor;
        self.collectIndicator.hidden = NO;
        self.footprintLb.textColor = kUIColorFromRGB(0x333333);
        self.footprintIndicator.hidden = YES;
        self.commentLb.textColor = kUIColorFromRGB(0x333333);
        self.commentIndicator.hidden = YES;
    }else if(self.type == MUPCTYPEFOOTPRINT){
        self.headerChooseView.hidden = NO;
        self.chooseHeight.constant = 40;
        
        self.footprintLb.font = [UIFont systemFontOfSize:17 weight:UIFontWeightBold];
        self.collectLb.textColor = kUIColorFromRGB(0x333333);
        self.collectIndicator.hidden = YES;
        self.footprintLb.textColor = kMainColor;
        self.footprintIndicator.hidden = NO;
        self.commentLb.textColor = kUIColorFromRGB(0x333333);
        self.commentIndicator.hidden = YES;
    }else {
        self.headerChooseView.hidden = YES;
        self.chooseHeight.constant = 0;
        
        self.commentLb.font = [UIFont systemFontOfSize:17 weight:UIFontWeightBold];
        self.collectLb.textColor = kUIColorFromRGB(0x333333);
        self.collectIndicator.hidden = YES;
        self.footprintLb.textColor = kUIColorFromRGB(0x333333);
        self.footprintIndicator.hidden = YES;
        self.commentLb.textColor = kMainColor;
        self.commentIndicator.hidden = NO;
    }
    if (self.chooseExhibition) {
        self.chooseExhibitionButton.selected = YES;
        self.chooseHallButton.selected = NO;
    }else{
        self.chooseExhibitionButton.selected = NO;
        self.chooseHallButton.selected = YES;
    }
    [self.mainCollectionView.mj_header beginRefreshing];
}

- (void)refreshFootprints {
    __weak typeof(self) weakSelf = self;
    NSString *typeStr = @"1";
    if (self.chooseExhibition) {
        typeStr = @"2";
    }
    [MUHttpDataAccess getFootPrintType:typeStr Success:^(id result) {

        weakSelf.footPrints = @[];
        [weakSelf.mainCollectionView.mj_header endRefreshing];
        [weakSelf.mainCollectionView.mj_footer endRefreshingWithNoMoreData];
        if ([result[@"state"]integerValue] == 10001) {
            NSMutableArray *array = [NSMutableArray array];
            for (NSDictionary *dic in result[@"data"]) {
                id exhibit;
                if (self.chooseExhibition) {
                    exhibit = [MUExhibitionModel exhibitionWithDic:dic];
                }else{
                    exhibit = [MUExhibitModel exhibitWithDic:dic];
                }
                [array addObject:exhibit];
            }
            weakSelf.footPrints = [NSArray arrayWithArray:array];
            [weakSelf.mainCollectionView reloadData];
        }else {
            weakSelf.footPrints = [NSArray array];
            [weakSelf.mainCollectionView reloadData];
        }
    } failed:^(NSError *error) {
        [weakSelf alertWithMsg:kFailedTips handler:nil];
    }];
}

- (void)refreshCollections {
    __weak typeof(self) weakSelf = self;
    NSString *typeStr = @"1";
    if (self.chooseExhibition) {
        typeStr = @"2";
    }
    [MUHttpDataAccess getCollectListType:typeStr Success:^(id result) {
  
        weakSelf.collectExhibits = @[];
        [weakSelf.mainCollectionView.mj_header endRefreshing];
        [weakSelf.mainCollectionView.mj_footer endRefreshingWithNoMoreData];
        if ([result[@"state"]integerValue] == 10001) {
            NSMutableArray *array = [NSMutableArray array];
            for (NSDictionary *dic in result[@"data"]) {
                id exhibit;
                if (self.chooseExhibition) {
                    exhibit = [MUExhibitionModel exhibitionWithDic:dic];
                }else{
                    exhibit = [MUExhibitModel exhibitWithDic:dic];
                }
                [array addObject:exhibit];
            }
            weakSelf.collectExhibits = [NSArray arrayWithArray:array];
            [weakSelf.mainCollectionView reloadData];
        }else {
            weakSelf.collectExhibits = [NSArray array];
            [weakSelf.mainCollectionView reloadData];
        }
    } failed:^(NSError *error) {
        [weakSelf alertWithMsg:kFailedTips handler:nil];
    }];
}

- (void)refreshComments {
    __weak typeof(self) weakSelf = self;
    [MUHttpDataAccess getMyCommentListWithPage:self.commentPage success:^(id result) {
        if ([result[@"state"]integerValue] == 10001) {
            if([weakSelf.mainCollectionView.mj_header isRefreshing]) {
                weakSelf.comments = @[];
            }
            NSArray *list = result[@"data"][@"list"];
            NSMutableArray *mutComments = [NSMutableArray arrayWithArray:weakSelf.comments];
            for (NSDictionary *dic in list) {
                MUComment *model = [MUComment commentWithDic:dic];
                [mutComments addObject:model];
            }
            weakSelf.comments = [NSArray arrayWithArray:mutComments];
            [weakSelf.mainCollectionView.mj_header endRefreshing];
            if(list.count < 10) {
                [weakSelf.mainCollectionView.mj_footer endRefreshingWithNoMoreData];
            } else {
                [weakSelf.mainCollectionView.mj_footer endRefreshing];
            }
            [weakSelf.mainCollectionView reloadData];
        }
    } failed:^(NSError *error) {
        [weakSelf alertWithMsg:kFailedTips handler:nil];
    }];
}

#pragma mark - delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    switch (self.type) {
        case MUPCTYPECOLLECT:
            return self.collectExhibits.count;
            break;
        case MUPCTYPEFOOTPRINT:
            return self.footPrints.count;
            break;
        case MUPCTYPECOMMENT:
            return self.comments.count;
            break;
        default:
            return 0;
            break;
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (self.type) {
        case MUPCTYPECOLLECT: {
            MUMyPCCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MUMyPCCollectionViewCell" forIndexPath:indexPath];
            if (self.collectExhibits.count>indexPath.row) {
                if (self.chooseExhibition) {
                    [cell bindCellWithExhibitionModel:self.collectExhibits[indexPath.row]];//MUExhibitionModel
                }else{
                    [cell bindCellWithExhibitModel:self.collectExhibits[indexPath.row]];//MUExhibitModel
                }
            }
            
            return cell;
            break;
        }
        case MUPCTYPEFOOTPRINT: {
            MUMyPCCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MUMyPCCollectionViewCell" forIndexPath:indexPath];
            if (self.footPrints.count>indexPath.row) {
                if (self.chooseExhibition) {
                    [cell bindCellWithExhibitionModel:self.footPrints[indexPath.row]];
                }else{
                    [cell bindCellWithExhibitModel:self.footPrints[indexPath.row]];
                }
            }
            return cell;
            break;
        }
        case MUPCTYPECOMMENT: {//comment
            MUMyCommentCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MUMyCommentCollectionViewCell" forIndexPath:indexPath];
            [cell bindCellWithModel:self.comments[indexPath.row]];
            return cell;
            break;
        }
        default:
            return nil;
            break;
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    switch (self.type) {
        case MUPCTYPECOMMENT:{
            return UIEdgeInsetsMake(5, 0, 0, 0);
        }break;
        default:{
            return UIEdgeInsetsMake(5, 12, 0, 12);
        }break;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat width = (SCREEN_WIDTH-40)/2;
    
    switch (self.type) {
        case MUPCTYPECOMMENT:{
            MUComment *comment = self.comments[indexPath.row];
            return CGSizeMake(SCREEN_WIDTH, 160+[self cellHeightWithMsg:comment.content]);
        }break;
        default:
            if (self.chooseExhibition) {
                return CGSizeMake(width, width/16*9 +65);
            }else{
                return CGSizeMake(width, width/16*9 +85);
            }
            break;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
        switch (self.type) {
            case MUPCTYPECOLLECT: {
                
                if (self.collectExhibits.count>indexPath.row) {
                    id nonModel = self.collectExhibits[indexPath.row];
                    if (self.chooseExhibition) {
                        MUExhibitionModel *model = (MUExhibitionModel *)nonModel;
                        MUExhibitionDetailViewController *vc = [MUExhibitionDetailViewController new];
                        vc.exhibitionId = model.hallId;
                        [self.navigationController pushViewController:vc animated:YES];
                    }else{
                        MUExhibitModel *model = (MUExhibitModel *)nonModel;
                        MUExhibitDetailViewController *vc = [MUExhibitDetailViewController new];
                        vc.exhibitId = model.exhibitId;
                        [self.navigationController pushViewController:vc animated:YES];
                    }
                }
                break;
            }
            case MUPCTYPEFOOTPRINT: {
                if (self.footPrints.count>indexPath.row) {
                    id nonModel = self.footPrints[indexPath.row];
                    if (self.chooseExhibition) {
                        MUExhibitionModel *model = (MUExhibitionModel *)nonModel;
                        MUExhibitionDetailViewController *vc = [MUExhibitionDetailViewController new];
                        vc.exhibitionId = model.hallId;
                        [self.navigationController pushViewController:vc animated:YES];
                    }else{
                        MUExhibitModel *model = (MUExhibitModel *)nonModel;
                        MUExhibitDetailViewController *vc = [MUExhibitDetailViewController new];
                        vc.exhibitId = model.exhibitId;
                        [self.navigationController pushViewController:vc animated:YES];
                    }
                }
                break;
            }
            case MUPCTYPECOMMENT: {
                MUComment *comment = self.comments[indexPath.row];
                if (comment.type == MUCOMMENTTYPEEXHIBIT) {
                    MUExhibitDetailViewController *vc = [MUExhibitDetailViewController new];
                    vc.exhibitId = comment.exhibitId;
                    [self.navigationController pushViewController:vc animated:YES];
                }else if(comment.type == MUCOMMENTTYPEEXHIBITION) {
                    MUExhibitionDetailViewController *vc = [MUExhibitionDetailViewController new];
                    vc.exhibitionId = comment.exhibitId;
                    [self.navigationController pushViewController:vc animated:YES];
                }
                break;
            }
            default:
                break;
        }
}

#pragma mark -
- (void)didCollectClicked:(id)sender {
    self.type = MUPCTYPECOLLECT;
    [self reloadView];
}

- (void)didFootPrintClicked:(id)sender {
    self.type = MUPCTYPEFOOTPRINT;
    [self reloadView];
}

- (void)didCommentClicked:(id)sender {
    self.type = MUPCTYPECOMMENT;
    [self reloadView];
}

- (IBAction)exhibitionClick:(id)sender {
    self.chooseExhibition = YES;
    [self reloadView];
}
- (IBAction)hallClick:(id)sender {
    self.chooseExhibition = NO;
    [self reloadView];
}

- (IBAction)didReturnClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (CGFloat)cellHeightWithMsg:(NSString *)msg
{
    UILabel *label = [[UILabel alloc] init];
    label.text = msg;
    label.font = [UIFont systemFontOfSize:15];
    label.numberOfLines = 0;
    CGSize size = [label sizeThatFits:CGSizeMake(SCREEN_WIDTH-30, CGFLOAT_MAX)];
    return size.height;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
