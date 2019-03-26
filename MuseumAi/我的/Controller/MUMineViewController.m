//
//  MUMineViewController.m
//  MuseumAi
//
//  Created by Kingo on 2018/9/18.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUMineViewController.h"
#import "UIImageView+WebCache.h"
#import "MUMyPCViewController.h"
#import "MUFeedBackViewController.h"
#import "MUAboutUsViewController.h"
#import "MUForgetPwdViewController.h"
#import "MUUserInfoViewController.h"

#import "MUARUtils.h"

#import "MUMineIconCell.h"
#import "MUMineOperationCell.h"
#import "MUMineInfoCell.h"

@interface MUMineViewController ()

@property (weak, nonatomic) IBOutlet UIView *headerBackGround;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *VIPLabel;

@property (weak, nonatomic) IBOutlet UIButton *collectButton;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIButton *footPrintButton;

@property (weak, nonatomic) IBOutlet UILabel *cacheLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerCenterName;//-10

@end

@implementation MUMineViewController



- (void)viewDidLoad {
    [super viewDidLoad];

    self.headerBackGround.layer.cornerRadius = 10.0;
    self.headerBackGround.layer.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.09].CGColor;//0.05
    self.headerBackGround.layer.shadowOpacity = 10;
    self.headerBackGround.layer.shadowOffset = CGSizeMake(0, 10);;
    self.headerBackGround.layer.shadowRadius = 10;
    self.headerBackGround.layer.shouldRasterize = NO;
    self.headerBackGround.layer.shadowPath = [[UIBezierPath bezierPathWithRoundedRect:[self.headerBackGround bounds] cornerRadius:10] CGPath];
    self.headerBackGround.layer.masksToBounds = NO;
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
    [self reloadUserInfo];
    [self customReloadViews];
}

- (void)reloadUserInfo {
    __weak typeof(self) weakSelf = self;
    [MUHttpDataAccess getUserInfoSuccess:^(id result) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        if ([result[@"state"]integerValue] == 10001) {
            [self.collectButton setTitle:[NSString stringWithFormat:@"%@",result[@"data"][@"userCollectionCount"]] forState:UIControlStateNormal];
            [self.commentButton setTitle:[NSString stringWithFormat:@"%@",result[@"data"][@"userCommentCount"]] forState:UIControlStateNormal];
            [self.footPrintButton setTitle:[NSString stringWithFormat:@"%@",result[@"data"][@"userFootCount"]] forState:UIControlStateNormal];
        }
    } failed:^(NSError *error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf alertWithMsg:kFailedTips handler:nil];
    }];
    
    NSInteger fileSize = [MUARUtils catchesSize];
    self.cacheLabel.text = [NSString stringWithFormat:@"%.2fM",fileSize/1024.0f/1024.0f];
}

- (void)customReloadViews{
        MUUserModel *user = [MUUserModel currentUser];
    if (user.isLogin) {
        [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:user.photo]];
        self.VIPLabel.text = [NSString stringWithFormat:@"Lv.%@",user.vipGrade];
        self.nameLabel.text = [NSString stringWithFormat:@"%@",user.nikeName];
        self.headerCenterName.constant = -10;
        self.VIPLabel.hidden = NO;
    }else {
        self.headerImageView.image = [UIImage imageNamed:@"默认图像"];
        self.VIPLabel.text = @"level1";
        self.nameLabel.text = @"未登陆";
        self.headerCenterName.constant = 0;
        self.VIPLabel.hidden = YES;
        
    }
}

//#pragma mark -
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 3;
//}
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    switch (section) {
//        case 0:
//            return 1;
//            break;
//        case 1:
//            return [self operationTitles].count;
//            break;
//        case 2:
//            return [self infoTitles].count;
//            break;
//        default:
//            return 0;
//            break;
//    }
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    MUUserModel *user = [MUUserModel currentUser];
//    switch (indexPath.section) {
//        case 0: {
//            MUMineIconCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MUMineIconCell"];
//            if (user.isLogin) {
//                [cell.iconImageView sd_setImageWithURL:[NSURL URLWithString:user.photo]];
//                cell.levelLb.text = [NSString stringWithFormat:@"level%@",user.vipGrade];
//                cell.nameLb.text = [NSString stringWithFormat:@"%@",user.nikeName];
//            }else {
//                cell.iconImageView.image = [UIImage imageNamed:@"默认图像"];
//                cell.levelLb.text = @"level1";
//                cell.nameLb.text = @"未登陆";
//            }
//            return cell;
//            break;
//        }
//        case 1: {
//            MUMineOperationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MUMineOperationCell"];
//            cell.operationImageView.image = [UIImage imageNamed:[self operationImages][indexPath.row]];
//            cell.operationLb.text = [self operationTitles][indexPath.row];
//            return cell;
//            break;
//        }
//        case 2: {
//            MUMineInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MUMineInfoCell"];
//            cell.operationLb.text = [self infoTitles][indexPath.row];
//            return cell;
//            break;
//        }
//        default:
//            break;
//    }
//    return nil;
//}
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//
//    switch (indexPath.section) {
//        case 0:
//            [self modifyMineInfo];
//            break;
//        case 1:
//            switch (indexPath.row) {
//                case 0:
//                    [self toMyFootPrint];
//                    break;
//                case 1:
//                    [self toMyCollect];
//                    break;
//                case 2:
//                    [self toMyComment];
//                    break;
//                default:
//                    break;
//            }
//            break;
//        case 2:
//            switch (indexPath.row) {
//                case 0:
//                    [self clearCaches];
//                    break;
//                case 1:
//                    [self toFeedBack];
//                    break;
//                case 2:
//                    [self aboutUs];
//                    break;
//                case 3:
//                    [self modifyPwd];
//                    break;
//                case 4:
//                    [self logout];
//                    break;
//                default:
//                    break;
//            }
//            break;
//
//        default:
//            break;
//    }
//
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.section == 0) {
//        return 84.0f;
//    }
//    return 44.0f;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    switch (section) {
//        case 0:
//            return 0;
//            break;
//        default:
//            return 10.0f;
//            break;
//    }
//}

#pragma mark ---- 操作我的界面

- (IBAction)modifyMineInfo:(id)sender {
    // 修改个人信息
    if ([MUUserModel currentUser].isLogin) {
        MUUserInfoViewController *vc = [MUUserInfoViewController new];
        [self.navigationController pushViewController:vc animated:YES];
    }else {
        MULoginViewController *loginVC = [MULoginViewController new];
        [self.navigationController pushViewController:loginVC animated:YES];
    }
}

- (IBAction)toMyFootPrint:(id)sender {
    // 我的足迹
    if ([MUUserModel currentUser].isLogin) {
        MUMyPCViewController *vc = [MUMyPCViewController new];
        vc.type = MUPCTYPEFOOTPRINT;
        [self.navigationController pushViewController:vc animated:YES];
    }else {
        MULoginViewController *loginVC = [MULoginViewController new];
        [self.navigationController pushViewController:loginVC animated:YES];
    }
}
- (IBAction)toMyCollect:(id)sender {

    // 我的收藏
    if ([MUUserModel currentUser].isLogin) {
        MUMyPCViewController *vc = [MUMyPCViewController new];
        vc.type = MUPCTYPECOLLECT;
        [self.navigationController pushViewController:vc animated:YES];
    }else {
        MULoginViewController *loginVC = [MULoginViewController new];
        [self.navigationController pushViewController:loginVC animated:YES];
    }
}
- (IBAction)toMyComment:(id)sender {
    // 我的评论
    if ([MUUserModel currentUser].isLogin) {
        MUMyPCViewController *vc = [MUMyPCViewController new];
        vc.type = MUPCTYPECOMMENT;
        [self.navigationController pushViewController:vc animated:YES];
    }else {
        MULoginViewController *loginVC = [MULoginViewController new];
        [self.navigationController pushViewController:loginVC animated:YES];
    }
}
- (IBAction)clearCaches:(id)sender {
    // 清除缓存
    __weak typeof(self) weakSelf = self;
    [self alertWithMsg:@"是否清除缓存？" okHandler:^{
        NSArray *hallIDs = [MUARUtils arHallIDs];
        [MUARUtils clearCatches:^(BOOL success, NSString * _Nonnull reason) {
            if (success) {
                for (NSString *fileName in hallIDs) {
                    NSString *updateKey = [NSString stringWithFormat:@"%@_fileDate",fileName];
                    if ([[NSUserDefaults standardUserDefaults]objectForKey:updateKey] != nil) {
                        [[NSUserDefaults standardUserDefaults] setObject:@(-1) forKey:updateKey];
                    }
                }
                NSInteger fileSize = [MUARUtils catchesSize];
                weakSelf.cacheLabel.text = [NSString stringWithFormat:@"%.2fM",fileSize/1024.0f/1024.0f];
            }
            [weakSelf alertWithMsg:reason handler:nil];
        }];
    }];
}


- (IBAction)toFeedBack:(id)sender {
    // 用户反馈
    if ([MUUserModel currentUser].isLogin) {
        MUFeedBackViewController *vc = [MUFeedBackViewController new];
        [self.navigationController pushViewController:vc animated:YES];
    }else {
        MULoginViewController *loginVC = [MULoginViewController new];
        [self.navigationController pushViewController:loginVC animated:YES];
    }
}

- (IBAction)aboutUs:(id)sender {
    // 关于我们
    MUAboutUsViewController *vc = [MUAboutUsViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)modifyPwd:(id)sender {
    // 修改密码
    if ([MUUserModel currentUser].isLogin) {
        MUForgetPwdViewController *vc = [MUForgetPwdViewController new];
        [self.navigationController pushViewController:vc animated:YES];
    }else {
        MULoginViewController *loginVC = [MULoginViewController new];
        [self.navigationController pushViewController:loginVC animated:YES];
    }
}

- (IBAction)logout:(id)sender {
    // 退出登陆
    __weak typeof(self) weakSelf = self;
    [self alertWithMsg:@"确认要退出登录吗？" okHandler:^{
        [[MUUserModel currentUser] clearDataByLogout];
        [self customReloadViews];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
