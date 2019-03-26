//
//  MUARUtils.h
//  MuseumAi
//
//  Created by 魏宙辉 on 2019/2/26.
//  Copyright © 2019年 Weizh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MUARModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MUWriteFileType) {
    MUWriteFileTypeXML = 0,     // 写入XML
    MUWriteFileTypeVideo = 1,   // 写入Video
};

@interface MUARUtils : NSObject

/** 视频文件存储目录 */
+ (NSString *)videosPathWithHallId:(NSString *)hallId;
/** 高通配置文件存储目录 */
+ (NSString *)vuforiaPathWithHallId:(NSString *)hallId;
/** 获取展馆某个展品的Video路径 */
+ (NSString *)getVideoPathWithHallID:(NSString *)hallId exhibit:(MUARModel *)exhibit;

/** 下载单个文件 */
+ (void)downLoadFile:(NSString *)url
                name:(NSString *)fileName
     completeHandler:(void(^)(NSData *fileData, NSString *fileName, NSError *error))handler;
/** 存储单个文件 */
+ (void)writeToFile:(NSData *)data
           fileName:(NSString *)fileName
               type:(MUWriteFileType)type
             hallID:(NSString *)hallID;

/** 判断某展品的视频文件是否存在 */
+ (BOOL)isVideoExsitForHall:(NSString *)hallID exhibits:(MUARModel *)exhibit;
/** 从ars中取出对应的ImageTargetID对应的展品 */
+ (MUARModel *)exhibitWithImageTargetID:(NSString *)targetID fromArs:(NSArray *)ars;

/** 获取已存储的展馆ID */
+ (NSArray *)arHallIDs;
/** 计算AR缓存大小 */
+ (NSInteger)catchesSize;
/** 清除缓存 */
+ (void)clearCatches:(void(^)(BOOL success, NSString *reason))handler;

@end

NS_ASSUME_NONNULL_END
