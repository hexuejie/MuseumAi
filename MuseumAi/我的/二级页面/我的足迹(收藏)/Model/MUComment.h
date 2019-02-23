//
//  MUComment.h
//  MuseumAi
//
//  Created by 魏宙辉 on 2018/10/23.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MUMYCOMMENTTYPE) {
    MUCOMMENTTYPEEXHIBIT = 4,   // 展品评论
    MUCOMMENTTYPEEXHIBITION = 7,// 展览评论
};

@interface MUComment : NSObject

/** 类型 */
@property (assign, nonatomic) MUMYCOMMENTTYPE type;
/** id */
@property (copy, nonatomic) NSString *exhibitId;
/** 内容 */
@property (copy, nonatomic) NSString *content;
/** 评论主题 */
@property (copy, nonatomic) NSString *title;
/** 评论时间 */
@property (copy, nonatomic) NSString *time;

+ (instancetype)commentWithDic:(NSDictionary *)dic;

@end
