//
//  MUUserModel.m
//  MuseumAi
//
//  Created by Kingo on 2018/9/25.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUUserModel.h"
#import "MUHttpDataAccess.h"

@implementation MUUserModel

+ (instancetype)currentUser {
    static MUUserModel *user;
    if (user == nil) {
        user = [NSKeyedUnarchiver unarchiveObjectWithFile:[MUUserModel userPath]];
        if (user == nil) {
            user = [MUUserModel new];
            [user clearDataByLogout];
        }
    }
    return user;
}

+ (NSString *)userPath {
    return [NSString stringWithFormat:@"%@/Documents/usermodel.plist",NSHomeDirectory()];
}

- (NSString *)genderDescripe {
    if ([_gender isEqualToString:@"1"]) {
        return @"男";
    }else if([_gender isEqualToString:@"2"]) {
        return @"女";
    }else {
        return @"保密";
    }
}

- (void)loadDataWithLoginDic:(NSDictionary *)dic {
    _isLogin = YES;
    
    self.userId = dic[@"id"];
    self.phoneNum = dic[@"phone"];
    self.vipGrade = dic[@"memberRade"];
    self.vipType = dic[@"memberType"];
    self.gender = dic[@"sex"];
    self.nikeName = dic[@"nikeName"];
    self.photo = dic[@"photo"];
    
    [NSKeyedArchiver archiveRootObject:self toFile:[MUUserModel userPath]];
}

- (void)updateUserWith:(NSDictionary *)dic {
    
    _isLogin = YES;
    
    self.userId = dic[@"id"];
    self.photo = dic[@"photo"];
    self.vipGrade = dic[@"memberRade"];
    self.vipType = dic[@"memberType"];
    if ([dic[@"sex"] isEqualToString:@"男"]) {
        self.gender = @"1";
    }else if([dic[@"sex"] isEqualToString:@"女"]) {
        self.gender = @"2";
    }else {
        self.gender = @"0";
    }
    self.birthDay = dic[@"dateOfBirth"];
    self.email = dic[@"email"];
    self.occupation = dic[@"occupation"];
    self.nikeName = dic[@"nikeName"];
    
    [NSKeyedArchiver archiveRootObject:self toFile:[MUUserModel userPath]];
}

- (void)clearDataByLogout {
    _isLogin = NO;
    self.userId = @"";
    self.phoneNum = @"";
    self.vipGrade = @"";
    self.vipType = @"";
    self.gender = @"";
    self.nikeName = @"";
    self.photo = @"";
    
    [NSKeyedArchiver archiveRootObject:self toFile:[MUUserModel userPath]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:self.userId forKey:@"userId"];
    [aCoder encodeObject:self.phoneNum forKey:@"phoneNum"];
    [aCoder encodeObject:self.vipGrade forKey:@"vipGrade"];
    [aCoder encodeObject:self.vipType forKey:@"vipType"];
    [aCoder encodeObject:self.gender forKey:@"gender"];
    [aCoder encodeObject:self.nikeName forKey:@"nikeName"];
    [aCoder encodeObject:self.photo forKey:@"photo"];
    [aCoder encodeObject:((self.isLogin)?@"1":@"0") forKey:@"loginState"];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.userId = [aDecoder decodeObjectForKey:@"userId"];
        self.phoneNum = [aDecoder decodeObjectForKey:@"phoneNum"];
        self.vipGrade = [aDecoder decodeObjectForKey:@"vipGrade"];
        self.vipType = [aDecoder decodeObjectForKey:@"vipType"];
        self.gender = [aDecoder decodeObjectForKey:@"gender"];
        self.nikeName = [aDecoder decodeObjectForKey:@"nikeName"];
        self.photo = [aDecoder decodeObjectForKey:@"photo"];
        self.isLogin = [[aDecoder decodeObjectForKey:@"loginState"] boolValue];
    }
    return self;
    
}

@end
