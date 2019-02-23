//
//  MUFeedBackViewController.m
//  MuseumAi
//
//  Created by Kingo on 2018/9/26.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUFeedBackViewController.h"
#import "KGOPlaceHolderTextView.h"

@interface MUFeedBackViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;

@property (weak, nonatomic) IBOutlet UIButton *returnBt;

@property (weak, nonatomic) IBOutlet KGOPlaceHolderTextView *contentTextView;

@property (weak, nonatomic) IBOutlet UIButton *submitBt;

@end

@implementation MUFeedBackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self viewInit];
}

- (void)viewInit {
    
    self.topConstraint.constant = SafeAreaTopHeight-44.0f;
    
    [self.returnBt setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    self.contentTextView.layer.masksToBounds = YES;
    self.contentTextView.layer.cornerRadius = 8.0f;
    self.contentTextView.placeHolder = @"请留下您宝贵的意见";
    self.contentTextView.backgroundColor = kUIColorFromRGB(0xe8e8e8);
    self.submitBt.layer.masksToBounds = YES;
    self.submitBt.layer.cornerRadius = 5.0f;
    
}

- (IBAction)didReturnButtonClicked:(id)sender {
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)didSubmitBtClicked:(id)sender {
    [self.view endEditing:YES];
    NSString *content = self.contentTextView.text;
    if (content.length == 0) {
        [self alertWithMsg:@"请输入反馈内容" handler:nil];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [MUHttpDataAccess feedBackWithContent:content success:^(id result) {
        
        if ([result[@"state"]integerValue] == 10001) {
            NSLog(@"反馈成功:%@",result);
            [weakSelf alertWithMsg:@"感谢您的反馈" handler:^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }];
        }
        
    } failed:^(NSError *error) {
        [weakSelf alertWithMsg:kFailedTips handler:nil];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
