//
//  UIViewController+MUExtension.m
//  MuseumAi
//
//  Created by 魏宙辉 on 2019/2/25.
//  Copyright © 2019年 Weizh. All rights reserved.
//

#import "UIViewController+MUExtension.h"

@implementation UIViewController (MUExtension)

#pragma mark - loading animation

- (void) showLoadingAnimation {
    
    CGRect indicatorBounds;
    CGRect mainBounds = [[UIScreen mainScreen] bounds];
    int smallerBoundsSize = MIN(mainBounds.size.width, mainBounds.size.height);
    int largerBoundsSize = MAX(mainBounds.size.width, mainBounds.size.height);
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown ) {
        indicatorBounds = CGRectMake(smallerBoundsSize / 2 - 12,
                                     largerBoundsSize / 2 - 12, 24, 24);
    } else {
        indicatorBounds = CGRectMake(largerBoundsSize / 2 - 12,
                                     smallerBoundsSize / 2 - 12, 24, 24);
    }
    
    UIActivityIndicatorView *loadingIndicator = [[UIActivityIndicatorView alloc]
                                                 initWithFrame:indicatorBounds];
    
    loadingIndicator.tag  = 1;
    loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [self.view addSubview:loadingIndicator];
    [loadingIndicator startAnimating];
}

- (void) hideLoadingAnimation {
    
    UIActivityIndicatorView *loadingIndicator = (UIActivityIndicatorView *)[self.view viewWithTag:1];
    [loadingIndicator removeFromSuperview];
}

- (void)alertWithMsg:(NSString *)msg
           leftTitle:(NSString *)leftTitle
         leftHandler:(void (^)(void))leftHandler
          rightTitle:(NSString *)rightTitle
        rightHandler:(void (^)(void))rightHandler {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:msg message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *leftAction = [UIAlertAction actionWithTitle:leftTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (leftHandler) {
            leftHandler();
        }
    }];
    UIAlertAction *rightAction = [UIAlertAction actionWithTitle:rightTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (rightHandler != nil) {
            rightHandler();
        }
    }];
    [alert addAction:leftAction];
    [alert addAction:rightAction];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf presentViewController:alert animated:YES completion:nil];
    });
}

- (void)alertWithMsg:(NSString *)msg handler:(void (^)())handler {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:msg message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (handler != nil) {
            handler();
        }
    }];
    [alert addAction:ok];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf presentViewController:alert animated:YES completion:nil];
    });
}

- (void)alertWithMsg:(NSString *)msg okHandler:(void (^)())handler {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:msg message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (handler != nil) {
            handler();
        }
    }];
    [alert addAction:cancel];
    [alert addAction:ok];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf presentViewController:alert animated:YES completion:nil];
    });
}

- (void)logResult:(id)result {
    NSData *data = [NSJSONSerialization dataWithJSONObject:result options:NSJSONWritingPrettyPrinted error:nil];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",str);
}

// 读取本地JSON文件
- (id)readJSONFileWithName:(NSString *)name {
    // 获取文件路径
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"json"];
    // 将文件数据化
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    // 对数据进行JSON格式化并返回字典形式
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}

@end
