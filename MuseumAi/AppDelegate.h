//
//  AppDelegate.h
//  MuseumAi
//
//  Created by Kingo on 2018/9/18.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

/** 抽奖活动 */
@property (nonatomic , copy) NSString *activityUrl;

- (void)tabBarInit;
- (void)toActivityPage:(NSURL *)url;

@end

