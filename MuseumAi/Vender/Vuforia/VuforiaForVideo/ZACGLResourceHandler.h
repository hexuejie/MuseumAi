//
//  ZACGLResourceHandler.h
//  MuseumAi
//
//  Created by 魏宙辉 on 2019/2/25.
//  Copyright © 2019年 Weizh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZACGLResourceHandler <NSObject>

@required
- (void) freeOpenGLESResources;
- (void) finishOpenGLESCommands;

@end

NS_ASSUME_NONNULL_END
