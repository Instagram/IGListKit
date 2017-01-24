//
//  IGLoadMoreViewController.m
//  IGListDemoObjc
//
//  Created by Charles on 1/21/17.
//  Copyright © 2017 Charles. All rights reserved.
//

#import "IGLoadMoreViewController.h"
#import <IGListKit.h>
#import "IGLabelSectionController.h"
#import "IGSpinnerCell.h"

@interface IGLoadMoreViewController () <IGListAdapterDataSource, UIScrollViewDelegate>
@property (nonatomic, strong) IGListCollectionView *collectionView;
@property (nonatomic, strong) IGListAdapter *adapter;
@property (nonatomic, strong) NSMutableArray *words;
@property (nonatomic, copy) NSString *spinObject;
@property (nonatomic, assign, getter=isLoading) BOOL loading;
@end

@implementation IGLoadMoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.collectionView.frame = self.view.bounds;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - setupUI

- (void)setupUI {
    
    [self.view addSubview:self.collectionView];
    
    self.adapter.collectionView = self.collectionView;
    self.adapter.dataSource = self;
    self.adapter.scrollViewDelegate = self;
}

#pragma mark - IGListAdapterDataSource

- (NSArray<id<IGListDiffable>> *)objectsForListAdapter:(IGListAdapter *)listAdapter {
    NSMutableArray *items = [self.words mutableCopy];
    if (self.isLoading) {
        [items addObject:self.spinObject];
    }
    return items;
}

- (IGListSectionController<IGListSectionType> *)listAdapter:(IGListAdapter *)listAdapter sectionControllerForObject:(id)object {
    if ([object isEqualToString:self.spinObject]) {
        IGListSingleSectionCellConfigureBlock configureBlock = ^(id item, UICollectionViewCell *cell) {};
        IGListSingleSectionCellSizeBlock sizeBlock =  ^CGSize ( id item, id<IGListCollectionContext> context) {
            return CGSizeMake(context.containerSize.width, 100);
        };
        return [[IGListSingleSectionController alloc] initWithCellClass:[IGSpinnerCell class] configureBlock:configureBlock sizeBlock:sizeBlock];
    } else {
        return [[IGLabelSectionController alloc] init];
    }
}

- (UIView *)emptyViewForListAdapter:(IGListAdapter *)listAdapter {
    return nil;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    CGFloat distance = scrollView.contentSize.height - (targetContentOffset -> y + scrollView.bounds.size.height);
    if (!self.isLoading && distance < 200) {
        self.loading = YES;
        [self.adapter performUpdatesAnimated:YES completion:nil];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            sleep(2);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.loading = NO;
                [self.words addObjectsFromArray:[@"Etiam porta sem malesuada magna mollis euismod" componentsSeparatedByString:@" "]];
                [self.adapter performUpdatesAnimated:YES completion:nil];
            });
        });
    }
}

#pragma mark - Custom Accessors

- (IGListAdapter *)adapter {
    if (!_adapter) {
        _adapter = [[IGListAdapter alloc] initWithUpdater:[[IGListAdapterUpdater alloc] init]
                                           viewController:self
                                         workingRangeSize:0];
    }
    return _adapter;
}

- (IGListCollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[IGListCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    }
    return _collectionView;
}

- (NSMutableArray *)words {
    if (!_words) {
        _words = [[@"Maecenas faucibus mollis interdum Praesent commodo cursus magna, vel scelerisque nisl consectetur et" componentsSeparatedByString:@" "] mutableCopy];
    }
    return _words;
}

- (NSString *)spinObject {
    if (!_spinObject) {
        _spinObject = @"";
    }
    return _spinObject;
}

@end
