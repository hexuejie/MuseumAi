//
//  UIView+KGOUtil.m
//  KingoPalm
//
//  Created by Kingo on 2018/9/15.
//  Copyright © 2018年 Kingo. All rights reserved.
//

#import "UIView+KGOUtil.h"

@implementation UIView (KGOUtil)

- (void)addTapTarget:(id)target action:(SEL)action {
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:target action:action];
    [self addGestureRecognizer:tap];
}

@end
