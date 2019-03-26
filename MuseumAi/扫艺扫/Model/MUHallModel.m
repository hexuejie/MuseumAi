//
//  MUHallModel.m
//  MuseumAi
//
//  Created by Kingo on 2018/9/21.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUHallModel.h"

@implementation MUHallModel

+ (instancetype)hallWithDic:(NSDictionary *)dic {
    MUHallModel *hall = [MUHallModel new];
    
    hall.hallId = dic[@"hallId"];
    hall.hallName = dic[@"hallName"];
    hall.hallAddress = dic[@"hallAddress"];
    hall.hallOpenTime = dic[@"hallOpenTime"];
    hall.hallPicUrl = dic[@"hallPicUrl"];
    hall.distance = dic[@"distance"];
    hall.introduce = dic[@"hallIntroduce"];
    CGFloat lng = [dic[@"sittingPositionX"] doubleValue];
    CGFloat lat = [dic[@"sittingPositionY"] doubleValue];
    hall.location = CLLocationCoordinate2DMake(lat, lng);
    
    return hall;
}

@end
