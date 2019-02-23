//
//  MUAlightLayout.h
//  MuseumAi
//
//  Created by 魏宙辉 on 2018/9/20.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,AlignType){
    AlignWithLeft,
    AlignWithCenter,
    AlignWithRight
};

@interface MUAlightLayout : UICollectionViewFlowLayout

//两个Cell之间的距离
@property (nonatomic,assign)CGFloat betweenOfCell;
//cell对齐方式
@property (nonatomic,assign)AlignType cellType;

- (instancetype)initWthType:(AlignType)cellType;

@end
