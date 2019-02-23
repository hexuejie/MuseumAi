//
//  MUHotGuideViewController.m
//  MuseumAi
//
//  Created by Kingo on 2018/11/12.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUHotGuideViewController.h"

@interface MUHotGuideViewController ()<UIWebViewDelegate>

/** 嵌套网页 */
@property (nonatomic , strong) UIWebView *exhibitionWebView;
/** 返回按钮 */
@property (nonatomic , strong) UIButton *backButton;

@end

@implementation MUHotGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.exhibitionWebView = [[UIWebView alloc]initWithFrame:SCREEN_BOUNDS];
    [self.view addSubview:self.exhibitionWebView];
    self.exhibitionWebView.delegate = self;
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:self.backButton];
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10.0f);
        make.top.mas_equalTo(20.0f);
        make.width.height.mas_equalTo(40.0f);
    }];
    [self.backButton setImage:[UIImage imageNamed:@"视频返回"] forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(didBackButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view bringSubviewToFront:self.backButton];
    
}

- (void)loadData {
    if (self.url != nil) {
        [self.exhibitionWebView loadRequest:[NSURLRequest requestWithURL:self.url]];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [[MUMapHandler getInstance]fetchPositionAsyn:^(CLLocation *location, BMKLocationReGeocode *regeo) {
        [MUHttpDataAccess getExhibitionsWithLong:location.coordinate.longitude
                                             lat:location.coordinate.latitude
                                            page:1
                                           state:MUEXHIBITIONTYPEDEFAULT
                                  exhibitionName:@""
                                    exhibitionId:self.exhibitionId success:^(id result) {
                                        
                                        if ([result[@"state"]integerValue] == 10001) {
                                            NSString *urlStr = [result[@"data"][@"list"] firstObject][@"vrUrl"];
                                            weakSelf.url = [NSURL URLWithString:urlStr];
                                            [weakSelf.exhibitionWebView loadRequest:[NSURLRequest requestWithURL:weakSelf.url]];
                                        }else {
                                            [weakSelf alertWithMsg:result[@"msg"] handler:nil];
                                        }
                                        
                                    } failed:^(NSError *error) {
                                        [weakSelf alertWithMsg:kFailedTips handler:nil];
                                    }];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
    [self loadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.exhibitionWebView stopLoading];
    [MBProgressHUD hideHUDForView:self.exhibitionWebView animated:YES];
}

- (void)didBackButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [MBProgressHUD showHUDAddedTo:self.exhibitionWebView animated:YES];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [MBProgressHUD hideHUDForView:self.exhibitionWebView animated:YES];
}
@end
