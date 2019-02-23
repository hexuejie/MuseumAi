//
//  MULayoutHandler.h
//  MuseumAi
//
//  Created by Kingo on 2018/9/21.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYLabel.h"
#import "YYText.h"

@interface MULayoutHandler : NSObject

/** 固定宽度计算lb的高度 */
+ (CGFloat)caculateHeightWithContent:(NSString *)content
                                font:(CGFloat)font
                               width:(CGFloat)width;

/** 固定高度计算lb的宽度 */
+ (CGFloat)caculateWidthWithContent:(NSString *)content
                               font:(CGFloat)font
                             height:(CGFloat)height;

/** 计算富文本高度 */
+ (CGFloat)caculateHeightWithContent:(NSAttributedString *)introText width:(CGFloat)width;
@end
