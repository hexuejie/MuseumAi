//
//  MUAlertView.h
//  MuseumAi
//
//  Created by 魏宙辉 on 2019/3/1.
//  Copyright © 2019年 Weizh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MUAlertView : UIView

/* 弹窗 */
@property(nonatomic, strong) UIView *contentView;
/* 尺寸 */
@property(nonatomic, assign) CGSize contentSize;

+ (instancetype)alertViewWithSize:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
