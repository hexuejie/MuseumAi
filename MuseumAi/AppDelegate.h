//
//  AppDelegate.h
//  MuseumAi
//
//  Created by Kingo on 2018/9/18.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef MUSimulatorTest
#import "ZACGLResourceHandler.h"
#endif

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

/** 抽奖活动 */
@property (nonatomic , copy) NSString *activityUrl;

#ifndef MUSimulatorTest
/** OpenGL代理 */
@property (nonatomic, weak) id<ZACGLResourceHandler> glResourceHandler;
#endif

- (void)tabBarInit;
- (void)toActivityPage:(NSURL *)url;
- (void)loginByQQ:(void (^)(NSString *errorMsg, NSDictionary *response))handler;

@end

