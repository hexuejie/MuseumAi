//
//  MUUserModel.h
//  MuseumAi
//
//  Created by Kingo on 2018/9/25.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MUUserModel : NSObject<NSCoding>

/** userId */
@property (nonatomic , copy) NSString *userId;
/** 手机号 */
@property (nonatomic , copy) NSString *phoneNum;
/** 会员等级 */
@property (nonatomic , copy) NSString *vipGrade;
/** 会员类型 1普通，2白银，3黄金 4铂金*/
@property (nonatomic , copy) NSString *vipType;
/** 性别 1男 0女 */
@property (nonatomic , copy) NSString *gender;
/** 昵称 */
@property (nonatomic , copy) NSString *nikeName;
/** 生日 */
@property (nonatomic , copy) NSString *birthDay;
/** 邮箱 */
@property (nonatomic , copy) NSString *email;
/** 职业 */
@property (nonatomic , copy) NSString *occupation;
/** 头像 */
@property (nonatomic , copy) NSString *photo;

/** 性别描述 */
@property (nonatomic , strong, readonly) NSString *genderDescripe;

/** 是否登陆 */
@property (nonatomic , assign) BOOL isLogin;

+ (instancetype)currentUser;

- (void)loadDataWithLoginDic:(NSDictionary *)dic;
- (void)clearDataByLogout;

- (void)updateUserWith:(NSDictionary *)dic;

@end
