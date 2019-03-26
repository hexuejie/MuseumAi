//
//  MUCommentModel.h
//  MuseumAi
//
//  Created by 魏宙辉 on 2018/9/24.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MUCommentModel : NSObject

/** 评论内容 */
@property (copy, nonatomic) NSString *content;
/** 评论id */
@property (copy, nonatomic) NSString *commentId;
/** 作者名 */
@property (copy, nonatomic) NSString *authorName;
/** 点赞数 */
@property (assign, nonatomic) NSInteger count;
/** 作者id */
@property (copy, nonatomic) NSString *authorId;
/* 作者图像 */
@property(nonatomic, copy) NSString *authorAvatar;
/** 创建时间 */
@property (copy, nonatomic) NSString *createDate;
/** 图片数组 */
@property (strong, nonatomic) NSArray<NSString *> *images;

+ (instancetype)commentWithDic:(NSDictionary *)dic;

- (CGFloat)contentHeight;

- (CGFloat)photoHeight;

- (CGFloat)commentTotalHeight;


@end
