///
//  MUHttpDataAccess.m
//  MuseumAi
//
//  Created by Kingo on 2018/9/18.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUHttpDataAccess.h"
#import "AFNetworking.h"
#import "NSData+Base64.h"

@implementation MUHttpDataAccess

#pragma mark ---- 游客接口

/** 获取抽奖活动 */
+ (void)getActivityStateSuccess:(MUHTTPSUCCESSBLOCK)success
                                 failed:(MUHTTPFAILEDBLOCK)failed {
    
    NSString *url = [NSString stringWithFormat:@"%@%@",kURLHostPort,kCustomRoute];
    NSDictionary *bodyDic = @{
                              @"api":@"awardActive",
                              };
    NSDictionary *reqDic = [MUHttpConstant combindDicWithReqBody:bodyDic];
    [[self manager] POST:url parameters:reqDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *result = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        }else {
            result = responseObject;
        }
        if (error == nil) {
            success(result);
        } else {
            failed(error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failed(error);
    }];

}

/** 获取蓝牙识别距离参数 */
+ (void)getBlueToothParameterWithHallId:(NSString *)hallId
                                success:(MUHTTPSUCCESSBLOCK)success
                                 failed:(MUHTTPFAILEDBLOCK)failed {
    
    NSString *url = [NSString stringWithFormat:@"%@%@",kURLHostPort,kCustomRoute];
    NSDictionary *bodyDic = @{
                              @"api":@"GetBluetoothconfigurationData",
                              @"hallId":hallId,
                              };
    NSDictionary *reqDic = [MUHttpConstant combindDicWithReqBody:bodyDic];
    [[self manager] POST:url parameters:reqDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *result = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        }else {
            result = responseObject;
        }
        if (error == nil) {
            success(result);
        } else {
            failed(error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failed(error);
    }];
    
}

+ (void)getExhibitionsHomeWithLong:(CGFloat)lng
                           lat:(CGFloat)lat
                          page:(NSInteger)page
                exhibitionName:(NSString *)exhibitionName
                  exhibitionId:(NSString *)exhibitionId
                       success:(MUHTTPSUCCESSBLOCK)success
                        failed:(MUHTTPFAILEDBLOCK)failed {
    
    NSString *url = [NSString stringWithFormat:@"%@%@",kURLHostPort,kCustomRoute];
    NSDictionary *bodyDic = @{
                              @"api":@"getExhibitionList1",
                              @"long1":@(lng),
                              @"lat1":@(lat),
                              @"page":@(page),
                              @"pageSize":@5,
                              @"exhibitionName":exhibitionName,
//                              @"exhibitionState":exhibitionState?@(exhibitionState):@"",
                              @"id":exhibitionId
                              };
    NSString *userId = [MUUserModel currentUser].userId;
    if (userId != nil) {
        bodyDic = @{
                    @"api":@"getExhibitionList1",
                    @"long1":@(lng),
                    @"lat1":@(lat),
                    @"page":@(page),
                    @"userId":userId,
                    @"pageSize":@5,
                    @"exhibitionName":exhibitionName,
//                    @"exhibitionState":exhibitionState?@(exhibitionState):@"",
                    @"id":exhibitionId
                    };
    }
    NSDictionary *reqDic = [MUHttpConstant combindDicWithReqBody:bodyDic];
    [[self manager] POST:url parameters:reqDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *result = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        }else {
            result = responseObject;
        }
        if (error == nil) {
            success(result);
        } else {
            failed(error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failed(error);
    }];
}

+ (void)getExhibitionsWithLong:(CGFloat)lng
                           lat:(CGFloat)lat
                          page:(NSInteger)page
                         state:(MUEXHIBITIONTYPE)exhibitionState
                exhibitionName:(NSString *)exhibitionName
                  exhibitionId:(NSString *)exhibitionId
                       success:(MUHTTPSUCCESSBLOCK)success
                        failed:(MUHTTPFAILEDBLOCK)failed {
    
    NSString *url = [NSString stringWithFormat:@"%@%@",kURLHostPort,kCustomRoute];
    NSDictionary *bodyDic = @{
                              @"api":@"getExhibitionList",
                              @"long1":@(lng),
                              @"lat1":@(lat),
                              @"page":@(page),
                              @"pageSize":@10,
                              @"exhibitionName":exhibitionName,
                              @"exhibitionState":exhibitionState?@(exhibitionState):@"",
                              @"id":exhibitionId
                              };
    NSString *userId = [MUUserModel currentUser].userId;
    if (userId != nil) {
        bodyDic = @{
                    @"api":@"getExhibitionList",
                    @"long1":@(lng),
                    @"lat1":@(lat),
                    @"page":@(page),
                    @"userId":userId,
                    @"pageSize":@10,
                    @"exhibitionName":exhibitionName,
                    @"exhibitionState":exhibitionState?@(exhibitionState):@"",
                    @"id":exhibitionId
                    };
        
    }
    
    NSDictionary *reqDic = [MUHttpConstant combindDicWithReqBody:bodyDic];
    [[self manager] POST:url parameters:reqDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        NSError *error;
        NSDictionary *result = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        }else {
            result = responseObject;
        }
        if (error == nil) {
            success(result);
        } else {
            failed(error);
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failed(error);
    }];
}

+ (void)getExhibitsFromRegionId:(NSString *)regionId
                          isHot:(BOOL)ishot
                        success:(MUHTTPSUCCESSBLOCK)success
                         failed:(MUHTTPFAILEDBLOCK)failed {
    
    NSString *url = [NSString stringWithFormat:@"%@%@",kURLHostPort,kCustomRoute];
    NSDictionary *bodyDic = @{
                              @"api":@"getHallExhibitsList2",
                              @"hallId":regionId,
                              };
    if (ishot) {
        bodyDic = @{
                    @"api":@"getHallExhibitsList2",
                    @"hallId":regionId,
                    @"isHot":@"1"
                    };
    }
    NSDictionary *reqDic = [MUHttpConstant combindDicWithReqBody:bodyDic];
    [[self manager] POST:url parameters:reqDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *result = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        }else {
            result = responseObject;
        }
        if (error == nil) {
            success(result);
        } else {
            failed(error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failed(error);
    }];
}

+ (void)submitScoreToExhibition:(NSString *)exhibitionId
                           name:(NSString *)exhibitionName
                          count:(NSInteger)count
                        success:(MUHTTPSUCCESSBLOCK)success
                         failed:(MUHTTPFAILEDBLOCK)failed {
    
    NSString *url = [NSString stringWithFormat:@"%@%@",kURLHostPort,kCustomRoute];
    NSString *userId = [MUUserModel currentUser].userId;
    if (userId == nil) {
        return;
    }
    NSDictionary *bodyDic = @{
                              @"api":@"createExhibitionScore",
                              @"userId":userId,
                              @"exhibitionId":exhibitionId,
                              @"exhibitionName":exhibitionName,
                              @"count":@(count)
                              };
    NSDictionary *reqDic = [MUHttpConstant combindDicWithReqBody:bodyDic];
    [[self manager] POST:url parameters:reqDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *result = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        }else {
            result = responseObject;
        }
        if (error == nil) {
            success(result);
        } else {
            failed(error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failed(error);
    }];
}

+ (void)getScoreByExhibtionId:(NSString *)exhibitionId
                      success:(MUHTTPSUCCESSBLOCK)success
                       failed:(MUHTTPFAILEDBLOCK)failed {
    
    NSString *url = [NSString stringWithFormat:@"%@%@",kURLHostPort,kCustomRoute];
    NSDictionary *bodyDic = @{
                              @"api":@"getExhibitionScore",
                              @"id":exhibitionId
                              };
    NSDictionary *reqDic = [MUHttpConstant combindDicWithReqBody:bodyDic];
    [[self manager] POST:url parameters:reqDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *result = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        }else {
            result = responseObject;
        }
        if (error == nil) {
            success(result);
        } else {
            failed(error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failed(error);
    }];
}

+ (void)getExhibitsFromExhition:(NSString *)exhibitionId
                          isHot:(BOOL)isHot
                           page:(NSInteger)page
                        success:(MUHTTPSUCCESSBLOCK)success
                         failed:(MUHTTPFAILEDBLOCK)failed {
    
    NSString *url = [NSString stringWithFormat:@"%@%@",kURLHostPort,kCustomRoute];
    NSDictionary *bodyDic = @{
                              @"api":@"getExhibitionExhibits",
                              @"page":@(page),
                              @"pageSize":@10,
                              @"isHot":isHot?@"1":@"0",
                              @"exhibitionId":exhibitionId
                              };
    NSDictionary *reqDic = [MUHttpConstant combindDicWithReqBody:bodyDic];
    [[self manager] POST:url parameters:reqDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *result = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        }else {
            result = responseObject;
        }
        if (error == nil) {
            success(result);
        } else {
            failed(error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failed(error);
    }];
    
}

+ (void)getClassesWithPage:(NSInteger)page
                   success:(MUHTTPSUCCESSBLOCK)success
                    failed:(MUHTTPFAILEDBLOCK)failed {
    
    NSString *url = [NSString stringWithFormat:@"%@%@",kURLHostPort,kCustomRoute];
    NSDictionary *bodyDic = @{
                              @"api":@"masterClassView",
                              @"page":@(page),
                              @"pageSize":@10
                              };
    NSDictionary *reqDic = [MUHttpConstant combindDicWithReqBody:bodyDic];
    [[self manager] POST:url parameters:reqDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *result = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        }else {
            result = responseObject;
        }
        if (error == nil) {
            success(result);
        } else {
            failed(error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failed(error);
    }];
}

+ (void)getHotsWithSize:(NSInteger)size
                   type:(MUHOTTYPE)type
                success:(MUHTTPSUCCESSBLOCK)success
                 failed:(MUHTTPFAILEDBLOCK)failed {
    
    NSString *url = [NSString stringWithFormat:@"%@%@",kURLHostPort,kCustomRoute];
    NSString *api = @"";
    if (type == MUHOTTYPEEXHIBITION) {
        api = @"getIsHotPicture";
    }else if(type == MUHOTTYPECLASS) {
        api = @"getMasterHotPhop";
    }else if(type == MUHOTTYPESHOP) {
        api = @"selectHotShop";
    }
    NSDictionary *bodyDic = @{
                              @"api":api,
                              @"size":@(size)
                              };
    NSDictionary *reqDic = [MUHttpConstant combindDicWithReqBody:bodyDic];
    [[self manager] POST:url parameters:reqDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *result = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        }else {
            result = responseObject;
        }
        if (error == nil) {
            success(result);
        } else {
            failed(error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failed != nil) {
            failed(error);
        }
    }];
}

+ (void)getHotSearchsWithPage:(NSInteger)page
                      success:(MUHTTPSUCCESSBLOCK)success
                       failed:(MUHTTPFAILEDBLOCK)failed {
    
    NSString *url = [NSString stringWithFormat:@"%@%@",kURLHostPort,kCustomRoute];
    
    NSDictionary *bodyDic = @{
                              @"api":@"selectExhibitionHits",
                              @"page":@(page),
                              @"pageSize":@6
                              };
    NSDictionary *reqDic = [MUHttpConstant combindDicWithReqBody:bodyDic];
    [[self manager] POST:url parameters:reqDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *result = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        }else {
            result = responseObject;
        }
        if (error == nil) {
            success(result);
        } else {
            failed(error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failed != nil) {
            failed(error);
        }
    }];
}

+ (void)getCourseDetailWithId:(NSString *)courseId
                      success:(MUHTTPSUCCESSBLOCK)success
                       failed:(MUHTTPFAILEDBLOCK)failed {
    
    NSString *url = [NSString stringWithFormat:@"%@%@",kURLHostPort,kCustomRoute];
    
    NSDictionary *bodyDic = @{
                              @"api":@"masterClassInfo",
                              @"id":courseId,
                              };
    NSDictionary *reqDic = [MUHttpConstant combindDicWithReqBody:bodyDic];
    [[self manager] POST:url parameters:reqDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *result = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        }else {
            result = responseObject;
        }
        if (error == nil) {
            success(result);
        } else {
            failed(error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failed != nil) {
            failed(error);
        }
    }];
}

+ (void)getMuseumsWithPage:(NSInteger)page
                       lng:(CGFloat)lng
                       lat:(CGFloat)lat
                      code:(NSString *)code
                  hallName:(NSString *)hallName
                   success:(MUHTTPSUCCESSBLOCK)success
                    failed:(MUHTTPFAILEDBLOCK)failed {
    
    NSString *url = [NSString stringWithFormat:@"%@%@",kURLHostPort,kCustomRoute];
    
    NSDictionary *bodyDic = @{
                              @"api":@"getExhibitionHallList",
                              @"page":@(page),
                              @"pageSize":@10,
                              @"long1":@(lng),
                              @"lat1":@(lat),
                              @"hallName":hallName,
                              @"code:":code
                              };
    NSDictionary *reqDic = [MUHttpConstant combindDicWithReqBody:bodyDic];
    [[self manager] POST:url parameters:reqDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *result = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        }else {
            result = responseObject;
        }
        if (error == nil) {
            success(result);
        } else {
            failed(error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failed != nil) {
            failed(error);
        }
    }];
}

+ (void)getHallIntroduceWithHallId:(NSString *)hallId
                           success:(MUHTTPSUCCESSBLOCK)success
                            failed:(MUHTTPFAILEDBLOCK)failed {
    
    NSString *url = [NSString stringWithFormat:@"%@%@",kURLHostPort,kCustomRoute];
    
    NSDictionary *bodyDic = @{
                              @"api":@"getExhibitionHallInfo",
                              @"hallId":hallId
                              };
    NSDictionary *reqDic = [MUHttpConstant combindDicWithReqBody:bodyDic];
    [[self manager] POST:url parameters:reqDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *result = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        }else {
            result = responseObject;
        }
        if (error == nil) {
            success(result);
        } else {
            failed(error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failed != nil) {
            failed(error);
        }
    }];
    
    
}

+ (void)getVuforiaDownloadInfoWithHallId:(NSString *)hallId
                                     lng:(CGFloat)lng
                                     lat:(CGFloat)lat
                                 success:(MUHTTPSUCCESSBLOCK)success
                                  failed:(MUHTTPFAILEDBLOCK)failed {

    NSString *url = [NSString stringWithFormat:@"%@%@",kURLHostPort,kCustomRoute];
    
    NSDictionary *bodyDic = @{
                              @"api":@"getNewResourceBundle",
                              @"long1":@(lng),
                              @"lat1":@(lat),
                              @"hallId":hallId
                              };
    NSDictionary *reqDic = [MUHttpConstant combindDicWithReqBody:bodyDic];
    [[self manager] POST:url parameters:reqDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *result = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        }else {
            result = responseObject;
        }
        if (error == nil) {
            success(result);
        } else {
            failed(error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failed != nil) {
            failed(error);
        }
    }];
    
}

+ (void)getArDownLoadInfoWithHallId:(NSString *)hallId
                                lng:(CGFloat)lng
                                lat:(CGFloat)lat
                            success:(MUHTTPSUCCESSBLOCK)success
                             failed:(MUHTTPFAILEDBLOCK)failed {
    
    NSString *url = [NSString stringWithFormat:@"%@%@",kURLHostPort,kCustomRoute];
    
    NSDictionary *bodyDic = @{
                              @"api":@"getResourceBundle",
                              @"long1":@(lng),
                              @"lat1":@(lat),
                              @"hallId":hallId
                              };
    NSDictionary *reqDic = [MUHttpConstant combindDicWithReqBody:bodyDic];
    [[self manager] POST:url parameters:reqDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *result = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        }else {
            result = responseObject;
        }
        if (error == nil) {
            success(result);
        } else {
            failed(error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failed != nil) {
            failed(error);
        }
    }];
}

+ (void)getBluetoothInfoWithHallId:(NSString *)hallId
                           success:(MUHTTPSUCCESSBLOCK)success
                            failed:(MUHTTPFAILEDBLOCK)failed {
    
    NSString *url = [NSString stringWithFormat:@"%@%@",kURLHostPort,kCustomRoute];
    
    NSDictionary *bodyDic = @{
                              @"api":@"exhibitionBluetoothInfo",
                              @"hallId":hallId,
                              };
    NSDictionary *reqDic = [MUHttpConstant combindDicWithReqBody:bodyDic];
    [[self manager] POST:url parameters:reqDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *result = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        }else {
            result = responseObject;
        }
        if (error == nil) {
            success(result);
        } else {
            failed(error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failed != nil) {
            failed(error);
        }
    }];
}

+ (void)getHallRegionWithHallId:(NSString *)hallId
                        success:(MUHTTPSUCCESSBLOCK)success
                         failed:(MUHTTPFAILEDBLOCK)failed {
    
    NSString *url = [NSString stringWithFormat:@"%@%@",kURLHostPort,kCustomRoute];
    
    NSDictionary *bodyDic = @{
                              @"api":@"selectExhibitionRegion",
                              @"hallId":hallId,
                              };
    NSDictionary *reqDic = [MUHttpConstant combindDicWithReqBody:bodyDic];
    [[self manager] POST:url parameters:reqDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *result = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        }else {
            result = responseObject;
        }
        if (error == nil) {
            success(result);
        } else {
            failed(error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failed != nil) {
            failed(error);
        }
    }];
}

+ (void)getExhibitsWithHallId:(NSString *)hallId
                         page:(NSInteger)page
                        isHot:(BOOL)isHot
                      success:(MUHTTPSUCCESSBLOCK)success
                       failed:(MUHTTPFAILEDBLOCK)failed {
    
    NSString *url = [NSString stringWithFormat:@"%@%@",kURLHostPort,kCustomRoute];
    
    NSDictionary *bodyDic = nil;
    if (isHot) {
        bodyDic = @{
                  @"api":@"getHallExhibitsList",
                  @"page":@(page),
                  @"pageSize":@(10),
                  @"hallId":hallId,
                  @"isHot":@"1"
                  };
    }else {
        bodyDic = @{
                    @"api":@"getHallExhibitsList",
                    @"page":@(page),
                    @"pageSize":@(10),
                    @"hallId":hallId,
                    };
    }
    NSDictionary *reqDic = [MUHttpConstant combindDicWithReqBody:bodyDic];
    [[self manager] POST:url parameters:reqDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *result = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        }else {
            result = responseObject;
        }
        if (error == nil) {
            success(result);
        } else {
            failed(error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failed != nil) {
            failed(error);
        }
    }];
}

+ (void)getExhibitDetailWithId:(NSString *)exhibitId
                       success:(MUHTTPSUCCESSBLOCK)success
                        failed:(MUHTTPFAILEDBLOCK)failed {
    
    NSString *userId = @"";
    if([MUUserModel currentUser].isLogin) {
        userId = [MUUserModel currentUser].userId;
    }
    NSString *url = [NSString stringWithFormat:@"%@%@",kURLHostPort,kCustomRoute];
    
    NSDictionary *bodyDic = @{
                              @"api":@"getHallExhibits",
                              @"exhibitsId":exhibitId,
                              @"userId":userId,
                              @"pageSize":@10
                              };
    NSDictionary *reqDic = [MUHttpConstant combindDicWithReqBody:bodyDic];
    [[self manager] POST:url parameters:reqDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *result = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        }else {
            result = responseObject;
        }
        if (error == nil) {
            success(result);
        } else {
            failed(error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failed != nil) {
            failed(error);
        }
    }];
}

+ (void)getCommentsWithType:(MUCOMMENTTYPE)type
                       page:(NSInteger)page
                  exhibitId:(NSString *)exhibitId
                    success:(MUHTTPSUCCESSBLOCK)success
                     failed:(MUHTTPFAILEDBLOCK)failed {
    
    NSString *url = [NSString stringWithFormat:@"%@%@",kURLHostPort,kCustomRoute];
    
    NSDictionary *bodyDic = @{
                              @"api":@"getHallExhibitsCommentPicture",
                              @"page":@(page),
                              @"pageSize":@(10),
                              @"exhibitsId":exhibitId,
                              @"subsidiaryChannel":@(type)
                              };
    NSDictionary *reqDic = [MUHttpConstant combindDicWithReqBody:bodyDic];
    [[self manager] POST:url parameters:reqDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *result = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        }else {
            result = responseObject;
        }
        if (error == nil) {
            success(result);
        } else {
            failed(error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failed != nil) {
            failed(error);
        }
    }];
}

#pragma mark ---- 用户接口
+ (void)loginWithUserId:(NSString *)userId
               password:(NSString *)password
                success:(MUHTTPSUCCESSBLOCK)success
                 failed:(MUHTTPFAILEDBLOCK)failed {
    
    NSString *url = [NSString stringWithFormat:@"%@%@",kURLHostPort,kUserRoute];
    
    NSDictionary *bodyDic = @{
                              @"api":@"login",
                              @"account":userId,
                              @"pwd":password
                              };
    NSDictionary *reqDic = [MUHttpConstant combindDicWithReqBody:bodyDic];
    [[self manager] POST:url parameters:reqDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *result = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        }else {
            result = responseObject;
        }
        if (error == nil) {
            success(result);
            [MUHttpDataAccess sendPhoneType:result[@"data"][@"id"]];
        } else {
            failed(error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failed != nil) {
            failed(error);
        }
    }];
}

+ (void)loginByPhoneNum:(NSString *)phone
                   code:(NSString *)code
                success:(MUHTTPSUCCESSBLOCK)success
                 failed:(MUHTTPFAILEDBLOCK)failed {
    
    NSString *url = [NSString stringWithFormat:@"%@%@",kURLHostPort,kUserRoute];
    
    NSDictionary *bodyDic = @{
                              @"api":@"phoneLogin",
                              @"phone":phone,
                              @"code":code
                              };
    NSDictionary *reqDic = [MUHttpConstant combindDicWithReqBody:bodyDic];
    [[self manager] POST:url parameters:reqDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *result = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        }else {
            result = responseObject;
        }
        if (error == nil) {
            success(result);
            [MUHttpDataAccess sendPhoneType:result[@"data"][@"id"]];
        } else {
            failed(error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failed != nil) {
            failed(error);
        }
    }];
}

+ (void)loginByWechatOpenId:(NSString *)openId
                   photoUrl:(NSString *)photoUrl
                   nickName:(NSString *)nickName
                        sex:(NSString *)sex
                    success:(MUHTTPSUCCESSBLOCK)success
                     failed:(MUHTTPFAILEDBLOCK)failed {
    
    NSString *url = [NSString stringWithFormat:@"%@%@",kURLHostPort,kUserRoute];
    
    NSDictionary *bodyDic = @{
                              @"api":@"wxlogin",
                              @"openid":openId,
                              @"photo":photoUrl,
                              @"nickname":nickName,
                              @"sex":sex,
                              };
    NSDictionary *reqDic = [MUHttpConstant combindDicWithReqBody:bodyDic];
    [[self manager] POST:url parameters:reqDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *result = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        }else {
            result = responseObject;
        }
        if (error == nil) {
            success(result);
            [MUHttpDataAccess sendPhoneType:result[@"data"]];
        } else {
            failed(error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failed != nil) {
            failed(error);
        }
    }];
}

/** qq登录 */
+ (void)loginByQQOpenId:(NSString *)openId
               photoUrl:(NSString *)photoUrl
               nickName:(NSString *)nickName
                    sex:(NSString *)sex
                success:(MUHTTPSUCCESSBLOCK)success
                 failed:(MUHTTPFAILEDBLOCK)failed {
    
    NSString *url = [NSString stringWithFormat:@"%@%@",kURLHostPort,kUserRoute];
    
    NSDictionary *bodyDic = @{
                              @"api":@"qqlogin",
                              @"userId":openId,
                              @"photo":photoUrl,
                              @"nickname":nickName,
                              @"sex":sex,
                              };
    NSDictionary *reqDic = [MUHttpConstant combindDicWithReqBody:bodyDic];
    [[self manager] POST:url parameters:reqDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *result = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        }else {
            result = responseObject;
        }
        if (error == nil) {
            success(result);
            [MUHttpDataAccess sendPhoneType:result[@"data"]];
        } else {
            failed(error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failed != nil) {
            failed(error);
        }
    }];
}

/** 每次登录成功都向后台传送手机型号 */
+ (void)sendPhoneType:(NSString *)userId {
    if (userId == nil) {
        return;
    }
    NSString *url = [NSString stringWithFormat:@"%@%@",kURLHostPort,kUserRoute];
    
    NSDictionary *bodyDic = @{
                              @"api":@"getPhoneType",
                              @"phoneType":[MUCustomUtils deviceModelName],
                              @"userId":userId,
                              };
    NSDictionary *reqDic = [MUHttpConstant combindDicWithReqBody:bodyDic];
    [[self manager] POST:url parameters:reqDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *result = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        }else {
            result = responseObject;
        }
        NSLog(@"result:%@",result);
        
    } failure:nil];
}

/**
 展品识别统计回调

 @param exhibitId 展品ID
 @param method 1扫描,2蓝牙
 */
+ (void)recoganizerExhibitWithExhibitId:(NSString *)exhibitId method:(NSInteger)method {
    NSString *url = [NSString stringWithFormat:@"%@%@",kURLHostPort,kCustomRoute];
    
    NSDictionary *bodyDic = @{
                              @"api":@"scanOrBluetoothCount",
                              @"type":@(method),
                              @"exhibitsId":exhibitId,
                              };
    NSDictionary *reqDic = [MUHttpConstant combindDicWithReqBody:bodyDic];
    [[self manager] POST:url parameters:reqDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *result = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        }else {
            result = responseObject;
        }
        NSLog(@"result:%@",result);
        
    } failure:nil];
}


+ (void)checkUsernameRepeat:(NSString *)username
                    success:(MUHTTPSUCCESSBLOCK)success
                     failed:(MUHTTPFAILEDBLOCK)failed {
    
    NSString *url = [NSString stringWithFormat:@"%@%@",kURLHostPort,kUserRoute];
    
    NSDictionary *bodyDic = @{
                              @"api":@"loginNameCheckRepeat",
                              @"account":username,
                              };
    NSDictionary *reqDic = [MUHttpConstant combindDicWithReqBody:bodyDic];
    [[self manager] POST:url parameters:reqDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *result = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        }else {
            result = responseObject;
        }
        if (error == nil) {
            success(result);
        } else {
            failed(error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failed != nil) {
            failed(error);
        }
    }];
    
}

+ (void)sendMsgCode:(NSString *)phoneNum
            success:(MUHTTPSUCCESSBLOCK)success
             failed:(MUHTTPFAILEDBLOCK)failed {
    
    NSString *url = [NSString stringWithFormat:@"%@%@",kURLHostPort,kUserRoute];
    
    NSDictionary *bodyDic = @{
                              @"api":@"smsSend",
                              @"phone":phoneNum,
                              };
    NSDictionary *reqDic = [MUHttpConstant combindDicWithReqBody:bodyDic];
    [[self manager] POST:url parameters:reqDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *result = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        }else {
            result = responseObject;
        }
        if (error == nil) {
            success(result);
        } else {
            failed(error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failed != nil) {
            failed(error);
        }
    }];
}

+ (void)registerByPhone:(NSString *)phoneNum
                   code:(NSString *)code
               password:(NSString *)password
                success:(MUHTTPSUCCESSBLOCK)success
                 failed:(MUHTTPFAILEDBLOCK)failed {
    
    NSString *url = [NSString stringWithFormat:@"%@%@",kURLHostPort,kUserRoute];
    
    NSDictionary *bodyDic = @{
                              @"api":@"phoneRegister",
                              @"phone":phoneNum,
                              @"password":password,
                              @"code":code
                              };
    NSDictionary *reqDic = [MUHttpConstant combindDicWithReqBody:bodyDic];
    [[self manager] POST:url parameters:reqDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *result = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        }else {
            result = responseObject;
        }
        if (error == nil) {
            success(result);
        } else {
            failed(error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failed != nil) {
            failed(error);
        }
    }];
}

+ (void)bindWechatWithOpenId:(NSString *)openId
                     success:(MUHTTPSUCCESSBLOCK)success
                      failed:(MUHTTPFAILEDBLOCK)failed {
    
    NSString *url = [NSString stringWithFormat:@"%@%@",kURLHostPort,kUserRoute];
    NSString *userId = [MUUserModel currentUser].userId;
    if (userId == nil) {
        return;
    }
    NSDictionary *bodyDic = @{
                              @"api":@"setUserIdWeixin",
                              @"id":userId,
                              @"openId":openId
                              };
    NSDictionary *reqDic = [MUHttpConstant combindDicWithReqBody:bodyDic];
    [[self manager] POST:url parameters:reqDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *result = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        }else {
            result = responseObject;
        }
        if (error == nil) {
            success(result);
        } else {
            failed(error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failed != nil) {
            failed(error);
        }
    }];
}

+ (void)changePwdWithOldPwd:(NSString *)oldPwd
                     newPwd:(NSString *)newPwd
                    success:(MUHTTPSUCCESSBLOCK)success
                     failed:(MUHTTPFAILEDBLOCK)failed {
    
    NSString *url = [NSString stringWithFormat:@"%@%@",kURLHostPort,kUserRoute];
    NSString *userId = [MUUserModel currentUser].userId;
    if (userId == nil) {
        return;
    }
    NSDictionary *bodyDic = @{
                              @"api":@"changePassword",
                              @"id":userId,
                              @"pwd":oldPwd,
                              @"newPwd":newPwd
                              };
    NSDictionary *reqDic = [MUHttpConstant combindDicWithReqBody:bodyDic];
    [[self manager] POST:url parameters:reqDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *result = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        }else {
            result = responseObject;
        }
        if (error == nil) {
            success(result);
        } else {
            failed(error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failed != nil) {
            failed(error);
        }
    }];
}

+ (void)changePwdWithPhoneNumber:(NSString *)phoneNum
                            code:(NSString *)code
                          newPwd:(NSString *)newPwd
                         success:(MUHTTPSUCCESSBLOCK)success
                          failed:(MUHTTPFAILEDBLOCK)failed {
    
    NSString *url = [NSString stringWithFormat:@"%@%@",kURLHostPort,kUserRoute];
    
    NSDictionary *bodyDic = @{
                              @"api":@"SMSchangePassword",
                              @"newPwd":newPwd,
                              @"phone":phoneNum,
                              @"code":code
                              };
    NSDictionary *reqDic = [MUHttpConstant combindDicWithReqBody:bodyDic];
    [[self manager] POST:url parameters:reqDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *result = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        }else {
            result = responseObject;
        }
        if (error == nil) {
            success(result);
        } else {
            failed(error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failed != nil) {
            failed(error);
        }
    }];
}

+ (void)getUserInfoSuccess:(MUHTTPSUCCESSBLOCK)success
                    failed:(MUHTTPFAILEDBLOCK)failed {
    
    NSString *url = [NSString stringWithFormat:@"%@%@",kURLHostPort,kUserRoute];
    NSString *userId = [MUUserModel currentUser].userId;
    if (userId == nil) {
        return;
    }
    NSDictionary *bodyDic = @{
                              @"api":@"userInfo",
                              @"id":userId,
                              };
    NSDictionary *reqDic = [MUHttpConstant combindDicWithReqBody:bodyDic];
    [[self manager] POST:url parameters:reqDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *result = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        }else {
            result = responseObject;
        }
        if (error == nil) {
            success(result);
        } else {
            failed(error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failed != nil) {
            failed(error);
        }
    }];
}

+ (void)modifyUserInfoByNikeName:(NSString *)nikeName
                             sex:(NSString *)sex
                           email:(NSString *)email
                      occupation:(NSString *)occupation
                     dateOfBirth:(NSString *)dateOfBirth
                           photo:(UIImage *)photo
                         success:(MUHTTPSUCCESSBLOCK)success
                          failed:(MUHTTPFAILEDBLOCK)failed {
    
    NSString *url = [NSString stringWithFormat:@"%@%@",kURLHostPort,kUserRoute];
    NSString *userId = [MUUserModel currentUser].userId;
    if (userId == nil) {
        return;
    }
    NSDictionary *baseDic = @{
                              @"api":@"userInfoUpdate",
                              @"id":userId,
                              };
    NSMutableDictionary *mutBodyDic = [NSMutableDictionary dictionaryWithDictionary:baseDic];
    if (nikeName.length > 0) {
        [mutBodyDic setObject:nikeName forKey:@"nikeName"];
    }
    if (photo != nil) {
        NSData *photoData = UIImageJPEGRepresentation(photo, 1.0);
        if(!photoData) {
            photoData = UIImagePNGRepresentation(photo);
        }
        [mutBodyDic setObject:[photoData base64EncodedString] forKey:@"photo"];
    }
    if (sex.length > 0) {
        [mutBodyDic setObject:sex forKey:@"sex"];
    }
    if (dateOfBirth.length > 0) {
        [mutBodyDic setObject:dateOfBirth forKey:@"dateOfBirth"];
    }
    if (email.length > 0) {
        [mutBodyDic setObject:email forKey:@"email"];
    }
    if (occupation.length > 0) {
        [mutBodyDic setObject:occupation forKey:@"occupation"];
    }
    NSDictionary *bodyDic = [NSDictionary dictionaryWithDictionary:mutBodyDic];
    
    NSDictionary *reqDic = [MUHttpConstant combindDicWithReqBody:bodyDic];
    [[self manager] POST:url parameters:reqDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *result = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        }else {
            result = responseObject;
        }
        if (error == nil) {
            success(result);
        } else {
            failed(error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failed != nil) {
            failed(error);
        }
    }];
}

+ (void)collectExhibitBy:(NSString *)exhibitId
                 success:(MUHTTPSUCCESSBLOCK)success
                  failed:(MUHTTPFAILEDBLOCK)failed {
    
    NSString *url = [NSString stringWithFormat:@"%@%@",kURLHostPort,kUserRoute];
    NSString *userId = [MUUserModel currentUser].userId;
    if (userId == nil) {
        return;
    }
    NSDictionary *bodyDic = @{
                              @"api":@"collectionHallExhibits",
                              @"id":userId,
                              @"exhibitsId":exhibitId
                              };
    NSDictionary *reqDic = [MUHttpConstant combindDicWithReqBody:bodyDic];
    [[self manager] POST:url parameters:reqDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *result = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        }else {
            result = responseObject;
        }
        if (error == nil) {
            success(result);
        } else {
            failed(error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failed != nil) {
            failed(error);
        }
    }];
}

+ (void)getCollectState:(NSString *)exhibitId
                success:(MUHTTPSUCCESSBLOCK)success
                 failed:(MUHTTPFAILEDBLOCK)failed {
    
    NSString *url = [NSString stringWithFormat:@"%@%@",kURLHostPort,kUserRoute];
    NSString *userId = [MUUserModel currentUser].userId;
    if (userId == nil) {
        return;
    }
    NSDictionary *bodyDic = @{
                              @"api":@"collectionState",
                              @"id":userId,
                              @"exhibitsId":exhibitId
                              };
    NSDictionary *reqDic = [MUHttpConstant combindDicWithReqBody:bodyDic];
    [[self manager] POST:url parameters:reqDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *result = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        }else {
            result = responseObject;
        }
        if (error == nil) {
            success(result);
        } else {
            failed(error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failed != nil) {
            failed(error);
        }
    }];
}

+ (void)getCollectListType:(NSString *)type Success:(MUHTTPSUCCESSBLOCK)success
                       failed:(MUHTTPFAILEDBLOCK)failed {
    
    NSString *url = [NSString stringWithFormat:@"%@%@",kURLHostPort,kUserRoute];
    NSString *userId = [MUUserModel currentUser].userId;
    if (userId == nil) {
        return;
    }
    NSDictionary *bodyDic = @{
                              @"type":type,//2
                              @"api":@"collectionList",
                              @"id":userId,
                              };
    NSDictionary *reqDic = [MUHttpConstant combindDicWithReqBody:bodyDic];
    [[self manager] POST:url parameters:reqDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *result = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        }else {
            result = responseObject;
        }
        if (error == nil) {
            success(result);
        } else {
            failed(error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failed != nil) {
            failed(error);
        }
    }];
}

/**
 足迹统计回调
 
 @param type 足迹统计类型
 @param statisticID 统计id
 */
+ (void)statisticFootprint:(MUFOOTPRINTTYPE)type statisticID:(NSString *)statisticID {
    
    NSString *url = [NSString stringWithFormat:@"%@%@",kURLHostPort,kCustomRoute];
    NSString *userId = [MUUserModel currentUser].userId;
    if (userId == nil) {
        userId = @"";
    }
    NSDictionary *bodyDic = @{
                              @"api":@"footprint",
                              @"userId":userId,
                              @"optionType":@(type),
                              @"busId":statisticID,
                              };
    NSDictionary *reqDic = [MUHttpConstant combindDicWithReqBody:bodyDic];
    [[self manager] POST:url parameters:reqDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *result = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        }else {
            result = responseObject;
        }
        NSLog(@"result:%@",result);
        
    } failure:nil];
}

+ (void)getFootPrintType:(NSString *)type Success:(MUHTTPSUCCESSBLOCK)success
                  failed:(MUHTTPFAILEDBLOCK)failed {
    
    NSString *url = [NSString stringWithFormat:@"%@%@",kURLHostPort,kUserRoute];
    NSString *userId = [MUUserModel currentUser].userId;
    if (userId == nil) {
        return;
    }
    NSDictionary *bodyDic = @{
                              @"type":type,//2
                              @"api":@"userFootList",
                              @"userId":userId,
                              };
    NSDictionary *reqDic = [MUHttpConstant combindDicWithReqBody:bodyDic];
    [[self manager] POST:url parameters:reqDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *result = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        }else {
            result = responseObject;
        }
        if (error == nil) {
            success(result);
        } else {
            failed(error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failed != nil) {
            failed(error);
        }
    }];
}

/** 获取我的评论 */
+ (void)getMyCommentListWithPage:(NSInteger)page
                         success:(MUHTTPSUCCESSBLOCK)success
                          failed:(MUHTTPFAILEDBLOCK)failed {
    
    NSString *url = [NSString stringWithFormat:@"%@%@",kURLHostPort,kUserRoute];
    NSString *userId = [MUUserModel currentUser].userId;
    if (userId == nil) {
        return;
    }
    NSDictionary *bodyDic = @{
                              @"api":@"getMyComments",
                              @"userId":userId,
                              @"pageSize":@10,
                              @"page":@(page),
                              };
    NSDictionary *reqDic = [MUHttpConstant combindDicWithReqBody:bodyDic];
    [[self manager] POST:url parameters:reqDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *result = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        }else {
            result = responseObject;
        }
        if (error == nil) {
            success(result);
        } else {
            failed(error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failed != nil) {
            failed(error);
        }
    }];
}

+ (void)feedBackWithContent:(NSString *)content
                    success:(MUHTTPSUCCESSBLOCK)success
                     failed:(MUHTTPFAILEDBLOCK)failed {
    
    NSString *url = [NSString stringWithFormat:@"%@%@",kURLHostPort,kUserRoute];
    NSString *userId = [MUUserModel currentUser].userId;
    if (userId == nil) {
        return;
    }
    NSDictionary *bodyDic = @{
                              @"api":@"userFeedback",
                              @"userId":userId,
                              @"content":content
                              };
    NSDictionary *reqDic = [MUHttpConstant combindDicWithReqBody:bodyDic];
    [[self manager] POST:url parameters:reqDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *result = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        }else {
            result = responseObject;
        }
        if (error == nil) {
            success(result);
        } else {
            failed(error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failed != nil) {
            failed(error);
        }
    }];
}

+ (void)submitImageCommentWith:(NSString *)content
                    exhibitsId:(NSString *)exhibitsId
                   commentType:(MUCOMMENTTYPE)type
                      pictures:(NSArray<UIImage *> *)images
                       success:(MUHTTPSUCCESSBLOCK)success
                        failed:(MUHTTPFAILEDBLOCK)failed {
    
    NSString *url = [NSString stringWithFormat:@"%@%@",kURLHostPort,kUserRoute];
    NSString *userId = [MUUserModel currentUser].userId;
    if (userId == nil) {
        return;
    }
    NSMutableArray *ary = [NSMutableArray array];
    for (UIImage *image in images) {
        NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
        if(!imageData) {
            imageData = UIImagePNGRepresentation(image);
        }
        [ary addObject:[imageData base64EncodedString]];
    }
    NSString *pictureStr = @"";
    if (ary.count > 0) {
        pictureStr = [ary componentsJoinedByString:@","];
    }
    
    NSDictionary *bodyDic = @{
                              @"api":@"commentPicture",
                              @"id":userId,
                              @"exhibitsId":exhibitsId,
                              @"content":content,
                              @"subsidiaryChannel":@(type),
                              @"picture":pictureStr,
                              };
    NSDictionary *reqDic = [MUHttpConstant combindDicWithReqBody:bodyDic];
    [[self manager] POST:url parameters:reqDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *result = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        }else {
            result = responseObject;
        }
        if (error == nil) {
            success(result);
        } else {
            failed(error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failed != nil) {
            failed(error);
        }
    }];
}

+ (void)submitNormalCommentWith:(NSString *)exhibitsId
                        content:(NSString *)content
                        success:(MUHTTPSUCCESSBLOCK)success
                         failed:(MUHTTPFAILEDBLOCK)failed {
    
    NSString *url = [NSString stringWithFormat:@"%@%@",kURLHostPort,kUserRoute];
    NSString *userId = [MUUserModel currentUser].userId;
    if (userId == nil) {
        return;
    }
    
    NSDictionary *bodyDic = @{
                              @"api":@"comment",
                              @"id":userId,
                              @"exhibitsId":exhibitsId,
                              @"content":content,
                              };
    NSDictionary *reqDic = [MUHttpConstant combindDicWithReqBody:bodyDic];
    [[self manager] POST:url parameters:reqDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *result = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        }else {
            result = responseObject;
        }
        if (error == nil) {
            success(result);
        } else {
            failed(error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failed != nil) {
            failed(error);
        }
    }];
}

/** 展品点赞 */
+ (void)agreeExhibit:(NSString *)exhibitId
             success:(MUHTTPSUCCESSBLOCK)success
              failed:(MUHTTPFAILEDBLOCK)failed {
    
    NSString *url = [NSString stringWithFormat:@"%@%@",kURLHostPort,kCustomRoute];
    NSString *userId = [MUUserModel currentUser].userId;
    if (userId == nil) {
        return;
    }
    
    NSDictionary *bodyDic = @{
                              @"api":@"exhibitionLick",
                              @"id":userId,
                              @"exhibitsId":exhibitId,
                              };
    NSDictionary *reqDic = [MUHttpConstant combindDicWithReqBody:bodyDic];
    [[self manager] POST:url parameters:reqDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *result = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        }else {
            result = responseObject;
        }
        if (error == nil) {
            success(result);
        } else {
            failed(error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failed != nil) {
            failed(error);
        }
    }];
}

/** 评论点赞 */
+ (void)agreeComment:(NSString *)commentId
             success:(MUHTTPSUCCESSBLOCK)success
              failed:(MUHTTPFAILEDBLOCK)failed {
    
    NSString *url = [NSString stringWithFormat:@"%@%@",kURLHostPort,kCustomRoute];
    NSString *userId = [MUUserModel currentUser].userId;
    if (userId == nil) {
        return;
    }
    
    NSDictionary *bodyDic = @{
                              @"api":@"commentLick",
                              @"userId":userId,
                              @"commentId":commentId,
                              };
    NSDictionary *reqDic = [MUHttpConstant combindDicWithReqBody:bodyDic];
    [[self manager] POST:url parameters:reqDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *result = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        }else {
            result = responseObject;
        }
        if (error == nil) {
            success(result);
        } else {
            failed(error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failed != nil) {
            failed(error);
        }
    }];
}

/** 喜欢展览 */
+ (void)loveExhibtion:(NSString *)exhibtionId
       exhibitionName:(NSString *)exhibitionName
              success:(MUHTTPSUCCESSBLOCK)success
               failed:(MUHTTPFAILEDBLOCK)failed {
    
    NSString *url = [NSString stringWithFormat:@"%@%@",kURLHostPort,kUserRoute];
    NSString *userId = [MUUserModel currentUser].userId;
    NSString *nikeName = [MUUserModel currentUser].nikeName;
    if (userId == nil || nikeName == nil) {
        return;
    }
    NSDictionary *bodyDic = @{
                              @"api":@"Exhibitionlike",
                              @"authorIdA":userId,
                              @"authorIdB":exhibtionId,
                              @"authorNameA":nikeName,
                              @"authorNameB":exhibitionName,
                              };
    NSDictionary *reqDic = [MUHttpConstant combindDicWithReqBody:bodyDic];
    [[self manager] POST:url parameters:reqDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *result = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        }else {
            result = responseObject;
        }
        if (error == nil) {
            success(result);
        } else {
            failed(error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failed != nil) {
            failed(error);
        }
    }];
}

+ (void)fetchWechatAccessTokenWithCode:(NSString *)code
                               success:(MUHTTPSUCCESSBLOCK)success
                               failed:(MUHTTPFAILEDBLOCK)failed {
    
    NSString *baseUrl = [NSString stringWithFormat:@"%@%@",kWechatBase,kWechatToken];
    NSDictionary *reqDic = @{
                             @"appid":WEIXINKEY,
                             @"secret":WEISCRETKEY,
                             @"code":code,
                             @"grant_type":@"authorization_code"
                             };
    NSString *url = [self combineUrl:baseUrl andDic:reqDic];
    
    [[self manager] GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *result = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        }else {
            result = responseObject;
        }
        if (error == nil) {
            success(result);
        } else {
            failed(error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failed != nil) {
            failed(error);
        }
    }];
    
}

+ (void)fetchWechatUserInfoWithToken:(NSString *)token
                              openid:(NSString *)openid
                             success:(MUHTTPSUCCESSBLOCK)success
                              failed:(MUHTTPFAILEDBLOCK)failed {
    
    NSString *baseUrl = [NSString stringWithFormat:@"%@%@",kWechatBase,kWechatUserInfo];
    NSDictionary *reqDic = @{
                             @"access_token":token,
                             @"openid":openid
                             };
    NSString *url = [self combineUrl:baseUrl andDic:reqDic];
    [[self manager] GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *result = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        }else {
            result = responseObject;
        }
        if (error == nil) {
            success(result);
        } else {
            failed(error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failed != nil) {
            failed(error);
        }
    }];
    
}

#pragma mark ---- 下载
+ (void)downLoadFromUrl:(NSString *)urlStr
             toFilePath:(NSString *)filePath
               progress:(void (^)(CGFloat currentFractor))progressFractor
      completionHandler:(void (^)(NSError * error))completion {
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    [[self manager] downloadTaskWithRequest:req progress:^(NSProgress * _Nonnull downloadProgress) {
        if (progressFractor != nil) {
            progressFractor(downloadProgress.fractionCompleted);
        }
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return [NSURL URLWithString:filePath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if(completion != nil) {
            completion(error);
        }
    }];
}

#pragma mark ---- 自用接口

+ (AFHTTPSessionManager *)manager {
    
    // 初始化对象
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    // 返回的格式 JSON
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    // 可接受的文本参数规格
    manager.responseSerializer.acceptableContentTypes =  [NSSet setWithObjects:@"application/json", @"text/html",@"text/plain",@"text/json",@"text/javascript", nil];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    // 开始设置请求头
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    return manager;
    
}

+ (NSString *)combineUrl:(NSString *)url andDic:(NSDictionary *)dic {
    
    NSMutableArray *mutItems = [NSMutableArray array];
    for (NSString *key in dic.allKeys) {
        NSString *item = [NSString stringWithFormat:@"%@=%@",key,dic[key]];
        [mutItems addObject:item];
    }
    NSString *itemStr = [mutItems componentsJoinedByString:@"&"];
    NSString *combinedUrl = [NSString stringWithFormat:@"%@?%@",url,itemStr];
    
    return combinedUrl;
}


@end
