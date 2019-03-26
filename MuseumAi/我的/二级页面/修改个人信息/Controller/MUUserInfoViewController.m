//
//  MUUserInfoViewController.m
//  MuseumAi
//
//  Created by Kingo on 2018/9/26.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUUserInfoViewController.h"
#import "YMSPhotoPickerViewController.h"
#import "UIViewController+YMSPhotoHelper.h"
#import "MUUserIconCell.h"
#import "MUUserInfoCell.h"
#import "WSDatePickerView.h"
#import "MUUserInfoFixViewController.h"

//typedef NS_ENUM(NSInteger, MUALERTTYPE) {
//    MUALERTTYPENICKNAME = 0,    // 昵称
//    MUALERTTYPEEAMAIL,          // 邮箱
//    MUALERTTYPEJOB              // 职业
//};

@interface MUUserInfoViewController ()<UITableViewDelegate,UITableViewDataSource,YMSPhotoPickerViewControllerDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;


@property (weak, nonatomic) IBOutlet UIButton *returnBt;

@property (weak, nonatomic) IBOutlet UITableView *infoTableView;

@property (strong, nonatomic) IBOutlet UIView *inputAlertBgView;

@property (weak, nonatomic) IBOutlet UIView *inputAlertView;

@property (weak, nonatomic) IBOutlet UITextField *inputTextField;


@property (strong, nonatomic) IBOutlet UIView *genderSelectView;

@property (weak, nonatomic) IBOutlet UIView *genderSelectAlert;

@property (weak, nonatomic) IBOutlet UIButton *maleBt;

@property (weak, nonatomic) IBOutlet UIButton *scretBt;

@property (weak, nonatomic) IBOutlet UIButton *femaleBt;

/** 人物图像 */
@property (nonatomic , strong) UIImage *image;
/** 输入类型 */
@property (nonatomic , assign) MUALERTTYPE inputType;

@property (nonatomic , strong) MUUserInfoCell *tempCell;
@end

@implementation MUUserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self viewInit];
    
    [self dataInit];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self reloadUserInfo];
}

- (void)viewInit {
    
    self.topConstraint.constant = SafeAreaTopHeight-36.0f;
    
    [self.returnBt setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    
    self.infoTableView.tableFooterView = [UIView new];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"MUUserIconCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MUUserIconCell"];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"MUUserInfoCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MUUserInfoCell"];
    
    self.inputAlertBgView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.2];
    self.inputAlertBgView.frame = SCREEN_BOUNDS;
    [self.view addSubview:self.inputAlertBgView];
    self.inputAlertBgView.hidden = YES;
    [self.inputAlertBgView addTapTarget:self action:@selector(hideAlertView)];
    
    self.inputAlertView.layer.masksToBounds = YES;
    self.inputAlertView.layer.cornerRadius = 5.0f;
    self.inputAlertView.backgroundColor = [UIColor whiteColor];
    [self.inputAlertView addTapTarget:self action:@selector(noneFuction)];
    
    self.genderSelectView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.2];
    self.genderSelectView.frame = SCREEN_BOUNDS;
    [self.view addSubview:self.genderSelectView];
    self.genderSelectView.hidden = YES;
    [self.genderSelectView addTapTarget:self action:@selector(didGenderViewTapped:)];
    
    self.genderSelectAlert.layer.masksToBounds = YES;
    self.genderSelectAlert.layer.cornerRadius = 5.0f;
    self.genderSelectAlert.backgroundColor = [UIColor whiteColor];
    [self.genderSelectAlert addTapTarget:self action:@selector(noneFuction)];
    
    self.scretBt.layer.masksToBounds = YES;
    self.scretBt.layer.cornerRadius = 25.0f;
}

- (void)dataInit {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self reloadUserInfo];
}

- (void)reloadUserInfo {
    __weak typeof(self) weakSelf = self;
    [MUHttpDataAccess getUserInfoSuccess:^(id result) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        if ([result[@"state"]integerValue] == 10001) {
            [[MUUserModel currentUser] updateUserWith:result[@"data"][@"member"]];
            [weakSelf.infoTableView reloadData];
        }
    } failed:^(NSError *error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf alertWithMsg:kFailedTips handler:nil];
    }];
}

#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }else {
        return 5;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        
        MUUserIconCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MUUserIconCell"];
        if (self.image == nil) {
            [cell.iconImageView sd_setImageWithURL:[NSURL URLWithString:[MUUserModel currentUser].photo]];
        }else {
            cell.iconImageView.image = self.image;
        }
        return cell;
    }else {
        MUUserInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MUUserInfoCell"];
        cell.sexChooseView.hidden = YES;
        switch (indexPath.row) {
            case 0:
                cell.infoTitleLb.text = @"昵称";
                cell.infoContentLb.text = [MUUserModel currentUser].nikeName;
                break;
            case 1:
                cell.infoTitleLb.text = @"性别";
                cell.sexChooseView.hidden = NO;
                if ([[MUUserModel currentUser].genderDescripe isEqualToString:@"男"]) {
                    cell.manButton.selected = YES;
                    cell.womanButton.selected = NO;
                    cell.womanButton.layer.borderColor = kUIColorFromRGB(0xDCDCDC).CGColor;
                    cell.manButton.layer.borderColor = kMainColor.CGColor;
                    
                }else if([[MUUserModel currentUser].genderDescripe isEqualToString:@"女"]) {
                    cell.manButton.selected = NO;
                    cell.womanButton.selected = YES;
                    cell.manButton.layer.borderColor = kUIColorFromRGB(0xDCDCDC).CGColor;
                    cell.womanButton.layer.borderColor = kMainColor.CGColor;
                }
                self.tempCell = cell;
                [cell.manButton addTarget:self action:@selector(chooseManClick:) forControlEvents:UIControlEventTouchUpInside];
                [cell.womanButton addTarget:self action:@selector(chooseWomanClick:) forControlEvents:UIControlEventTouchUpInside];
                break;
            case 2:
                cell.infoTitleLb.text = @"生日";
                cell.infoContentLb.text = [MUUserModel currentUser].birthDay;
                break;
            case 3:
                cell.infoTitleLb.text = @"邮箱";
                cell.infoContentLb.text = [MUUserModel currentUser].email;
                break;
            case 4:
                cell.infoTitleLb.text = @"职业";
                cell.infoContentLb.text = [MUUserModel currentUser].occupation;
                break;
            default:
                break;
        }
        return cell;
    }
    
}

- (void)chooseManClick:(UIButton *)sender{
    [self updateGenderWithStr:@"1"];
    if (self.tempCell) {
        MUUserInfoCell *cell = [self.infoTableView dequeueReusableCellWithIdentifier:@"MUUserInfoCell" forIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
        cell.manButton.selected = YES;
        cell.womanButton.selected = NO;
        cell.manButton.layer.borderColor = kUIColorFromRGB(0xDCDCDC).CGColor;
        cell.womanButton.layer.borderColor = kMainColor.CGColor;
    }
}
- (void)chooseWomanClick:(UIButton *)sender{
    [self updateGenderWithStr:@"2"];
    if (self.tempCell) {
        MUUserInfoCell *cell = [self.infoTableView dequeueReusableCellWithIdentifier:@"MUUserInfoCell" forIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
        cell.manButton.selected = NO;
        cell.womanButton.selected = YES;
        cell.womanButton.layer.borderColor = kUIColorFromRGB(0xDCDCDC).CGColor;
        cell.manButton.layer.borderColor = kMainColor.CGColor;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            return 85.0f;
            break;
        default:
            return 50.0f;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section ==0){
        return 0.01;
    }
    return 10.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf openPhotoLibrary];
        });
    }else {
        switch (indexPath.row) {
            case 0: {
                self.inputType = MUALERTTYPENICKNAME;
//                self.inputTextField.keyboardType = UIKeyboardTypeDefault;
//                self.inputTextField.text = [MUUserModel currentUser].nikeName;
//                [self.inputTextField becomeFirstResponder];
//                self.inputAlertBgView.hidden = NO;
                MUUserInfoFixViewController *fixVC = [MUUserInfoFixViewController new];
                fixVC.titleLabelView.text = @"设置昵称";
                fixVC.inputType = MUALERTTYPENICKNAME;
                [self.navigationController pushViewController:fixVC animated:YES];
                break;
            }
            case 1: {
//                NSInteger genderIndex = [[MUUserModel currentUser].gender integerValue];
//                if (genderIndex == 1) { // 男
//                    self.maleBt.selected = YES;
//                    self.femaleBt.selected = NO;
//                    self.scretBt.backgroundColor = kUIColorFromRGB(0xe8e8e8);
//                }else if(genderIndex == 2) {    // 女
//                    self.maleBt.selected = NO;
//                    self.femaleBt.selected = YES;
//                    self.scretBt.backgroundColor = kUIColorFromRGB(0xe8e8e8);
//                }else { // 保密
//                    self.maleBt.selected = NO;
//                    self.femaleBt.selected = NO;
//                    self.scretBt.backgroundColor = kMainColor;
//                }
//                self.genderSelectView.hidden = NO;
                break;
            }
            case 2: {
                __weak typeof(self) weakSelf = self;
                WSDatePickerView *datePicker = [[WSDatePickerView alloc]initWithDateStyle:DateStyleShowYearMonthDay scrollToDate:[NSDate date] CompleteBlock:^(NSDate *date) {
                    NSString *dateStr = [date stringWithFormat:@"yyyy-MM-dd"];
                    [MUHttpDataAccess modifyUserInfoByNikeName:nil sex:nil email:nil occupation:nil dateOfBirth:dateStr photo:nil success:^(id result) {
                        if ([result[@"state"]integerValue] == 10001) {
                            [MUUserModel currentUser].birthDay = dateStr;
                            [weakSelf.infoTableView reloadData];
                        }
                    } failed:nil];
                }];
                [datePicker show];
                break;
            }
            case 3: {
//                self.inputType = MUALERTTYPEEAMAIL;
//                self.inputTextField.keyboardType = UIKeyboardTypeEmailAddress;
//                self.inputTextField.text = [MUUserModel currentUser].email;
//                [self.inputTextField becomeFirstResponder];
//                self.inputAlertBgView.hidden = NO;
                
                MUUserInfoFixViewController *fixVC = [MUUserInfoFixViewController new];
                fixVC.titleLabelView.text = @"设置邮箱";
                fixVC.inputType = MUALERTTYPEEAMAIL;
                [self.navigationController pushViewController:fixVC animated:YES];
                break;
            }
            case 4: {
//                self.inputType = MUALERTTYPEJOB;
//                self.inputTextField.keyboardType = UIKeyboardTypeDefault;
//                self.inputTextField.text = [MUUserModel currentUser].occupation;
//                [self.inputTextField becomeFirstResponder];
//                self.inputAlertBgView.hidden = NO;
                
                MUUserInfoFixViewController *fixVC = [MUUserInfoFixViewController new];
                fixVC.titleLabelView.text = @"设置职业";
                fixVC.inputType = MUALERTTYPEJOB;
                [self.navigationController pushViewController:fixVC animated:YES];
                break;
            }
            default:
                break;
        }
    }
}

- (void)openPhotoLibrary {
    YMSPhotoPickerViewController *pickerVC = [[YMSPhotoPickerViewController alloc] init];
    pickerVC.numberOfPhotoToSelect = 1;
    [self yms_presentCustomAlbumPhotoView:pickerVC delegate:self];
}

#pragma mark - YMSPhotoPickerViewControllerDelegate
- (void)photoPickerViewControllerDidReceivePhotoAlbumAccessDenied:(YMSPhotoPickerViewController *)picker {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"允许使用相册吗?", nil) message:NSLocalizedString(@"需要您的允许来访问相册", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"设置", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    [alertController addAction:dismissAction];
    [alertController addAction:settingsAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)photoPickerViewControllerDidReceiveCameraAccessDenied:(YMSPhotoPickerViewController *)picker {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"允许访问相机吗?", nil) message:NSLocalizedString(@"需要您的允许来添加照片", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"设置", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    [alertController addAction:dismissAction];
    [alertController addAction:settingsAction];
    
    [picker presentViewController:alertController animated:YES completion:nil];
}

-(void)photoPickerViewController:(YMSPhotoPickerViewController *)picker didFinishPickingImages:(NSArray<PHAsset *> *)photoAssets
{
    __weak typeof(self) weakSelf = self;
    [picker dismissViewControllerAnimated:YES completion:^() {
        
        PHImageManager *imageManager = [[PHImageManager alloc] init];
        
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.networkAccessAllowed = YES;
        options.resizeMode = PHImageRequestOptionsResizeModeExact;
        options.synchronous = YES;
        
        for (PHAsset *asset in photoAssets) {
            
            CGSize targetSize = CGSizeMake((SCREEN_WIDTH - 20*2)* [UIScreen mainScreen].scale, (SCREEN_HEIGHT-30.0f-20*2)* [UIScreen mainScreen].scale);
            
            [imageManager requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *image, NSDictionary *info){
                
                NSData *tempData = UIImageJPEGRepresentation(image, 1.0);
                if(!tempData) {
                    tempData = UIImagePNGRepresentation(image);
                }
                float tPercent = 1000.0*1024.0/tempData.length;
                
                UIImage *compressedImage = [self compressImage:image toTargetPercent:tPercent];
                tempData = UIImageJPEGRepresentation(compressedImage,1.0);
                if(!tempData)
                {
                    tempData = UIImagePNGRepresentation(compressedImage);
                }
                image = [UIImage imageWithData:tempData];
                
                [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
                [MUHttpDataAccess modifyUserInfoByNikeName:nil sex:nil email:nil occupation:nil dateOfBirth:nil photo:image success:^(id result) {
                    [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                    if ([result[@"state"]integerValue] == 10001) {
                        weakSelf.image = image;
                        [weakSelf.infoTableView reloadData];
                        [weakSelf reloadUserInfo];  // 重新加载图片
                    }else {
                        [weakSelf alertWithMsg:result[@"msg"] handler:nil];
                    }
                } failed:^(NSError *error) {
                    [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                    [weakSelf alertWithMsg:kFailedTips handler:nil];
                }];
                
            }];
        }
    }];
}

- (UIImage *)compressImage:(UIImage *)sourceImage toTargetPercent:(float)targetPercent {
    
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetPercent*width;
    CGFloat targetHeight = targetPercent*height;
    
    UIGraphicsBeginImageContext(CGSizeMake(targetWidth, targetHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, targetWidth, targetHeight)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

#pragma mark -

- (IBAction)didReturnBtClicked:(id)sender {
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didGenderViewTapped:(id)sender {
    self.genderSelectView.hidden = YES;
}

- (void)hideAlertView {
    [self.view endEditing:YES];
    self.inputAlertBgView.hidden = YES;
}

- (void)noneFuction {
    [self.view endEditing:YES];
}

- (IBAction)didSureBtClicked:(id)sender {
    [self.view endEditing:YES];
    self.inputAlertBgView.hidden = YES;
    NSString *inputStr = self.inputTextField.text;
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
                    [weakSelf.infoTableView reloadData];
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
                    [weakSelf.infoTableView reloadData];
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
                    [weakSelf.infoTableView reloadData];
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

- (IBAction)didMaleBtClicked:(id)sender {
    self.genderSelectView.hidden = YES;
    [self updateGenderWithStr:@"1"];
}

- (IBAction)didScretClicked:(id)sender {
    self.genderSelectView.hidden = YES;
    [self updateGenderWithStr:@"0"];
}

- (IBAction)didFemaleClicked:(id)sender {
    self.genderSelectView.hidden = YES;
    [self updateGenderWithStr:@"2"];
}

- (void)updateGenderWithStr:(NSString *)gender {
    __weak typeof(self) weakSelf = self;
    [MUHttpDataAccess modifyUserInfoByNikeName:nil sex:gender email:nil occupation:nil dateOfBirth:nil photo:nil success:^(id result) {
        if ([result[@"state"]integerValue] == 10001) {
            [MUUserModel currentUser].gender = gender;
            [weakSelf.infoTableView reloadData];
            
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
