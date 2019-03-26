//
//  MUARModel.m
//  MuseumAi
//
//  Created by 魏宙辉 on 2018/9/22.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUARModel.h"

@implementation MUARModel

+ (instancetype)exhibitsARModel:(NSDictionary *)dic {
    
    MUARModel *model = [MUARModel new];
    model.exhibitsId = dic[@"exhibitsId"];
    model.videoUrl = dic[@"vrFileUrl"];
    if(model.videoUrl == nil) {
        model.type = ExhibitsARTypeNone;
    }else {
        model.type = ExhibitsARTypePop;
    }
    model.vuforiaIDs = dic[@"GTid"];
    
    return model;
    
}

@end
