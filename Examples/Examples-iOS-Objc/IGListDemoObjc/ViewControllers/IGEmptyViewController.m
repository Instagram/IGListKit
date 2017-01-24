//
//  IGEmptyViewController.m
//  IGListDemoObjc
//
//  Created by Charles on 1/21/17.
//  Copyright © 2017 Charles. All rights reserved.
//

#import "IGEmptyViewController.h"
#import <IGListKit.h>
#import "IGRemoveSectionController.h"

@interface IGEmptyViewController () <IGListAdapterDataSource, IGRemoveSectionControllerDelegate>
@property (nonatomic, strong) IGListCollectionView *collectionView;
@property (nonatomic, strong) IGListAdapter *adapter;
@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, strong) NSNumber *tally;
@property (nonatomic, strong) UILabel *emptyLabel;
@end

@implementation IGEmptyViewController

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
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onAdd)];
    
    self.tally = @(self.data.count);
    
    self.collectionView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    [self.view addSubview:self.collectionView];
    
    self.adapter.collectionView = self.collectionView;
    self.adapter.dataSource = self;
}

#pragma mark - Actions

- (void)onAdd {
    self.tally = @(self.tally.integerValue + 1);
    [self.data addObject:self.tally];
    [self.adapter performUpdatesAnimated:YES completion:nil];
}

#pragma mark - IGListAdapterDataSource

- (NSArray<id<IGListDiffable>> *)objectsForListAdapter:(IGListAdapter *)listAdapter {
    return self.data;
}

- (IGListSectionController<IGListSectionType> *)listAdapter:(IGListAdapter *)listAdapter sectionControllerForObject:(id)object {
    IGRemoveSectionController *sectionController = [[IGRemoveSectionController alloc] init];
    sectionController.delegate = self;
    return sectionController;
}

- (UIView *)emptyViewForListAdapter:(IGListAdapter *)listAdapter {
    return self.emptyLabel;
}

#pragma mark - IGRemoveSectionControllerDelegate

- (void)removeSectionControllerwantsRemove:(IGRemoveSectionController *)removeSectionControlller {
    NSInteger section = [self.adapter sectionForSectionController:removeSectionControlller];
    if (section < self.data.count) {
        [self.data removeObjectAtIndex:section];
        [self.adapter performUpdatesAnimated:YES completion:nil];
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

- (NSMutableArray *)data {
    if (!_data) {
        _data = [@[ @(1), @(2), @(3), @(4) ] mutableCopy];
    }
    return _data;
}

- (UILabel *)emptyLabel {
    if (!_emptyLabel) {
        _emptyLabel = [[UILabel alloc] init];
        _emptyLabel.numberOfLines = 0;
        _emptyLabel.textAlignment = NSTextAlignmentCenter;
        _emptyLabel.text = @"No more data!";
        _emptyLabel.backgroundColor = [UIColor clearColor];
    }
    return _emptyLabel;
}

@end
