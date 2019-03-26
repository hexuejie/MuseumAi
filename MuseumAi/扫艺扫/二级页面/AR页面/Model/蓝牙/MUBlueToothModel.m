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

/* 距离 */
@property(nonatomic, assign) CGFloat distance;

@end

@implementation MUBlueToothModel

+ (instancetype)blueToothModelWithDic:(NSDictionary *)dic {
    MUBlueToothModel *model = [MUBlueToothModel new];
    model.blueToothName = dic[@"bluetoothName"];
    model.blueToothId = dic[@"bluetoothId"];
    /*
    if ([model.blueToothName isEqualToString:@"唐三彩"]) {
        model.blueToothId = @"FDA50693-A4E2-4FB1-AFCF-C6EB07647826";
    }
    */
    model.exhibitionId = dic[@"exhibitsId"];
    model.exhibitionUrl = dic[@"exhibitsSurfacePlotUrl"];
    model.regionId = dic[@"regionId"];
    model.audio = dic[@"audio"];
    model.scan = ([dic[@"audioType"]integerValue] == 1);
    model.foundDistance = FOUNEDISTANCE;
    model.distance = MAXFLOAT;
    return model;
}

- (void)calcDistanceByRSSI:(int)rssi {
    int iRSSI = abs(rssi);
    double power = (iRSSI-_valueA)/(10.0*_valueN);
    double distance = pow(10, power);
    NSLog(@"参数：a:%.2f,n:%.2f,dis:%.2f",_valueA,_valueN,_foundDistance);
    NSLog(@"更新距离：%d,%.2f",rssi, distance);
    if (rssi == 0) {
        self.distance = 2*_foundDistance;
    } else {
        self.distance = distance;
    }
}

@end
