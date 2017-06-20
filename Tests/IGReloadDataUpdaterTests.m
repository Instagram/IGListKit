/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <XCTest/XCTest.h>

#import <IGListKit/IGListKit.h>

#import "IGListTestSection.h"
#import "IGListTestAdapterDataSource.h"

@interface IGReloadDataUpdaterTests : XCTestCase

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) IGListAdapter *adapter;
@property (nonatomic, strong) IGListTestAdapterDataSource *dataSource;
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) UIWindow *window;

@end

@implementation IGReloadDataUpdaterTests

- (void)setUp {
    [super setUp];

    // minimum line spacing, item size, and minimum interim spacing are all set in IGListTestSection
    self.window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];

    self.layout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.window.bounds collectionViewLayout:self.layout];

    [self.window addSubview:self.collectionView];

    // syncronous reloads so we dont have to do expectations or other nonsense
    IGListReloadDataUpdater *updater = [[IGListReloadDataUpdater alloc] init];

    self.dataSource = [[IGListTestAdapterDataSource alloc] init];
    self.adapter = [[IGListAdapter alloc] initWithUpdater:updater
                                           viewController:nil];
    self.adapter.collectionView = self.collectionView;
    self.adapter.dataSource = self.dataSource;
}

- (void)test_whenCompletionBlockExists_thatBlockExecuted {
    __block BOOL executed = NO;
    self.dataSource.objects = @[@0, @1, @2];
    [self.adapter reloadDataWithCompletion:^(BOOL finished) {
        executed = YES;
    }];
    XCTAssertTrue(executed);
}

- (void)test_whenInsertingIntoContext_thatCollectionViewUpdated {
    self.dataSource.objects = @[@2];
    [self.adapter reloadDataWithCompletion:nil];
    XCTAssertEqual([self.collectionView numberOfItemsInSection:0], 2);
    IGListTestSection *section = [self.adapter sectionControllerForObject:@2];
    [section.collectionContext performBatchAnimated:YES updates:^(id<IGListBatchContext> batchContext) {
        section.items = 3;
        [batchContext insertInSectionController:section atIndexes:[NSIndexSet indexSetWithIndex:0]];
    } completion:nil];
    XCTAssertEqual([self.collectionView numberOfItemsInSection:0], 3);
}

- (void)test_whenDeletingFromContext_thatCollectionViewUpdated {
    self.dataSource.objects = @[@2];
    [self.adapter reloadDataWithCompletion:nil];
    XCTAssertEqual([self.collectionView numberOfItemsInSection:0], 2);
    IGListTestSection *section = [self.adapter sectionControllerForObject:@2];
    [section.collectionContext performBatchAnimated:YES updates:^(id<IGListBatchContext> batchContext) {
        section.items = 1;
        [batchContext deleteInSectionController:section atIndexes:[NSIndexSet indexSetWithIndex:0]];
    } completion:nil];
    XCTAssertEqual([self.collectionView numberOfItemsInSection:0], 1);
}

- (void)test_whenReloadingInContext_thatCollectionViewUpdated {
    self.dataSource.objects = @[@2];
    [self.adapter reloadDataWithCompletion:nil];
    XCTAssertEqual([self.collectionView numberOfItemsInSection:0], 2);
    IGListTestSection *section = [self.adapter sectionControllerForObject:@2];
    [section.collectionContext performBatchAnimated:YES updates:^(id<IGListBatchContext> batchContext) {
        [batchContext reloadInSectionController:section atIndexes:[NSIndexSet indexSetWithIndex:0]];
    } completion:nil];
    XCTAssertEqual([self.collectionView numberOfItemsInSection:0], 2);
}

- (void)test_whenPerformingUpdate_thatCompletionExecuted {
    __block BOOL executed = NO;
    self.dataSource.objects = @[@0, @1, @2];
    [self.adapter performUpdatesAnimated:NO completion:^(BOOL finished) {
        executed = YES;
    }];
    XCTAssertTrue(executed);
}

- (void)test_whenMovingFromContext_thatCollectionViewUpdated {
    self.dataSource.objects = @[@2];
    [self.adapter reloadDataWithCompletion:nil];
    XCTAssertEqual([self.collectionView numberOfItemsInSection:0], 2);
    IGListTestSection *section = [self.adapter sectionControllerForObject:@2];
    [section.collectionContext performBatchAnimated:YES updates:^(id<IGListBatchContext> batchContext) {
        [batchContext moveInSectionController:section fromIndex:0 toIndex:1];
    } completion:nil];
    XCTAssertEqual([self.collectionView numberOfItemsInSection:0], 2);
}

@end
