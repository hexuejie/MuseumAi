//
//  MURootViewController.h
//  MuseumAi
//
//  Created by Kingo on 2018/9/18.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MUHttpDataAccess.h"
#import "MUMapHandler.h"
#import "MULoginViewController.h"

@interface MURootViewController : UIViewController

- (void)alertWithMsg:(NSString *)msg handler:(void (^)())handler;

- (void)alertWithMsg:(NSString *)msg okHandler:(void (^)())handler;

@end
