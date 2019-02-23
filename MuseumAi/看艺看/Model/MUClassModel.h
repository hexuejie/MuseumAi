//
//  MUClassModel.h
//  MuseumAi
//
//  Created by Kingo on 2018/9/19.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MUClassModel : NSObject

/** 标题 */
@property (nonatomic , copy) NSString *classTitle;
/** 副标题 */
@property (nonatomic , copy) NSString *classSubTitle;
/** 描述 */
@property (nonatomic , copy) NSString *classDesctiption;
/** id */
@property (nonatomic , copy) NSString *classId;
/** 课程日期 */
@property (nonatomic , copy) NSString *classDate;
/** 课程作者 */
@property (nonatomic , copy) NSString *classAuthor;
/** 图片地址 */
@property (nonatomic , copy) NSString *imageUrl;
/** 视频地址 */
@property (nonatomic , copy) NSString *videoUrl;
/** 是否热门 */
@property (nonatomic , assign) BOOL isHot;

+ (instancetype)classWithDic:(NSDictionary *)dic;

@end
