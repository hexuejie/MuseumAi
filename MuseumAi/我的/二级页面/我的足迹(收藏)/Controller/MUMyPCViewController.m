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
#import "MUExhibitDetailViewController.h"
#import "MUExhibitionDetailViewController.h"
#import "MJRefresh.h"

#define SPACE 10.0f

@interface MUMyPCViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;


@property (weak, nonatomic) IBOutlet UIButton *returnBt;

@property (weak, nonatomic) IBOutlet UIImageView *titleImageView;

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;

@property (weak, nonatomic) IBOutlet UILabel *nickNameLb;


@property (weak, nonatomic) IBOutlet UILabel *collectLb;
@property (weak, nonatomic) IBOutlet UIView *collectIndicator;
@property (weak, nonatomic) IBOutlet UIView *collectBgView;

@property (weak, nonatomic) IBOutlet UILabel *footprintLb;
@property (weak, nonatomic) IBOutlet UIView *footprintIndicator;
@property (weak, nonatomic) IBOutlet UIView *footprintBgView;

@property (weak, nonatomic) IBOutlet UILabel *commentLb;
@property (weak, nonatomic) IBOutlet UIView *commentIndicator;
@property (weak, nonatomic) IBOutlet UIView *commentBgView;

@property (weak, nonatomic) IBOutlet UITableView *listTableView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleWIdthConstraint;


/** 收藏列表 */
@property (strong, nonatomic) NSArray<MUExhibitModel *> *collectExhibits;
/** 足迹列表 */
@property (strong, nonatomic) NSArray<MUExhibitModel *> *footPrints;
/** 评论 */
@property (strong, nonatomic) NSArray<MUComment *> *comments;
/** 评论页数 */
@property (assign, nonatomic) NSInteger commentPage;

@end

@implementation MUMyPCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self dataInit];
    
    [self viewInit];
    
}

- (void)viewInit {
    
    self.topConstraint.constant = SafeAreaTopHeight-44.0f;
    self.bottomConstraint.constant = SafeAreaBottomHeight;
    
    [self.returnBt setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    
    self.titleImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.titleImageView.layer.masksToBounds = YES;
    
    self.userImageView.layer.masksToBounds = YES;
    self.userImageView.layer.cornerRadius = 22.0f;
    self.titleImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.userImageView sd_setImageWithURL:[NSURL URLWithString:[MUUserModel currentUser].photo]];
    
    self.nickNameLb.text = [MUUserModel currentUser].nikeName;
    
    [self.collectBgView addTapTarget:self action:@selector(didCollectClicked:)];
    [self.footprintBgView addTapTarget:self action:@selector(didFootPrintClicked:)];
    [self.commentBgView addTapTarget:self action:@selector(didCommentClicked:)];
    self.titleWIdthConstraint.constant = SCREEN_WIDTH/3.0f;
    
    self.listTableView.tableFooterView = [UIView new];
    [self.listTableView registerNib:[UINib nibWithNibName:@"MUMyCommentCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MUMyCommentCell"];
    [self.listTableView registerNib:[UINib nibWithNibName:@"MUMyPCTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MUMyPCTableViewCell"];
    
    [self reloadView];
}

- (void)dataInit {
    __weak typeof (self) weakSelf = self;
    self.listTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        weakSelf.commentPage = 1;
        [weakSelf.listTableView.mj_footer resetNoMoreData];
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
    self.listTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        weakSelf.commentPage++;
        [weakSelf refreshComments];
    }];
}

- (void)reloadView {
    
    if (self.type == MUPCTYPECOLLECT) {
        self.collectLb.textColor = kMainColor;
        self.collectIndicator.hidden = NO;
        self.footprintLb.textColor = kUIColorFromRGB(0x333333);
        self.footprintIndicator.hidden = YES;
        self.commentLb.textColor = kUIColorFromRGB(0x333333);
        self.commentIndicator.hidden = YES;
    }else if(self.type == MUPCTYPEFOOTPRINT){
        self.collectLb.textColor = kUIColorFromRGB(0x333333);
        self.collectIndicator.hidden = YES;
        self.footprintLb.textColor = kMainColor;
        self.footprintIndicator.hidden = NO;
        self.commentLb.textColor = kUIColorFromRGB(0x333333);
        self.commentIndicator.hidden = YES;
    }else {
        self.collectLb.textColor = kUIColorFromRGB(0x333333);
        self.collectIndicator.hidden = YES;
        self.footprintLb.textColor = kUIColorFromRGB(0x333333);
        self.footprintIndicator.hidden = YES;
        self.commentLb.textColor = kMainColor;
        self.commentIndicator.hidden = NO;
    }
    
    [self.listTableView.mj_header beginRefreshing];
}

- (void)refreshFootprints {
    __weak typeof(self) weakSelf = self;
    [MUHttpDataAccess getFootPrintSuccess:^(id result) {
        weakSelf.footPrints = @[];
        [weakSelf.listTableView.mj_header endRefreshing];
        [weakSelf.listTableView.mj_footer endRefreshingWithNoMoreData];
        if ([result[@"state"]integerValue] == 10001) {
            NSMutableArray *array = [NSMutableArray array];
            for (NSDictionary *dic in result[@"data"]) {
                MUExhibitModel *exhibit = [MUExhibitModel exhibitWithDic:dic];
                [array addObject:exhibit];
            }
            weakSelf.footPrints = [NSArray arrayWithArray:array];
            [weakSelf.listTableView reloadData];
        }else {
            weakSelf.footPrints = [NSArray array];
            [weakSelf.listTableView reloadData];
        }
    } failed:^(NSError *error) {
        [weakSelf alertWithMsg:kFailedTips handler:nil];
    }];
}

- (void)refreshCollections {
    __weak typeof(self) weakSelf = self;
    [MUHttpDataAccess getCollectListSuccess:^(id result) {
        weakSelf.collectExhibits = @[];
        [weakSelf.listTableView.mj_header endRefreshing];
        [weakSelf.listTableView.mj_footer endRefreshingWithNoMoreData];
        if ([result[@"state"]integerValue] == 10001) {
            NSMutableArray *array = [NSMutableArray array];
            for (NSDictionary *dic in result[@"data"]) {
                MUExhibitModel *exhibit = [MUExhibitModel exhibitWithDic:dic];
                [array addObject:exhibit];
            }
            weakSelf.collectExhibits = [NSArray arrayWithArray:array];
            [weakSelf.listTableView reloadData];
        }else {
            weakSelf.collectExhibits = [NSArray array];
            [weakSelf.listTableView reloadData];
        }
    } failed:^(NSError *error) {
        [weakSelf alertWithMsg:kFailedTips handler:nil];
    }];
}

- (void)refreshComments {
    __weak typeof(self) weakSelf = self;
    [MUHttpDataAccess getMyCommentListWithPage:self.commentPage success:^(id result) {
        if ([result[@"state"]integerValue] == 10001) {
            if([weakSelf.listTableView.mj_header isRefreshing]) {
                weakSelf.comments = @[];
            }
            NSArray *list = result[@"data"][@"list"];
            NSMutableArray *mutComments = [NSMutableArray arrayWithArray:weakSelf.comments];
            for (NSDictionary *dic in list) {
                MUComment *model = [MUComment commentWithDic:dic];
                [mutComments addObject:model];
            }
            weakSelf.comments = [NSArray arrayWithArray:mutComments];
            [weakSelf.listTableView.mj_header endRefreshing];
            if(list.count < 10) {
                [weakSelf.listTableView.mj_footer endRefreshingWithNoMoreData];
            } else {
                [weakSelf.listTableView.mj_footer endRefreshing];
            }
            [weakSelf.listTableView reloadData];
        }
    } failed:^(NSError *error) {
        [weakSelf alertWithMsg:kFailedTips handler:nil];
    }];
}

#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (self.type) {
        case MUPCTYPECOLLECT: {
            MUMyPCTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MUMyPCTableViewCell"];
            [cell bindCellWithExhibitModel:self.collectExhibits[indexPath.row]];
            return cell;
            break;
        }
        case MUPCTYPEFOOTPRINT: {
            MUMyPCTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MUMyPCTableViewCell"];
            [cell bindCellWithExhibitModel:self.footPrints[indexPath.row]];
            return cell;
            break;
        }
        case MUPCTYPECOMMENT: {
            MUMyCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MUMyCommentCell"];
            [cell bindCellWithModel:self.comments[indexPath.row]];
            return cell;
            break;
        }
        default:
            return nil;
            break;
    }
    
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (self.type) {
        case MUPCTYPECOLLECT: {
            MUExhibitModel *exhibit = self.collectExhibits[indexPath.item];
            MUExhibitDetailViewController *vc = [MUExhibitDetailViewController new];
            vc.exhibitId = exhibit.exhibitId;
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case MUPCTYPEFOOTPRINT: {
            MUExhibitModel *exhibit = self.footPrints[indexPath.item];
            MUExhibitDetailViewController *vc = [MUExhibitDetailViewController new];
            vc.exhibitId = exhibit.exhibitId;
            [self.navigationController pushViewController:vc animated:YES];
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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (self.type) {
        case MUPCTYPECOMMENT:
            return UITableViewAutomaticDimension;
            break;
        default:
            return 100.0f;
            break;
    }
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120.0f;
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

- (IBAction)didReturnClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
