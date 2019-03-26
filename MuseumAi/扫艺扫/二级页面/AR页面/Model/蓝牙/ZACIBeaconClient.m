//
//  BeaconClient.m
//  KGOTest
//
//  Created by Kingo on 2018/10/10.
//  Copyright © 2018年 Kingo. All rights reserved.
//

#import "ZACIBeaconClient.h"

#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface ZACIBeaconClient()<CLLocationManagerDelegate,CBCentralManagerDelegate>

/** 定位管理器 */
@property (nonatomic , strong) CLLocationManager *locationManager;
/** 蓝牙设备列表 */
@property (nonatomic , strong) NSArray<MUBlueToothModel *> *blueToothes;
@property (nonatomic , strong) NSArray<CLBeaconRegion *> *regions;
/** 蓝牙状态检测 */
@property(nonatomic , strong) CBCentralManager *centralManager;
/** 当前已检测到的蓝牙 */
@property (nonatomic , strong) MUBlueToothModel *currentBlueTooth;

@end

@implementation ZACIBeaconClient

- (id)initWithBlueToothes:(NSArray<MUBlueToothModel *> *)blueToothes {
    if (self = [super init]) {
        
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        
        _blueToothes = blueToothes;
        _regions = [self regionsFromBlueToothes:blueToothes];
        
        _centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
        _currentBlueTooth = nil;
    }
    return self;
}

- (BOOL)openClient {
    // 在开始监控之前，我们需要判断改设备是否支持，和区域权限请求
    BOOL availableMonitor = [CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]];
    
    if (availableMonitor) {
        CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
        switch (authorizationStatus) {
            case kCLAuthorizationStatusNotDetermined: {
                [_locationManager requestAlwaysAuthorization];
                return NO;
                break;
            }
            case kCLAuthorizationStatusRestricted:
            case kCLAuthorizationStatusDenied: {
                NSLog(@"受限制或者拒绝");
                return NO;
                break;
            }
            case kCLAuthorizationStatusAuthorizedAlways:
            case kCLAuthorizationStatusAuthorizedWhenInUse:{
                for (CLBeaconRegion *region in self.regions) {
                    [_locationManager startRangingBeaconsInRegion:region];
                    [_locationManager startMonitoringForRegion:region];
                }
                return YES;
                break;
            }
            default:
                return NO;
                break;
        }
    } else {
        NSLog(@"该设备不支持 CLBeaconRegion 区域检测");
        return NO;
    }
}

- (void)closeClient {
    for (CLBeaconRegion *region in self.regions) {
        [_locationManager stopRangingBeaconsInRegion:region];
        [_locationManager stopMonitoringForRegion:region];
    }
}

#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBManagerStatePoweredOn: {
            if (_delegate != nil &&
                [_delegate respondsToSelector:@selector(ibeacon:didChangeBlueToothStatus:)]) {
                [_delegate ibeacon:self didChangeBlueToothStatus:YES];
            }
            break;
        }
        case CBManagerStatePoweredOff:{
            if (_delegate != nil &&
                [_delegate respondsToSelector:@selector(ibeacon:didChangeBlueToothStatus:)]) {
                [_delegate ibeacon:self didChangeBlueToothStatus:NO];
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status  {
    if (status == kCLAuthorizationStatusAuthorizedAlways
        || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        for (CLBeaconRegion *region in self.regions) {
            [_locationManager stopRangingBeaconsInRegion:region];
            [_locationManager stopMonitoringForRegion:region];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"!!");
}

- (void)locationManager:(CLLocationManager *)manager
      didDetermineState:(CLRegionState)state
              forRegion:(CLRegion *)region {
    
    if(state == CLRegionStateInside) {
        NSLog(@"靠近region:%@",region);
    }else if(state == CLRegionStateOutside) {
        NSLog(@"离开region:%@",region);
    }else {
        NSLog(@"其他状态");
    }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    //发现iBeacon Server
    for (CLBeacon* beacon in beacons) {
        NSString * uuid = beacon.proximityUUID.UUIDString;
        int rssi = (int)beacon.rssi;
        MUBlueToothModel *blueTooth = [self getBlueToothWithUUID:uuid];
        if (blueTooth == nil) {
            continue;
        }
        [blueTooth calcDistanceByRSSI:rssi];
    }
    CGFloat minDistance = MAXFLOAT;
    MUBlueToothModel *minBlueTooth = nil;
    for (MUBlueToothModel *blueTooth in self.blueToothes) {
        if (blueTooth.distance < minDistance) {
            minBlueTooth = blueTooth;
            minDistance = blueTooth.distance;
        }
    }
    if (minDistance > [self.blueToothes firstObject].foundDistance) {
        if (self.currentBlueTooth != nil) {
            self.currentBlueTooth = nil;
            if (_delegate != nil &&
                [_delegate respondsToSelector:@selector(ibeacon:didFoundNewBlueTooth:)]) {
                [_delegate ibeacon:self didFoundNewBlueTooth:self.currentBlueTooth];
            }
        }
    }else {
        if (![self.currentBlueTooth isEqual:minBlueTooth]) {
            self.currentBlueTooth = minBlueTooth;
            if (_delegate != nil &&
                [_delegate respondsToSelector:@selector(ibeacon:didFoundNewBlueTooth:)]) {
                [_delegate ibeacon:self didFoundNewBlueTooth:self.currentBlueTooth];
            }
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager
         didEnterRegion:(CLRegion *)region {
    NSLog(@"Hi，你已经进入 iSS iBeacon region");
}

- (void)locationManager:(CLLocationManager *)manager
          didExitRegion:(CLRegion *)region {
    NSLog(@"sorry，你离开了 iSS iBeacon region");
}

#pragma mark -

- (NSArray *)regionsFromBlueToothes:(NSArray *)blueToothes {
    
    NSMutableArray *mutRegions = [NSMutableArray array];
    for (int i=0; i<blueToothes.count; i++) {
        MUBlueToothModel *blueTooth = blueToothes[i];
        NSUUID *uuid = [[NSUUID alloc]initWithUUIDString:blueTooth.blueToothId];
        CLBeaconRegion *region = [[CLBeaconRegion alloc]initWithProximityUUID:uuid identifier:blueTooth.blueToothName];
        region.notifyOnExit = YES;
        region.notifyOnEntry = YES;
        region.notifyEntryStateOnDisplay = YES;
        if (region == nil) {
            NSLog(@"蓝牙：%@初始失败",blueTooth.blueToothId);
            continue;
        }
        [mutRegions addObject:region];
    }
    return [NSArray arrayWithArray:mutRegions];
}

- (MUBlueToothModel *)getBlueToothWithUUID:(NSString *)uuid {
    for (MUBlueToothModel *model in self.blueToothes) {
        if ([model.blueToothId caseInsensitiveCompare:uuid] == NSOrderedSame) {
            return model;
        }
    }
    return nil;
}



@end

