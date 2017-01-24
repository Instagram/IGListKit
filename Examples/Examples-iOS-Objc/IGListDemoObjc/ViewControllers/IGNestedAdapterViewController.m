//
//  IGNestedAdapterViewController.m
//  IGListDemoObjc
//
//  Created by Charles on 1/21/17.
//  Copyright © 2017 Charles. All rights reserved.
//

#import "IGNestedAdapterViewController.h"
#import <IGListKit.h>
#import "IGHorizontalSectionController.h"
#import "IGLabelSectionController.h"

@interface IGNestedAdapterViewController () <IGListAdapterDataSource>
@property (nonatomic, strong) IGListCollectionView *collectionView;
@property (nonatomic, strong) IGListAdapter *adapter;
@property (nonatomic, strong) NSArray *data;
@end

@implementation IGNestedAdapterViewController

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
}

#pragma mark - IGListAdapterDataSource

- (NSArray<id<IGListDiffable>> *)objectsForListAdapter:(IGListAdapter *)listAdapter {
    return self.data;
}

- (IGListSectionController<IGListSectionType> *)listAdapter:(IGListAdapter *)listAdapter sectionControllerForObject:(id)object {
    if ([object isKindOfClass:[NSNumber class]]) {
        return [[IGHorizontalSectionController alloc] init];
    } else {
        return [[IGLabelSectionController alloc] init];
    }
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

- (IGListCollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[IGListCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    }
    return _collectionView;
}

- (NSArray *)data {
    if (!_data) {
        _data = @[
                  @"Ridiculus Elit Tellus Purus Aenean",
                  @"Condimentum Sollicitudin Adipiscing",
                  @(14),
                  @"Ligula Ipsum Tristique Parturient Euismod",
                  @"Purus Dapibus Vulputate",
                  @(6),
                  @"Tellus Nibh Ipsum Inceptos",
                  @(2)
                  ];
    }
    return _data;
}

@end
