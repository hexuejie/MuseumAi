//
//  MUARModel.h
//  MuseumAi
//
//  Created by 魏宙辉 on 2018/9/22.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ExhibitsARType) {
    ExhibitsARTypeNone = 0,     // 无视频
    ExhibitsARTypeFollow = 1,   // 跟随
    ExhibitsARTypePop = 2       // 弹出
};

@interface MUARModel : NSObject

/** 展品Id */
@property (copy, nonatomic) NSString *exhibitsId;
/** 展品视频URL */
@property (copy, nonatomic) NSString *videoUrl;
/** 展品Id */
@property (assign, nonatomic) ExhibitsARType type;
/** 展品image */
@property (copy, nonatomic) NSArray *imageUrls;

+ (instancetype)exhibitsARModel:(NSDictionary *)dic;

@end
