//
//  MUSearchViewController.m
//  MuseumAi
//
//  Created by Kingo on 2018/9/20.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUSearchViewController.h"
#import "MUSearchModel.h"
#import "MUSearchCollectionCell.h"
#import "MUAlightLayout.h"
#import "MUSearchResultViewController.h"

#import "MUSearchHotReusableView.h"
#import "MUSearchHistoryReusableView.h"

#define HISTORYKEY @"historySearch"

@interface MUSearchViewController ()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UISearchResultsUpdating,UISearchBarDelegate,UITextFieldDelegate>


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;

/** 热门搜索列表 */
@property (nonatomic , strong) NSArray<MUSearchModel *> *hotSearchs;
/** 我的搜索列表 */
@property (nonatomic , strong) NSArray<NSString *> *historySearchs;


@property (weak, nonatomic) IBOutlet UIButton *returnBt;

//@property (weak, nonatomic) IBOutlet UIButton *searchBt;
@property (weak, nonatomic) IBOutlet UIView *searchBackView;

@property (weak, nonatomic) IBOutlet UICollectionView *historyCollectionView;

@property (nonatomic, strong) UITextField *searchField;
@property (nonatomic, strong) UISearchBar *searchBar;
@end

@implementation MUSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self viewInit];
    
    [self dataInit];
}

- (void)viewInit {
    
    self.topConstraint.constant = SafeAreaTopHeight-44.0f;
    self.navHeight.constant = SafeAreaTopHeight;
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(52, self.topConstraint.constant, SCREEN_WIDTH - 77, 34)];
    _searchBar.placeholder = @"请输入展览馆的名称";
    _searchBar.layer.cornerRadius = 17;
    _searchBar.layer.masksToBounds = YES;
    _searchBar.backgroundImage = [[UIImage alloc] init];
    _searchBar.backgroundColor = [UIColor whiteColor];
    _searchBar.showsCancelButton = NO;
    _searchBar.barStyle=UIBarStyleDefault;
    _searchBar.keyboardType = UIKeyboardTypeNamePhonePad;
    _searchBar.delegate = self;
    _searchBar.showsSearchResultsButton = NO;
    //    [searchBar setImage:[UIImage imageNamed:@"Search_Icon"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    [_searchBar setImage:[UIImage imageNamed:@"搜索"] forSearchBarIcon:UISearchBarIconClear state:UIControlStateNormal];
    _searchBar.tintColor = kUIColorFromRGB(0x333333);
    
    _searchField = [_searchBar valueForKey:@"_searchField"];
    //    _searchField.delegate = self;
    [_searchField setBackgroundColor:[UIColor clearColor]];
    _searchField.textColor= kUIColorFromRGB(0x333333);
    _searchField.font = [UIFont systemFontOfSize:15];
    [_searchField setValue:[UIFont systemFontOfSize:15] forKeyPath:@"_placeholderLabel.font"];
    [_searchField setValue:kUIColorFromRGB(0x999999) forKeyPath:@"_placeholderLabel.textColor"];
    //只有编辑时出现出现那个叉叉
    _searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.searchBackView addSubview:_searchBar];
    
    
    [self.returnBt setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];

    MUAlightLayout  *layout2 = [[MUAlightLayout alloc] initWthType:AlignWithLeft];
    layout2.minimumLineSpacing = 5;
    layout2. minimumInteritemSpacing  = 2;
    layout2.scrollDirection =  UICollectionViewScrollDirectionVertical;
    layout2.sectionInset = UIEdgeInsetsMake(0,0,0,0);
    
    [self.historyCollectionView setCollectionViewLayout:layout2];
    self.historyCollectionView.backgroundColor = [UIColor whiteColor];
    self.historyCollectionView.delegate = self;
    self.historyCollectionView.dataSource = self;
    [self.historyCollectionView registerClass:[MUSearchCollectionCell class] forCellWithReuseIdentifier:@"MUSearchCollectionCell"];
    [self.historyCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([MUSearchHotReusableView class]) bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"MUSearchHotReusableView"];
    [self.historyCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([MUSearchHistoryReusableView class]) bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"MUSearchHistoryReusableView"];
    
    
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
//    if ([keyPath isEqualToString:@"contentSize"] && [object isEqual:self.hotCollectionView]) {
//        CGSize size = self.hotCollectionView.contentSize;
//        self.hotConstraint.constant = size.height;
//    }
//}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.historySearchs = [[NSUserDefaults standardUserDefaults]objectForKey:HISTORYKEY];
    if (![self.historySearchs isKindOfClass:[NSArray class]]) {
        self.historySearchs = [NSArray array];
    }
    [self.historyCollectionView reloadData];

}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [self.searchBar resignFirstResponder];
}

- (void)dataInit {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak typeof(self) weakSelf = self;
    [MUHttpDataAccess getHotSearchsWithPage:1 success:^(id result) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        if ([result[@"state"]integerValue] == 10001) {
            NSMutableArray *mutSearchs = [NSMutableArray array];
            NSArray *list = result[@"data"][@"list"];
            for (NSDictionary *dic in list) {
                MUSearchModel *search = [MUSearchModel new];
                search.name = dic[@"exhibitionName"];
                search.exhibitionId = dic[@"id"];
                search.clickNum = dic[@"click"];
                [mutSearchs addObject:search];
            }
            weakSelf.hotSearchs = [NSArray arrayWithArray:mutSearchs];
            [weakSelf.historyCollectionView reloadData];
        }
    } failed:^(NSError *error) {
        [weakSelf alertWithMsg:kFailedTips handler:nil];
    }];
}

#pragma mark -
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return self.hotSearchs.count;
    } else if(section == 1) {
        return self.historySearchs.count;
    } else {
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        /// 热门
        MUSearchCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MUSearchCollectionCell" forIndexPath:indexPath];
        MUSearchModel *search = self.hotSearchs[indexPath.item];
        cell.textLabel.text = search.name;
        return cell;
    } else if (indexPath.section == 1) {
        /// 我的
        MUSearchCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MUSearchCollectionCell" forIndexPath:indexPath];
        cell.textLabel.text = self.historySearchs[indexPath.item];
        return cell;
    } else {
        return nil;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(SCREEN_WIDTH, 55.0f);
}
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section;

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(SCREEN_WIDTH, 40.0f);
//    if ([collectionView isEqual:self.hotCollectionView]) {
//        /// 热门
//        MUSearchModel *search = self.hotSearchs[indexPath.item];
//        UILabel *lb = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30.0f)];
//        lb.text = search.name;
//        lb.font = [UIFont systemFontOfSize:12.0f];
//        [lb sizeToFit];
//        CGFloat width = lb.frame.size.width;
//        return CGSizeMake(width+10.0f, 30.0f);
//    } else if([collectionView isEqual:self.historyCollectionView]) {
//        /// 我的
//        UILabel *lb = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30.0f)];
//        lb.text = self.historySearchs[indexPath.item];
//        lb.font = [UIFont systemFontOfSize:12.0f];
//        [lb sizeToFit];
//        CGFloat width = lb.frame.size.width;
//        return CGSizeMake(width+10.0f, 30.0f);
//    } else {
//        return CGSizeZero;
//    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if ([kind  isEqualToString:UICollectionElementKindSectionHeader]) {  //header
        if (indexPath.section == 0) {
            /// 热门
            MUSearchHotReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"MUSearchHotReusableView" forIndexPath:indexPath];
            return header;
        } else if (indexPath.section == 1) {
            MUSearchHistoryReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"MUSearchHistoryReusableView" forIndexPath:indexPath];
            return header;
        }
    }
    return [UICollectionReusableView new];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        /// 热门
        NSString *searchStr = self.hotSearchs[indexPath.item].name;
        NSMutableArray *mutHis = [NSMutableArray arrayWithArray:self.historySearchs];
        if ([mutHis containsObject:searchStr]) {
            [mutHis removeObject:searchStr];
        }
        [mutHis insertObject:searchStr atIndex:0];
        self.historySearchs = [NSArray arrayWithArray:mutHis];
        [[NSUserDefaults standardUserDefaults] setObject:self.historySearchs forKey:HISTORYKEY];
        
        [self toSearchController:searchStr];
        
    } else if (indexPath.section == 1) {
        /// 我的
        NSString *searchStr = self.historySearchs[indexPath.item];
        NSMutableArray *mutHis = [NSMutableArray arrayWithArray:self.historySearchs];
        if ([mutHis containsObject:searchStr]) {
            [mutHis removeObject:searchStr];
        }
        [mutHis insertObject:searchStr atIndex:0];
        self.historySearchs = [NSArray arrayWithArray:mutHis];
        [[NSUserDefaults standardUserDefaults] setObject:self.historySearchs forKey:HISTORYKEY];
        
        [self toSearchController:searchStr];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.searchBar resignFirstResponder];
}
#pragma mark -
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.searchBar resignFirstResponder];
}

#pragma mark - Text View Delegate

// 键盘中，搜索按钮被按下，执行的方法
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self didSearchClicked:nil];
}

#pragma mark -

- (IBAction)didReturnClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)didSearchClicked:(id)sender {
    
    NSString *searchStr = self.searchBar.text;
    if (searchStr.length == 0) {
        [self alertWithMsg:@"请输入搜索内容" handler:nil];
        return;
    }
    NSMutableArray *mutHis = [NSMutableArray arrayWithArray:self.historySearchs];
    if ([mutHis containsObject:searchStr]) {
        [mutHis removeObject:searchStr];
    }
    [mutHis insertObject:searchStr atIndex:0];
    self.historySearchs = [NSArray arrayWithArray:mutHis];
    [[NSUserDefaults standardUserDefaults] setObject:self.historySearchs forKey:HISTORYKEY];
    
    [self toSearchController:searchStr];
}

- (void)toSearchController:(NSString *)searchStr {
    
    MUSearchResultViewController *resultVC = [MUSearchResultViewController new];
    resultVC.searchStr = searchStr;
    [self.navigationController pushViewController:resultVC animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
