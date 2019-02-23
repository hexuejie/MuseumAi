//
//  MURegisterViewController.m
//  MuseumAi
//
//  Created by Kingo on 2018/9/25.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MURegisterViewController.h"

@interface MURegisterViewController ()

@property (weak, nonatomic) IBOutlet UILabel *codeLb;

@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;

@property (weak, nonatomic) IBOutlet UITextField *codeTextField;

@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;

@property (weak, nonatomic) IBOutlet UIButton *submitBt;

/** 倒计时 */
@property (nonatomic , strong) NSTimer *timer;
@property (nonatomic , assign) NSInteger count;

@end

@implementation MURegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.submitBt.layer.masksToBounds = YES;
    self.submitBt.layer.cornerRadius = 5.0f;
    
    self.codeLb.layer.masksToBounds = YES;
    self.codeLb.layer.cornerRadius = 2.0f;
    self.codeLb.layer.borderColor = kUIColorFromRGB(0x666666).CGColor;
    self.codeLb.layer.borderWidth = 1.0f;
    [self.codeLb addTapTarget:self action:@selector(getCodeClicked:)];
}

#pragma mark -

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.timer invalidate];
    self.timer = nil;
}
- (IBAction)didReturnClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)didSubmitClicked:(id)sender {
    if (self.phoneTextField.text.length == 0) {
        [self alertWithMsg:@"请输入手机号" handler:nil];
        return;
    }
    if (self.codeTextField.text.length == 0) {
        [self alertWithMsg:@"请输入验证码" handler:nil];
        return;
    }
    if (self.pwdTextField.text.length < 6 || self.pwdTextField.text.length > 16) {
        [self alertWithMsg:@"密码长度需要设置在6~16位" handler:nil];
        return;
    }
    if (![MUCustomUtils isValidateTelNumber:self.phoneTextField.text]) {
        [self alertWithMsg:@"手机号码格式不正确" handler:nil];
        return;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak typeof(self) weakSelf = self;
    [MUHttpDataAccess registerByPhone:self.phoneTextField.text code:self.codeTextField.text password:self.pwdTextField.text success:^(id result) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        
        if ([result[@"state"]integerValue] == 10001) {
            [MUUserModel currentUser].userId = result[@"data"];
            [MUHttpDataAccess getUserInfoSuccess:^(id result) {
                [[MUUserModel currentUser] updateUserWith:result[@"data"][@"member"]];
                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
            } failed:nil];
        }else {
            [weakSelf alertWithMsg:result[@"msg"] handler:nil];
        }
        
    } failed:^(NSError *error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf alertWithMsg:kFailedTips handler:nil];
    }];
}

- (void)getCodeClicked:(id)sender {
    [self.view endEditing:YES];
    if (![MUCustomUtils isValidateTelNumber:self.phoneTextField.text]) {
        [self alertWithMsg:@"手机号码格式不正确" handler:nil];
        return;
    }
    if (self.count > 0) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    [MUHttpDataAccess sendMsgCode:self.phoneTextField.text success:^(id result) {
        if ([result[@"state"]integerValue] == 10001) {
            [weakSelf startCount];
        }else {
            [weakSelf alertWithMsg:result[@"msg"] handler:nil];
        }
    } failed:^(NSError *error) {
        [weakSelf alertWithMsg:kFailedTips handler:nil];
    }];
}

- (void)startCount {
    self.count = 60.0f;
    self.codeLb.text = [NSString stringWithFormat:@"%ld秒后重新发送",self.count];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerReachedOneSec) userInfo:nil repeats:YES];
}
- (void)timerReachedOneSec {
    if (self.count <= 0) {
        [self.timer invalidate];
        self.timer = nil;
        self.codeLb.text = @"验证码";
    }
    self.count--;
    self.codeLb.text = [NSString stringWithFormat:@"%ld秒",self.count];
    if (self.count == 0) {
        [self.timer invalidate];
        self.timer = nil;
        self.codeLb.text = @"验证码";
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
