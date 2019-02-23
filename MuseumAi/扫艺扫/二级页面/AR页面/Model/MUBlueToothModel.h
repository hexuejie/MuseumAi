//
//  MUBlueToothModel.h
//  MuseumAi
//
//  Created by Kingo on 2018/10/8.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TOTALVALUE 1         // 1次平均

@interface MUBlueToothModel : NSObject

/** 蓝牙名称 */
@property (nonatomic , copy) NSString *blueToothName;
/** 蓝牙id */
@property (nonatomic , copy) NSString *blueToothId;
/** 对应展品id */
@property (nonatomic , copy) NSString *exhibitionId;
/** 对应展品图片 */
@property (nonatomic , copy) NSString *exhibitionUrl;
/** 地图id */
@property (copy, nonatomic) NSString *regionId;
/** 音频 */
@property (copy, nonatomic) NSString *audio;
/** 是否弹出扫一扫 */
@property (nonatomic , assign) BOOL scan;

/** 距离 */
@property (nonatomic , assign, readonly) CGFloat distance;
- (void)addDistanceWithRSSI:(int)rssi;
/** 识别距离 */
@property (assign, nonatomic) CGFloat foundDistance;
/** 发射端和接收端相隔1米时的信号强度 */
@property (assign, nonatomic) CGFloat valueA;
/** 环境衰减因子 */
@property (assign, nonatomic) CGFloat valueN;

+ (instancetype)blueToothModelWithDic:(NSDictionary *)dic;

@end
