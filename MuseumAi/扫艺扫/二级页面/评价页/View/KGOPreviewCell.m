//
//  PreviewCell.m
//  KingoPalm
//
//  Created by Kingo on 16/11/14.
//  Copyright © 2016年 kingomacmini. All rights reserved.
//

#import "KGOPreviewCell.h"

@interface KGOPreviewCell()

@property (strong, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageWidthConstraint;

@end

@implementation KGOPreviewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.contentView.backgroundColor = [UIColor blackColor];
}

-(void)setPhotoImage:(UIImage *)photoImage{
    
    CGFloat cellHeight = SCREEN_HEIGHT-SafeAreaTopHeight-SafeAreaBottomHeight;
    CGFloat cellWidth = SCREEN_WIDTH;
    _photoImage = photoImage;
    CGFloat iHeight = photoImage.size.height;
    CGFloat iWidth = photoImage.size.width;
    
    if (iHeight < iWidth*cellHeight/cellWidth) {
        _imageWidthConstraint.constant = cellWidth;
        _imageHeightConstraint.constant = iHeight*cellWidth/iWidth;
    }else {
        _imageHeightConstraint.constant = cellHeight;
        _imageWidthConstraint.constant = iWidth*cellHeight/iHeight;
    }
    
    self.photoImageView.image = photoImage;
}

@end









