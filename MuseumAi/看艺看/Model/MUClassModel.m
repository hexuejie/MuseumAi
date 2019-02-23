//
//  MUClassModel.m
//  MuseumAi
//
//  Created by Kingo on 2018/9/19.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUClassModel.h"

@implementation MUClassModel

+ (instancetype)classWithDic:(NSDictionary *)dic {
    MUClassModel *model = [MUClassModel new];
    
    model.classTitle = dic[@"classTitle"];
    model.classSubTitle = dic[@"classSubTitle"];
    model.classDesctiption = dic[@"classDescribe"];
    model.classAuthor = dic[@"authorName"];
    model.classId = dic[@"id"];
    model.classDate = dic[@"classDate"];
    model.imageUrl = dic[@"mclassPicUrl"];
    model.videoUrl = dic[@"vedioPath"];
    model.isHot = [dic[@"isHot"] boolValue];
    
    return model;
}

@end
