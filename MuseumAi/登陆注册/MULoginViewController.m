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
#import "MUForgetPwdViewController.h"
#import "AppDelegate.h"

typedef NS_ENUM(NSInteger, MULOGINTYPE) {
    MULOGINTYPEBYUSERID = 1,    // 用户名密码登录
    MULOGINTYPEBYCODE  ,         // 验证码登录
    MULOGINTYPEBYREGISTER           // 注册登录
};

@interface MULoginViewController ()<UITextFieldDelegate>


@property (weak, nonatomic) IBOutlet UIButton *chooseLoginButton;
@property (weak, nonatomic) IBOutlet UIButton *chooseRegisterButton;
@property (weak, nonatomic) IBOutlet UIView *mainContentView;

@property (strong, nonatomic) IBOutlet UIView *loginByPwdView;
@property (strong, nonatomic) IBOutlet UIView *loginByRegisterView;
@property (strong, nonatomic) IBOutlet UIView *loginByCodeView;




/** 通过用户名登陆 */
@property (weak, nonatomic) IBOutlet UITextField *userIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;

@property (weak, nonatomic) IBOutlet UILabel *phoneTipLabel;
@property (weak, nonatomic) IBOutlet UIView *phoneTipLine;
@property (weak, nonatomic) IBOutlet UILabel *passWordTipLabel;
@property (weak, nonatomic) IBOutlet UIView *passWordTipLine;

@property (weak, nonatomic) IBOutlet UIButton *weichatButton;
@property (weak, nonatomic) IBOutlet UILabel *weichatLabel;
@property (weak, nonatomic) IBOutlet UIButton *qqButton;

///** 通过验证码登陆 */
@property (weak, nonatomic) IBOutlet UILabel *getCodeButton;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;

@property (weak, nonatomic) IBOutlet UILabel *codePhoneTipLabel;
@property (weak, nonatomic) IBOutlet UIView *codePhoneTipLine;
@property (weak, nonatomic) IBOutlet UILabel *codePassWordTipLabel;
@property (weak, nonatomic) IBOutlet UIView *codePassWordTipLine;


///** 注册 */

@property (weak, nonatomic) IBOutlet UILabel *senderCodeLabel;

@property (weak, nonatomic) IBOutlet UITextField *regPhoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *regCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *regPasswordTextField;

@property (weak, nonatomic) IBOutlet UILabel *regPhoneTipLabel;
@property (weak, nonatomic) IBOutlet UIView *regPhoneTipLine;
@property (weak, nonatomic) IBOutlet UILabel *regCodeTipLabel;
@property (weak, nonatomic) IBOutlet UIView *regCodeTipLine;
@property (weak, nonatomic) IBOutlet UILabel *regPassWordTipLabel;
@property (weak, nonatomic) IBOutlet UIView *regPassWordTipLine;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backTop1;




/** 倒计时 */
@property (nonatomic , strong) NSTimer *timer;
@property (nonatomic , assign) NSInteger count;

@property (nonatomic , assign) MULOGINTYPE loginType;

@end

@implementation MULoginViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

#pragma mark - viewInit
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.backTop1.constant = SafeAreaTopHeight-44.0f;
    //j最外层初始化视图
    self.mainContentView.layer.cornerRadius = 10.0;
    self.mainContentView.layer.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.09].CGColor;//0.05
    self.mainContentView.layer.shadowOpacity = 10;
    self.mainContentView.layer.shadowOffset = CGSizeMake(0, 10);;
    self.mainContentView.layer.shadowRadius = 10;
    self.mainContentView.layer.shouldRasterize = NO;
    self.mainContentView.layer.shadowPath = [[UIBezierPath bezierPathWithRoundedRect:[self.mainContentView bounds] cornerRadius:15] CGPath];
    self.mainContentView.layer.masksToBounds = NO;
    
    [self.mainContentView addSubview:self.loginByPwdView];
    [self.mainContentView addSubview:self.loginByRegisterView];
    [self.mainContentView addSubview:self.loginByCodeView];
    [self.loginByPwdView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self.mainContentView);
    }];
    [self.loginByRegisterView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self.mainContentView);
    }];
    [self.loginByCodeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self.mainContentView);
    }];
    
    //内部层初始化视图
    [self viewInit];
}

- (void)viewInit {
//状态初始化
    
    if ([WXApi isWXAppInstalled]) {
        self.weichatLabel.hidden = NO;
        self.weichatButton.hidden = NO;
    }else {
        self.weichatLabel.hidden = YES;
        self.weichatButton.hidden = YES;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didWechatAuthOK:) name:kWechatAuthorOKNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [self.chooseLoginButton addTarget:self action:@selector(chooseLoginButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.chooseRegisterButton addTarget:self action:@selector(chooseRegisterButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.senderCodeLabel addTapTarget:self action:@selector(didGetCodeClicked:)];
    [self.getCodeButton addTapTarget:self action:@selector(didGetCodeClicked:)];
    
    self.userIdTextField.delegate = self;
    self.pwdTextField.delegate = self;
    self.phoneTextField.delegate = self;
    self.codeTextField.delegate = self;
    self.regPhoneTextField.delegate = self;
    self.regCodeTextField.delegate = self;
    self.regPasswordTextField.delegate = self;
    
    self.loginType = MULOGINTYPEBYUSERID;
    [self customReloadSubview];
}


- (void)customReloadSubview{
    [self.view endEditing:YES];
    
    self.phoneTipLabel.hidden = YES;
    self.passWordTipLabel.hidden = YES;
    self.phoneTipLine.backgroundColor = kLineColorDE;
    self.passWordTipLine.backgroundColor = kLineColorDE;
    
    self.codePhoneTipLabel.hidden = YES;
    self.codePassWordTipLabel.hidden = YES;
    self.codePhoneTipLine.backgroundColor = kLineColorDE;
    self.codePassWordTipLine.backgroundColor = kLineColorDE;
    
    self.regPhoneTipLabel.hidden = YES;
    self.regCodeTipLabel.hidden = YES;
    self.regPhoneTipLine.backgroundColor = kLineColorDE;
    self.regCodeTipLine.backgroundColor = kLineColorDE;
    self.regPassWordTipLabel.hidden = YES;
    self.regPassWordTipLine.backgroundColor = kLineColorDE;
    
    if (self.loginType == MULOGINTYPEBYUSERID) {//密码登陆
        self.loginByPwdView.hidden = NO;
        self.loginByRegisterView.hidden = YES;
        self.loginByCodeView.hidden = YES;
        self.chooseLoginButton.titleLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightBold];
        self.chooseRegisterButton.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
        
    }else if (self.loginType == MULOGINTYPEBYCODE) {
        self.loginByPwdView.hidden = YES;
        self.loginByRegisterView.hidden = YES;
        self.loginByCodeView.hidden = NO;
        self.chooseLoginButton.titleLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightBold];
        self.chooseRegisterButton.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
        
    }else if (self.loginType == MULOGINTYPEBYREGISTER) {
        self.loginByPwdView.hidden = YES;
        self.loginByRegisterView.hidden = NO;
        self.loginByCodeView.hidden = YES;
        self.chooseLoginButton.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
        self.chooseRegisterButton.titleLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightBold];
    }
    self.senderCodeLabel.userInteractionEnabled = YES;
    self.getCodeButton.userInteractionEnabled = YES;
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{

    if (textField == self.userIdTextField) {
        self.phoneTipLabel.hidden = NO;
        self.passWordTipLabel.hidden = YES;
        self.phoneTipLine.backgroundColor = kMainColor;
        self.passWordTipLine.backgroundColor = kLineColorDE;
        
    }else if (textField == self.pwdTextField) {
        self.phoneTipLabel.hidden = YES;
        self.passWordTipLabel.hidden = NO;
        self.phoneTipLine.backgroundColor = kLineColorDE;
        self.passWordTipLine.backgroundColor = kMainColor;
    }
    
    if (textField == self.phoneTextField) {
        self.codePhoneTipLabel.hidden = NO;
        self.codePassWordTipLabel.hidden = YES;
        self.codePhoneTipLine.backgroundColor = kMainColor;
        self.codePassWordTipLine.backgroundColor = kLineColorDE;
        
    }else if (textField == self.codeTextField) {
        self.codePhoneTipLabel.hidden = YES;
        self.codePassWordTipLabel.hidden = NO;
        self.codePhoneTipLine.backgroundColor = kLineColorDE;
        self.codePassWordTipLine.backgroundColor = kMainColor;
    }
    
    
    if (textField == self.regPhoneTextField) {
        self.regPhoneTipLabel.hidden = NO;
        self.regCodeTipLabel.hidden = YES;
        self.regPassWordTipLabel.hidden = YES;
        self.regPhoneTipLine.backgroundColor = kMainColor;
        self.regCodeTipLine.backgroundColor = kLineColorDE;
        self.regPassWordTipLine.backgroundColor = kLineColorDE;
        
    }else if (textField == self.regCodeTextField) {
        self.regPhoneTipLabel.hidden = YES;
        self.regCodeTipLabel.hidden = NO;
        self.regPassWordTipLabel.hidden = YES;
        self.regPhoneTipLine.backgroundColor = kLineColorDE;
        self.regCodeTipLine.backgroundColor = kMainColor;
        self.regPassWordTipLine.backgroundColor = kLineColorDE;
        
    }else if (textField == self.regPasswordTextField) {
        self.regPhoneTipLabel.hidden = YES;
        self.regCodeTipLabel.hidden = YES;
        self.regPassWordTipLabel.hidden = NO;
        self.regPhoneTipLine.backgroundColor = kLineColorDE;
        self.regCodeTipLine.backgroundColor = kLineColorDE;
        self.regPassWordTipLine.backgroundColor = kMainColor;
    }
   return  YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    return YES;
}

#pragma mark - Click
#pragma mark 登陆
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
        if (![MUCustomUtils isValidateTelNumber:self.phoneTextField.text]) {
            [self alertWithMsg:@"手机号码格式不正确" handler:nil];
        }else if(self.codeTextField.text.length == 0) {
            [self alertWithMsg:@"请输入验证码" handler:nil];
        }else {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            __weak typeof(self) weakSelf = self;
            [MUHttpDataAccess loginByPhoneNum:self.phoneTextField.text code:self.codeTextField.text success:^(id result) {
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

    }else if(self.loginType == MULOGINTYPEBYREGISTER){
        if (self.regPhoneTextField.text.length == 0) {
            [self alertWithMsg:@"请输入手机号" handler:nil];
            return;
        }
        if (self.regCodeTextField.text.length == 0) {
            [self alertWithMsg:@"请输入验证码" handler:nil];
            return;
        }
        if (self.regPasswordTextField.text.length < 6 || self.regPasswordTextField.text.length > 16) {
            [self alertWithMsg:@"密码长度需要设置在6~16位" handler:nil];
            return;
        }
        if (![MUCustomUtils isValidateTelNumber:self.regPhoneTextField.text]) {
            [self alertWithMsg:@"手机号码格式不正确" handler:nil];
            return;
        }
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        __weak typeof(self) weakSelf = self;
        [MUHttpDataAccess registerByPhone:self.regPhoneTextField.text code:self.regCodeTextField.text password:self.regPasswordTextField.text success:^(id result) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            
            if ([result[@"state"]integerValue] == 10001) {
                [MUUserModel currentUser].userId = result[@"data"];
                [MUHttpDataAccess getUserInfoSuccess:^(id result) {
                    [[MUUserModel currentUser] updateUserWith:result[@"data"][@"member"]];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kDidLoginSuccessNotification object:nil];
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                } failed:nil];
            }else {
                [weakSelf alertWithMsg:result[@"msg"] handler:nil];
            }
            
        } failed:^(NSError *error) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            [weakSelf alertWithMsg:kFailedTips handler:nil];
        }];
    }
}

/** 获取验证码 */
- (void)didGetCodeClicked:(id)sender {
    UITextField *tempTextField;
    if (self.loginType == MULOGINTYPEBYCODE) {
        tempTextField = self.phoneTextField;
    }else if (self.loginType == MULOGINTYPEBYREGISTER) {
        tempTextField = self.regPhoneTextField;
    }
    if (![MUCustomUtils isValidateTelNumber:tempTextField.text]) {
        [self alertWithMsg:@"手机号码格式不正确" handler:nil];
        return;
    }
    if (self.count > 0) {
        return;
    }
    self.senderCodeLabel.userInteractionEnabled = NO;
    self.getCodeButton.userInteractionEnabled = NO;
     
    __weak typeof(self) weakSelf = self;
    [MUHttpDataAccess sendMsgCode:tempTextField.text success:^(id result) {
        weakSelf.senderCodeLabel.userInteractionEnabled = YES;
        weakSelf.getCodeButton.userInteractionEnabled = YES;
        
        if ([result[@"state"]integerValue] == 10001) {
            [weakSelf startCount];
        }else {
            [weakSelf alertWithMsg:result[@"msg"] handler:nil];
        }
    } failed:^(NSError *error) {
        weakSelf.senderCodeLabel.userInteractionEnabled = YES;
        weakSelf.getCodeButton.userInteractionEnabled = YES;
        [weakSelf alertWithMsg:kFailedTips handler:nil];
    }];
    
}
- (void)startCount {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(didOneSecReached:) userInfo:nil repeats:YES];
    self.count = 60;
    
    UILabel *tempLabel;
    if (self.loginType == MULOGINTYPEBYCODE) {
        tempLabel = self.getCodeButton;
    }else if (self.loginType == MULOGINTYPEBYREGISTER) {
        tempLabel = self.senderCodeLabel;
    }
    tempLabel.text = @"60秒后重新获取";
}
- (void)didOneSecReached:(id)sender {
    UILabel *tempLabel;
    if (self.loginType == MULOGINTYPEBYCODE) {
        tempLabel = self.getCodeButton;
    }else if (self.loginType == MULOGINTYPEBYREGISTER) {
        tempLabel = self.senderCodeLabel;
    }
    
    if (self.count > 0) {
        self.count--;
        NSString *countStr = [NSString stringWithFormat:@"%ld秒后重新获取",self.count];
        tempLabel.text = countStr;
        if (self.count == 0) {
            tempLabel.text = @"获取验证码";
            [self.timer invalidate];
            self.timer = nil;
        }
    }
}

#pragma mark push
- (IBAction)forgetPasswordClick:(id)sender {
    MUForgetPwdViewController *forgetVC = [MUForgetPwdViewController new];
    [self.navigationController pushViewController:forgetVC animated:YES];
}

- (IBAction)otherLoginClick:(id)sender {
    if (self.loginType == MULOGINTYPEBYUSERID) {//密码登陆
        self.loginType = MULOGINTYPEBYCODE;
        [self customReloadSubview];
        
    }else if (self.loginType == MULOGINTYPEBYCODE) {
        self.loginType = MULOGINTYPEBYUSERID;
        [self customReloadSubview];
    }
}

- (void)chooseLoginButtonClick{
    if (self.loginType == MULOGINTYPEBYUSERID  || self.loginType == MULOGINTYPEBYCODE) {//密码登陆
        return;
    }
    self.loginType = MULOGINTYPEBYUSERID;
    [self customReloadSubview];
}
- (void)chooseRegisterButtonClick{
    if (self.loginType == MULOGINTYPEBYREGISTER ) {
        return;
    }
    self.loginType = MULOGINTYPEBYREGISTER;
    [self customReloadSubview];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

/** 返回 */
- (IBAction)didReturnClicked:(id)sender {
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
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
/** qq登录 */
- (IBAction)didQQButtonClicked:(id)sender {
    __weak typeof(self) weakSelf = self;
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate loginByQQ:^(NSString *errorMsg, NSDictionary *response) {
        if (errorMsg.length > 0) {
            [weakSelf alertWithMsg:errorMsg handler:nil];
        } else {
            [MUHttpDataAccess loginByQQOpenId:response[@"openID"] photoUrl:response[@"image"] nickName:response[@"nickname"] sex:response[@"sex"] success:^(id result) {
                if ([result[@"state"]integerValue] == 10001) {
                    [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                    
                    NSString *userId = result[@"data"];
                    NSDictionary *userDic = @{
                                              @"id":userId,
                                              @"phone":@"",
                                              @"memberRade":@"0",
                                              @"memberType":@"0",
                                              @"sex":[NSString stringWithFormat:@"%@",response[@"sex"]],
                                              @"nikeName":[NSString stringWithFormat:@"%@",response[@"nickname"]],
                                              @"photo":[NSString stringWithFormat:@"%@",response[@"image"]],
                                              };
                    [[MUUserModel currentUser] loadDataWithLoginDic:userDic];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kDidLoginSuccessNotification object:nil];
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }
            } failed:^(NSError *error) {
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                [weakSelf alertWithMsg:kFailedTips handler:nil];
            }];
        }
    }];
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
