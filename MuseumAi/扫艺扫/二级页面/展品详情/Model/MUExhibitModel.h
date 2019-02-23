//
//  MUExhibitModel.h
//  MuseumAi
//
//  Created by 魏宙辉 on 2018/9/23.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, MUEXHIBITMEDIATYPE) {
    MUEXHIBITMEDIATYPENONE = 0,     // 无媒体
    MUEXHIBITMEDIATYPEVOICE = 1,    // 语音
    MUEXHIBITMEDIATYPEVIDEO = 2     // 视频
};

@interface MUExhibitModel : NSObject

/** 展品id */
@property (copy, nonatomic) NSString *exhibitId;
/** 展品名称 */
@property (copy, nonatomic) NSString *exhibitName;
/** 展品图片 */
@property (copy, nonatomic) NSString *exhibitUrl;
/** 展品3D模型 */
@property (nonatomic , copy) NSString *exhibit3DUrl;
/** 位置X */
@property (assign, nonatomic) NSInteger positionX;
/** 位置Y */
@property (assign, nonatomic) NSInteger positionY;
/** 平面图id */
@property (nonatomic , copy) NSString *regionId;

/** 媒体类型 */
@property (assign, nonatomic) MUEXHIBITMEDIATYPE mediaType;
/** 媒体讲解id */
@property (copy, nonatomic) NSString *mediaId;
/** 媒体url */
@property (copy, nonatomic) NSString *mediaUrl;
/** 描述 */
@property (copy, nonatomic) NSString *exhibitsDescribe;
/** 工艺 */
@property (copy, nonatomic) NSString *exhibitsTechnology;
/** 风格 */
@property (copy, nonatomic) NSString *exhibitsStyle;

- (NSAttributedString *)exhibitIntroduce;

+ (instancetype)exhibitWithDic:(NSDictionary *)dic;
+ (instancetype)exhibitDetailWithDic:(NSDictionary *)dic;


@end
