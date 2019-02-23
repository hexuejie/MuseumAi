//
//  MUExhibitModel.m
//  MuseumAi
//
//  Created by 魏宙辉 on 2018/9/23.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUExhibitModel.h"

@implementation MUExhibitModel

+ (instancetype)exhibitWithDic:(NSDictionary *)dic {
    MUExhibitModel *model = [MUExhibitModel new];
    
    model.exhibitId = dic[@"exhibitsId"];
    if (model.exhibitId == nil) {
        model.exhibitId = dic[@"exhibitionId"];
    }
    model.exhibitName = dic[@"exhibitsName"];
    model.exhibitUrl = dic[@"exhibitsSurfacePlotUrl"];
    model.positionX = [dic[@"positionX"] integerValue];
    model.positionY = [dic[@"positionY"] integerValue];
    model.regionId = dic[@"regionId"];
    model.exhibitsDescribe = dic[@"exhibitsDescribe"];
    
    return model;
}

+ (instancetype)exhibitDetailWithDic:(NSDictionary *)dic {
    MUExhibitModel *model = [MUExhibitModel new];
    
    model.exhibitId = dic[@"hallExhibits"][@"exhibitsId"];
    model.exhibitName = dic[@"hallExhibits"][@"exhibitsName"];
    model.exhibitUrl = dic[@"hallExhibits"][@"exhibitsSurfacePlotUrl"];
    model.exhibitsDescribe = dic[@"hallExhibits"][@"exhibitsDescribe"];
    model.exhibitsTechnology = dic[@"hallExhibits"][@"exhibitsTechnology"];
    model.exhibitsStyle = dic[@"hallExhibits"][@"exhibitsStyle"];
    model.exhibit3DUrl = dic[@"Url3d"];
    NSDictionary *mediaDic = [dic[@"exhibitsExplainList"] firstObject];
    if (mediaDic != nil) {
        model.mediaType = [mediaDic[@"explainFileType"]integerValue];
        model.mediaId = mediaDic[@"explainId"];
        model.mediaUrl = mediaDic[@"fileUrl"];
    }else {
        model.mediaType = MUEXHIBITMEDIATYPENONE;
    }
    
    return model;
}

- (NSAttributedString *)exhibitIntroduce {
    
    NSMutableAttributedString *introduce = [[NSMutableAttributedString alloc]init];
    if (self.exhibitsDescribe.length > 0) {
        NSString *describe = [NSString stringWithFormat:@"展品介绍\n　　%@",self.exhibitsDescribe];
        NSMutableAttributedString *describeAttrbuted = [[NSMutableAttributedString alloc]initWithString:describe];
        describeAttrbuted.yy_font = [UIFont systemFontOfSize:13.0f];
        describeAttrbuted.yy_lineSpacing = 5.0f;
        describeAttrbuted.yy_color = kUIColorFromRGB(0x333333);
        [describeAttrbuted yy_setFont:[UIFont boldSystemFontOfSize:14.0f] range:[describe rangeOfString:@"展品介绍"]];
        [introduce appendAttributedString:describeAttrbuted];
    }
    if (self.exhibitsTechnology.length > 0) {
        NSString *describe = [NSString stringWithFormat:@"\n展品工艺\n　　%@",self.exhibitsTechnology];
        NSMutableAttributedString *describeAttrbuted = [[NSMutableAttributedString alloc]initWithString:describe];
        describeAttrbuted.yy_font = [UIFont systemFontOfSize:13.0f];
        describeAttrbuted.yy_lineSpacing = 5.0f;
        describeAttrbuted.yy_color = kUIColorFromRGB(0x333333);
        [describeAttrbuted yy_setFont:[UIFont boldSystemFontOfSize:14.0f] range:[describe rangeOfString:@"展品工艺"]];
        [introduce appendAttributedString:describeAttrbuted];
    }
    if (self.exhibitsStyle.length > 0) {
        NSString *describe = [NSString stringWithFormat:@"\n展品风格\n　　%@",self.exhibitsStyle];
        NSMutableAttributedString *describeAttrbuted = [[NSMutableAttributedString alloc]initWithString:describe];
        describeAttrbuted.yy_font = [UIFont systemFontOfSize:13.0f];
        describeAttrbuted.yy_lineSpacing = 5.0f;
        describeAttrbuted.yy_color = kUIColorFromRGB(0x333333);
        [describeAttrbuted yy_setFont:[UIFont boldSystemFontOfSize:14.0f] range:[describe rangeOfString:@"展品风格"]];
        [introduce appendAttributedString:describeAttrbuted];
    }
    
    return introduce;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[MUExhibitModel class]]) {
        return [self.exhibitId isEqual:[object exhibitId]];
    }
    return NO;
}

@end


















