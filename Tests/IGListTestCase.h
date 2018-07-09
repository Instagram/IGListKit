/**
 * Copyright (c) 2016-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <XCTest/XCTest.h>

#import <IGListKit/IGListKit.h>

#import "IGListTestHelpers.h"

@protocol IGListTestCaseDataSource <IGListAdapterDataSource>
- (NSArray *)objects;
- (void)setObjects:(NSArray<id<IGListDiffable>> *)objects;
@end

@interface IGListTestCase : XCTestCase

// These objects are created for you in -setUp
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) IGListAdapter *adapter;
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;

// Created in -setUp if your subclass has not already created one
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) CGRect frame; // default 0,0,100,100
@property (nonatomic, strong) id<IGListUpdatingDelegate> updater; // default IGListAdapterUpdater

// Required objects must be set before [super setUp] in your test subclass
@property (nonatomic, strong) id<IGListTestCaseDataSource> dataSource;

// Optional properties that you can set before [super setUp]
@property (nonatomic, strong) UIViewController *viewController; // default nil
@property (nonatomic, assign) NSInteger workingRangeSize; // default 0

// Call to configure, layout, and display the adapter and collection view
- (void)setupWithObjects:(NSArray *)objects;

@end
