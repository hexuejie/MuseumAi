//
//  previewPhoto_ViewController.h
//  KingoPalm
//
//  Created by Kingo on 16/11/11.
//  Copyright © 2016年 kingomacmini. All rights reserved.
//

#import "MURootViewController.h"

@class KGOPreviewPhotoViewController;

@protocol KGOPreviewDelegate <NSObject>

@required
-(void)previewPhoto:(KGOPreviewPhotoViewController *)previewPhoto deleteSelectedImageWithImage:(UIImage *)image;
@end

@interface KGOPreviewPhotoViewController : MURootViewController

@property (nonatomic, weak) id<KGOPreviewDelegate> delegate;

/** 当前位置 */
@property (nonatomic , assign) NSInteger currentIndex;

+(void)setPreviewImage:(NSArray *)imageArray;

@end
