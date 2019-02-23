//
//  MUBlueToothModel.m
//  MuseumAi
//
//  Created by Kingo on 2018/10/8.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUBlueToothModel.h"
#define FOUNEDISTANCE 10.0f  // 10米之内

@interface MUBlueToothModel()

@property (nonatomic , strong) NSMutableArray *mutDistances;

@end

@implementation MUBlueToothModel

+ (instancetype)blueToothModelWithDic:(NSDictionary *)dic {
    MUBlueToothModel *model = [MUBlueToothModel new];
    model.blueToothName = dic[@"bluetoothName"];
    model.blueToothId = dic[@"bluetoothId"];
    if ([model.blueToothName isEqualToString:@"唐三彩"]) {
        model.blueToothId = @"FDA50693-A4E2-4FB1-AFCF-C6EB07647826";
    }
    model.exhibitionId = dic[@"exhibitsId"];
    model.exhibitionUrl = dic[@"exhibitsSurfacePlotUrl"];
    model.regionId = dic[@"regionId"];
    model.audio = dic[@"audio"];
    model.scan = ([dic[@"audioType"]integerValue] == 1);
    model.foundDistance = FOUNEDISTANCE;
    return model;
}

- (NSMutableArray *)mutDistances {
    if (_mutDistances == nil) {
        _mutDistances = [NSMutableArray array];
    }
    return _mutDistances;
}

- (void)addDistanceWithRSSI:(int)rssi {
    int iRSSI = abs(rssi);
    double power = (iRSSI - _valueA) / 10*_valueN;
    double distance = pow(10, power);
    if (self.mutDistances.count >= TOTALVALUE) {
        [self.mutDistances removeObjectAtIndex:0];
    }
    NSLog(@"更新距离：%d,%.2f",rssi, distance);
    if (rssi == 0) {
        [self.mutDistances addObject:@(2*_foundDistance)];
    } else {
        [self.mutDistances addObject:@(distance)];
    }
}

- (CGFloat)distance {
    if (self.mutDistances.count == 0) {
        return 2*_foundDistance;
    }
    CGFloat total = 0.0f;
    for (NSNumber *num in self.mutDistances) {
        total += [num doubleValue];
    }
    CGFloat avgDistance = total/self.mutDistances.count;
    return avgDistance;
}

@end
