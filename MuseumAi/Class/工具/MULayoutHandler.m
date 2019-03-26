//
//  MULayoutHandler.m
//  MuseumAi
//
//  Created by Kingo on 2018/9/21.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MULayoutHandler.h"

@implementation MULayoutHandler

+ (CGFloat)caculateHeightWithContent:(NSString *)content
                                font:(CGFloat)font
                               width:(CGFloat)width {
    
    UILabel *lb = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, width, MAXFLOAT)];
    lb.text = content;
    lb.numberOfLines = 0;
    lb.font = [UIFont systemFontOfSize:font];
    [lb sizeToFit];
    CGFloat height = lb.frame.size.height;
    return height+15.0f;
}

+ (CGFloat)caculateWidthWithContent:(NSString *)content
                                font:(CGFloat)font
                             height:(CGFloat)height {
    
    UILabel *lb = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, MAXFLOAT, height)];
    lb.text = content;
    lb.font = [UIFont systemFontOfSize:font];
    [lb sizeToFit];
    CGFloat width = lb.frame.size.width;
    return width+5.0f;
}

+ (CGFloat)caculateHeightWithContent:(NSAttributedString *)introText width:(CGFloat)width {
    
    YYLabel *lb = [YYLabel new];
    lb.attributedText = introText;
    CGSize introSize = CGSizeMake(width, CGFLOAT_MAX);
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:introSize text:introText];
    lb.textLayout = layout;
    CGFloat introHeight = layout.textBoundingSize.height;
    return introHeight+5.0f;
    
}

@end
