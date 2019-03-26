//
//  MUIbeaconAlertView.h
//  MuseumAi
//
//  Created by 魏宙辉 on 2019/3/4.
//  Copyright © 2019年 Weizh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MUAlertView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MUIbeaconAlertView : MUAlertView

+ (instancetype)ibeaconAlertWithImageUrl:(NSString *)url;

/* 图片Url */
@property(nonatomic, copy) NSString *imageUrl;

@end

NS_ASSUME_NONNULL_END
