//
//  BeaconClient.m
//  KGOTest
//
//  Created by Kingo on 2018/10/10.
//  Copyright © 2018年 Kingo. All rights reserved.
//

#import "ZACIBeaconClient.h"
#import "MinewBeaconManager.h"
#import "MinewBeacon.h"

@interface ZACIBeaconClient()<MinewBeaconManagerDelegate>

/** 蓝牙管理  */
@property (strong, nonatomic) MinewBeaconManager *manager;
/** 蓝牙设备 */
@property (strong, nonatomic) NSArray<MUBlueToothModel *> *blueToothes;
/** uuids */
@property (strong, nonatomic) NSArray *blueToothUUIDs;
/** 当前蓝牙 */
@property (strong, nonatomic) MUBlueToothModel *currentBlueTooth;

@end

@implementation ZACIBeaconClient

- (id)initWithBlueToothes:(NSArray<MUBlueToothModel *> *)blueToothes {
    if (self = [super init]) {
        _manager = [MinewBeaconManager sharedInstance];
        _manager.delegate = self;
        _blueToothUUIDs = [blueToothes valueForKey:@"blueToothId"];
        _blueToothes = blueToothes;
    }
    return self;
}

- (void)openClient {
    [_manager startScan:_blueToothUUIDs backgroundSupport:YES];
}

- (void)closeClient {
    [_manager stopScan];
}

#pragma mark - MinewBeaconManagerDelegate

- (void)minewBeaconManager:(MinewBeaconManager *)manager didRangeBeacons:(NSArray<MinewBeacon *> *)beacons
{
    NSLog(@"=======%lu devices", (unsigned long)beacons.count);
    //发现iBeacon Server
    for (MinewBeacon* ibeacon in beacons) {
        NSString * uuid = [ibeacon getBeaconValue:BeaconValueIndex_UUID].stringValue;
        int rssi = (int)[ibeacon getBeaconValue:BeaconValueIndex_RSSI].intValue;
        MUBlueToothModel *blueTooth = [self getBlueToothWithUUID:uuid];
        if (blueTooth == nil) {
            continue;
        }
        [blueTooth addDistanceWithRSSI:rssi];
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
#pragma mark -
- (MUBlueToothModel *)getBlueToothWithUUID:(NSString *)uuid {
    for (MUBlueToothModel *model in self.blueToothes) {
        if ([model.blueToothId caseInsensitiveCompare:uuid] == NSOrderedSame) {
            return model;
        }
    }
    return nil;
}



@end

