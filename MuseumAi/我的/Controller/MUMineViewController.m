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
#import "MUChangedPwdViewController.h"
#import "MUUserInfoViewController.h"

#import "MUMineIconCell.h"
#import "MUMineOperationCell.h"
#import "MUMineInfoCell.h"

@interface MUMineViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@property (weak, nonatomic) IBOutlet UITableView *mineTableView;

@end

@implementation MUMineViewController

- (NSArray *)operationTitles {
    return @[@"足迹",@"收藏",@"我的评论"];
}

- (NSArray *)operationImages {
    return @[@"足迹",@"收藏",@"评论_on"];
}

- (NSArray *)infoTitles {
    if([MUUserModel currentUser].isLogin) {
        return @[@"清除缓存",@"用户反馈",@"关于我们",@"修改密码",@"退出登陆"];
    } else {
        return @[@"清除缓存",@"用户反馈",@"关于我们",@"修改密码"];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self viewInit];
    
    [self dataInit];
}

#pragma mark -

- (void)viewInit {
    
    self.topConstraint.constant = SafeAreaTopHeight-44.0f;
    self.bottomConstraint.constant = SafeAreaBottomHeight;
    
    self.mineTableView.tableFooterView = [UIView new];
    [self.mineTableView registerNib:[UINib nibWithNibName:@"MUMineIconCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MUMineIconCell"];
    [self.mineTableView registerNib:[UINib nibWithNibName:@"MUMineOperationCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MUMineOperationCell"];
    [self.mineTableView registerNib:[UINib nibWithNibName:@"MUMineInfoCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MUMineInfoCell"];
}

- (void)dataInit {
    
    [self.mineTableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
    [self.mineTableView reloadData];
}

#pragma mark -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return [self operationTitles].count;
            break;
        case 2:
            return [self infoTitles].count;
            break;
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MUUserModel *user = [MUUserModel currentUser];
    switch (indexPath.section) {
        case 0: {
            MUMineIconCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MUMineIconCell"];
            if (user.isLogin) {
                [cell.iconImageView sd_setImageWithURL:[NSURL URLWithString:user.photo]];
                cell.levelLb.text = [NSString stringWithFormat:@"level%@",user.vipGrade];
                cell.nameLb.text = [NSString stringWithFormat:@"%@",user.nikeName];
            }else {
                cell.iconImageView.image = [UIImage imageNamed:@"默认图像"];
                cell.levelLb.text = @"level1";
                cell.nameLb.text = @"未登陆";
            }
            return cell;
            break;
        }
        case 1: {
            MUMineOperationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MUMineOperationCell"];
            cell.operationImageView.image = [UIImage imageNamed:[self operationImages][indexPath.row]];
            cell.operationLb.text = [self operationTitles][indexPath.row];
            return cell;
            break;
        }
        case 2: {
            MUMineInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MUMineInfoCell"];
            cell.operationLb.text = [self infoTitles][indexPath.row];
            return cell;
            break;
        }
        default:
            break;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 0:
            [self modifyMineInfo];
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    [self toMyFootPrint];
                    break;
                case 1:
                    [self toMyCollect];
                    break;
                case 2:
                    [self toMyComment];
                    break;
                default:
                    break;
            }
            break;
        case 2:
            switch (indexPath.row) {
                case 0:
                    [self clearCaches];
                    break;
                case 1:
                    [self toFeedBack];
                    break;
                case 2:
                    [self aboutUs];
                    break;
                case 3:
                    [self modifyPwd];
                    break;
                case 4:
                    [self logout];
                    break;
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 84.0f;
    }
    return 44.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 0;
            break;
        default:
            return 10.0f;
            break;
    }
}

#pragma mark ---- 操作我的界面
- (void)modifyMineInfo {
    // 修改个人信息
    if ([MUUserModel currentUser].isLogin) {
        MUUserInfoViewController *vc = [MUUserInfoViewController new];
        [self.navigationController pushViewController:vc animated:YES];
    }else {
        MULoginViewController *loginVC = [MULoginViewController new];
        [self.navigationController pushViewController:loginVC animated:YES];
    }
}
- (void)toMyFootPrint {
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
- (void)toMyCollect {
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
- (void)toMyComment {
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
- (void)clearCaches {
    // 清除缓存
    __weak typeof(self) weakSelf = self;
    [self alertWithMsg:@"是否清除缓存？" okHandler:^{
        NSString *cachePath = [NSString stringWithFormat:@"%@/Library/Caches/",NSHomeDirectory()];
        NSArray *fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cachePath error:nil];
        if (fileList.count > 0) {
            for (NSString *fileName in fileList) {
                NSString *filePath = [NSString stringWithFormat:@"%@%@",cachePath,fileName];
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
                NSString *updateKey = [NSString stringWithFormat:@"%@_fileDate",fileName];
                if ([[NSUserDefaults standardUserDefaults]objectForKey:updateKey] != nil) {
                    [[NSUserDefaults standardUserDefaults] setObject:@(-1) forKey:updateKey];
                }
            }
            [weakSelf alertWithMsg:@"已清除缓存" handler:nil];
        }else {
            [weakSelf alertWithMsg:@"缓存为空" handler:nil];
        }
    }];
}

- (void)toFeedBack {
    // 用户反馈
    if ([MUUserModel currentUser].isLogin) {
        MUFeedBackViewController *vc = [MUFeedBackViewController new];
        [self.navigationController pushViewController:vc animated:YES];
    }else {
        MULoginViewController *loginVC = [MULoginViewController new];
        [self.navigationController pushViewController:loginVC animated:YES];
    }
}
- (void)aboutUs {
    // 关于我们
    MUAboutUsViewController *vc = [MUAboutUsViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)modifyPwd {
    // 修改密码
    if ([MUUserModel currentUser].isLogin) {
        MUChangedPwdViewController *vc = [MUChangedPwdViewController new];
        [self.navigationController pushViewController:vc animated:YES];
    }else {
        MULoginViewController *loginVC = [MULoginViewController new];
        [self.navigationController pushViewController:loginVC animated:YES];
    }
}
- (void)logout {
    // 退出登陆
    __weak typeof(self) weakSelf = self;
    [self alertWithMsg:@"确认要退出登录吗？" okHandler:^{
        [[MUUserModel currentUser] clearDataByLogout];
        [weakSelf.mineTableView reloadData];
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
