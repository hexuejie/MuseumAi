//
//  MUComment.m
//  MuseumAi
//
//  Created by 魏宙辉 on 2018/10/23.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUComment.h"

@implementation MUComment

+ (instancetype)commentWithDic:(NSDictionary *)dic {
    MUComment *comment = [MUComment new];
    comment.type = [dic[@"subsidiaryChannel"]integerValue];
    comment.exhibitId = dic[@"bussinessId"];
    comment.content = dic[@"content"];
    comment.title = dic[@"authorNameB"];
    comment.time = dic[@"createDate"];
    return comment;
}

@end
