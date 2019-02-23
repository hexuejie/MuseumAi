//
//  MUChangedPwdViewController.m
//  MuseumAi
//
//  Created by Kingo on 2018/9/26.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUChangedPwdViewController.h"

@interface MUChangedPwdViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;


@property (weak, nonatomic) IBOutlet UIButton *returnBt;

@property (weak, nonatomic) IBOutlet UIButton *submitBt;

@property (weak, nonatomic) IBOutlet UITextField *oldPwdTextField;

@property (weak, nonatomic) IBOutlet UITextField *changedPwdTextField;
@property (weak, nonatomic) IBOutlet UITextField *repeatPwdTextField;

@end

@implementation MUChangedPwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self viewInit];
}

- (void)viewInit {
    
    self.topConstraint.constant = SafeAreaTopHeight-44.0f;
    [self.returnBt setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    self.submitBt.enabled = NO;
    self.submitBt.backgroundColor = [kMainColor colorWithAlphaComponent:0.5];
    self.submitBt.layer.cornerRadius = 5.0f;
    self.submitBt.layer.masksToBounds = YES;
    
    self.oldPwdTextField.delegate = self;
    self.changedPwdTextField.delegate = self;
    self.repeatPwdTextField.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidChangeValue:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)textFieldDidChangeValue:(id)sender {
    
    if (self.oldPwdTextField.text.length > 0 &&
        self.changedPwdTextField.text.length > 0 &&
        self.repeatPwdTextField.text.length > 0) {
        self.submitBt.backgroundColor = kMainColor;
        self.submitBt.enabled = YES;
    }else {
        self.submitBt.enabled = NO;
        self.submitBt.backgroundColor = [kMainColor colorWithAlphaComponent:0.5];
    }
}

#pragma mark -

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
- (IBAction)didReturnClicked:(id)sender {
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)didSubmitBtClicked:(id)sender {
    [self.view endEditing:YES];
    NSString *oldPwd = self.oldPwdTextField.text;
    NSString *newPwd = self.changedPwdTextField.text;
    NSString *repeatPwd = self.repeatPwdTextField.text;
    if (oldPwd.length == 0 || newPwd.length == 0) {
        // 按钮使能有作限制，正常情况下，程序不会跑入这里
        return;
    }
    if (newPwd.length < 6 || newPwd.length>16) {
        [self alertWithMsg:@"密码请输入6~16个字符" handler:nil];
        return;
    }
    if (![newPwd isEqualToString:repeatPwd]) {
        [self alertWithMsg:@"密码输入不一致" handler:nil];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [MUHttpDataAccess changePwdWithOldPwd:oldPwd newPwd:newPwd success:^(id result) {
        
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}



@end
