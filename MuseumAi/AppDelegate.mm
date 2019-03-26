//
//  AppDelegate.m
//  MuseumAi
//
//  Created by Kingo on 2018/9/18.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "AppDelegate.h"
#import "WXApi.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <AVFoundation/AVFoundation.h>

#import "MULookViewController.h"
#import "MUScanViewController.h"
#import "MUShopViewController.h"
#import "MUMineViewController.h"
#import "MUStartViewController.h"
#import "MUActivityViewController.h"

typedef void(^LoginHandler)(NSString *errorMsg, NSDictionary *response);

@interface AppDelegate ()<BMKGeneralDelegate,BMKLocationAuthDelegate,WXApiDelegate, TencentSessionDelegate>
{
    BMKMapManager *_mapManager;
    UIBackgroundTaskIdentifier taskId;
}

/* 腾讯授权 */
@property(nonatomic, strong) TencentOAuth *tencentOAuth;
/* 登录后回调 */
@property(nonatomic, copy) LoginHandler handler;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
//    if (![easyar_Engine initialize:EasyARKey]) {
//        NSLog(@"Initialization Failed.");
//    }
    [self BaiduMapInit];
    BOOL registerWX = [WXApi registerApp:WEIXINKEY];
    if (registerWX) {
        NSLog(@"微信注册成功");
    } else {
        NSLog(@"微信注册失败");
    }
    
    _tencentOAuth = [[TencentOAuth alloc] initWithAppId:QQAppID andDelegate:self];
    
    self.window = [[UIWindow alloc]initWithFrame:SCREEN_BOUNDS];
//    [self tabBarInit];
    [self startInit];
    
    [self sysInit];
    [self setLaunchScreen];
    return YES;
}

- (void)sysInit {
    // 屏幕常亮
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    // 后台播放音频设置
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    /// FIXME: 调试清除
//    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"scan_guide"];
//    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"help_guide"];
//    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"guide_guide"];
//    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"exhibit_guide"];
#ifdef MUSimulatorTest
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"scan_guide"];
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"help_guide"];
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"guide_guide"];
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"exhibit_guide"];
#endif
}

- (void)setLaunchScreen {
//    NSArray *frames = [MUCustomUtils imagesFromGif:@"启动图"];
//
//    __block UIImageView *launchIV = [[UIImageView alloc]initWithFrame:SCREEN_BOUNDS];
//    launchIV.userInteractionEnabled = YES;
//
//    launchIV.animationImages = frames; // 将图片数组加入UIImageView动画数组中
//    launchIV.animationDuration = 3.0;  // 每次动画时长
//    [launchIV startAnimating];         // 开启动画
//
//    [[UIApplication sharedApplication].keyWindow addSubview:launchIV];
//    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:launchIV];
//
//    //3.2秒后自动关闭
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.2*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        if (launchIV) {
//            [UIView animateWithDuration:0.3 animations:^{
//                launchIV.alpha = 0;
//            } completion:^(BOOL finished) {
//                [launchIV removeFromSuperview];
//                launchIV = nil;
//            }];
//        }
//    });
}

- (void)startInit {
    MUStartViewController *vc = [MUStartViewController new];
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
}

- (void)toActivityPage:(NSURL *)url {
    MUActivityViewController *vc = [MUActivityViewController new];
    vc.url = url;
    self.window.rootViewController = vc;
    [self.window makeKeyWindow];
}

- (void)tabBarInit {
    // 看艺看
    MULookViewController *lookVC = [MULookViewController new];
    UINavigationController *lookNav = [[UINavigationController alloc]initWithRootViewController:lookVC];
    // 扫艺扫
    MUScanViewController *scanVC = [MUScanViewController new];
    UINavigationController *scanNav = [[UINavigationController alloc]initWithRootViewController:scanVC];
    // 购艺购
    MUShopViewController *shopVC = [MUShopViewController new];
    UINavigationController *shopNav = [[UINavigationController alloc]initWithRootViewController:shopVC];
    // 我的
    MUMineViewController *mineVC = [MUMineViewController new];
    UINavigationController *mineNav = [[UINavigationController alloc]initWithRootViewController:mineVC];
    
    UITabBarController *tabBar = [[UITabBarController alloc]init];
    tabBar.viewControllers = @[lookNav, scanNav, shopNav, mineNav];
    
    //未选中字体颜色
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:kUIColorFromRGB(0x7C7C7C),NSFontAttributeName:[UIFont systemFontOfSize:11.0f]} forState:UIControlStateNormal];
    //选中字体颜色
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:kMainColor,NSFontAttributeName:[UIFont systemFontOfSize:11.0f]} forState:UIControlStateSelected];
    
    [lookNav.tabBarItem setImage:[[UIImage imageNamed:@"看艺看"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [lookNav.tabBarItem setSelectedImage:[[UIImage imageNamed:@"看艺看选中"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [lookNav.tabBarItem setTitle:@"看艺看"];
    
    [scanNav.tabBarItem setImage:[[UIImage imageNamed:@"扫艺扫"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [scanNav.tabBarItem setSelectedImage:[[UIImage imageNamed:@"扫艺扫选中"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [scanNav.tabBarItem setTitle:@"扫艺扫"];
    
    [shopNav.tabBarItem setImage:[[UIImage imageNamed:@"购艺购"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [shopNav.tabBarItem setSelectedImage:[[UIImage imageNamed:@"购艺购选中"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [shopNav.tabBarItem setTitle:@"购艺购"];
    
    [mineNav.tabBarItem setImage:[[UIImage imageNamed:@"我的"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [mineNav.tabBarItem setSelectedImage:[[UIImage imageNamed:@"我的选中"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [mineNav.tabBarItem setTitle:@"我的"];
    
    tabBar.selectedIndex = 1;
    self.window.rootViewController = tabBar;
    [self.window makeKeyAndVisible];    
}

- (void)BaiduMapInit {
    // 初始化定位SDK
    [[BMKLocationAuth sharedInstance] checkPermisionWithKey:BaiduMapKey authDelegate:self];
    //要使用百度地图，请先启动BMKMapManager
    _mapManager = [[BMKMapManager alloc] init];
    
    /**
     百度地图SDK所有API均支持百度坐标（BD09）和国测局坐标（GCJ02），用此方法设置您使用的坐标类型.
     默认是BD09（BMK_COORDTYPE_BD09LL）坐标.
     如果需要使用GCJ02坐标，需要设置CoordinateType为：BMK_COORDTYPE_COMMON.
     */
    if ([BMKMapManager setCoordinateTypeUsedInBaiduMapSDK:BMK_COORDTYPE_BD09LL]) {
        NSLog(@"经纬度类型设置成功");
    } else {
        NSLog(@"经纬度类型设置失败");
    }
    
    //启动引擎并设置AK并设置delegate
    BOOL result = [_mapManager start:BaiduMapKey generalDelegate:self];
    if (!result) {
        NSLog(@"启动引擎失败");
    }
}

/**
 联网结果回调
 
 @param iError 联网结果错误码信息，0代表联网成功
 */
- (void)onGetNetworkState:(int)iError {
    if (0 == iError) {
        NSLog(@"联网成功");
    } else {
        NSLog(@"联网失败：%d", iError);
    }
}

/**
 鉴权结果回调
 
 @param iError 鉴权结果错误码信息，0代表鉴权成功
 */
- (void)onGetPermissionState:(int)iError {
    if (0 == iError) {
        NSLog(@"授权成功");
    } else {
        NSLog(@"授权失败：%d", iError);
    }
}
/*
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [WXApi handleOpenURL:url delegate:self];
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [WXApi handleOpenURL:url delegate:self];
}
*/
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    NSString *sourceApplication = options[@"UIApplicationOpenURLOptionsSourceApplicationKey"];
    NSLog(@"sourceApplication:%@",sourceApplication);
    if([sourceApplication containsString:@"com.tencent.xin"] ||
       [sourceApplication containsString:@"weixin"]) {
        return [WXApi handleOpenURL:url delegate:self];
    } else if ([sourceApplication containsString:@"tencent"] ||
               [sourceApplication containsString:@"qq"] ||
               [sourceApplication containsString:@"mqzone"] ||
               [sourceApplication containsString:@"mtt"]) {
        return [TencentOAuth HandleOpenURL:url];
    } else {
        return YES;
    }
}

#pragma mark 微信回调方法
- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        SendAuthResp *authResp = (SendAuthResp *)resp;
        if ([authResp.state isEqualToString:@"login"]) {
            NSString *code = authResp.code;
            [[NSNotificationCenter defaultCenter] postNotificationName:kWechatAuthorOKNotification object:code];
        }
    }
}
- (void)onReq:(BaseReq *)req {
    
}

#pragma mark ---- qq登录回调
- (void)loginByQQ:(void (^)(NSString *errorMsg, NSDictionary *response))handler {
    _handler = handler;
    [_tencentOAuth authorize:@[@"get_user_info",@"get_simple_userinfo",@"add_t"] inSafari:NO];
}
/**
 * 登录成功后的回调
 */
- (void)tencentDidLogin {
    NSLog(@"登录完成");
    if (_tencentOAuth.accessToken.length > 0) {
        BOOL result = [_tencentOAuth getUserInfo];
        if (!result) {
            if (self.handler) {
                self.handler(@"获取用户信息失败", nil);
            }
        }
    } else {
        if (self.handler) {
            self.handler(@"登录失败", nil);
        }
    }
    
}

- (void)getUserInfoResponse:(APIResponse*)response{
    
    NSString *openID = [_tencentOAuth getUserOpenID];
    NSString *imageUrl = response.jsonResponse[@"figureurl_qq"];
    NSString *sex = response.jsonResponse[@"gender"];
    NSString *nickname = response.jsonResponse[@"nickname"];
    NSDictionary *dic = @{
                          @"openID":openID,
                          @"image":imageUrl,
                          @"sex":sex,
                          @"nickname":nickname
                          };
    if (self.handler) {
        self.handler(nil, dic);
    }
}
/**
 * 登录失败后的回调
 * \param cancelled 代表用户是否主动退出登录
 */
- (void)tencentDidNotLogin:(BOOL)cancelled {
    if (cancelled) {
        if (self.handler) {
            self.handler(@"取消登录", nil);
        }
    } else {
        if (self.handler) {
            self.handler(@"非网络原因失败", nil);
        }
    }
}

/**
 * 登录时网络有问题的回调
 */
- (void)tencentDidNotNetWork {
    if (self.handler) {
        self.handler(@"请检查网络连接", nil);
    }
}



#pragma mark ----
- (void)applicationWillResignActive:(UIApplication *)application {
//    [easyar_Engine onPause];
    taskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:NULL];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[NSNotificationCenter defaultCenter] postNotificationName:kEnterBackgroundNotification object:self];
    
    __block UIBackgroundTaskIdentifier background_task;
    background_task = [application beginBackgroundTaskWithExpirationHandler:^ {
        [application endBackgroundTask: background_task];
        background_task = UIBackgroundTaskInvalid;
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while(TRUE)
        {
            [NSThread sleepForTimeInterval:1];
            
            //编写执行任务代码
            
        }
        
        [application endBackgroundTask: background_task];
        background_task = UIBackgroundTaskInvalid;
    });
    
#ifndef MUSimulatorTest
    if (self.glResourceHandler) {
        // Delete OpenGL resources (e.g. framebuffer) of the SampleApp AR View
        [self.glResourceHandler freeOpenGLESResources];
        [self.glResourceHandler finishOpenGLESCommands];
    }
#endif
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[NSNotificationCenter defaultCenter] postNotificationName:kEnterForegroundNotification object:self];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
//    [easyar_Engine onResume];
    [[UIApplication sharedApplication] endBackgroundTask:taskId];
}


- (void)applicationWillTerminate:(UIApplication *)application {

}


@end
