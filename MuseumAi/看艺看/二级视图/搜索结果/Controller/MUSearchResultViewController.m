//
//  MUSearchResultViewController.m
//  MuseumAi
//
//  Created by 魏宙辉 on 2018/9/20.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUSearchResultViewController.h"
#import "MUMapHandler.h"
#import "MUExhibitionTableCell.h"
#import "MJRefresh.h"
#import "MUExhibitionDetailViewController.h"

@interface MUSearchResultViewController ()<UITableViewDelegate, UITableViewDataSource>


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;

@property (weak, nonatomic) IBOutlet UIButton *returnBt;

@property (weak, nonatomic) IBOutlet UITableView *resultTbView;


/** 页数 */
@property (assign, nonatomic) NSInteger page;
/** 展览列表 */
@property (strong, nonatomic) NSArray *exhibitions;

@end

@implementation MUSearchResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self viewInit];
    
    [self dataInit];
}

- (void)viewInit {
    
    self.topConstraint.constant = SafeAreaTopHeight-44.0f;
    self.navHeight.constant = SafeAreaTopHeight;
    [self.returnBt setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    
    self.resultTbView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.resultTbView.tableFooterView = [UIView new];
    [self.resultTbView registerNib:[UINib nibWithNibName:@"MUExhibitionTableCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MUExhibitionTableCell"];
    
    __weak typeof (self) weakSelf = self;
    
    self.resultTbView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        weakSelf.page = 1;
        [weakSelf.resultTbView.mj_footer resetNoMoreData];
        [weakSelf reloadData];
    }];
    self.resultTbView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        weakSelf.page++;
        [weakSelf reloadData];
    }];
}

- (void)reloadData {
    __weak typeof(self) weakSelf = self;
    [[MUMapHandler getInstance]fetchPositionAsyn:^(CLLocation *location, BMKLocationReGeocode *regeo) {
        [MUHttpDataAccess getExhibitionsWithLong:location.coordinate.longitude
                                             lat:location.coordinate.latitude
                                            page:self.page
                                           state:0
                                  exhibitionName:self.searchStr
                                    exhibitionId:@"" success:^(id result) {
                                        if([weakSelf.resultTbView.mj_header isRefreshing]) {
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
                                            [weakSelf.resultTbView reloadData];
                                            [weakSelf.resultTbView.mj_header endRefreshing];
                                            if(list.count < 10) {
                                                [weakSelf.resultTbView.mj_footer endRefreshingWithNoMoreData];
                                            } else {
                                                [weakSelf.resultTbView.mj_footer endRefreshing];
                                            }
                                        } else {
                                            [weakSelf.resultTbView.mj_header endRefreshing];
                                            [weakSelf.resultTbView.mj_footer endRefreshing];
                                        }
                                    } failed:^(NSError *error) {
                                        [weakSelf.resultTbView.mj_header endRefreshing];
                                        [weakSelf alertWithMsg:kFailedTips handler:nil];
                                    }];
    }];
}

- (void)dataInit {
    [self reloadData];
}

#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.exhibitions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MUExhibitionModel *model = self.exhibitions[indexPath.row];
    MUExhibitionTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MUExhibitionTableCell"];
    [cell bindCellWithExhibition:model];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 114.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MUExhibitionModel *model = self.exhibitions[indexPath.row];
    MUExhibitionDetailViewController *vc = [MUExhibitionDetailViewController new];
    vc.exhibitionId = model.hallId;
    [self.navigationController pushViewController:vc animated:YES];
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
