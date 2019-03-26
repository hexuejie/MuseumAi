//
//  MUForgetPwdViewController.m
//  MuseumAi
//
//  Created by Kingo on 2018/9/25.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUForgetPwdViewController.h"

@interface MUForgetPwdViewController ()

@property (weak, nonatomic) IBOutlet UIButton *returnBt;

@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;

@property (weak, nonatomic) IBOutlet UITextField *repeatPwdTextField;

@property (weak, nonatomic) IBOutlet UITextField *phoneNumTextField;

@property (weak, nonatomic) IBOutlet UILabel *sendMsgLb;

@property (weak, nonatomic) IBOutlet UITextField *codeTextField;

@property (weak, nonatomic) IBOutlet UIButton *submitBt;
@property (weak, nonatomic) IBOutlet UIView *backGronud;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backTop;

/** 计时器 */
@property (nonatomic , strong) NSTimer *timer;
@property (nonatomic , assign) NSInteger count;


@end

@implementation MUForgetPwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.backTop.constant = SafeAreaTopHeight-44.0f;
    self.count = 0;
    
    self.submitBt.layer.masksToBounds = YES;
    self.submitBt.layer.cornerRadius = 22.0f;
    self.backGronud.layer.cornerRadius = 10.0;
    self.backGronud.layer.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.09].CGColor;//0.05
    self.backGronud.layer.shadowOpacity = 10;
    self.backGronud.layer.shadowOffset = CGSizeMake(0, 10);;
    self.backGronud.layer.shadowRadius = 10;
    self.backGronud.layer.shouldRasterize = NO;
    self.backGronud.layer.shadowPath = [[UIBezierPath bezierPathWithRoundedRect:[self.backGronud bounds] cornerRadius:15] CGPath];
    self.backGronud.layer.masksToBounds = NO;
    
    [self.sendMsgLb addTapTarget:self action:@selector(didSendMsgClicked:)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
}

- (void)didSendMsgClicked:(id)sender {
    [self.view endEditing:YES];
    if (![MUCustomUtils isValidateTelNumber:self.phoneNumTextField.text]) {
        [self alertWithMsg:@"手机号码格式不正确" handler:nil];
        return;
    }
    if (self.count > 0) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    [MUHttpDataAccess sendMsgCode:self.phoneNumTextField.text success:^(id result) {
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
    self.sendMsgLb.text = [NSString stringWithFormat:@"%ld秒后重新获取",self.count];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerReachedOneSec) userInfo:nil repeats:YES];
}
- (void)timerReachedOneSec {
    if (self.count <= 0) {
        [self.timer invalidate];
        self.timer = nil;
        self.sendMsgLb.text = @"获取验证码";
    }
    self.count--;
    self.sendMsgLb.text = [NSString stringWithFormat:@"%ld秒后重新获取",self.count];
    if (self.count == 0) {
        [self.timer invalidate];
        self.timer = nil;
        self.sendMsgLb.text = @"获取验证码";
    }
}

- (IBAction)returnClicked:(id)sender {
    [self.timer invalidate];
    self.timer = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)didSubmitClicked:(id)sender {

    NSString *newPwd = self.pwdTextField.text;
    NSString *repeatPwd = self.repeatPwdTextField.text;
    NSString *phone = self.phoneNumTextField.text;
    NSString *code = self.codeTextField.text;
    
    if (newPwd.length == 0) {
        [self alertWithMsg:@"新密码不能为空" handler:nil];
        return;
    }
//    if (![newPwd isEqualToString:repeatPwd]) {
//        [self alertWithMsg:@"密码输入不一致" handler:nil];
//        return;
//    }
    if (![MUCustomUtils isValidateTelNumber:phone]) {
        [self alertWithMsg:@"电话号码格式不正确" handler:nil];
        return;
    }
    if (code.length == 0) {
        [self alertWithMsg:@"请输入验证码" handler:nil];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [MUHttpDataAccess changePwdWithPhoneNumber:phone code:code newPwd:newPwd success:^(id result) {
        
        if ([result[@"state"]integerValue] == 10001) {
            [weakSelf alertWithMsg:result[@"msg"] handler:^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }];
        }else {
            [weakSelf alertWithMsg:result[@"msg"] handler:nil];
        }
    } failed:^(NSError *error) {
        [weakSelf alertWithMsg:kFailedTips handler:nil];
    }];
}
- (void)keyboardChange:(NSNotification *)note{
    CGRect frame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyHeight =  [UIScreen mainScreen].bounds.size.height - frame.origin.y;
    self.view.frame = CGRectMake(0, -keyHeight/5, SCREEN_WIDTH, SCREEN_HEIGHT);
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
}
- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.timer != nil) {
        [self.timer invalidate];
        self.timer = nil;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
