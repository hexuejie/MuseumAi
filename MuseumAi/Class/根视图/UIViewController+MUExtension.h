//
//  UIViewController+MUExtension.h
//  MuseumAi
//
//  Created by 魏宙辉 on 2019/2/25.
//  Copyright © 2019年 Weizh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (MUExtension)

#pragma mark - loading animation

- (void) showLoadingAnimation;
- (void) hideLoadingAnimation;

- (void)alertWithMsg:(NSString *)msg handler:(void (^)())handler;
- (void)alertWithMsg:(NSString *)msg okHandler:(void (^)())handler;
- (void)alertWithMsg:(NSString *)msg
           leftTitle:(NSString *)leftTitle
         leftHandler:(void (^)(void))leftHandler
          rightTitle:(NSString *)rightTitle
        rightHandler:(void (^)(void))rightHandler;

// 读取本地JSON文件
- (id)readJSONFileWithName:(NSString *)name;
// 打印请求结果
- (void)logResult:(id)result;

@end

