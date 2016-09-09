/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant 
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <objc/runtime.h>

#import <XCTest/XCTest.h>

#import <OCMock/OCMockObject.h>

#import <IGListKit/IGListKit.h>
#import <IGListKit/IGListReloadDataUpdater.h>

#import "IGListAdapterInternal.h"
#import "IGListTestAdapterDataSource.h"
#import "IGListTestSection.h"
#import "IGTestSupplementarySource.h"

@interface IGListAdapterTests : XCTestCase

// infra does not hold a strong ref to collection view
@property (nonatomic, strong) IGListCollectionView *collectionView;
@property (nonatomic, strong) IGListAdapter *adapter;
@property (nonatomic, strong) IGListTestAdapterDataSource *dataSource;
@property (nonatomic, strong) UIWindow *window;

@end

@implementation IGListAdapterTests

- (void)setUp {
    [super setUp];

    // minimum line spacing, item size, and minimum interim spacing are all set in IGListTestSection
    self.window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionView = [[IGListCollectionView alloc] initWithFrame:self.window.bounds collectionViewLayout:layout];

    [self.window addSubview:self.collectionView];

    // syncronous reloads so we dont have to do expectations or other nonsense
    IGListReloadDataUpdater *updater = [[IGListReloadDataUpdater alloc] init];

    self.dataSource = [[IGListTestAdapterDataSource alloc] init];
    self.adapter = [[IGListAdapter alloc] initWithUpdatingDelegate:updater
                                                    viewController:nil
                                                  workingRangeSize:0];
    self.adapter.collectionView = self.collectionView;
    self.adapter.dataSource = self.dataSource;
}

- (void)tearDown {
    [super tearDown];
    self.window = nil;
    self.collectionView = nil;
    self.adapter = nil;
    self.dataSource = nil;
}

- (void)test_whenAdapterNotUpdated_withDataSourceUpdated_thatAdapterHasNoItemControllers {
    self.dataSource.objects = @[@0, @1, @2];
    XCTAssertNil([self.adapter itemControllerForItem:@0]);
    XCTAssertNil([self.adapter itemControllerForItem:@1]);
    XCTAssertNil([self.adapter itemControllerForItem:@2]);
}

- (void)test_whenAdapterUpdated_thatAdapterHasItemControllers {
    self.dataSource.objects = @[@0, @1, @2];
    [self.adapter performUpdatesAnimated:YES completion:nil];
    XCTAssertNotNil([self.adapter itemControllerForItem:@0]);
    XCTAssertNotNil([self.adapter itemControllerForItem:@1]);
    XCTAssertNotNil([self.adapter itemControllerForItem:@2]);
}

- (void)test_whenAdapterReloaded_thatAdapterHasItemControllers {
    self.dataSource.objects = @[@0, @1, @2];
    [self.adapter reloadDataWithCompletion:nil];
    XCTAssertNotNil([self.adapter itemControllerForItem:@0]);
    XCTAssertNotNil([self.adapter itemControllerForItem:@1]);
    XCTAssertNotNil([self.adapter itemControllerForItem:@2]);
}

- (void)test_whenAdapterUpdated_thatItemControllerHasSection {
    self.dataSource.objects = @[@0, @1, @2];
    [self.adapter performUpdatesAnimated:YES completion:nil];
    IGListItemController <IGListItemType> * list = [self.adapter itemControllerForItem:@1];
    XCTAssertEqual([self.adapter sectionForItemController:list], 1);
}

- (void)test_whenAdapterUpdated_withUnknownItem_thatItemControllerHasNoSection {
    self.dataSource.objects = @[@0, @1, @2];
    [self.adapter performUpdatesAnimated:YES completion:nil];
    IGListItemController <IGListItemType> * randomList = [[IGListTestSection alloc] init];
    XCTAssertEqual([self.adapter sectionForItemController:randomList], NSNotFound);
}

- (void)test_whenQueryingAdapter_withUnknownItem_thatItemControllerIsNil {
    self.dataSource.objects = @[@0, @1, @2];
    [self.adapter performUpdatesAnimated:YES completion:nil];
    XCTAssertNil([self.adapter itemControllerForItem:@3]);
}

- (void)test_whenQueryingIndexPaths_withItemController_thatPathsAreEqual {
    self.dataSource.objects = @[@0, @1, @2];
    [self.adapter performUpdatesAnimated:YES completion:nil];
    IGListItemController <IGListItemType> * second = [self.adapter itemControllerForItem:@1];
  NSArray *paths0 = [self.adapter indexPathsFromItemController:second
                                                       indexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 4)]
                                          adjustForUpdateBlock:NO];
    NSArray *expected = @[
                          [NSIndexPath indexPathForItem:2 inSection:1],
                          [NSIndexPath indexPathForItem:3 inSection:1],
                          [NSIndexPath indexPathForItem:4 inSection:1],
                          [NSIndexPath indexPathForItem:5 inSection:1],
                          ];
    XCTAssertEqualObjects(paths0, expected);
}

- (void)test_whenQueryingIndexPaths_insideBatchUpdateBlock_thatPathsAreEqual {
    self.dataSource.objects = @[@0, @1, @2];
    [self.adapter performUpdatesAnimated:YES completion:nil];
    IGListItemController <IGListItemType> * second = [self.adapter itemControllerForItem:@1];

    __block BOOL executed = NO;
    [self.adapter performBatchAnimated:YES updates:^{
      NSArray *paths = [self.adapter indexPathsFromItemController:second
                                                          indexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 2)]
                                             adjustForUpdateBlock:YES];
        NSArray *expected = @[
                              [NSIndexPath indexPathForItem:2 inSection:1],
                              [NSIndexPath indexPathForItem:3 inSection:1],
                              ];
        XCTAssertEqualObjects(paths, expected);

        executed = YES;
    } completion:nil];
    XCTAssertTrue(executed);
}

- (void)test_whenQueryingReusableIdentifier_thatIdentifierEqualsClassName {
    NSString *identifier = [self.adapter reusableViewIdentifierForClass:UICollectionViewCell.class];
    XCTAssertEqualObjects(identifier, @"UICollectionViewCell");
}

- (void)test_whenDataSourceChanges_thatBackgroundViewVisibilityChanges {
    self.dataSource.objects = @[@1];
    UIView *background = [[UIView alloc] init];
    self.dataSource.backgroundView = background;
    __block BOOL executed = NO;
    [self.adapter reloadDataWithCompletion:^(BOOL finished) {
        XCTAssertTrue(self.adapter.collectionView.backgroundView.hidden, @"Background view should be hidden");
        XCTAssertEqualObjects(background, self.adapter.collectionView.backgroundView, @"Background view not correctly assigned");

        self.dataSource.objects = @[];
        [self.adapter reloadDataWithCompletion:^(BOOL finished2) {
            XCTAssertFalse(self.adapter.collectionView.backgroundView.hidden, @"Background view should be visible");
            XCTAssertEqualObjects(background, self.adapter.collectionView.backgroundView, @"Background view not correctly assigned");
            executed = YES;
        }];
    }];
    XCTAssertTrue(executed);
}

- (void)test_whenReloadingData_thatNewItemControllersAreCreated {
    self.dataSource.objects = @[@0, @1, @2];
    [self.adapter reloadDataWithCompletion:nil];
    IGListItemController <IGListItemType> *oldItemController = [self.adapter itemControllerForItem:@1];
    [self.adapter reloadDataWithCompletion:nil];
    IGListItemController <IGListItemType> *newItemController = [self.adapter itemControllerForItem:@1];
    XCTAssertNotEqual(oldItemController, newItemController);
}

- (void)test_whenSettingCollectionView_thenSettingDataSource_thatViewControllerIsSet {
    self.dataSource.objects = @[@0, @1, @2];
    UIViewController *controller = [UIViewController new];
    IGListAdapter *adapter = [[IGListAdapter alloc] initWithUpdatingDelegate:[IGListReloadDataUpdater new]
                                                              viewController:controller
                                                            workingRangeSize:0];
    adapter.collectionView = self.collectionView;
    adapter.dataSource = self.dataSource;
    IGListItemController <IGListItemType> *itemController = [adapter itemControllerForItem:@1];
    XCTAssertEqual(controller, itemController.viewController);
}

- (void)test_whenSettingCollectionView_thenSettingDataSource_thatCellExists {
    self.dataSource.objects = @[@1];
    IGListAdapter *adapter = [[IGListAdapter alloc] initWithUpdatingDelegate:[IGListReloadDataUpdater new]
                                                              viewController:nil
                                                            workingRangeSize:0];
    adapter.collectionView = self.collectionView;
    adapter.dataSource = self.dataSource;
    [self.collectionView layoutIfNeeded];
    XCTAssertNotNil([self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]]);
}

- (void)test_whenSettingDataSource_thenSettingCollectionView_thatCellExists {
    self.dataSource.objects = @[@1];
    IGListAdapter *adapter = [[IGListAdapter alloc] initWithUpdatingDelegate:[IGListReloadDataUpdater new]
                                                              viewController:nil
                                                            workingRangeSize:0];
    adapter.dataSource = self.dataSource;
    adapter.collectionView = self.collectionView;
    [self.collectionView layoutIfNeeded];
    XCTAssertNotNil([self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]]);
}

- (void)test_whenChangingCollectionViews_thatCellsExist {
    self.dataSource.objects = @[@1];
    IGListAdapterUpdater *updater = [[IGListAdapterUpdater alloc] init];
    IGListAdapter *adapter = [[IGListAdapter alloc] initWithUpdatingDelegate:updater viewController:nil workingRangeSize:0];
    adapter.dataSource = self.dataSource;
    adapter.collectionView = self.collectionView;
    [self.collectionView layoutIfNeeded];
    XCTAssertNotNil([self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]]);

    IGListCollectionView *otherCollectionView = [[IGListCollectionView alloc] initWithFrame:self.collectionView.frame collectionViewLayout:self.collectionView.collectionViewLayout];
    adapter.collectionView = otherCollectionView;
    [otherCollectionView layoutIfNeeded];
    XCTAssertNotNil([otherCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]]);
}

- (void)test_whenChangingCollectionViewsToACollectionViewInUseByAnotherAdapter_thatCollectionViewDelegateIsUpdated {
    IGListTestAdapterDataSource *dataSource1 = [[IGListTestAdapterDataSource alloc] init];
    dataSource1.objects = @[@1];
    IGListAdapterUpdater *updater1 = [[IGListAdapterUpdater alloc] init];
    IGListAdapter *adapter1 = [[IGListAdapter alloc] initWithUpdatingDelegate:updater1 viewController:nil workingRangeSize:0];
    adapter1.dataSource = dataSource1;

    IGListTestAdapterDataSource *dataSource2 = [[IGListTestAdapterDataSource alloc] init];
    dataSource1.objects = @[@1];
    IGListAdapterUpdater *updater2 = [[IGListAdapterUpdater alloc] init];
    IGListAdapter *adapter2 = [[IGListAdapter alloc] initWithUpdatingDelegate:updater2 viewController:nil workingRangeSize:0];
    adapter1.dataSource = dataSource2;

    // associate collection view with adapter1
    adapter1.collectionView = self.collectionView;
    XCTAssertEqual(self.collectionView.dataSource, adapter1);

    // associate collection view with adapter2
    adapter2.collectionView = self.collectionView;
    XCTAssertEqual(self.collectionView.dataSource, adapter2);

    // associate collection view with adapter1
    adapter1.collectionView = self.collectionView;
    XCTAssertEqual(self.collectionView.dataSource, adapter1);
}

- (void)test_whenCellsExtendBeyondBounds_thatVisibleItemControllersAreLimited {
    // # of items for each object == [item integerValue], so @2 has 2 items (cells)
    self.dataSource.objects = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10, @11, @12];
    [self.adapter reloadDataWithCompletion:nil];
    XCTAssertEqual([self.collectionView numberOfSections], 12);
    NSArray *visibleItemControllers = [self.adapter visibleItemControllers];
    // UIWindow is 100x100, each cell is 100x10 so should have the following section/cell count: 1 + 2 + 3 + 4 = 10 (100 tall)
    XCTAssertEqual(visibleItemControllers.count, 4);
    XCTAssertTrue([visibleItemControllers containsObject:[self.adapter itemControllerForItem:@1]]);
    XCTAssertTrue([visibleItemControllers containsObject:[self.adapter itemControllerForItem:@2]]);
    XCTAssertTrue([visibleItemControllers containsObject:[self.adapter itemControllerForItem:@3]]);
    XCTAssertTrue([visibleItemControllers containsObject:[self.adapter itemControllerForItem:@4]]);
}

- (void)test_whenCellsExtendBeyondBounds_thatVisibleCellsExistForItemControllers {
    self.dataSource.objects = @[@2, @3, @4, @5, @6];
    [self.adapter reloadDataWithCompletion:nil];
    id itemController2 = [self.adapter itemControllerForItem:@2];
    id itemController3 = [self.adapter itemControllerForItem:@3];
    id itemController4 = [self.adapter itemControllerForItem:@4];
    id itemController5 = [self.adapter itemControllerForItem:@5];
    id itemController6 = [self.adapter itemControllerForItem:@6];
    XCTAssertEqual([self.adapter visibleCellsForItemController:itemController2].count, 2);
    XCTAssertEqual([self.adapter visibleCellsForItemController:itemController3].count, 3);
    XCTAssertEqual([self.adapter visibleCellsForItemController:itemController4].count, 4);
    XCTAssertEqual([self.adapter visibleCellsForItemController:itemController5].count, 1);
    XCTAssertEqual([self.adapter visibleCellsForItemController:itemController6].count, 0);
}

- (void)test_whenDataSourceAddsItems_thatEmptyViewBecomesVisible {
    self.dataSource.objects = @[];
    UIView *background = [UIView new];
    self.dataSource.backgroundView = background;
    [self.adapter reloadDataWithCompletion:nil];
    XCTAssertEqual(self.collectionView.backgroundView, background);
    XCTAssertFalse(self.collectionView.backgroundView.hidden);
    self.dataSource.objects = @[@2];
    [self.adapter reloadDataWithCompletion:nil];
    XCTAssertTrue(self.collectionView.backgroundView.hidden);
}

- (void)test_whenScrollViewDelegateSet_thatDelegateReceivesEvents {
    id mockDelegate = [OCMockObject mockForProtocol:@protocol(UIScrollViewDelegate)];

    self.adapter.collectionViewDelegate = nil;
    self.adapter.scrollViewDelegate = mockDelegate;

    [[mockDelegate expect] scrollViewDidScroll:self.collectionView];

    [self.adapter scrollViewDidScroll:self.collectionView];

    [mockDelegate verify];
}

- (void)test_whenCollectionViewDelegateSet_thatDelegateReceivesEvents {
    // silence display handler asserts
    self.dataSource.objects = @[@1, @2];
    [self.adapter reloadDataWithCompletion:nil];

    id mockDelegate = [OCMockObject mockForProtocol:@protocol(UICollectionViewDelegate)];

    self.adapter.collectionViewDelegate = mockDelegate;
    self.adapter.scrollViewDelegate = nil;

    NSIndexPath *path = [NSIndexPath indexPathForItem:0 inSection:0];
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:path];
    [[mockDelegate expect] collectionView:self.collectionView didEndDisplayingCell:cell forItemAtIndexPath:path];

    [self.adapter collectionView:self.collectionView didEndDisplayingCell:cell forItemAtIndexPath:path];

    [mockDelegate verify];
}

- (void)test_whenCollectionViewDelegateSet_withScrollViewDelegateSet_thatDelegatesReceiveUniqueEvents {
    // silence display handler asserts
    self.dataSource.objects = @[@1, @2];
    [self.adapter reloadDataWithCompletion:nil];

    id mockCollectionViewDelegate = [OCMockObject mockForProtocol:@protocol(UICollectionViewDelegate)];
    id mockScrollViewDelegate = [OCMockObject mockForProtocol:@protocol(UIScrollViewDelegate)];

    self.adapter.collectionViewDelegate = mockCollectionViewDelegate;
    self.adapter.scrollViewDelegate = mockScrollViewDelegate;

    NSIndexPath *path = [NSIndexPath indexPathForItem:0 inSection:0];
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:path];

    [[mockScrollViewDelegate expect] scrollViewDidScroll:self.collectionView];

    [[mockCollectionViewDelegate reject] scrollViewDidScroll:self.collectionView];
    [[mockCollectionViewDelegate expect] collectionView:self.collectionView didEndDisplayingCell:cell forItemAtIndexPath:path];

    [self.adapter scrollViewDidScroll:self.collectionView];
    [self.adapter collectionView:self.collectionView didEndDisplayingCell:cell forItemAtIndexPath:path];

    [mockScrollViewDelegate verify];
    [mockCollectionViewDelegate verify];
}

- (void)test_whenSupplementarySourceSupportsFooter_thatHeaderViewsAreNil {
    self.dataSource.objects = @[@1, @2];
    [self.adapter reloadDataWithCompletion:nil];

    IGTestSupplementarySource *supplementarySource = [IGTestSupplementarySource new];
    supplementarySource.collectionContext = self.adapter;
    supplementarySource.supportedElementKinds = @[UICollectionElementKindSectionFooter];

    IGListItemController<IGListItemType> *controller = [self.adapter itemControllerForItem:@1];
    controller.supplementaryViewSource = supplementarySource;
    supplementarySource.itemController = controller;

    [self.adapter performUpdatesAnimated:NO completion:nil];

    XCTAssertNotNil([self.collectionView supplementaryViewForElementKind:UICollectionElementKindSectionFooter atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]]);
    XCTAssertNil([self.collectionView supplementaryViewForElementKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]]);
    XCTAssertNil([self.collectionView supplementaryViewForElementKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:1]]);
    XCTAssertNil([self.collectionView supplementaryViewForElementKind:UICollectionElementKindSectionFooter atIndexPath:[NSIndexPath indexPathForItem:0 inSection:1]]);
}

- (void)test_whenAdapterReleased_withItemControllerStrongRefToCell_thatItemControllersRelease {
    __weak id weakCollectionView = nil, weakAdapter = nil, weakItemController = nil;

    @autoreleasepool {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        IGListCollectionView *collectionView = [[IGListCollectionView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)
                                                                      collectionViewLayout:layout];
        weakCollectionView = collectionView;

        IGListTestAdapterDataSource *dataSource = [[IGListTestAdapterDataSource alloc] init];
        dataSource.objects = @[@0, @1, @2];

        IGListReloadDataUpdater *updater = [[IGListReloadDataUpdater alloc] init];
        IGListAdapter *adapter = [[IGListAdapter alloc] initWithUpdatingDelegate:updater viewController:nil workingRangeSize:0];
        adapter.collectionView = collectionView;
        adapter.dataSource = dataSource;
        weakAdapter = adapter;

        IGListItemController *itemController = [adapter itemControllerForItem:@1];
        weakItemController = itemController;

        // force the collection view to layout and generate cells
        [collectionView layoutIfNeeded];

        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1]];
        XCTAssertNotNil(cell);
        // strongly attach the cell to an item controller
        objc_setAssociatedObject(itemController, @"some_random_key", cell, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

        // weak refs should exist at this point
        XCTAssertNotNil(weakCollectionView);
        XCTAssertNotNil(weakAdapter);
        XCTAssertNotNil(weakItemController);
    }

    XCTAssertNil(weakCollectionView);
    XCTAssertNil(weakAdapter);
    XCTAssertNil(weakItemController);
}

- (void)test_whenAdapterReleased_withItemControllerStrongRefToCollectionView_thatItemControllersRelease {
    __weak id weakCollectionView = nil, weakAdapter = nil, weakItemController = nil;

    @autoreleasepool {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        IGListCollectionView *collectionView = [[IGListCollectionView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)
                                                                      collectionViewLayout:layout];
        weakCollectionView = collectionView;

        IGListTestAdapterDataSource *dataSource = [[IGListTestAdapterDataSource alloc] init];
        dataSource.objects = @[@0, @1, @2];

        IGListReloadDataUpdater *updater = [[IGListReloadDataUpdater alloc] init];
        IGListAdapter *adapter = [[IGListAdapter alloc] initWithUpdatingDelegate:updater viewController:nil workingRangeSize:0];
        adapter.collectionView = collectionView;
        adapter.dataSource = dataSource;
        weakAdapter = adapter;

        IGListItemController *itemController = [adapter itemControllerForItem:@1];
        weakItemController = itemController;

        // force the collection view to layout and generate cells
        [collectionView layoutIfNeeded];

        // strongly attach the cell to an item controller
        objc_setAssociatedObject(itemController, @"some_random_key", collectionView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

        // weak refs should exist at this point
        XCTAssertNotNil(weakCollectionView);
        XCTAssertNotNil(weakAdapter);
        XCTAssertNotNil(weakItemController);
    }

    XCTAssertNil(weakCollectionView);
    XCTAssertNil(weakAdapter);
    XCTAssertNil(weakItemController);
}

@end
