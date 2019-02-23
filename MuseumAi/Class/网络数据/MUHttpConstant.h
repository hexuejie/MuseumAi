//
//  MUHttpConstant.h
//  MuseumAi
//
//  Created by Kingo on 2018/9/18.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MUHttpConstant : NSObject

// 主机名和端口号
UIKIT_EXTERN NSString * const kURLHostPort;
// 游客路径
UIKIT_EXTERN NSString * const kCustomRoute;
// 注册用户路径
UIKIT_EXTERN NSString * const kUserRoute;
// 微信相关接口
UIKIT_EXTERN NSString * const kWechatBase;
UIKIT_EXTERN NSString * const kWechatToken;
UIKIT_EXTERN NSString * const kWechatUserInfo;

// 网络请求错误
UIKIT_EXTERN NSString * const kFailedTips;


+ (NSDictionary *)combindDicWithReqBody:(NSDictionary *)reqBody;

@end
