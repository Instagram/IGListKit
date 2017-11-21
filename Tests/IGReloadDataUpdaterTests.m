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

#import "IGListAdapterInternal.h"
#import "IGListTestSection.h"
#import "IGListTestAdapterDataSource.h"
#import "IGListTestAdapterReorderingDataSource.h"
#import "IGTestReorderableSection.h"

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

- (void)test_whenSectionIsInteractivelyReordered_thatIndexesUpdateCorrectly {
    IGListReloadDataUpdater *updater = [[IGListReloadDataUpdater alloc] init];
    IGListAdapter *adapter = [[IGListAdapter alloc] initWithUpdater:updater viewController:nil];

    IGListTestAdapterReorderingDataSource *dataSource = [IGListTestAdapterReorderingDataSource new];
    dataSource.objects = @[@0, @1, @2];
    adapter.dataSource = dataSource;
    adapter.moveDelegate = dataSource;

    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                                          collectionViewLayout:[UICollectionViewFlowLayout new]];
    adapter.collectionView = collectionView;

    IGTestReorderableSection *section0 = (IGTestReorderableSection *)[adapter sectionControllerForSection:0];
    IGTestReorderableSection *section1 = (IGTestReorderableSection *)[adapter sectionControllerForSection:1];
    IGTestReorderableSection *section2 = (IGTestReorderableSection *)[adapter sectionControllerForSection:2];
    section0.sectionObject = [IGTestReorderableSectionObject sectionWithObjects:@[@0]];
    section1.sectionObject = [IGTestReorderableSectionObject sectionWithObjects:@[@0]];
    section2.sectionObject = [IGTestReorderableSectionObject sectionWithObjects:@[@0]];
    section2.isReorderable = YES;
    
    [adapter performUpdatesAnimated:NO completion:nil];

    NSIndexPath *fromIndexPath, *toIndexPath;

    // move the last section into the first position, dropping into the end of the first section
    fromIndexPath = [NSIndexPath indexPathForItem:0 inSection:2];
    toIndexPath = [NSIndexPath indexPathForItem:1 inSection:0];
    [adapter collectionView:collectionView moveItemAtIndexPath:fromIndexPath toIndexPath:toIndexPath];

    XCTAssertEqual(section0, [adapter sectionControllerForSection:0]);
    XCTAssertEqual(section2, [adapter sectionControllerForSection:1]);
    XCTAssertEqual(section1, [adapter sectionControllerForSection:2]);

    // move the last section into the first position, dropping into the start of the first section
    fromIndexPath = [NSIndexPath indexPathForItem:0 inSection:2];
    toIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [adapter collectionView:collectionView moveItemAtIndexPath:fromIndexPath toIndexPath:toIndexPath];

    XCTAssertEqual(section1, [adapter sectionControllerForSection:0]);
    XCTAssertEqual(section0, [adapter sectionControllerForSection:1]);
    XCTAssertEqual(section2, [adapter sectionControllerForSection:2]);

    // move the first section into the last position, dropping into the start of the last section
    fromIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    toIndexPath = [NSIndexPath indexPathForItem:0 inSection:2];
    [adapter collectionView:collectionView moveItemAtIndexPath:fromIndexPath toIndexPath:toIndexPath];

    XCTAssertEqual(section0, [adapter sectionControllerForSection:0]);
    XCTAssertEqual(section1, [adapter sectionControllerForSection:1]);
    XCTAssertEqual(section2, [adapter sectionControllerForSection:2]);

    // move the first section into the last position, dropping into the end of the last section
    fromIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    toIndexPath = [NSIndexPath indexPathForItem:1 inSection:2];
    [adapter collectionView:collectionView moveItemAtIndexPath:fromIndexPath toIndexPath:toIndexPath];

    XCTAssertEqual(section1, [adapter sectionControllerForSection:0]);
    XCTAssertEqual(section2, [adapter sectionControllerForSection:1]);
    XCTAssertEqual(section0, [adapter sectionControllerForSection:2]);
}

- (void)test_whenItemsInSectionAreInteractivelyReordered_thatIndexesUpdateCorrectly {
    IGListReloadDataUpdater *updater = [[IGListReloadDataUpdater alloc] init];
    IGListAdapter *adapter = [[IGListAdapter alloc] initWithUpdater:updater viewController:nil];

    IGListTestAdapterReorderingDataSource *dataSource = [IGListTestAdapterReorderingDataSource new];
    dataSource.objects = @[@0];
    adapter.dataSource = dataSource;
    adapter.moveDelegate = dataSource;

    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                                          collectionViewLayout:[UICollectionViewFlowLayout new]];
    adapter.collectionView = collectionView;

    NSArray *sectionObjects = @[@0, @1, @2];

    IGTestReorderableSection *section = (IGTestReorderableSection *)[adapter sectionControllerForSection:0];
    section.sectionObject = [IGTestReorderableSectionObject sectionWithObjects:sectionObjects];
    section.isReorderable = YES;

    [adapter performUpdatesAnimated:NO completion:nil];

    NSIndexPath *fromIndexPath, *toIndexPath;

    // move the last item into the first position
    fromIndexPath = [NSIndexPath indexPathForItem:2 inSection:0];
    toIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [adapter collectionView:collectionView moveItemAtIndexPath:fromIndexPath toIndexPath:toIndexPath];

    XCTAssertEqual(sectionObjects[2], section.sectionObject.objects[0]);
    XCTAssertEqual(sectionObjects[0], section.sectionObject.objects[1]);
    XCTAssertEqual(sectionObjects[1], section.sectionObject.objects[2]);

    // move the last item into the middle position
    fromIndexPath = [NSIndexPath indexPathForItem:2 inSection:0];
    toIndexPath = [NSIndexPath indexPathForItem:1 inSection:0];
    [adapter collectionView:collectionView moveItemAtIndexPath:fromIndexPath toIndexPath:toIndexPath];

    XCTAssertEqual(sectionObjects[2], section.sectionObject.objects[0]);
    XCTAssertEqual(sectionObjects[1], section.sectionObject.objects[1]);
    XCTAssertEqual(sectionObjects[0], section.sectionObject.objects[2]);
}

- (void)test_whenItemsAreInteractivelyReorderedAcrossSections_thatIndexesRevertToOriginalState {
    IGListReloadDataUpdater *updater = [[IGListReloadDataUpdater alloc] init];
    IGListAdapter *adapter = [[IGListAdapter alloc] initWithUpdater:updater viewController:nil];

    IGListTestAdapterReorderingDataSource *dataSource = [IGListTestAdapterReorderingDataSource new];
    dataSource.objects = @[@0, @1];
    adapter.dataSource = dataSource;
    adapter.moveDelegate = dataSource;

    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                                          collectionViewLayout:[UICollectionViewFlowLayout new]];
    adapter.collectionView = collectionView;

    NSArray *section0Objects = @[@0, @1, @2];
    NSArray *section1Objects = @[@3, @4, @5];

    IGTestReorderableSection *section0 = (IGTestReorderableSection *)[adapter sectionControllerForSection:0];
    section0.sectionObject = [IGTestReorderableSectionObject sectionWithObjects:section0Objects];
    IGTestReorderableSection *section1 = (IGTestReorderableSection *)[adapter sectionControllerForSection:1];
    section1.sectionObject = [IGTestReorderableSectionObject sectionWithObjects:section1Objects];
    section1.isReorderable = YES;

    [adapter performUpdatesAnimated:NO completion:nil];

    NSIndexPath *fromIndexPath, *toIndexPath;

    // move an item from section 1 to section 0 and check that they are reverted
    fromIndexPath = [NSIndexPath indexPathForItem:0 inSection:1];
    toIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];

    [collectionView performBatchUpdates:^{
        [collectionView moveItemAtIndexPath:fromIndexPath toIndexPath:toIndexPath];

        [collectionView.dataSource collectionView:collectionView
                              moveItemAtIndexPath:fromIndexPath
                                      toIndexPath:toIndexPath];
    } completion:nil];

    XCTAssertEqual(section0Objects[0], section0.sectionObject.objects[0]);
    XCTAssertEqual(section0Objects[1], section0.sectionObject.objects[1]);
    XCTAssertEqual(section0Objects[2], section0.sectionObject.objects[2]);
    XCTAssertEqual(section1Objects[0], section1.sectionObject.objects[0]);
    XCTAssertEqual(section1Objects[1], section1.sectionObject.objects[1]);
    XCTAssertEqual(section1Objects[2], section1.sectionObject.objects[2]);
}

@end
