//
//  MUHallModel.h
//  MuseumAi
//
//  Created by Kingo on 2018/9/21.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MUHallModel : NSObject

/** 展馆id */
@property (nonatomic , copy) NSString *hallId;
/** 展馆名称 */
@property (nonatomic , copy) NSString *hallName;
/** 展馆位置 */
@property (nonatomic , copy) NSString *hallAddress;
/** 展馆坐标 */
@property (nonatomic , assign) CLLocationCoordinate2D location;
/** 开放时间 */
@property (nonatomic , copy) NSString *hallOpenTime;
/** 展馆图片url */
@property (nonatomic , copy) NSString *hallPicUrl;
/** 展馆距离 */
@property (nonatomic , copy) NSString *distance;
/** 展馆介绍 */
@property (nonatomic , copy) NSString *introduce;
/** 资料更新时间 */
@property (nonatomic , copy) NSNumber *fileUpdate;

+ (instancetype)hallWithDic:(NSDictionary *)dic;

@end
