//
//  NotesPhotoContainerView.h
//  KingoPalm
//
//  Created by kingomacmini on 16/9/8.
//  Copyright © 2016年 kingomacmini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotesPhotoContainerView : UIView

@property (nonatomic, strong) NSArray *picPathStringsArray;
@property (nonatomic, strong) NSArray *bigPicPathStringArray;

/** 上部重叠的view */
@property (nonatomic , copy) NSString *topImageName;

/** 高度 */
@property (nonatomic , assign) CGFloat photoContainerHeight;
/** 设置宽度 */
@property (nonatomic , assign) CGFloat photoContainerWidth;

@end
