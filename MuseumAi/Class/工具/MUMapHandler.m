//
//  MUMapHandler.m
//  MuseumAi
//
//  Created by Kingo on 2018/9/18.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUMapHandler.h"

@interface MUMapHandler()<BMKLocationManagerDelegate>
{
    BMKLocation *_location;
    MUMAPPOSITIONBLOCK _postionHandler;
}
/** 定位 */
@property (nonatomic , strong) BMKLocationManager *locationManager;

@end

@implementation MUMapHandler

+ (instancetype)getInstance {
    static MUMapHandler *handler;
    if (handler == nil) {
        handler = [MUMapHandler new];
        [handler locationInit];
        [[BMKLocationAuth sharedInstance] checkPermisionWithKey:BaiduMapKey authDelegate:nil];
    }
    return handler;
}

- (void)locationInit {
    //初始化实例
    _locationManager = [[BMKLocationManager alloc] init];
    //设置delegate
    _locationManager.delegate = self;
    //设置返回位置的坐标系类型
    _locationManager.coordinateType = BMKLocationCoordinateTypeBMK09LL;
    //设置距离过滤参数
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    //设置预期精度参数
    _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    //设置应用位置类型
    _locationManager.activityType = CLActivityTypeAutomotiveNavigation;
    //设置是否自动停止位置更新
    _locationManager.pausesLocationUpdatesAutomatically = NO;
    //设置是否允许后台定位
    _locationManager.allowsBackgroundLocationUpdates = NO;
    //设置位置获取超时时间
    _locationManager.locationTimeout = 10;
    //设置获取地址信息超时时间
    _locationManager.reGeocodeTimeout = 10;
    
    [_locationManager setLocatingWithReGeocode:YES];
    [_locationManager startUpdatingLocation];
}

- (void)fetchPositionAsyn:(MUMAPPOSITIONBLOCK)postionHandler {
    _postionHandler = postionHandler;
    if (_location) {
        _postionHandler(_location.location, _location.rgcData);
        _postionHandler = nil;
    }
}

#pragma mark -
- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager didUpdateLocation:(BMKLocation * _Nullable)location orError:(NSError * _Nullable)error {
    
    if (error) {
        NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
    } if (location) {//得到定位信息，添加annotation
        _location = location;
        if (_postionHandler) {
            _postionHandler(location.location, location.rgcData);
            _postionHandler = nil;
        }
    }
}

@end
