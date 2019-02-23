//
//  MUHttpConstant.m
//  MuseumAi
//
//  Created by Kingo on 2018/9/18.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUHttpConstant.h"

@implementation MUHttpConstant

NSString * const kURLHostPort = @"https://www.airart.com.cn/admin";
NSString * const kCustomRoute = @"/p/interface/index/api";
NSString * const kUserRoute = @"/p/interface/user/api";

NSString * const kWechatBase = @"https://api.weixin.qq.com/sns";
NSString * const kWechatToken = @"/oauth2/access_token";
NSString * const kWechatUserInfo = @"/userinfo";

NSString * const kFailedTips = @"服务器忙，请稍后再试";

NSString *const kAppKey = @"zKaw7utGcDyLsaQhD2g3IGzOakzLtfuz";

+ (NSDictionary *)combindDicWithReqBody:(NSDictionary *)reqBody {
    NSString *versionStr = [[[NSBundle mainBundle] infoDictionary]objectForKey:@"CFBundleShortVersionString"];
    return @{
             @"from": @"ios",
             @"version": versionStr,
             @"appkey": kAppKey,
             @"reqBody": reqBody
             };
}

@end
