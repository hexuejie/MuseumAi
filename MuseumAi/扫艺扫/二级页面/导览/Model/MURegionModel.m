//
//  MURegionModel.m
//  MuseumAi
//
//  Created by Kingo on 2018/9/28.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MURegionModel.h"

@implementation MURegionModel

+ (instancetype)regionWithDic:(NSDictionary *)dic {
    MURegionModel *region = [MURegionModel new];
    
    region.regionId = dic[@"id"];
    region.regionUrl = dic[@"regionPlanePicUrl"];
    region.width = [dic[@"photoWidth"]doubleValue];
    region.height = [dic[@"photoHeight"]doubleValue];
    
    return region;
}
@end
