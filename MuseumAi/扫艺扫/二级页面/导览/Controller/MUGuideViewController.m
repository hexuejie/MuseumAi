//
//  MUGuideViewController.m
//  MuseumAi
//
//  Created by 魏宙辉 on 2018/9/23.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUGuideViewController.h"
#import "MURegionModel.h"
#import "MUExhibitDetailViewController.h"
#import "ZACCollectionFlowLayout.h"

#import "MUFloorCell.h"
#import "MUExhibitCell.h"

@interface MUGuideViewController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property (weak, nonatomic) IBOutlet UIButton *returnBt;
@property (weak, nonatomic) IBOutlet UIImageView *hallImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hallImageHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hallImageWidthConstraint;
@property (weak, nonatomic) IBOutlet UICollectionView *floorCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *hotExhibitsCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *allExhibitsCollectionView;

/** 导航mask */
@property (nonatomic , strong) UIView *guideView;

/** 平面图 */
@property (nonatomic , strong) NSArray<MURegionModel *> *regions;
/** 当前层 */
@property (nonatomic , assign) NSInteger currentFloor;
@property (nonatomic , assign) NSInteger currentHotIndex;
@property (nonatomic , assign) NSInteger currentAllIndex;

@property (strong, nonatomic) IBOutlet UIView *guideAlertBgView;
@property (weak, nonatomic) IBOutlet UIView *guideAlertView;
@property (weak, nonatomic) IBOutlet UIImageView *guideImageView;
@property (weak, nonatomic) IBOutlet UILabel *guideLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *guideAlertHeight;

@end

@implementation MUGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self viewInit];
    [self dataInit];
}

- (void)viewInit {
    
    self.topConstraint.constant = SafeAreaTopHeight-44.0f;
    [self.view bringSubviewToFront:self.returnBt];
    [self.returnBt setImageEdgeInsets:UIEdgeInsetsMake(13.5, 13.5, 13.5, 13.5)];
    
    self.hallImageView.userInteractionEnabled = YES;
    self.hallImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    ZACCollectionFlowLayout *layout = [[ZACCollectionFlowLayout alloc]initWthType:AlignWithCenter];
    layout.minimumLineSpacing = 20;
    layout.minimumLineSpacing = 20;
    layout.itemSize = CGSizeMake(40.0f, 40.0f);
    layout.sectionInset = UIEdgeInsetsMake(2, 20, 2, 20);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [self.floorCollectionView setCollectionViewLayout:layout];
    [self.floorCollectionView registerNib:[UINib nibWithNibName:@"MUFloorCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"MUFloorCell"];
    self.floorCollectionView.showsHorizontalScrollIndicator = NO;
    
    UICollectionViewFlowLayout *hotLayout = [[UICollectionViewFlowLayout alloc]init];
    hotLayout.minimumLineSpacing = 10.0f;
    hotLayout.minimumInteritemSpacing = 0.0f;
    hotLayout.sectionInset = UIEdgeInsetsMake(0, 15, 0, 15);
    hotLayout.itemSize = CGSizeMake(120.0, 100.0f);
    hotLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [self.hotExhibitsCollectionView setCollectionViewLayout:hotLayout];
    [self.hotExhibitsCollectionView registerNib:[UINib nibWithNibName:@"MUExhibitCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"MUExhibitCell"];
    self.hotExhibitsCollectionView.showsHorizontalScrollIndicator = NO;
    
    UICollectionViewFlowLayout *allLayout = [[UICollectionViewFlowLayout alloc]init];
    allLayout.minimumLineSpacing = 10.0f;
    allLayout.minimumInteritemSpacing = 0.0f;
    allLayout.sectionInset = UIEdgeInsetsMake(0, 15, 0, 15);
    allLayout.itemSize = CGSizeMake(120.0, 100.0f);
    allLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [self.allExhibitsCollectionView setCollectionViewLayout:allLayout];
    [self.allExhibitsCollectionView registerNib:[UINib nibWithNibName:@"MUExhibitCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"MUExhibitCell"];
    self.allExhibitsCollectionView.showsHorizontalScrollIndicator = NO;
    
    self.guideAlertBgView.frame = SCREEN_BOUNDS;
    self.guideAlertBgView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.3];
    [self.view addSubview:self.guideAlertBgView];
    self.guideAlertBgView.hidden = YES;
    self.guideAlertView.layer.cornerRadius = 5.0f;
    self.guideAlertView.layer.masksToBounds = YES;
    [self.guideAlertView bringSubviewToFront:self.guideLabel];
    self.guideLabel.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5f];
    self.guideLabel.textColor = [UIColor whiteColor];
    [self.guideAlertBgView addTapTarget:self action:@selector(hideGuideAlert)];
}

- (void)dataInit {
    // 加载平面图
    __weak typeof(self) weakSelf = self;
    [MUHttpDataAccess getHallRegionWithHallId:self.hall.hallId success:^(id result) {
        if ([result[@"state"]integerValue] == 10001) {
            NSMutableArray *mutRegions = [NSMutableArray array];
            for (NSDictionary *dic in result[@"data"][@"list"]) {
                [mutRegions addObject:[MURegionModel regionWithDic:dic]];
            }
            weakSelf.regions = [NSArray arrayWithArray:mutRegions];
            NSNumber *floor = [[NSUserDefaults standardUserDefaults]valueForKey:[NSString stringWithFormat:@"%@_floor",weakSelf.hall.hallId]];
            if (floor == nil || ![floor isKindOfClass:[NSNumber class]]) {
                weakSelf.currentFloor = 0;
                [[NSUserDefaults standardUserDefaults] setObject:@(weakSelf.currentFloor) forKey:[NSString stringWithFormat:@"%@_floor",weakSelf.hall.hallId]];
            }else {
                weakSelf.currentFloor = [floor integerValue];
            }
            if (weakSelf.selectExhibit != nil) {
                for (int i=0; i<weakSelf.regions.count; i++) {
                    MURegionModel *region = weakSelf.regions[i];
                    if ([region.regionId isEqualToString:weakSelf.selectExhibit.regionId]) {
                        self.currentFloor = i;
                        [[NSUserDefaults standardUserDefaults] setObject:@(weakSelf.currentFloor) forKey:[NSString stringWithFormat:@"%@_floor",weakSelf.hall.hallId]];
                    }
                }
            }
            [weakSelf reloadRegion];
        }
    } failed:^(NSError *error) {
        [weakSelf alertWithMsg:kFailedTips handler:nil];
    }];
}

- (void)reloadRegion {
    [self.floorCollectionView reloadData];
    
    if (self.currentFloor >= self.regions.count) {
        return;
    }
    MURegionModel *region = self.regions[self.currentFloor];
    if (region.width != 0 && region.height != 0) {
        CGFloat height = SCREEN_WIDTH * region.height / region.width;
        CGFloat width = SCREEN_WIDTH;
        if (height > SCREEN_HEIGHT-500) {   // 412
            height = SCREEN_HEIGHT-500;
            width = height * region.width/region.height;
        }
        self.hallImageWidthConstraint.constant = width;
        self.hallImageHeightConstraint.constant = height;
    }
    [self.hallImageView sd_setImageWithURL:[NSURL URLWithString:region.regionUrl]];
    
    __weak typeof(self) weakSelf = self;
    [MUHttpDataAccess getExhibitsFromRegionId:region.regionId isHot:NO success:^(id result) {
        if ([result[@"state"]integerValue] == 10001) {
            NSMutableArray *mutExhibits = [NSMutableArray array];
            for (NSDictionary *dic in result[@"data"][@"list"]) {
                MUExhibitModel *exhibit = [MUExhibitModel exhibitWithDic:dic];
                [mutExhibits addObject:exhibit];
            }
            weakSelf.allExhibits = [NSArray arrayWithArray:mutExhibits];
            [weakSelf reloadRegionExhibits];
        }
    } failed:^(NSError *error) {
        [weakSelf alertWithMsg:kFailedTips handler:nil];
    }];
    [MUHttpDataAccess getExhibitsFromRegionId:region.regionId isHot:YES success:^(id result) {
        if ([result[@"state"]integerValue] == 10001) {
            NSMutableArray *mutExhibits = [NSMutableArray array];
            for (NSDictionary *dic in result[@"data"][@"list"]) {
                MUExhibitModel *exhibit = [MUExhibitModel exhibitWithDic:dic];
                [mutExhibits addObject:exhibit];
            }
            weakSelf.hotExhibits = [NSArray arrayWithArray:mutExhibits];
            [weakSelf.hotExhibitsCollectionView reloadData];
            NSString *exhibitGuide = [[NSUserDefaults standardUserDefaults] objectForKey:@"exhibit_guide"];
            if (![exhibitGuide boolValue]) {
                [weakSelf addExhibitGuideMask];
            }
        }
    } failed:^(NSError *error) {
        [weakSelf alertWithMsg:kFailedTips handler:nil];
    }];
    
}
// 重新加载展区展品
- (void)reloadRegionExhibits {
    [self.allExhibitsCollectionView reloadData];
    for (UIView *subView in self.hallImageView.subviews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            [subView removeFromSuperview];
        }
    }
    for (int i=0;i<self.allExhibits.count;i++) {
        MUExhibitModel *exhibit = self.allExhibits[i];
        UIButton *exhibitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat scale = self.hallImageWidthConstraint.constant/800.0f;
        exhibitButton.frame = CGRectMake(exhibit.positionX*scale-15.0f, exhibit.positionY*scale-25.0f, 30, 30);
        exhibitButton.tag = 1000+i;
        [exhibitButton addTarget:self action:@selector(didExhibitMapClicked:) forControlEvents:UIControlEventTouchUpInside];
        [exhibitButton setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
        [exhibitButton setImage:[UIImage imageNamed:@"位置_un"] forState:UIControlStateNormal];
        [exhibitButton setImage:[UIImage imageNamed:@"位置_on"] forState:UIControlStateSelected];
        [self.hallImageView addSubview:exhibitButton];
        if (self.selectExhibit != nil &&
            [exhibit isEqual:self.selectExhibit]) {
            exhibitButton.selected = YES;
        }else {
            exhibitButton.selected = NO;
        }
    }
}

- (void)didExhibitMapClicked:(UIButton *)sender {
    self.selectExhibit = nil;
    for (UIView *subView in self.hallImageView.subviews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            UIButton *bt = (UIButton *)subView;
            bt.selected = NO;
        }
    }
    sender.selected = YES;
    NSInteger exhibitIndex = sender.tag-1000;
    MUExhibitModel *exhibit = self.allExhibits[exhibitIndex];
    self.guideAlertBgView.hidden = NO;
    __weak typeof(self) weakSelf = self;
    [self.guideImageView sd_setImageWithURL:[NSURL URLWithString:exhibit.exhibitUrl] placeholderImage:kPlaceHolderImage completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        CGFloat height = (SCREEN_WIDTH-40.0f) * image.size.height/image.size.width;
        weakSelf.guideAlertHeight.constant = height;
    }];
    self.guideLabel.text = exhibit.exhibitName;
}

- (void)hideGuideAlert {
    self.guideAlertBgView.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.currentHotIndex = NSNotFound;
    self.currentAllIndex = NSNotFound;
    [self.hotExhibitsCollectionView reloadData];
    [self.allExhibitsCollectionView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.guideView.hidden = YES;
}

#pragma mark -
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([collectionView isEqual:self.floorCollectionView]) {
        return self.regions.count;
    }else if([collectionView isEqual:self.hotExhibitsCollectionView]) {
        return self.hotExhibits.count;
    }else if([collectionView isEqual:self.allExhibitsCollectionView]) {
        return self.allExhibits.count;
    }else {
        return 0;
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([collectionView isEqual:self.floorCollectionView]) {
        MUFloorCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MUFloorCell" forIndexPath:indexPath];
        cell.floorLb.text = [NSString stringWithFormat:@"%ldF",indexPath.item+1];
        if (indexPath.item == self.currentFloor) {
            cell.floorLb.backgroundColor = kUIColorFromRGB(0x666666);
        }else {
            cell.floorLb.backgroundColor = kUIColorFromRGB(0x999999);
        }
        return cell;
    }else if([collectionView isEqual:self.hotExhibitsCollectionView]) {
        MUExhibitCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MUExhibitCell" forIndexPath:indexPath];
        MUExhibitModel *exhibit = self.hotExhibits[indexPath.item];
        [cell.exhibitImageView sd_setImageWithURL:[NSURL URLWithString:exhibit.exhibitUrl] placeholderImage:kPlaceHolderImage];
        if (indexPath.item == self.currentHotIndex) {
            cell.detailBgView.hidden = NO;
            cell.detailLb.textColor = [UIColor whiteColor];
        } else {
            cell.detailBgView.hidden = YES;
        }
        cell.exhibitNameLb.text = exhibit.exhibitName;
        return cell;
    }else if([collectionView isEqual:self.allExhibitsCollectionView]) {
        MUExhibitCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MUExhibitCell" forIndexPath:indexPath];
        MUExhibitModel *exhibit = self.allExhibits[indexPath.item];
        [cell.exhibitImageView sd_setImageWithURL:[NSURL URLWithString:exhibit.exhibitUrl] placeholderImage:kPlaceHolderImage];
        if (indexPath.item == self.currentAllIndex) {
            cell.detailBgView.hidden = NO;
            cell.detailLb.textColor = [UIColor whiteColor];
        } else {
            cell.detailBgView.hidden = YES;
        }
        cell.exhibitNameLb.text = exhibit.exhibitName;
        return cell;
    }else {
        return nil;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([collectionView isEqual:self.floorCollectionView]) {
        self.currentFloor = indexPath.item;
        [[NSUserDefaults standardUserDefaults] setObject:@(self.currentFloor) forKey:[NSString stringWithFormat:@"%@_floor",self.hall.hallId]];
        [self reloadRegion];
        [collectionView reloadData];
    }else if([collectionView isEqual:self.hotExhibitsCollectionView]) {
        MUExhibitModel *exhibit = self.hotExhibits[indexPath.item];
        if (self.currentHotIndex == indexPath.item) {
            MUExhibitDetailViewController *vc = [MUExhibitDetailViewController new];
            vc.exhibitId = exhibit.exhibitId;
            [self.navigationController pushViewController:vc animated:YES];
            return;
        }
        self.selectExhibit = nil;
        self.currentHotIndex = indexPath.item;
        NSInteger tag = [self.allExhibits indexOfObject:exhibit]+1000;
        for (UIView *subView in self.hallImageView.subviews) {
            if ([subView isKindOfClass:[UIButton class]]) {
                UIButton *bt = (UIButton *)subView;
                if (bt.tag == tag) {
                    bt.selected = YES;
                }else {
                    bt.selected = NO;
                }
            }
        }
        [collectionView reloadData];
    }else if([collectionView isEqual:self.allExhibitsCollectionView]) {
        MUExhibitModel *exhibit = self.allExhibits[indexPath.item];
        if (self.currentAllIndex == indexPath.item) {
            MUExhibitDetailViewController *vc = [MUExhibitDetailViewController new];
            vc.exhibitId = exhibit.exhibitId;
            [self.navigationController pushViewController:vc animated:YES];
            return;
        }
        self.selectExhibit = nil;
        self.currentAllIndex = indexPath.item;
        NSInteger tag = [self.allExhibits indexOfObject:exhibit]+1000;
        for (UIView *subView in self.hallImageView.subviews) {
            if ([subView isKindOfClass:[UIButton class]]) {
                UIButton *bt = (UIButton *)subView;
                if (bt.tag == tag) {
                    bt.selected = YES;
                }else {
                    bt.selected = NO;
                }
            }
        }
        [collectionView reloadData];
    }
}

#pragma mark -
- (CAShapeLayer *)addTransparencyViewWith:(UIBezierPath *)tempPath{
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:SCREEN_BOUNDS];
    [path appendPath:tempPath];
    path.usesEvenOddFillRule = YES;
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = path.CGPath;
    shapeLayer.fillColor= [UIColor blackColor].CGColor;  // 其他颜色都可以，只要不是透明的
    shapeLayer.fillRule = kCAFillRuleEvenOdd;
    return shapeLayer;
}

- (void)addExhibitGuideMask {
    
    CGRect rect = CGRectMake(15, self.topConstraint.constant+45+10+self.hallImageHeightConstraint.constant+44.0f+10.0f+44.0f, 120.0f, 100.0f);
    if (self.hotExhibits.count == 0) {
        rect = CGRectMake(15, self.topConstraint.constant+45+10+self.hallImageHeightConstraint.constant+44.0f+10.0f+44.0f+100.0f+44.0f, 120.0f, 100.0f);
    }
    UIBezierPath *tempPath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:(UIRectCornerTopLeft |UIRectCornerTopRight |UIRectCornerBottomRight|UIRectCornerBottomLeft) cornerRadii:CGSizeMake(4, 4)];
    UIView *guideView = [[UIView alloc] initWithFrame:SCREEN_BOUNDS];
    guideView.backgroundColor = [UIColor blackColor];
    guideView.alpha = 0.8;
    guideView.layer.mask = [self addTransparencyViewWith:tempPath];
    [[UIApplication sharedApplication].keyWindow addSubview:guideView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = rect;
    button.backgroundColor = [UIColor clearColor];
    [button addTapTarget:self action:@selector(didMaskExhibitClicked:)];
    [guideView addSubview:button];;
    
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"引导下箭头"]];
    [guideView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(button.mas_top).offset(-5.0f);
        make.centerX.equalTo(button);
        make.width.height.mas_equalTo(30.0f);
    }];
    
    UILabel *tipsLb = [[UILabel alloc]init];
    tipsLb.textColor = [UIColor whiteColor];
    tipsLb.font = [UIFont systemFontOfSize:14.0f];
    tipsLb.text = @"第二次点击可查看展品详情";
    [guideView addSubview:tipsLb];
    [tipsLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20.0f);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(30.0f);
        make.bottom.equalTo(imageView.mas_top).offset(-5.0f);
    }];
    self.guideView = guideView;
}

- (void)didMaskExhibitClicked:(id)sender {
    if (self.hotExhibits.count == 0) {
        MUExhibitModel *exhibit = [self.allExhibits firstObject];
        if (exhibit == nil) return;
        if (self.currentAllIndex == 0) {
            self.guideView.hidden = YES;
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"exhibit_guide"];
            MUExhibitDetailViewController *vc = [MUExhibitDetailViewController new];
            vc.exhibitId = exhibit.exhibitId;
            [self.navigationController pushViewController:vc animated:YES];
            return;
        }
        self.selectExhibit = nil;
        self.currentAllIndex = 0;
        NSInteger tag = [self.allExhibits indexOfObject:exhibit]+1000;
        for (UIView *subView in self.hallImageView.subviews) {
            if ([subView isKindOfClass:[UIButton class]]) {
                UIButton *bt = (UIButton *)subView;
                if (bt.tag == tag) {
                    bt.selected = YES;
                }else {
                    bt.selected = NO;
                }
            }
        }
        [self.allExhibitsCollectionView reloadData];
    } else {
        MUExhibitModel *exhibit = [self.hotExhibits firstObject];
        if (exhibit == nil) return;
        if (self.currentHotIndex == 0) {
            self.guideView.hidden = YES;
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"exhibit_guide"];
            MUExhibitDetailViewController *vc = [MUExhibitDetailViewController new];
            vc.exhibitId = exhibit.exhibitId;
            [self.navigationController pushViewController:vc animated:YES];
            return;
        }
        self.selectExhibit = nil;
        self.currentHotIndex = 0;
        NSInteger tag = [self.allExhibits indexOfObject:exhibit]+1000;
        for (UIView *subView in self.hallImageView.subviews) {
            if ([subView isKindOfClass:[UIButton class]]) {
                UIButton *bt = (UIButton *)subView;
                if (bt.tag == tag) {
                    bt.selected = YES;
                }else {
                    bt.selected = NO;
                }
            }
        }
        [self.hotExhibitsCollectionView reloadData];
    }
}

#pragma mark -

- (IBAction)didReturnClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
