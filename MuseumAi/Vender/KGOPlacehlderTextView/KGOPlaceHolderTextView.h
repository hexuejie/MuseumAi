//
//  KGOPlaceHolderTextView.h
//  KingoPalm
//
//  Created by Kingo on 2018/5/16.
//  Copyright © 2018年 Kingo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KGOPlaceHolderTextView : UITextView

/** placeholder string */
@property (nonatomic , strong) NSString *placeHolder;

/** color */
@property (nonatomic , strong) UIColor *placeHolderColor;

@end
