//
//  MUScanBackView.h
//  MuseumAi
//
//  Created by 魏宙辉 on 2019/2/27.
//  Copyright © 2019年 Weizh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MUExhibitModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^MUButtonCallBack)(id sender);
typedef void(^MUExhibitSelected)(MUExhibitModel *exhibit);

@interface MUScanBackView : UIView

@property (weak, nonatomic) IBOutlet UILabel *hallNameLabel;

@property (weak, nonatomic) IBOutlet UIView *hotExhibitsBgView;
@property (weak, nonatomic) IBOutlet UICollectionView *hotExhibitsCollectionView;

@property (weak, nonatomic) IBOutlet UIView *buttonsBgView;

/* 热门展品 */
@property(nonatomic, strong) NSArray<MUExhibitModel *> *exhibits;

+ (instancetype)scanBackViewShareCallback:(MUButtonCallBack)shareCallback
                             helpCallback:(MUButtonCallBack)helpCallback
                            guideCallback:(MUButtonCallBack)guideCallback
                             mainCallback:(MUButtonCallBack)mainCallback
                     exhibitSelectHandler:(MUExhibitSelected)exhibitSelectHandler;

@end

NS_ASSUME_NONNULL_END
