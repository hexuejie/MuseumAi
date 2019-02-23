//
//  ZACAnimationView.m
//  KGOTest
//
//  Created by Kingo on 2018/10/9.
//  Copyright © 2018年 Kingo. All rights reserved.
//

#import "ZACAnimationView.h"

typedef enum Direction{
    Right = 0,
    Left,
} Direction;

@interface ZACAnimationView()
{
    NSArray<NSURL *> *imageList;
    UIImageView *showImage;
    UILabel *indexLb;
    int index;
}
@end

@implementation ZACAnimationView

- (instancetype)initWithImageUrls:(NSArray<NSURL *> *)imageUrls {
    
    if (self = [super init]) {
        imageList = imageUrls;
        showImage = [[UIImageView alloc]init];
        showImage.contentMode = UIViewContentModeScaleAspectFit;
        showImage.layer.cornerRadius = 8.0f;
        showImage.layer.masksToBounds = YES;
        [showImage sd_setImageWithURL:imageList[0]];
        showImage.userInteractionEnabled = YES;
        [self addSubview:showImage];
        [showImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.bottom.right.mas_equalTo(0);
        }];
        
        indexLb = [[UILabel alloc]init];
        indexLb.textAlignment = NSTextAlignmentCenter;
        indexLb.textColor = [UIColor whiteColor];
        indexLb.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.35f];
        indexLb.layer.masksToBounds = YES;
        indexLb.layer.cornerRadius = 20.0f;
        [self addSubview:indexLb];
        [indexLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.bottom.mas_equalTo(-10.0f);
            make.width.height.mas_equalTo(40.0f);
        }];
        indexLb.text = [NSString stringWithFormat:@"1/%ld",imageList.count];
        
        UISwipeGestureRecognizer *rightSWip = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(right)];
        rightSWip.direction = UISwipeGestureRecognizerDirectionRight;
        [self addGestureRecognizer:rightSWip];
        
        UISwipeGestureRecognizer *leftSwip = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(left)];
        leftSwip.direction = UISwipeGestureRecognizerDirectionLeft;
        [self addGestureRecognizer:leftSwip];
    }
    return self;
    
}

- (void)left {
    [self changeImageWithDirection:Left];
}

- (void)right {
    [self changeImageWithDirection:Right];
}

- (void)changeImageWithDirection:(Direction)direction {
    index = (direction == Right) ? [self countRelease]:[self countAdd];
    indexLb.text = [NSString stringWithFormat:@"%d/%ld",index+1,imageList.count];
    CATransition *transition = [CATransition animation];
    // suckEffect/rippleEffect
    transition.type = (direction == Left) ? kCATransitionReveal:kCATransitionFade;
    transition.subtype = (direction == Right) ? kCATransitionFromLeft:kCATransitionFromRight;
    transition.duration = (direction == Left) ? 0.5 : 1.0;
    NSString *urlStr = [imageList[index] absoluteString];
    [showImage.layer addAnimation:transition forKey:urlStr];
    [showImage sd_setImageWithURL:imageList[index]];
}

#pragma mark ------- 向左滑动图片自加++   ------
//需要通过方向判断是自加还是自减 把计算号的值 赋值给 全局变量index
- (int)countAdd {
    index ++;
    //如果超出了 图片数组的元素个数 让index等于0(修复成0) 如果没有超出 返回自加之后的值
    return index >= imageList.count ? 0:index;
}
#pragma mark ------- 向右滑动图片自加++   ------
- (int)countRelease {
    index --;
    return index < 0 ?
    (int)imageList.count-1:index;
}

@end
