//
//  MUShopViewController.m
//  MuseumAi
//
//  Created by Kingo on 2018/9/18.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUShopViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>

#define SHOPWEBURL @"https://www.airart.com.cn/museumai/#/shopping"

@protocol PICBridgeExport <JSExport>
JSExportAs(jsTaobao, -(void)jsTaobao:(NSString *)link);
@end
@interface PICBridge : NSObject<PICBridgeExport>
@property(nonatomic,weak) id<PICBridgeExport> delegate;
@end
@implementation PICBridge
- (void)jsTaobao:(NSString *)link {
    [self.delegate jsTaobao:link];
}
@end

@interface MUShopViewController ()<UIWebViewDelegate, PICBridgeExport>
/** 嵌套网页 */
@property (nonatomic , strong) UIWebView *shopWebView;
/** 桥接 */
@property (nonatomic , strong) PICBridge *bridge;
@end

@implementation MUShopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.shopWebView = [[UIWebView alloc]initWithFrame:SCREEN_BOUNDS];
    [self.view addSubview:self.shopWebView];
    self.shopWebView.delegate = self;
    
    self.bridge =[[PICBridge alloc] init];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
    [self.shopWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:SHOPWEBURL]]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.shopWebView stopLoading];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"URL:%@",request.URL.absoluteString);
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    JSContext *context=[webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    PICBridge *jsObject = [PICBridge new];
    jsObject.delegate = self;
    context[@"Android"] = jsObject;
    
}

- (void)jsTaobao:(NSString *)link {
    NSLog(@"link:%@",link);
    NSURL *url = [NSURL URLWithString:link];
    if (url != nil) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
