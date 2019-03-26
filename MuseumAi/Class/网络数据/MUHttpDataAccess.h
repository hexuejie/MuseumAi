//
//  MUHttpDataAccess.h
//  MuseumAi
//
//  Created by Kingo on 2018/9/18.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MUHttpConstant.h"

// halls 展馆
// exhibits 展品
// exhibitions 展览

typedef void (^MUHTTPSUCCESSBLOCK)(id result);
typedef void (^MUHTTPFAILEDBLOCK)(NSError *error);

typedef NS_ENUM(NSInteger, MUEXHIBITIONTYPE) {
    MUEXHIBITIONTYPEDEFAULT = 0,    // 默认的
    MUEXHIBITIONTYPEHOT = 1,        // 热门的
    MUEXHIBITIONTYPEWILL = 2,       // 即将的
    MUEXHIBITIONTYPEONLINE = 3      // 线上的
};

typedef NS_ENUM(NSInteger, MUHOTTYPE) {
    MUHOTTYPEEXHIBITION = 0,    // 热门展览
    MUHOTTYPECLASS,             // 热门课程
    MUHOTTYPESHOP               // 热门商铺
};

typedef NS_ENUM(NSInteger, MUCOMMENTTYPE) {
    MUEXHIBITOCOMMENT = 1,  // 展品讲解
    MUMARKETCOMMENT = 2,    // 商城
    MUSHOWCOMMENT = 3,      // 秀一秀
    MUEXHIBITSCOMMENT = 4,  // 展品
    MUCOMMENT = 5,          // 评论
    MUCOURSECOMMENT = 6,    // 课堂
    MUEXHIBITIONCOMMENT = 7 // 展览
};

typedef NS_ENUM(NSInteger, MUFOOTPRINTTYPE) {
    MUFOOTPRINTTYPEEXHIBIT = 1,     // 展品
    MUFOOTPRINTTYPEEXHIBITION = 2,  // 展览
    MUFOOTPRINTTYPEHALL = 3,        // 展馆
    MUFOOTPRINTTYPESHOP = 4,        // 文创
};

@interface MUHttpDataAccess : NSObject

#pragma mark ---- 游客接口

/** 获取抽奖活动 */
+ (void)getActivityStateSuccess:(MUHTTPSUCCESSBLOCK)success
                         failed:(MUHTTPFAILEDBLOCK)failed;

/** 获取蓝牙识别距离参数 */
+ (void)getBlueToothParameterWithHallId:(NSString *)hallId
                                success:(MUHTTPSUCCESSBLOCK)success
                                 failed:(MUHTTPFAILEDBLOCK)failed;

/** 获取展览列表(详情) */
+ (void)getExhibitionsWithLong:(CGFloat)lng
                           lat:(CGFloat)lat
                          page:(NSInteger)page
                         state:(MUEXHIBITIONTYPE)exhibitionState
                exhibitionName:(NSString *)exhibitionName
                  exhibitionId:(NSString *)exhibitionId
                       success:(MUHTTPSUCCESSBLOCK)success
                        failed:(MUHTTPFAILEDBLOCK)failed;

/** 提交展览评分 */
+ (void)submitScoreToExhibition:(NSString *)exhibitionId
                           name:(NSString *)exhibitionName
                          count:(NSInteger)count
                        success:(MUHTTPSUCCESSBLOCK)success
                         failed:(MUHTTPFAILEDBLOCK)failed;

/** 获取展区展品 */
+ (void)getExhibitsFromRegionId:(NSString *)regionId
                          isHot:(BOOL)ishot
                        success:(MUHTTPSUCCESSBLOCK)success
                         failed:(MUHTTPFAILEDBLOCK)failed;

/** 查询展览评分 */
+ (void)getScoreByExhibtionId:(NSString *)exhibitionId
                      success:(MUHTTPSUCCESSBLOCK)success
                       failed:(MUHTTPFAILEDBLOCK)failed;

/** 获取某展览展品列表 */
+ (void)getExhibitsFromExhition:(NSString *)exhibitionId
                          isHot:(BOOL)isHot
                           page:(NSInteger)page
                        success:(MUHTTPSUCCESSBLOCK)success
                         failed:(MUHTTPFAILEDBLOCK)failed;

/** 获取课程列表 */
+ (void)getClassesWithPage:(NSInteger)page
                   success:(MUHTTPSUCCESSBLOCK)success
                    failed:(MUHTTPFAILEDBLOCK)failed;

/** 获取课程详情 */
+ (void)getCourseDetailWithId:(NSString *)courseId
                      success:(MUHTTPSUCCESSBLOCK)success
                       failed:(MUHTTPFAILEDBLOCK)failed;



/** 获取热门图片(展览，课堂，商铺) */
+ (void)getHotsWithSize:(NSInteger)size
                   type:(MUHOTTYPE)type
                success:(MUHTTPSUCCESSBLOCK)success
                 failed:(MUHTTPFAILEDBLOCK)failed;

/** 获取热门搜索词 */
+ (void)getHotSearchsWithPage:(NSInteger)page
                      success:(MUHTTPSUCCESSBLOCK)success
                       failed:(MUHTTPFAILEDBLOCK)failed;

/** 获取展馆列表 */
+ (void)getMuseumsWithPage:(NSInteger)page
                       lng:(CGFloat)lng
                       lat:(CGFloat)lat
                      code:(NSString *)code
                  hallName:(NSString *)hallName
                   success:(MUHTTPSUCCESSBLOCK)success
                    failed:(MUHTTPFAILEDBLOCK)failed;

+ (void)getExhibitionsHomeWithLong:(CGFloat)lng
                               lat:(CGFloat)lat
                              page:(NSInteger)page
                    exhibitionName:(NSString *)exhibitionName
                      exhibitionId:(NSString *)exhibitionId
                           success:(MUHTTPSUCCESSBLOCK)success
                            failed:(MUHTTPFAILEDBLOCK)failed;

/** 获取展馆介绍 */
+ (void)getHallIntroduceWithHallId:(NSString *)hallId
                           success:(MUHTTPSUCCESSBLOCK)success
                            failed:(MUHTTPFAILEDBLOCK)failed;

/** 获取AR下载信息(Vuforia) */
+ (void)getVuforiaDownloadInfoWithHallId:(NSString *)hallId
                                     lng:(CGFloat)lng
                                     lat:(CGFloat)lat
                                 success:(MUHTTPSUCCESSBLOCK)success
                                  failed:(MUHTTPFAILEDBLOCK)failed;

/** 获取AR下载信息(EasyAR已过期) */
+ (void)getArDownLoadInfoWithHallId:(NSString *)hallId
                                lng:(CGFloat)lng
                                lat:(CGFloat)lat
                            success:(MUHTTPSUCCESSBLOCK)success
                             failed:(MUHTTPFAILEDBLOCK)failed;

/** 获取蓝牙设备信息 */
+ (void)getBluetoothInfoWithHallId:(NSString *)hallId
                           success:(MUHTTPSUCCESSBLOCK)success
                            failed:(MUHTTPFAILEDBLOCK)failed;

/** 获取展区平面图 */
+ (void)getHallRegionWithHallId:(NSString *)hallId
                        success:(MUHTTPSUCCESSBLOCK)success
                         failed:(MUHTTPFAILEDBLOCK)failed;

/** 获取某展馆展品列表 */
+ (void)getExhibitsWithHallId:(NSString *)hallId
                         page:(NSInteger)page
                        isHot:(BOOL)isHot
                      success:(MUHTTPSUCCESSBLOCK)success
                       failed:(MUHTTPFAILEDBLOCK)failed;

/** 获取展品官方讲解详情 */
+ (void)getExhibitDetailWithId:(NSString *)exhibitId
                       success:(MUHTTPSUCCESSBLOCK)success
                        failed:(MUHTTPFAILEDBLOCK)failed;

/** 获取评论列表 */
+ (void)getCommentsWithType:(MUCOMMENTTYPE)type
                       page:(NSInteger)page
                  exhibitId:(NSString *)exhibitId
                    success:(MUHTTPSUCCESSBLOCK)success
                     failed:(MUHTTPFAILEDBLOCK)failed;


#pragma mark ---- 用户接口
/** 用户登陆 */
+ (void)loginWithUserId:(NSString *)userId
               password:(NSString *)password
                success:(MUHTTPSUCCESSBLOCK)success
                 failed:(MUHTTPFAILEDBLOCK)failed;

/** 手机验证码登录 */
+ (void)loginByPhoneNum:(NSString *)phone
                   code:(NSString *)code
                success:(MUHTTPSUCCESSBLOCK)success
                 failed:(MUHTTPFAILEDBLOCK)failed;

/** 微信三方登录 */
+ (void)loginByWechatOpenId:(NSString *)openId
                   photoUrl:(NSString *)photoUrl
                   nickName:(NSString *)nickName
                        sex:(NSString *)sex
                    success:(MUHTTPSUCCESSBLOCK)success
                     failed:(MUHTTPFAILEDBLOCK)failed;
/** qq登录 */
+ (void)loginByQQOpenId:(NSString *)openId
               photoUrl:(NSString *)photoUrl
               nickName:(NSString *)nickName
                    sex:(NSString *)sex
                success:(MUHTTPSUCCESSBLOCK)success
                 failed:(MUHTTPFAILEDBLOCK)failed;

/** 用户名查重 */
+ (void)checkUsernameRepeat:(NSString *)username
                    success:(MUHTTPSUCCESSBLOCK)success
                     failed:(MUHTTPFAILEDBLOCK)failed;

/** 发送验证码 */
+ (void)sendMsgCode:(NSString *)phoneNum
            success:(MUHTTPSUCCESSBLOCK)success
             failed:(MUHTTPFAILEDBLOCK)failed;

/** 注册 */
+ (void)registerByPhone:(NSString *)phoneNum
                   code:(NSString *)code
               password:(NSString *)password
                success:(MUHTTPSUCCESSBLOCK)success
                 failed:(MUHTTPFAILEDBLOCK)failed;

/** 绑定微信 */
+ (void)bindWechatWithOpenId:(NSString *)openId
                     success:(MUHTTPSUCCESSBLOCK)success
                      failed:(MUHTTPFAILEDBLOCK)failed;

/** 旧密码改密 */
+ (void)changePwdWithOldPwd:(NSString *)oldPwd
                     newPwd:(NSString *)newPwd
                    success:(MUHTTPSUCCESSBLOCK)success
                     failed:(MUHTTPFAILEDBLOCK)failed;

/** 验证码改密 */
+ (void)changePwdWithPhoneNumber:(NSString *)phoneNum
                            code:(NSString *)code
                          newPwd:(NSString *)newPwd
                         success:(MUHTTPSUCCESSBLOCK)success
                          failed:(MUHTTPFAILEDBLOCK)failed;

/** 获取用户信息 */
+ (void)getUserInfoSuccess:(MUHTTPSUCCESSBLOCK)success
                    failed:(MUHTTPFAILEDBLOCK)failed;

/** 修改个人信息 */
+ (void)modifyUserInfoByNikeName:(NSString *)nikeName
                             sex:(NSString *)sex
                           email:(NSString *)email
                      occupation:(NSString *)occupation
                     dateOfBirth:(NSString *)dateOfBirth
                           photo:(UIImage *)photo
                         success:(MUHTTPSUCCESSBLOCK)success
                          failed:(MUHTTPFAILEDBLOCK)failed;

/** 收藏展品 */
+ (void)collectExhibitBy:(NSString *)exhibitId
                 success:(MUHTTPSUCCESSBLOCK)success
                  failed:(MUHTTPFAILEDBLOCK)failed;

/** 查看某展品的收藏状态 */
+ (void)getCollectState:(NSString *)exhibitId
                success:(MUHTTPSUCCESSBLOCK)success
                 failed:(MUHTTPFAILEDBLOCK)failed;

/** 获取收藏列表 */
+ (void)getCollectListType:(NSString *)type Success:(MUHTTPSUCCESSBLOCK)success
                    failed:(MUHTTPFAILEDBLOCK)failed;

/** 获取足迹列表 */
+ (void)getFootPrintType:(NSString *)type Success:(MUHTTPSUCCESSBLOCK)success
                     failed:(MUHTTPFAILEDBLOCK)failed;

/** 获取我的评论 */
+ (void)getMyCommentListWithPage:(NSInteger)page
                         success:(MUHTTPSUCCESSBLOCK)success
                          failed:(MUHTTPFAILEDBLOCK)failed;

/** 反馈信息 */
+ (void)feedBackWithContent:(NSString *)content
                    success:(MUHTTPSUCCESSBLOCK)success
                     failed:(MUHTTPFAILEDBLOCK)failed;

/** 展品点赞 */
+ (void)agreeExhibit:(NSString *)exhibitId
             success:(MUHTTPSUCCESSBLOCK)success
              failed:(MUHTTPFAILEDBLOCK)failed;

/** 评论点赞 */
+ (void)agreeComment:(NSString *)commentId
             success:(MUHTTPSUCCESSBLOCK)success
              failed:(MUHTTPFAILEDBLOCK)failed;

/** 提交带图评论 */
+ (void)submitImageCommentWith:(NSString *)content
                    exhibitsId:(NSString *)exhibitsId
                   commentType:(MUCOMMENTTYPE)type
                      pictures:(NSArray<UIImage *> *)images
                       success:(MUHTTPSUCCESSBLOCK)success
                        failed:(MUHTTPFAILEDBLOCK)failed;

/** 提交普通评论 */
+ (void)submitNormalCommentWith:(NSString *)exhibitsId
                        content:(NSString *)content
                        success:(MUHTTPSUCCESSBLOCK)success
                         failed:(MUHTTPFAILEDBLOCK)failed;

/** 喜欢展览 */
+ (void)loveExhibtion:(NSString *)exhibtionId
       exhibitionName:(NSString *)exhibitionName
              success:(MUHTTPSUCCESSBLOCK)success
               failed:(MUHTTPFAILEDBLOCK)failed;

+ (void)downLoadFromUrl:(NSString *)urlStr
             toFilePath:(NSString *)filePath
               progress:(void (^)(CGFloat currentFractor))progressFractor
      completionHandler:(void (^)(NSError * error))completion;

#pragma mark ---- 微信后台

/** 获取微信认证信息 */
+ (void)fetchWechatAccessTokenWithCode:(NSString *)code
                               success:(MUHTTPSUCCESSBLOCK)success
                                failed:(MUHTTPFAILEDBLOCK)failed;

/** 获取微信用户信息 */
+ (void)fetchWechatUserInfoWithToken:(NSString *)token
                              openid:(NSString *)openid
                             success:(MUHTTPSUCCESSBLOCK)success
                              failed:(MUHTTPFAILEDBLOCK)failed;

#pragma mark ---- 后台统计回调
/**
 展品识别统计回调
 
 @param exhibitId 展品ID
 @param method 1扫描,2蓝牙
 */
+ (void)recoganizerExhibitWithExhibitId:(NSString *)exhibitId method:(NSInteger)method;


/**
  足迹统计回调

 @param type 足迹统计类型
 @param statisticID 统计id
 */
+ (void)statisticFootprint:(MUFOOTPRINTTYPE)type statisticID:(NSString *)statisticID;



@end



























