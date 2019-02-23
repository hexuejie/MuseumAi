//
//  MUSearchModel.h
//  MuseumAi
//
//  Created by Kingo on 2018/9/20.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MUSearchModel : NSObject

/** 展览名称 */
@property (nonatomic , copy) NSString *name;
/** id */
@property (nonatomic , copy) NSString *exhibitionId;
/** 点击量 */
@property (nonatomic , copy) NSString *clickNum;

@end
