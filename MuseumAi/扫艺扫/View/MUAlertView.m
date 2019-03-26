//
//  MUAlertView.m
//  MuseumAi
//
//  Created by 魏宙辉 on 2019/3/1.
//  Copyright © 2019年 Weizh. All rights reserved.
//

#import "MUAlertView.h"

@interface MUAlertView ()

@end

@implementation MUAlertView

- (CAShapeLayer *)addTransparencyViewWith:(NSArray<UIBezierPath *> *)tempPaths{
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:SCREEN_BOUNDS];
    for (UIBezierPath *tempPath in tempPaths) {
        [path appendPath:tempPath];
    }
    path.usesEvenOddFillRule = YES;
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = path.CGPath;
    shapeLayer.fillColor= [UIColor blackColor].CGColor;  // 其他颜色都可以，只要不是透明的
    shapeLayer.fillRule = kCAFillRuleEvenOdd;
    return shapeLayer;
}

- (void)addMaskHalfRound:(CGFloat)radius forView:(UIView *)view {
    CGRect leftRect = CGRectMake(-radius, 30, 2*radius, 2*radius);
    UIBezierPath *leftPath = [UIBezierPath bezierPathWithRoundedRect:leftRect byRoundingCorners:(UIRectCornerTopLeft |UIRectCornerTopRight |UIRectCornerBottomRight|UIRectCornerBottomLeft) cornerRadii:CGSizeMake(radius, radius)];
    view.layer.masksToBounds = YES;
    
    CGRect rightRect = CGRectMake(self.contentSize.width-radius, 30, 2*radius, 2*radius);
    UIBezierPath *rightPath = [UIBezierPath bezierPathWithRoundedRect:rightRect byRoundingCorners:(UIRectCornerTopLeft |UIRectCornerTopRight |UIRectCornerBottomRight|UIRectCornerBottomLeft) cornerRadii:CGSizeMake(radius, radius)];
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = 5.0f;
    view.layer.mask = [self addTransparencyViewWith:@[leftPath, rightPath]];
}

+ (instancetype)alertViewWithSize:(CGSize)size {
    MUAlertView *alertView = [[[self class] alloc]initWithFrame:SCREEN_BOUNDS];
    alertView.contentSize = size;
    alertView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    UIView *alert = [[UIView alloc] init];
    [alertView addSubview:alert];
    [alert mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(size.width);
        make.height.mas_equalTo(size.height);
        make.centerX.mas_equalTo(0);
        make.centerY.mas_equalTo(0);
    }];
    alertView.contentView = alert;
    alert.backgroundColor = [UIColor whiteColor];
    [alertView addMaskHalfRound:16.0f forView:alert];
    
    return alertView;
}

- (void)setContentSize:(CGSize)contentSize {
    _contentSize = contentSize;
    [_contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(contentSize.height);
    }];
}

@end
