//
//  MUVideoTabBar.m
//  MuseumAi
//
//  Created by 魏宙辉 on 2018/9/24.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUVideoTabBar.h"

@interface MUVideoTabBar()
{
    BOOL _slideChangeAble;
}
/** 播放键 */
@property (strong, nonatomic) UIButton *playBt;
/** 时间显示 */
@property (strong, nonatomic) UILabel *timeLb;
/** 进度条 */
@property (strong, nonatomic) UISlider *slider;
/** 声音调节 */
@property (strong, nonatomic) UIButton *voiceBt;
/** 最大最小化 */
@property (strong, nonatomic) UIButton *sizeBt;

@end

@implementation MUVideoTabBar

+ (instancetype)videoTabBarWithDelegate:(id<MUVideoTabBarDelegate>)delegate {
    MUVideoTabBar *bar = [MUVideoTabBar new];
    bar.delegate = delegate;
    bar.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.2];
    [bar loadWidgets];
    return bar;
}

- (void)loadWidgets {
    self.playBt = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playBt addTarget:self action:@selector(didPlayClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.playBt setImage:[UIImage imageNamed:@"暂停"] forState:UIControlStateSelected];
    [self.playBt setImage:[UIImage imageNamed:@"播放"] forState:UIControlStateNormal];
    [self addSubview:self.playBt];
    [self.playBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.width.height.mas_equalTo(30.0f);
        make.centerY.mas_equalTo(0);
    }];
    [self.playBt setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    
    __weak typeof(self) weakSelf = self;
    self.timeLb = [[UILabel alloc]init];
    self.timeLb.font = [UIFont systemFontOfSize:13.0f];
    self.timeLb.textColor = kUIColorFromRGB(0x333333);
    self.timeLb.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.timeLb];
    [self.timeLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(0);
        make.left.equalTo(weakSelf.playBt.mas_right);
        make.width.mas_equalTo(80);
    }];
    self.timeLb.text = @"00:00/00:10";
    
    self.sizeBt = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.sizeBt setImage:[UIImage imageNamed:@"视频全屏"] forState:UIControlStateNormal];
    [self.sizeBt setImage:[UIImage imageNamed:@"视频小屏"] forState:UIControlStateSelected];
    [self.sizeBt addTarget:self action:@selector(didSizeClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.sizeBt setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [self addSubview:self.sizeBt];
    [self.sizeBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-5);
        make.width.height.mas_equalTo(30.0f);
        make.centerY.mas_equalTo(0);
    }];
    
    self.voiceBt = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.voiceBt setImage:[UIImage imageNamed:@"声音"] forState:UIControlStateNormal];
    [self.voiceBt setImage:[UIImage imageNamed:@"静音"] forState:UIControlStateSelected];
    [self.voiceBt addTarget:self action:@selector(didVoiceClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.voiceBt setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [self addSubview:self.voiceBt];
    [self.voiceBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.sizeBt.mas_left).offset(-5);
        make.width.height.mas_equalTo(30.0f);
        make.centerY.mas_equalTo(0);
    }];
    
    self.slider = [[UISlider alloc]init];
    [self.slider setThumbImage:[self OriginImage:[UIImage imageNamed:@"滑动圆"] scaleToSize:CGSizeMake(10, 10)] forState:UIControlStateNormal];
    _slideChangeAble = YES;
    [self.slider setMinimumTrackTintColor:kMainColor];
    [self.slider addTarget:self action:@selector(didSlideTouched:) forControlEvents:UIControlEventTouchDown];
    [self.slider addTarget:self action:@selector(didSlideUp:) forControlEvents:UIControlEventTouchUpInside];
    [self.slider addTarget:self action:@selector(didSlideChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.slider];
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.timeLb.mas_right).offset(5);
        make.right.equalTo(weakSelf.voiceBt.mas_left).offset(-5);
        make.height.mas_equalTo(2.0f);
        make.centerY.mas_equalTo(0);
    }];
}

- (void)didSlideTouched:(id)sender {
    NSLog(@"禁止被动变化");
    _slideChangeAble = NO;
}

- (void)didSlideUp:(id)sender {
    NSLog(@"允许被动变化");
    _slideChangeAble = YES;
}

-(UIImage *)OriginImage:(UIImage *)image scaleToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0,0, size.width, size.height)];
    UIImage *scaleImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaleImage;
}

- (void)setType:(VIDEOSCREENTYPE)type {
    _type = type;
    if (type == VIDEOSCREENTYPEBIG) {
        self.sizeBt.selected = YES;
    }else {
        self.sizeBt.selected = NO;
    }
}

- (void)setStatus:(VIDEOSTATUS)status {
    _status = status;
    if (status == VIDEOSTATUSPLAY) {
        self.playBt.selected = YES;
    }else {
        self.playBt.selected = NO;
    }
}

- (void)setCurrentTime:(NSInteger)currentTime totalTime:(NSInteger)totalTime refreshSlider:(BOOL)refreshSlider {
    if (refreshSlider && _slideChangeAble) {
        CGFloat value = currentTime/(CGFloat)totalTime;
        self.slider.value = value;
    }
    NSInteger currentMin = currentTime/60;
    NSInteger currentSec = currentTime%60;
    NSInteger totalMin = totalTime/60;
    NSInteger totalSec = totalTime%60;
    self.timeLb.text = [NSString stringWithFormat:@"%02ld:%02ld/%02ld:%02ld",currentMin,currentSec,totalMin,totalSec];
}


- (void)didPlayClicked:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    if (_delegate != nil &&
        [_delegate respondsToSelector:@selector(videoBar:isPlay:)]) {
        [_delegate videoBar:self isPlay:sender.selected];
    }
    
}

- (void)didSlideChanged:(UISlider *)slider {
    
    CGFloat value = slider.value;
//    NSLog(@"value:%.2f",value);
    if (_delegate != nil &&
        [_delegate respondsToSelector:@selector(videoBar:didSlideBarChanged:)]) {
        [_delegate videoBar:self didSlideBarChanged:value];
    }
}

- (void)didVoiceClicked:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (_delegate != nil &&
        [_delegate respondsToSelector:@selector(videoBar:isSlilence:)]) {
        [_delegate videoBar:self isSlilence:sender.selected];
    }
}

- (void)didSizeClicked:(UIButton *)sender {
    if (_delegate != nil &&
        [_delegate respondsToSelector:@selector(didSizeBtClicked:)]) {
        [_delegate didSizeBtClicked:self];
    }
}

@end
