//
//  MUUserInfoFixViewController.m
//  MuseumAi
//
//  Created by 何学杰 on 2019/3/4.
//  Copyright © 2019 Weizh. All rights reserved.
//

#import "MUUserInfoFixViewController.h"

@interface MUUserInfoFixViewController ()

@end

@implementation MUUserInfoFixViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    switch (self.inputType) {
        case MUALERTTYPENICKNAME: {
            self.fixTextField.placeholder = @"请输入您的昵称";
            self.titleLabelView.text = @"设置昵称";
            break;
        }
        case MUALERTTYPEEAMAIL: {
            self.fixTextField.placeholder = @"请输入您的邮箱";
            self.titleLabelView.text = @"设置邮箱";
            break;
        }
        case MUALERTTYPEJOB: {
            self.fixTextField.placeholder = @"请输入您的职业";
            self.titleLabelView.text = @"设置职业";
        }
        default:
            break;
    }
    
    [self.fixTextField becomeFirstResponder];
}

- (IBAction)saveClick:(id)sender {
    [self.view endEditing:YES];
    //    self.inputAlertBgView.hidden = YES;
    NSString *inputStr = self.fixTextField.text;
    if (inputStr.length == 0) {
        [self alertWithMsg:@"请输入内容" handler:nil];
        return;
    }
    __weak typeof(self) weakSelf = self;
    switch (self.inputType) {
        case MUALERTTYPENICKNAME: {
            [MUHttpDataAccess modifyUserInfoByNikeName:inputStr sex:nil email:nil occupation:nil dateOfBirth:nil photo:nil success:^(id result) {
                if ([result[@"state"]integerValue] == 10001) {
                    [MUUserModel currentUser].nikeName = inputStr;
                    [weakSelf didReturnBtClicked];
                }else {
                    [weakSelf alertWithMsg:result[@"msg"] handler:nil];
                }
            } failed:^(NSError *error) {
                [weakSelf alertWithMsg:kFailedTips handler:nil];
            }];
            break;
        }
        case MUALERTTYPEEAMAIL: {
            if(![MUCustomUtils validateEmail:inputStr]) {
                [self alertWithMsg:@"请输入有效邮箱" handler:nil];
                return;
            }
            [MUHttpDataAccess modifyUserInfoByNikeName:nil sex:nil email:inputStr occupation:nil dateOfBirth:nil photo:nil success:^(id result) {
                if ([result[@"state"]integerValue] == 10001) {
                    [MUUserModel currentUser].email = inputStr;
                    [weakSelf didReturnBtClicked];
                }else {
                    [weakSelf alertWithMsg:result[@"msg"] handler:nil];
                }
            } failed:^(NSError *error) {
                [weakSelf alertWithMsg:kFailedTips handler:nil];
            }];
            break;
        }
        case MUALERTTYPEJOB: {
            [MUHttpDataAccess modifyUserInfoByNikeName:nil sex:nil email:nil occupation:inputStr dateOfBirth:nil photo:nil success:^(id result) {
                if ([result[@"state"]integerValue] == 10001) {
                    [MUUserModel currentUser].occupation = inputStr;
                    [weakSelf didReturnBtClicked];
                }else {
                    [weakSelf alertWithMsg:result[@"msg"] handler:nil];
                }
            } failed:^(NSError *error) {
                [weakSelf alertWithMsg:kFailedTips handler:nil];
            }];
            break;
        }
        default:
            break;
    }
}

- (void)didReturnBtClicked {
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
