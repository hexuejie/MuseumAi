//
//  BeaconClient.h
//  KGOTest
//
//  Created by Kingo on 2018/10/10.
//  Copyright © 2018年 Kingo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MUBlueToothModel.h"

@class ZACIBeaconClient;

@protocol ZACIBeaconClientDelegate <NSObject>

/** 蓝牙状态有改变 */
- (void)ibeacon:(ZACIBeaconClient *)ibeacon didChangeBlueToothStatus:(BOOL)isOn;
/** 发现新的蓝牙设备 */
- (void)ibeacon:(ZACIBeaconClient *)ibeacon didFoundNewBlueTooth:(MUBlueToothModel *)blueTooth;

@end

@interface ZACIBeaconClient : NSObject

/** 代理 */
@property (nonatomic , weak) id<ZACIBeaconClientDelegate> delegate;

- (id)initWithBlueToothes:(NSArray<MUBlueToothModel *> *)blueToothes;

- (BOOL)openClient;
- (void)closeClient;

@end

