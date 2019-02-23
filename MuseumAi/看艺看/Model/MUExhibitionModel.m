//
//  MUExhibitionModel.m
//  MuseumAi
//
//  Created by Kingo on 2018/9/19.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUExhibitionModel.h"

@implementation MUExhibitionModel

+ (instancetype)exhibitionWithDic:(NSDictionary *)dic {
    
    MUExhibitionModel *model = [[MUExhibitionModel alloc]init];
    
    model.sell = [dic[@"sellTicketState"] integerValue];
    model.isHot = [dic[@"isHot"] boolValue];
    model.hallId = dic[@"id"];
    model.name = dic[@"exhibitionName"];
    model.introduce = dic[@"exhibitionIntroduce"];
    model.imageUrl = dic[@"exhibitionPicUrl"];
    model.loveCount = dic[@"count"];
    model.clickCount = dic[@"click"];
    model.location = CLLocationCoordinate2DMake([dic[@"sittingPositionY"] doubleValue], [dic[@"sittingPositionX"] doubleValue]);
    model.address = dic[@"exhibitionAddress"];
    model.position = dic[@"sittingPosition"];
    
    model.distance = dic[@"distance"];
    model.time = dic[@"time"];
    
    return model;
}

@end
