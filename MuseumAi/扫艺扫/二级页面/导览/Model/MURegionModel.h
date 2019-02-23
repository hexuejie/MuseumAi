//
//  MURegionModel.h
//  MuseumAi
//
//  Created by Kingo on 2018/9/28.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MURegionModel : NSObject

/** id */
@property (nonatomic , copy) NSString *regionId;
/** 图片 */
@property (nonatomic , copy) NSString *regionUrl;
/** 宽 */
@property (nonatomic , assign) CGFloat width;
/** 高 */
@property (nonatomic , assign) CGFloat height;

+ (instancetype)regionWithDic:(NSDictionary *)dic;

@end
