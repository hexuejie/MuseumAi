//
//  MUExhibitionModel.h
//  MuseumAi
//
//  Created by Kingo on 2018/9/19.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MUHttpDataAccess.h"

typedef NS_ENUM(NSInteger, MUExhibitionTicketType) {
    MUExhibitionTicketTypeFree = 1,     // 免费
    MUExhibitionTicketTypeSell = 2,     // 售票
    MUExhibitionTicketTypeUnSell = 3,   // 停售
};

@interface MUExhibitionModel : NSObject

/** 是否在售票 */
@property (nonatomic , assign) MUExhibitionTicketType sell;
/** 是否火爆 */
@property (nonatomic , assign) BOOL isHot;
/** 展馆 */
@property (nonatomic , copy) NSString *hallId;
/** 名称 */
@property (nonatomic , copy) NSString *name;
/** 介绍 */
@property (nonatomic , copy) NSString *introduce;
/** imageURL */
@property (nonatomic , copy) NSString *imageUrl;
/** 收藏量 */
@property (nonatomic , copy) NSString *loveCount;
/** 点击量 */
@property (nonatomic , copy) NSString *clickCount;
/** 位置 */
@property (nonatomic , assign) CLLocationCoordinate2D location;
/** 地址 */
@property (nonatomic , copy) NSString *address;
/** 展厅位置 */
@property (nonatomic , copy) NSString *position;
/** 状态 */
@property (nonatomic , assign) MUEXHIBITIONTYPE exhibitionType;
/** 距离 */
@property (nonatomic , copy) NSString *distance;
///** 开始时间 */
//@property (nonatomic , strong) NSDate *startDate;
///** 结束时间 */
//@property (nonatomic , strong) NSDate *endDate;
///** 开馆时间段 */
//@property (nonatomic , copy) NSString *exhibitionTime;
/** 时间描述 */
@property (nonatomic , copy) NSString *time;

+ (instancetype)exhibitionWithDic:(NSDictionary *)dic;

@end
