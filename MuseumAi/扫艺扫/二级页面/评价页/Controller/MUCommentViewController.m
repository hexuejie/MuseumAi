//
//  MUCommentViewController.m
//  MuseumAi
//
//  Created by 魏宙辉 on 2018/9/26.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUCommentViewController.h"
#import "KGOPlaceHolderTextView.h"
#import "MUImageCell.h"
#import "YMSPhotoPickerViewController.h"
#import "UIViewController+YMSPhotoHelper.h"
#import "KGOPreviewPhotoViewController.h"

@interface MUCommentViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, YMSPhotoPickerViewControllerDelegate, KGOPreviewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navHeight;
@property (weak, nonatomic) IBOutlet UIButton *returnBt;

@property (weak, nonatomic) IBOutlet UIButton *submitBt;

@property (weak, nonatomic) IBOutlet KGOPlaceHolderTextView *contentTextField;

@property (weak, nonatomic) IBOutlet UICollectionView *photoCollectionView;

/** 选取的照片 */
@property (strong, nonatomic) NSArray<UIImage *> *photos;

@end

@implementation MUCommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self viewInit];
}

- (void)viewInit {
    
    self.topConstraint.constant = SafeAreaTopHeight-36.0f;
    self.navHeight.constant = SafeAreaTopHeight;
    
    
    [self.returnBt setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    self.submitBt.layer.masksToBounds = YES;
    self.submitBt.layer.cornerRadius = 5.0f;
    
    self.contentTextField.layer.masksToBounds = YES;
    self.contentTextField.layer.cornerRadius = 5.0f;
    self.contentTextField.backgroundColor = [UIColor clearColor];
    self.contentTextField.placeHolder = @"请输入至少10个字以上要评价的内容以便于我们更 好的为您服务";
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.minimumLineSpacing = 10.0f;
    layout.minimumInteritemSpacing = 10.0f;
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    CGFloat itemW = (SCREEN_WIDTH-60.0f)/3.0f;
    layout.itemSize = CGSizeMake(itemW, itemW);
    [self.photoCollectionView setCollectionViewLayout:layout];
    [self.photoCollectionView registerNib:[UINib nibWithNibName:@"MUImageCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"MUImageCell"];
    self.photoCollectionView.backgroundColor = [UIColor clearColor];
}

#pragma mark -
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.photos.count >= 9) {
        return 9;
    }else {
        return self.photos.count+1;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MUImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MUImageCell" forIndexPath:indexPath];
    UIImage *image = nil;
    if(indexPath.row == self.photos.count){
        image = [UIImage imageNamed:@"添加图片"];
    }else{
        image = self.photos[indexPath.item];
    }
    cell.photoImageView.image = image;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == self.photos.count)
    {
        YMSPhotoPickerViewController *pickerVC = [[YMSPhotoPickerViewController alloc] init];
        pickerVC.numberOfPhotoToSelect = 9 - self.photos.count;
        
        [self yms_presentCustomAlbumPhotoView:pickerVC delegate:self];
    }else {
        [KGOPreviewPhotoViewController setPreviewImage:self.photos];
        KGOPreviewPhotoViewController *previewVC = [[KGOPreviewPhotoViewController alloc] init];
        previewVC.delegate = self;
        previewVC.currentIndex = indexPath.item;
        [self.navigationController pushViewController:previewVC animated:YES];
        
    }
}


#pragma mark - YMSPhotoPickerViewControllerDelegate
- (void)photoPickerViewControllerDidReceivePhotoAlbumAccessDenied:(YMSPhotoPickerViewController *)picker
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"允许使用相册吗?", nil) message:NSLocalizedString(@"需要您的允许来访问相册", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"设置", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    [alertController addAction:dismissAction];
    [alertController addAction:settingsAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)photoPickerViewControllerDidReceiveCameraAccessDenied:(YMSPhotoPickerViewController *)picker
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"允许访问相机吗?", nil) message:NSLocalizedString(@"需要您的允许来添加照片", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"设置", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    [alertController addAction:dismissAction];
    [alertController addAction:settingsAction];
    
    // The access denied of camera is always happened on picker, present alert on it to follow the view hierarchy
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
        
        NSMutableArray *mutPhotos = [NSMutableArray arrayWithArray:weakSelf.photos];
        for (PHAsset *asset in photoAssets) {
            
            CGSize targetSize = CGSizeMake((SCREEN_WIDTH - 20*2)* [UIScreen mainScreen].scale, (SCREEN_HEIGHT-64.0f-20*2)* [UIScreen mainScreen].scale);
            
            [imageManager requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *image, NSDictionary *info){
                
                NSData *tempData = UIImageJPEGRepresentation(image, 1.0);
                if(!tempData)
                {
                    tempData = UIImagePNGRepresentation(image);
                }
                float tPercent = 1000.0*1024.0/tempData.length;
                if(tempData.length > 800*1024)
                {
                    UIImage *compressedImage = [self compressImage:image toTargetPercent:tPercent];
                    tempData = UIImageJPEGRepresentation(compressedImage,1.0);
                    if(!tempData)
                    {
                        tempData = UIImagePNGRepresentation(compressedImage);
                    }
                    image = [UIImage imageWithData:tempData];
                }
                if(mutPhotos.count < 10)
                {
                    [mutPhotos addObject:image];
                }
            }];
        }
        
        weakSelf.photos = [NSArray arrayWithArray:mutPhotos];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.photoCollectionView reloadData];
        });
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

#pragma mark - KGOPreviewDelegate
-(void)previewPhoto:(KGOPreviewPhotoViewController *)previewPhoto deleteSelectedImageWithImage:(UIImage *)image
{
    NSMutableArray *mutPhotos = [NSMutableArray arrayWithArray:self.photos];
    if(mutPhotos)
    {
        [mutPhotos removeObject:image];
    }
    self.photos = [NSMutableArray arrayWithArray:mutPhotos];
    
    [self.photoCollectionView reloadData];
}

#pragma mark -

- (IBAction)didReturnClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)didSubmitClicked:(id)sender {
    if (self.contentTextField.text.length == 0 && self.photos.count == 0) {
        [self alertWithMsg:@"信息为空，不能上传" handler:nil];
        return;
    }
    NSString *content = self.contentTextField.text;
    if (content == nil) {
        content = @"";
    }
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [MUHttpDataAccess submitImageCommentWith:content exhibitsId:self.exhibitId commentType:self.type pictures:self.photos success:^(id result) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        if ([result[@"state"]integerValue] == 10001) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kSubmitCommentOKNotification object:weakSelf];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }else {
            [weakSelf alertWithMsg:result[@"msg"] handler:nil];
        }
    } failed:^(NSError *error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf alertWithMsg:kFailedTips handler:nil];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
