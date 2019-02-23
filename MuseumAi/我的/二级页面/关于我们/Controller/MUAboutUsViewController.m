//
//  MUAboutUsViewController.m
//  MuseumAi
//
//  Created by Kingo on 2018/9/26.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUAboutUsViewController.h"

@interface MUAboutUsViewController ()


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;

@property (weak, nonatomic) IBOutlet UIButton *returnBt;

@end

@implementation MUAboutUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.topConstraint.constant = SafeAreaTopHeight-44.0f;
    [self.returnBt setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
}

- (IBAction)didReturnClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)shareApp:(id)sender {
    NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/cn/app/museumai/id1439194328?mt=8"];
    UIImage *image = [UIImage imageNamed:@"loginLogo"];
    UIActivityViewController *vc = [MUCustomUtils shareWeixinWithText:@"museumai" content:@"" image:image url:url];
    [self presentViewController:vc animated:YES completion:nil];
    __weak typeof(self) weakSelf = self;
    [vc setCompletionWithItemsHandler:^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
        if (completed) {
            [weakSelf alertWithMsg:@"分享成功" handler:nil];
        }else {
            [weakSelf alertWithMsg:@"已取消分享" handler:nil];
        }
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
