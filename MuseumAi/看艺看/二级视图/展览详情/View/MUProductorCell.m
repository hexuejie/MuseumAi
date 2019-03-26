//
//  MUProductorCell.m
//  MuseumAi
//
//  Created by Kingo on 2018/9/27.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUProductorCell.h"
#import "MUImageCell.h"

@interface MUProductorCell()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>

/** 展品列表 */
@property (nonatomic , strong) NSArray<MUExhibitModel *> *exhibits;

@end

@implementation MUProductorCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.separatorInset = UIEdgeInsetsMake(0, SCREEN_WIDTH, 0, 0);
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.minimumLineSpacing = 10.0f;
    layout.minimumInteritemSpacing = 0.0f;
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    layout.itemSize = CGSizeMake(116.0, 116.0f);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [self.productorCollectionView setCollectionViewLayout:layout];
    [self.productorCollectionView registerNib:[UINib nibWithNibName:@"MUImageCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"MUImageCell"];
    self.productorCollectionView.showsHorizontalScrollIndicator = NO;
    self.productorCollectionView.dataSource = self;
    self.productorCollectionView.delegate = self;
    
}

- (void)bindCellWithModel:(MUExhibitionDetailModel *)exhibition delegate:(id<MUExhibitionCellDelegate>)delegate {
    self.delegate = delegate;
    self.exhibits = exhibition.exhibits;
    [self.productorCollectionView reloadData];
}

#pragma mark -
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.exhibits.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MUExhibitModel *exhibit = self.exhibits[indexPath.item];
    MUImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MUImageCell" forIndexPath:indexPath];
    [cell.photoImageView sd_setImageWithURL:[NSURL URLWithString:exhibit.exhibitUrl]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_delegate != nil &&
        [_delegate respondsToSelector:@selector(didProduction:tappedInCell:)]) {
        [_delegate didProduction:indexPath.item tappedInCell:self];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
