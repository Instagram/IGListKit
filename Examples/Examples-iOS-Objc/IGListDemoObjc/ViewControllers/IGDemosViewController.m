//
//  IGDemosViewController.m
//  IGListDemoObjc
//
//  Created by Charles on 1/21/17.
//  Copyright © 2017 Charles. All rights reserved.
//

#import "IGDemosViewController.h"
#import <IGListKit.h>
#import "IGDemoSectionController.h"
#import "IGLoadMoreViewController.h"
#import "IGSearchViewController.h"
#import "IGMixedDataViewController.h"
#import "IGNestedAdapterViewController.h"
#import "IGEmptyViewController.h"
#import "IGDemoItem.h"

@interface IGDemosViewController () <IGListAdapterDataSource>
@property (nonatomic, strong) IGListCollectionView *collectionView;
@property (nonatomic, strong) IGListAdapter *adapter;
@property (nonatomic, strong) NSArray *demos;
@end

@implementation IGDemosViewController

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
    self.title = @"Demos";
    
    UICollectionViewLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionView = [[IGListCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [self.view addSubview:self.collectionView];
    
    self.adapter.collectionView = self.collectionView;
    self.adapter.dataSource = self;
}

#pragma mark - IGListAdapterDataSource

- (NSArray<id<IGListDiffable>> *)objectsForListAdapter:(IGListAdapter *)listAdapter {
    return self.demos;
}

- (IGListSectionController<IGListSectionType> *)listAdapter:(IGListAdapter *)listAdapter sectionControllerForObject:(id)object {
    return [[IGDemoSectionController alloc] init];
}

- (UIView *)emptyViewForListAdapter:(IGListAdapter *)listAdapter {
    return nil;
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

- (NSArray *)demos {
    return @[
             [[IGDemoItem alloc] initWithName:@"Tail Loading" controller:[[IGLoadMoreViewController alloc] init]],
             [[IGDemoItem alloc] initWithName:@"Search Autocomplete" controller:[[IGSearchViewController alloc] init]],
             [[IGDemoItem alloc] initWithName:@"Mixed Data" controller:[[IGMixedDataViewController alloc] init]],
             [[IGDemoItem alloc] initWithName:@"Nested Adapter" controller:[[IGNestedAdapterViewController alloc] init]],
             [[IGDemoItem alloc] initWithName:@"Empty View" controller:[[IGEmptyViewController alloc] init]]
             ];
}

@end
