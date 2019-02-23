//
//  previewPhoto_ViewController.m
//  KingoPalm
//
//  Created by Kingo on 16/11/11.
//  Copyright © 2016年 kingomacmini. All rights reserved.
//

#import "KGOPreviewPhotoViewController.h"
#import "KGOPreviewCell.h"

static NSString *KGOPreviewCellIndentifier = @"KGOPreviewCell";
static NSArray *images;

@interface KGOPreviewPhotoViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;


@property (strong, nonatomic) IBOutlet UICollectionView *previewCollectionView;

@end

@implementation KGOPreviewPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"照片预览";
    
    self.topConstraint.constant = SafeAreaTopHeight;
    
    UIBarButtonItem *deleteBarButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteCurrentPhotoImage:)];
    self.navigationItem.rightBarButtonItem = deleteBarButton;

    [self.previewCollectionView registerNib:[UINib nibWithNibName:KGOPreviewCellIndentifier bundle:nil] forCellWithReuseIdentifier:KGOPreviewCellIndentifier];
    self.previewCollectionView.backgroundColor = [UIColor blackColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidLayoutSubviews {
    if (_currentIndex < images.count) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_currentIndex inSection:0];
        [self.previewCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    }
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    KGOPreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:KGOPreviewCellIndentifier forIndexPath:indexPath];
    cell.photoImage = [images objectAtIndex:indexPath.item];
    
    return cell;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (decelerate == NO) {
        CGFloat currentX = scrollView.contentOffset.x;
        _currentIndex = currentX/SCREEN_WIDTH;
        NSLog(@"%ld",_currentIndex);
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat currentX = scrollView.contentOffset.x;
    _currentIndex = currentX/SCREEN_WIDTH;
    NSLog(@"%ld",_currentIndex);
}

- (void)deleteCurrentPhotoImage:(id)sender {
    
    BOOL isLast = NO;
    if (_currentIndex == images.count-1) {
        isLast = YES;
    }
    NSMutableArray *mutableImages = [NSMutableArray arrayWithArray:images];
    if([_delegate respondsToSelector:@selector(previewPhoto:deleteSelectedImageWithImage:)])
    {
        [_delegate previewPhoto:self deleteSelectedImageWithImage:images[_currentIndex]];
    }
    [mutableImages removeObjectAtIndex:_currentIndex];
    if (mutableImages.count == 0) { // 没有照片预览了，退出该页面
        [self.navigationController popViewControllerAnimated:YES];
    }
    images = [mutableImages copy];
    __weak typeof(self) weakSelf = self;
    [self.previewCollectionView performBatchUpdates:^{
        [weakSelf.previewCollectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:weakSelf.currentIndex inSection:0]]];
    }completion:nil];
    if (isLast) { //是最后一张，会向前移动，currentIndex要减1
        _currentIndex--;
    }
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return images.count;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    return CGSizeMake(CGRectGetWidth(collectionView.bounds), CGRectGetHeight(collectionView.bounds));
}

+ (void)setPreviewImage:(NSArray *)imageArray
{
    images = imageArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
