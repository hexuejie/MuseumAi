//
//  MUActivityViewController.m
//  MuseumAi
//
//  Created by Kingo on 2018/11/21.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUActivityViewController.h"
#import "AppDelegate.h"

@interface MUActivityViewController ()<UIWebViewDelegate>

/** 嵌套网页 */
@property (nonatomic , strong) UIWebView *exhibitionWebView;
/** 返回按钮 */
@property (nonatomic , strong) UIButton *backButton;

@end

@implementation MUActivityViewController


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
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate tabBarInit];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [MBProgressHUD showHUDAddedTo:self.exhibitionWebView animated:YES];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [MBProgressHUD hideHUDForView:self.exhibitionWebView animated:YES];
}

@end
