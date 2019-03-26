//
//  MUIbeaconAlertView.m
//  MuseumAi
//
//  Created by 魏宙辉 on 2019/3/4.
//  Copyright © 2019年 Weizh. All rights reserved.
//

#import "MUIbeaconAlertView.h"

@interface MUIbeaconAlertView ()

@property (strong, nonatomic) UIImageView *exhibitImageView;

@property (strong, nonatomic) UILabel *tipsLabel;

@end

@implementation MUIbeaconAlertView

+ (instancetype)ibeaconAlertWithImageUrl:(NSString *)url {
    
    MUIbeaconAlertView *alertView = [MUIbeaconAlertView alertViewWithSize:CGSizeMake(SCREEN_WIDTH-100, 100.0f)];
    alertView.tipsLabel = [[UILabel alloc]init];
    alertView.tipsLabel.backgroundColor = [UIColor clearColor];
    alertView.tipsLabel.textColor = kUIColorFromRGB(0x333333);
    alertView.tipsLabel.text = @"附近发现支持扫一扫的展品哦";
    alertView.tipsLabel.textAlignment = NSTextAlignmentCenter;
    [alertView.contentView addSubview:alertView.tipsLabel];
    [alertView.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(30.0f);
    }];
    
    alertView.exhibitImageView = [[UIImageView alloc]init];
    [alertView.contentView addSubview:alertView.exhibitImageView];
    [alertView.exhibitImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.bottom.equalTo(alertView.tipsLabel.mas_top);
    }];
    
    if (url.length > 0 && [url containsString:@"://"]) {
        [alertView.exhibitImageView sd_setImageWithURL:[NSURL URLWithString:url] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (!error) {
                CGFloat imageHeight = (SCREEN_WIDTH-100.0f)*image.size.height/image.size.width;
                alertView.contentSize = CGSizeMake(SCREEN_WIDTH, imageHeight+30.0f);
            }
        }];
    }
    
    return alertView;
}

- (void)setImageUrl:(NSString *)url {
    __weak typeof(self) weakSelf = self;
    if (url.length > 0 && [url containsString:@"://"]) {
        [self.exhibitImageView sd_setImageWithURL:[NSURL URLWithString:url] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (!error) {
                CGFloat imageHeight = (SCREEN_WIDTH-100.0f)*image.size.height/image.size.width;
                weakSelf.contentSize = CGSizeMake(SCREEN_WIDTH, imageHeight+30.0f);
            }
        }];
    }
}

@end
