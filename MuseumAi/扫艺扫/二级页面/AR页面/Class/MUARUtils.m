//
//  MUARUtils.m
//  MuseumAi
//
//  Created by 魏宙辉 on 2019/2/26.
//  Copyright © 2019年 Weizh. All rights reserved.
//

#import "MUARUtils.h"

@implementation MUARUtils

/** 视频文件存储目录 */
+ (NSString *)videosPathWithHallId:(NSString *)hallId {
    return [NSString stringWithFormat:@"%@/Library/Caches/ARFiles/%@/videos/",NSHomeDirectory(),hallId];
}
/** 高通配置文件存储目录 */
+ (NSString *)vuforiaPathWithHallId:(NSString *)hallId {
    return [NSString stringWithFormat:@"%@/Library/Caches/ARFiles/%@/vuforia/",NSHomeDirectory(),hallId];
}
/** 获取已存储的展馆ID */
+ (NSArray *)arHallIDs {
    NSString *arRootDir = [NSString stringWithFormat:@"%@/Library/Caches/ARFiles/",NSHomeDirectory()];
    NSArray *fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:arRootDir error:nil];
    NSLog(@"fileList:%@",fileList);
    return fileList;
}
/** 清除缓存 */
+ (void)clearCatches:(void(^)(BOOL success, NSString *reason))handler {
    NSString *arRootDir = [NSString stringWithFormat:@"%@/Library/Caches/ARFiles/",NSHomeDirectory()];
    NSArray *fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:arRootDir error:nil];
    if (fileList.count > 0) {
        for (NSString *fileName in fileList) {
            NSString *filePath = [NSString stringWithFormat:@"%@%@",arRootDir,fileName];
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        if (handler) {
            handler(YES, @"已清除缓存");
        }
    } else {
        if (handler) {
            handler(NO, @"缓存为空");
        }
    }
}
/** 计算AR缓存大小 */
+ (NSInteger)catchesSize {
    NSString *arRootDir = [NSString stringWithFormat:@"%@/Library/Caches/ARFiles/",NSHomeDirectory()];
    return [MUARUtils folderSizeAtPath:arRootDir];
}
/** 计算文件夹的大小 */
+ (NSInteger)folderSizeAtPath:(NSString *)filePath {
    
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:filePath])
        return 0;
    NSString* fileName = [filePath copy];
    NSInteger folderSize = 0;
    
    BOOL isdir;
    [manager fileExistsAtPath:fileName isDirectory:&isdir];
    if (isdir != YES) {
        return [MUARUtils fileSizeAtPath:fileName];
    }
    else
    {
        NSArray * items = [manager contentsOfDirectoryAtPath:fileName error:nil];
        for (int i =0; i<items.count; i++) {
            BOOL subisdir;
            NSString* fileAbsolutePath = [fileName stringByAppendingPathComponent:items[i]];
            
            [manager fileExistsAtPath:fileAbsolutePath isDirectory:&subisdir];
            if (subisdir==YES) {
                folderSize += [MUARUtils folderSizeAtPath:fileAbsolutePath]; //文件夹就递归计算
            }
            else
            {
                folderSize += [MUARUtils fileSizeAtPath:fileAbsolutePath];//文件直接计算
            }
        }
    }
    return folderSize; //folderSize/(1024*1024)递归时候会运算两次出错，所以返回字节。在外面再计算
}
//单个文件的大小
+ (NSInteger)fileSizeAtPath:(NSString*)filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}
/** 获取展馆某个展品的Video路径 */
+ (NSString *)getVideoPathWithHallID:(NSString *)hallId exhibit:(MUARModel *)exhibit {
    NSString *videoRootPath = [MUARUtils videosPathWithHallId:hallId];
    NSString *videoPath = [NSString stringWithFormat:@"%@%@.mp4",videoRootPath,exhibit.exhibitsId];
    return videoPath;
}

/** 下载单个文件 */
+ (void)downLoadFile:(NSString *)url
                name:(NSString *)fileName
     completeHandler:(void(^)(NSData *fileData, NSString *fileName, NSError *error))handler {
    
    dispatch_queue_t queue = dispatch_queue_create("DownLoadFile", NULL);
    dispatch_async(queue, ^{
        NSError *error;
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]
                                             options:NSDataReadingUncached
                                               error:&error];
        if (handler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(data,fileName,error);
            });
            NSLog(@"weizh -> data:%ld",data.length);
        }
    });
}

/** 存储单个文件 */
+ (void)writeToFile:(NSData *)data
           fileName:(NSString *)fileName
               type:(MUWriteFileType)type
             hallID:(NSString *)hallID {
    
    if (type == MUWriteFileTypeXML) {
        NSString *xmlPath = [MUARUtils vuforiaPathWithHallId:hallID];
        if (![[NSFileManager defaultManager] fileExistsAtPath:xmlPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:xmlPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSString *path = [NSString stringWithFormat:@"%@%@",xmlPath,fileName];
        // 写入文件
        NSError *error;
        BOOL writeFg = [data writeToFile:path options:NSDataWritingAtomic error:&error];
        if (writeFg) {
            NSLog(@"写入完成：%@",fileName);
        }else {
            NSLog(@"存储失败:%@",error);
        }

    } else if (type == MUWriteFileTypeVideo) {
        NSString *videoPath = [MUARUtils videosPathWithHallId:hallID];
        if (![[NSFileManager defaultManager] fileExistsAtPath:videoPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:videoPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSString *path = [NSString stringWithFormat:@"%@%@",videoPath,fileName];
        // 写入文件
        NSError *error;
        BOOL writeFg = [data writeToFile:path options:NSDataWritingAtomic error:&error];
        if (writeFg) {
            NSLog(@"写入完成：%@",fileName);
        }else {
            NSLog(@"存储失败:%@",error);
        }
    }
}

/** 判断某展品的视频文件是否存在 */
+ (BOOL)isVideoExsitForHall:(NSString *)hallID exhibits:(MUARModel *)exhibit {
    NSString *videoPath = [MUARUtils getVideoPathWithHallID:hallID exhibit:exhibit];
    return [[NSFileManager defaultManager] fileExistsAtPath:videoPath];
}
/** 从ars中取出对应的ImageTargetID对应的展品 */
+ (MUARModel *)exhibitWithImageTargetID:(NSString *)targetID fromArs:(NSArray *)ars {
    for (MUARModel *ar in ars) {
        if ([ar.vuforiaIDs containsObject:targetID]) {
            return ar;
        }
    }
    return nil;
}
@end
