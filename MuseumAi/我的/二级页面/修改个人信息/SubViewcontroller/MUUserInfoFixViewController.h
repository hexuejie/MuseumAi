//
//  MUUserInfoFixViewController.h
//  MuseumAi
//
//  Created by 何学杰 on 2019/3/4.
//  Copyright © 2019 Weizh. All rights reserved.
//

#import "MURootViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MUALERTTYPE) {
    MUALERTTYPENICKNAME = 0,    // 昵称
    MUALERTTYPEEAMAIL,          // 邮箱
    MUALERTTYPEJOB              // 职业
};

@interface MUUserInfoFixViewController : MURootViewController
@property (weak, nonatomic) IBOutlet UILabel *titleLabelView;
@property (weak, nonatomic) IBOutlet UITextField *fixTextField;

@property (nonatomic , assign) MUALERTTYPE inputType;
@end

NS_ASSUME_NONNULL_END
