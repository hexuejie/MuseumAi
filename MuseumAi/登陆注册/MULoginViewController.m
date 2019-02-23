//
//  MULoginViewController.m
//  MuseumAi
//
//  Created by Kingo on 2018/9/25.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MULoginViewController.h"
#import "MURegisterViewController.h"
#import "MUForgetPwdViewController.h"
#import "WXApi.h"

typedef NS_ENUM(NSInteger, MULOGINTYPE) {
    MULOGINTYPEBYUSERID = 1,    // 用户名密码登录
    MULOGINTYPEBYCODE           // 验证码登录
};

@interface MULoginViewController ()

/** 输入背景 */
@property (weak, nonatomic) IBOutlet UIView *inputBgView;

/** 通过用户名登陆 */
@property (strong, nonatomic) IBOutlet UIView *loginByUserIdBgView;
@property (weak, nonatomic) IBOutlet UITextField *userIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;
@property (weak, nonatomic) IBOutlet UIButton *eyeButton;

/** 通过验证码登陆 */
@property (strong, nonatomic) IBOutlet UIView *loginByCodeBgView;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumTextField;
@property (weak, nonatomic) IBOutlet UILabel *getCodeButton;
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;

/** 登陆按钮 */
@property (weak, nonatomic) IBOutlet UIButton *loginBt;

@property (weak, nonatomic) IBOutlet UILabel *wechatLoginLb;
@property (weak, nonatomic) IBOutlet UIButton *wechatLoginButton;

/** 倒计时 */
@property (nonatomic , strong) NSTimer *timer;
@property (nonatomic , assign) NSInteger count;

@property (nonatomic , assign) MULOGINTYPE loginType;

@end

@implementation MULoginViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self viewInit];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewInit {
    
    [self.inputBgView addSubview:self.loginByUserIdBgView];
    [self.loginByUserIdBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.top.mas_equalTo(0);
    }];
    [self.inputBgView addSubview:self.loginByCodeBgView];
    [self.loginByCodeBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.top.mas_equalTo(0);
    }];
    self.loginByCodeBgView.hidden = YES;
    self.loginByUserIdBgView.hidden = NO;
    
    self.getCodeButton.layer.cornerRadius = 5.0f;
    self.getCodeButton.layer.borderColor = kUIColorFromRGB(0x666666).CGColor;
    self.getCodeButton.layer.borderWidth = 1.0f;
    self.getCodeButton.text = @"获取验证码";
    self.getCodeButton.enabled = YES;
    [self.getCodeButton addTapTarget:self action:@selector(didGetCodeClicked:)];
    
    self.loginBt.layer.cornerRadius = 5.0f;
    self.loginBt.layer.masksToBounds = YES;
    
    self.loginType = MULOGINTYPEBYUSERID;
    
    if ([WXApi isWXAppInstalled]) {
        self.wechatLoginLb.hidden = NO;
        self.wechatLoginButton.hidden = NO;
    }else {
        self.wechatLoginLb.hidden = YES;
        self.wechatLoginButton.hidden = YES;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didWechatAuthOK:) name:kWechatAuthorOKNotification object:nil];
}

#pragma mark -

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
/** 注册 */
- (IBAction)didRegisterClicked:(id)sender {
    [self.view endEditing:YES];
    MURegisterViewController *vc = [MURegisterViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}
/** 返回 */
- (IBAction)didReturnClicked:(id)sender {
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}
/** 密码可见 */
- (IBAction)didEyeClicked:(UIButton *)sender {
    [self.view endEditing:YES];
    sender.selected = !sender.selected;
    if (sender.selected) {
        self.pwdTextField.secureTextEntry = NO;
    }else {
        self.pwdTextField.secureTextEntry = YES;
    }
}
/** 获取验证码 */
- (void)didGetCodeClicked:(id)sender {
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
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(didOneSecReached:) userInfo:nil repeats:YES];
    self.count = 60;
    self.getCodeButton.text = @"60秒后重新获取";
}
- (void)didOneSecReached:(id)sender {
    if (self.count > 0) {
        self.count--;
        NSString *countStr = [NSString stringWithFormat:@"%ld秒后重新获取",self.count];
        self.getCodeButton.text = countStr;
        if (self.count == 0) {
            self.getCodeButton.text = @"获取验证码";
            [self.timer invalidate];
            self.timer = nil;
        }
    }
}

/** 微信登录 */
- (IBAction)didWechatClicked:(id)sender {
    [self.view endEditing:YES];
    if ([WXApi isWXAppInstalled]) {
        SendAuthReq *req = [[SendAuthReq alloc] init];
        req.scope = @"snsapi_userinfo";
        req.state = @"login";
        [WXApi sendReq:req];
    }else {
        [self alertWithMsg:@"您的手机尚未安装微信" handler:nil];
    }
}
- (void)didWechatAuthOK:(NSNotification *)notification {
    NSString *code = (NSString *)notification.object;
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [MUHttpDataAccess fetchWechatAccessTokenWithCode:code success:^(id result) {
        NSString *token = result[@"access_token"];
        NSString *openId = result[@"openid"];
        [MUHttpDataAccess fetchWechatUserInfoWithToken:token openid:openId success:^(id userInfo) {
            
            [MUHttpDataAccess loginByWechatOpenId:openId photoUrl:userInfo[@"headimgurl"] nickName:userInfo[@"nickname"] sex:userInfo[@"sex"] success:^(id result) {
                if ([result[@"state"]integerValue] == 10001) {
                    [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                    
                    NSString *userId = result[@"data"];
                    NSDictionary *userDic = @{
                                              @"id":userId,
                                              @"phone":@"",
                                              @"memberRade":@"0",
                                              @"memberType":@"0",
                                              @"sex":[NSString stringWithFormat:@"%@",userInfo[@"sex"]],
                                              @"nikeName":[NSString stringWithFormat:@"%@",userInfo[@"nickname"]],
                                              @"photo":[NSString stringWithFormat:@"%@",userInfo[@"headimgurl"]],
                                              };
                    [[MUUserModel currentUser] loadDataWithLoginDic:userDic];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kDidLoginSuccessNotification object:nil];
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }
            } failed:^(NSError *error) {
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                [weakSelf alertWithMsg:kFailedTips handler:nil];
            }];
        } failed:^(NSError *error) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            [weakSelf alertWithMsg:kFailedTips handler:nil];
        }];
        
    } failed:^(NSError *error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf alertWithMsg:kFailedTips handler:nil];
    }];
}
/** 登录方式 */
- (IBAction)didTypeBtClicked:(UIButton *)sender {
    [self.view endEditing:YES];
    
    if (self.loginType == MULOGINTYPEBYUSERID) {
        self.loginType = MULOGINTYPEBYCODE;
        self.loginByCodeBgView.hidden = NO;
        self.loginByUserIdBgView.hidden = YES;
        [sender setTitle:@"使用账号密码登录" forState:UIControlStateNormal];
    }else {
        self.loginType = MULOGINTYPEBYUSERID;
        self.loginByCodeBgView.hidden = YES;
        self.loginByUserIdBgView.hidden = NO;
        [sender setTitle:@"使用手机验证码登录" forState:UIControlStateNormal];
    }
    
    
}
/** 忘记密码 */
- (IBAction)didForgetClicked:(id)sender {
    [self.view endEditing:YES];
    MUForgetPwdViewController *vc = [MUForgetPwdViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}
/** 登陆 */
- (IBAction)didLoginClicked:(id)sender {
    [self.view endEditing:YES];
    if (self.loginType == MULOGINTYPEBYUSERID) {
        // 用户名密码登陆
        if (self.userIdTextField.text.length == 0 ||
            self.pwdTextField.text.length == 0) {
            [self alertWithMsg:@"用户名密码不能为空" handler:nil];
        }else {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            __weak typeof(self) weakSelf = self;
            [MUHttpDataAccess loginWithUserId:self.userIdTextField.text password:self.pwdTextField.text success:^(id result) {
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                if ([result[@"state"]integerValue] == 10001) {
                    [[MUUserModel currentUser] loadDataWithLoginDic:result[@"data"]];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kDidLoginSuccessNotification object:nil];
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }else {
                    [weakSelf alertWithMsg:result[@"msg"] handler:nil];
                }
            } failed:^(NSError *error) {
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                [weakSelf alertWithMsg:kFailedTips handler:nil];
            }];
        }
    }else if(self.loginType == MULOGINTYPEBYCODE) {
        // 验证码登陆
        if (![MUCustomUtils isValidateTelNumber:self.phoneNumTextField.text]) {
            [self alertWithMsg:@"手机号码格式不正确" handler:nil];
        }else if(self.codeTextField.text.length == 0) {
            [self alertWithMsg:@"请输入验证码" handler:nil];
        }else {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            __weak typeof(self) weakSelf = self;
            [MUHttpDataAccess loginByPhoneNum:self.phoneNumTextField.text code:self.codeTextField.text success:^(id result) {
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                if ([result[@"state"]integerValue] == 10001) {
                    [[MUUserModel currentUser] loadDataWithLoginDic:result[@"data"]];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kDidLoginSuccessNotification object:nil];
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }else {
                    [weakSelf alertWithMsg:result[@"msg"] handler:nil];
                }
            } failed:^(NSError *error) {
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                [weakSelf alertWithMsg:kFailedTips handler:nil];
            }];
        }
    }
}

- (void)alertWithMsg:(NSString *)msg handler:(void (^)())handler {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:msg message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (handler != nil) {
            handler();
        }
    }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
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
    // Dispose of any resources that can be recreated.
}


@end
