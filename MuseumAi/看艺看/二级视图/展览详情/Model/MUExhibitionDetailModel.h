//
//  MUExhibitionDetailModel.h
//  MuseumAi
//
//  Created by Kingo on 2018/9/27.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MUExhibitModel.h"
#import "MUExhibitionModel.h"

@interface MUExhibitionDetailModel : NSObject

/** 图片 */
@property (nonatomic , copy) NSString *imageUrl;
/** 评论人数 */
@property (nonatomic , copy) NSString *userCount;
/** 分数 */
@property (nonatomic , copy) NSString *score;
/** 购票 */
@property (nonatomic , strong) NSURL *buyUrl;
/** 展览id */
@property (nonatomic , copy) NSString *exhibitionId;
/** 展览名称 */
@property (nonatomic , copy) NSString *exhibitionName;
/** 售票状态 */
@property (nonatomic , assign) MUExhibitionTicketType sellState;
/** 展览时间 */
@property (nonatomic , copy) NSString *exhibitionTime;
/** 展览地点 */
@property (nonatomic , copy) NSString *exhibitionPosition;
/** 展览描述 */
@property (nonatomic , copy) NSString *exhibitionIntroduce;
/** 作品图片 */
@property (nonatomic , strong) NSArray<MUExhibitModel *> *exhibits;
/** 地理坐标 */
@property (nonatomic , assign) CLLocationCoordinate2D locationCoordinate;

#pragma mark ---- Layout
/** 是否可展开 */
@property (nonatomic , assign, readonly) BOOL foldEnable;
/** 是否展开 */
@property (nonatomic , assign) BOOL fold;
/** 介绍高度 */
@property (nonatomic , assign, readonly) CGFloat introduceHeight;

/** 是否收藏 */
@property (nonatomic , assign) BOOL isLove;
/** 是否评分 */
@property (nonatomic , assign) BOOL isScore;


+ (instancetype)exhibitionWithDic:(NSDictionary *)dic;

@end








