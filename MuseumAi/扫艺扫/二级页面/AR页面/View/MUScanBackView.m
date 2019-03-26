//
//  MUScanBackView.m
//  MuseumAi
//
//  Created by 魏宙辉 on 2019/2/27.
//  Copyright © 2019年 Weizh. All rights reserved.
//

#import "MUScanBackView.h"
#import "MUExhibitCell.h"

@interface MUScanBackView()<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

/* 分享回调 */
@property(nonatomic, copy) MUButtonCallBack shareCallback;
/* 帮助回调 */
@property(nonatomic, copy) MUButtonCallBack helpCallback;
/* 导览回调 */
@property(nonatomic, copy) MUButtonCallBack guideCallback;
/* 首页回调 */
@property(nonatomic, copy) MUButtonCallBack mainCallback;
/* 展品选择回调 */
@property(nonatomic, copy) MUExhibitSelected exhibitSelectHandler;

@end

@implementation MUScanBackView

+ (instancetype)scanBackViewShareCallback:(MUButtonCallBack)shareCallback
                             helpCallback:(MUButtonCallBack)helpCallback
                            guideCallback:(MUButtonCallBack)guideCallback
                             mainCallback:(MUButtonCallBack)mainCallback
                     exhibitSelectHandler:(MUExhibitSelected)exhibitSelectHandler {
    
    MUScanBackView *scanBackView = [[[NSBundle mainBundle] loadNibNamed:@"MUScanBackView" owner:self options:nil] firstObject];
    
    scanBackView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
    scanBackView.hotExhibitsBgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
    scanBackView.buttonsBgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    scanBackView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    scanBackView.hotExhibitsCollectionView.backgroundColor = [UIColor clearColor];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.minimumLineSpacing = 10.0f;
    layout.minimumInteritemSpacing = 10.0f;
    layout.itemSize = CGSizeMake(80.0f, 80.0f);
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [scanBackView.hotExhibitsCollectionView setCollectionViewLayout:layout];
    [scanBackView.hotExhibitsCollectionView registerNib:[UINib nibWithNibName:@"MUExhibitCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"MUExhibitCell"];
    scanBackView.hotExhibitsCollectionView.dataSource = scanBackView;
    scanBackView.hotExhibitsCollectionView.delegate= scanBackView;
    
    scanBackView.shareCallback = shareCallback;
    scanBackView.helpCallback = helpCallback;
    scanBackView.guideCallback = guideCallback;
    scanBackView.mainCallback = mainCallback;
    scanBackView.exhibitSelectHandler = exhibitSelectHandler;
    
    scanBackView.exhibits = @[];
    
    return scanBackView;
}

- (void)setExhibits:(NSArray<MUExhibitModel *> *)exhibits {
    _exhibits = exhibits;
    if (exhibits.count == 0) {
        self.hotExhibitsBgView.hidden = YES;
    } else {
        self.hotExhibitsBgView.hidden = NO;
        [self.hotExhibitsCollectionView reloadData];
    }
}

#pragma mark ----
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.exhibits.count;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MUExhibitModel *exhibit = self.exhibits[indexPath.item];
    MUExhibitCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MUExhibitCell" forIndexPath:indexPath];
    cell.detailBgView.hidden = YES;
    [cell.exhibitImageView sd_setImageWithURL:[NSURL URLWithString:exhibit.exhibitUrl]];
    cell.exhibitNameLb.text = exhibit.exhibitName;
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.exhibitSelectHandler) {
        self.exhibitSelectHandler(self.exhibits[indexPath.item]);
    }
}

#pragma mark ----

- (IBAction)didShareButtonClicked:(id)sender {
    if (self.shareCallback) {
        self.shareCallback(sender);
    }
}

- (IBAction)didHelpButtonClicked:(id)sender {
    if (self.helpCallback) {
        self.helpCallback(sender);
    }
}

- (IBAction)didGuideButtonClicked:(id)sender {
    if (self.guideCallback) {
        self.guideCallback(sender);
    }
}

- (IBAction)didMainButtonClicked:(id)sender {
    if (self.mainCallback) {
        self.mainCallback(sender);
    }
}


@end
