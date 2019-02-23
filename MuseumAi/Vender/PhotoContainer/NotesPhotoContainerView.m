//
//  NotesPhotoContainerView.m
//  KingoPalm
//
//  Created by kingomacmini on 16/9/8.
//  Copyright © 2016年 kingomacmini. All rights reserved.
//

#import "NotesPhotoContainerView.h"
#import "UIView+SDAutoLayout.h"
#import "SDPhotoBrowser.h"
#import "UIImageView+WebCache.h"
#import "SDImageCache.h"

@interface NotesPhotoContainerView()<SDPhotoBrowserDelegate>

@property (nonatomic, strong) NSArray *imageViewsArray;

@end

@implementation NotesPhotoContainerView

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

-(void)setup{
    NSMutableArray *temp = [[NSMutableArray alloc]init];
    for(int i=0; i<9;i++){
        UIImageView *imageView = [[UIImageView alloc]init];
        /** 设置按比例裁剪 */
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = 5.0f;
        [self addSubview:imageView];
        imageView.userInteractionEnabled = YES;
        imageView.tag = i;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImageView:)];
        [imageView addGestureRecognizer:tap];
        [temp addObject:imageView];
    }
    self.imageViewsArray = [temp copy];
}

- (CGFloat)photoContainerHeight {
    return [self.fixedHeight floatValue];
}

-(void)setPicPathStringsArray:(NSArray *)picPathStringsArray{
    
    _picPathStringsArray = picPathStringsArray;
    for(NSInteger i=_picPathStringsArray.count;i<self.imageViewsArray.count;i++){
        UIImageView *imageView = [self.imageViewsArray objectAtIndex:i];
        imageView.hidden=YES;
    }
    if(_picPathStringsArray.count == 0){
        self.height_sd = 0;
        self.fixedHeight = @(0);
        return;
    }
    CGFloat itemW = [self itemWidthForPicPathArray:_picPathStringsArray];
    CGFloat itemH = 0;
    UIImage *image = nil;
    if(_picPathStringsArray.count == 1)
    {
        SDImageCache *imageCache = [SDImageCache sharedImageCache];
        NSString *imageURL = _picPathStringsArray.firstObject;
        image = [imageCache imageFromDiskCacheForKey:imageURL];
        if(image == nil)
        {
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
            image = [UIImage imageWithData:data];
            [imageCache storeImage:image forKey:imageURL completion:^{
                
            }];
        }
        if(image.size.width){
            itemH = image.size.height/image.size.width *itemW;
        }
        if (itemH > 200) {
            itemH = 200;
            itemW = image.size.width/image.size.height *itemH;
        }
    }else{
        itemH = itemW;
    }
    NSInteger perRowItemCount = [self perRowItemCountForPicPathArray:_picPathStringsArray];
    CGFloat margin = 5;
    
    __weak typeof(self) weakSelf = self;
    [_picPathStringsArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj,NSUInteger idx, BOOL * _Nonnull stop){
        NSInteger columnIndex = idx%perRowItemCount;
        NSInteger rowIndex = idx/perRowItemCount;
        UIImageView *imageView = [_imageViewsArray objectAtIndex:idx];
        imageView.hidden = NO;
        
        [weakSelf graphicsImageToImageView:imageView imageUrl:obj];
        imageView.frame = CGRectMake(columnIndex*(itemW+margin), rowIndex*(itemH+margin), itemW, itemH);
    }];
    CGFloat w = perRowItemCount*itemW +(perRowItemCount-1)*margin;
    NSInteger columnCount = ceilf(_picPathStringsArray.count*1.0/perRowItemCount);
    CGFloat h = columnCount*itemH + (columnCount - 1) * margin;
    self.width_sd = w;
    self.height_sd = h;
    
    self.fixedHeight = @(h);
    self.fixedWidth = @(w);
    
}

- (void)graphicsImageToImageView:(UIImageView *)imageView imageUrl:(NSString *)imageURL {
    if (_topImageName == nil) {
        [imageView sd_setImageWithURL:[NSURL URLWithString:imageURL]
                     placeholderImage:[UIImage imageNamed:@"loadImageFailed"]];
    }else {
        imageView.image = [self addImage:[UIImage imageNamed:@"loadImageFailed"] withImage:[UIImage imageNamed:_topImageName]];
        
        dispatch_queue_t queue = dispatch_queue_create("imageData_q", NULL);
        dispatch_async(queue, ^{
            UIImage *image = nil;
            SDImageCache *imageCache = [SDImageCache sharedImageCache];
            image = [imageCache imageFromDiskCacheForKey:imageURL];
            if (image == nil) {
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
                image = [UIImage imageWithData:data];
                [imageCache storeImage:image forKey:imageURL completion:nil];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                imageView.image = [self addImage:image withImage:[UIImage imageNamed:_topImageName]];
            });
        });
        
    }
}

- (UIImage *)addImage:(UIImage *)image1 withImage:(UIImage *)image2 {
    
    UIGraphicsBeginImageContextWithOptions(image1.size, YES, [UIScreen mainScreen].scale);
    
    [image1 drawInRect:CGRectMake(0, 0, image1.size.width, image1.size.height)];
    
    CGFloat image2Width = image1.size.width-20.0f<image1.size.height-20.0f?(image1.size.width-20.0f):(image1.size.height-20.0f);
    [image2 drawInRect:CGRectMake((image1.size.width-image2Width)/2.0f,
                                  (image1.size.height-image2Width)/2.0f,
                                  image2Width,
                                  image2Width)];
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultingImage;
}

#pragma mark - private actions
-(void)tapImageView:(UITapGestureRecognizer *)tap{
    UIView *imageView = tap.view;
    SDPhotoBrowser *browser = [[SDPhotoBrowser alloc]init];
    browser.currentImageIndex = imageView.tag;
    browser.sourceImagesContainerView = self;
    browser.imageCount = self.picPathStringsArray.count;
    browser.delegate = self;
    browser.topImageName = _topImageName;
    [browser show];
}
-(CGFloat)itemWidthForPicPathArray:(NSArray *)array{
    if(array.count ==1){
        return (SCREEN_WIDTH - 70.0f)/2.0;
    }else{
        CGFloat w = (self.photoContainerWidth-10.0f)/3.0;
        return w;
    }
}
-(NSInteger)perRowItemCountForPicPathArray:(NSArray *)array{
    if(array.count < 4){
        return array.count;
    }else if(array.count == 4){
        return 2;
    }
    return 3;
}

#pragma mark - SDPhotoBrowserDelegate
-(NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index{
    NSString *imageName = self.bigPicPathStringArray[index];
    NSURL *url = [NSURL URLWithString:imageName];
    return url;
}

-(UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index{
    UIImageView *imageView = self.subviews[index];
    return imageView.image;
}

@end
