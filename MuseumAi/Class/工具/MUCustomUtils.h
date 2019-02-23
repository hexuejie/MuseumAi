//
//  MUCustomUtils.h
//  MuseumAi
//
//  Created by Kingo on 2018/9/26.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MUCustomUtils : NSObject

//验证邮箱格式
+ (BOOL)validateEmail:(NSString *)candidate;
//验证电话号码格式
+ (BOOL)isValidateTelNumber:(NSString *)number;

/** 分享 */
+ (UIActivityViewController *)shareWeixinWithText:(NSString *)textToShare
                                          content:(NSString *)content
                                            image:(UIImage *)imageToShare
                                              url:(NSURL *)urlToShare;

/** 通过微信分享 */
+ (void)shareByWechatWith:(NSString *)title
                  content:(NSString *)content
                    image:(UIImage *)image
                      url:(NSString *)url
                     type:(int)type;

/** 从gif图片中获取图片源 */
+ (NSArray *)imagesFromGif:(NSString *)gifName;

/** 获取手机型号 */
+ (NSString*)deviceModelName;

@end
