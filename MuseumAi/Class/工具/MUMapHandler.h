//
//  MUMapHandler.h
//  MuseumAi
//
//  Created by Kingo on 2018/9/18.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMKLocationkit/BMKLocationComponent.h>

typedef void(^MUMAPPOSITIONBLOCK)(CLLocation *location, BMKLocationReGeocode *regeo);

@interface MUMapHandler : NSObject

+ (instancetype)getInstance;

- (void)fetchPositionAsyn:(MUMAPPOSITIONBLOCK)postionHandler;

@end
