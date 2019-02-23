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

#define HISTORYKEY @"historySearch"

@interface MUSearchViewController ()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;

/** 热门搜索列表 */
@property (nonatomic , strong) NSArray<MUSearchModel *> *hotSearchs;
/** 我的搜索列表 */
@property (nonatomic , strong) NSArray<NSString *> *historySearchs;


@property (weak, nonatomic) IBOutlet UIButton *returnBt;

@property (weak, nonatomic) IBOutlet UIButton *searchBt;

@property (weak, nonatomic) IBOutlet UITextField *inputTextField;

@property (weak, nonatomic) IBOutlet UICollectionView *hotCollectionView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hotConstraint;

@property (weak, nonatomic) IBOutlet UICollectionView *historyCollectionView;

//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hostoryConstraint;

@end

@implementation MUSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self viewInit];
    
    [self dataInit];
}

- (void)viewInit {
    
    self.topConstraint.constant = SafeAreaTopHeight-44.0f;
    
    [self.returnBt setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [self.searchBt setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    
    MUAlightLayout  *layout = [[MUAlightLayout alloc] initWthType:AlignWithLeft];
    layout.minimumLineSpacing = 5;
    layout. minimumInteritemSpacing  = 2;
    layout.scrollDirection =  UICollectionViewScrollDirectionVertical;
    layout.sectionInset = UIEdgeInsetsMake(0,0,0,0);
    [self.hotCollectionView setCollectionViewLayout:layout];
    self.hotCollectionView.backgroundColor = [UIColor whiteColor];
    self.hotCollectionView.delegate = self;
    self.hotCollectionView.dataSource = self;
    [self.hotCollectionView registerClass:[MUSearchCollectionCell class] forCellWithReuseIdentifier:@"MUSearchCollectionCell"];
    [self.hotCollectionView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    
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
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentSize"] && [object isEqual:self.hotCollectionView]) {
        CGSize size = self.hotCollectionView.contentSize;
        self.hotConstraint.constant = size.height;
    }
}

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
    
    [self.inputTextField resignFirstResponder];
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
            [weakSelf.hotCollectionView reloadData];
        }
    } failed:^(NSError *error) {
        [weakSelf alertWithMsg:kFailedTips handler:nil];
    }];
}

#pragma mark -
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([collectionView isEqual:self.hotCollectionView]) {
        return self.hotSearchs.count;
    } else if([collectionView isEqual:self.historyCollectionView]) {
        return self.historySearchs.count;
    } else {
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([collectionView isEqual:self.hotCollectionView]) {
        /// 热门
        MUSearchCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MUSearchCollectionCell" forIndexPath:indexPath];
        MUSearchModel *search = self.hotSearchs[indexPath.item];
        cell.textLabel.text = search.name;
        return cell;
    } else if([collectionView isEqual:self.historyCollectionView]) {
        /// 我的
        MUSearchCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MUSearchCollectionCell" forIndexPath:indexPath];
        cell.textLabel.text = self.historySearchs[indexPath.item];
        return cell;
    } else {
        return nil;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([collectionView isEqual:self.hotCollectionView]) {
        /// 热门
        MUSearchModel *search = self.hotSearchs[indexPath.item];
        UILabel *lb = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30.0f)];
        lb.text = search.name;
        lb.font = [UIFont systemFontOfSize:12.0f];
        [lb sizeToFit];
        CGFloat width = lb.frame.size.width;
        return CGSizeMake(width+10.0f, 30.0f);
    } else if([collectionView isEqual:self.historyCollectionView]) {
        /// 我的
        UILabel *lb = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30.0f)];
        lb.text = self.historySearchs[indexPath.item];
        lb.font = [UIFont systemFontOfSize:12.0f];
        [lb sizeToFit];
        CGFloat width = lb.frame.size.width;
        return CGSizeMake(width+10.0f, 30.0f);
    } else {
        return CGSizeZero;
    }
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([collectionView isEqual:self.hotCollectionView]) {
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
        
    } else if([collectionView isEqual:self.historyCollectionView]) {
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

#pragma mark -
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.inputTextField resignFirstResponder];
}

#pragma mark -

- (IBAction)didReturnClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)didSearchClicked:(id)sender {
    
    NSString *searchStr = self.inputTextField.text;
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
