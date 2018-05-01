/**
 * Copyright (c) 2016-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <objc/runtime.h>

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import <IGListKit/IGListExperiments.h>
#import <IGListKit/IGListKit.h>

#import "IGListAdapterInternal.h"
#import "IGListTestAdapterDataSource.h"
#import "IGListTestAdapterReorderingDataSource.h"
#import "IGListTestAdapterHorizontalDataSource.h"
#import "IGListTestOffsettingLayout.h"
#import "IGListTestSection.h"
#import "IGTestReorderableSection.h"
#import "IGTestSupplementarySource.h"
#import "IGTestNibSupplementaryView.h"
#import "IGListTestCase.h"

#import "UICollectionViewLayout+InteractiveReordering.h"

@interface IGListAdapterTests : IGListTestCase
@end

@implementation IGListAdapterTests

- (void)setUp {
    self.dataSource = [IGListTestAdapterDataSource new];
    self.updater = [IGListReloadDataUpdater new];

    [super setUp];

    // test case doesn't use -setupWithObjects for more control over update events
    self.adapter.collectionView = self.collectionView;
    self.adapter.dataSource = self.dataSource;
}

- (void)test_whenAdapterNotUpdated_withDataSourceUpdated_thatAdapterHasNoSectionControllers {
    self.dataSource.objects = @[@0, @1, @2];
    XCTAssertNil([self.adapter sectionControllerForObject:@0]);
    XCTAssertNil([self.adapter sectionControllerForObject:@1]);
    XCTAssertNil([self.adapter sectionControllerForObject:@2]);
}

- (void)test_whenAdapterUpdated_thatAdapterHasSectionControllers {
    self.dataSource.objects = @[@0, @1, @2];
    [self.adapter performUpdatesAnimated:YES completion:nil];
    XCTAssertNotNil([self.adapter sectionControllerForObject:@0]);
    XCTAssertNotNil([self.adapter sectionControllerForObject:@1]);
    XCTAssertNotNil([self.adapter sectionControllerForObject:@2]);
}

- (void)test_whenAdapterReloaded_thatAdapterHasSectionControllers {
    self.dataSource.objects = @[@0, @1, @2];
    [self.adapter reloadDataWithCompletion:nil];
    XCTAssertNotNil([self.adapter sectionControllerForObject:@0]);
    XCTAssertNotNil([self.adapter sectionControllerForObject:@1]);
    XCTAssertNotNil([self.adapter sectionControllerForObject:@2]);
}

- (void)test_whenAdapterUpdated_thatSectionControllerHasSection {
    self.dataSource.objects = @[@0, @1, @2];
    [self.adapter performUpdatesAnimated:YES completion:nil];
    IGListSectionController * list = [self.adapter sectionControllerForObject:@1];
    XCTAssertEqual([self.adapter sectionForSectionController:list], 1);
}

- (void)test_whenAdapterUpdated_withUnknownItem_thatSectionControllerHasNoSection {
    self.dataSource.objects = @[@0, @1, @2];
    [self.adapter performUpdatesAnimated:YES completion:nil];
    IGListSectionController * randomList = [[IGListTestSection alloc] init];
    XCTAssertEqual([self.adapter sectionForSectionController:randomList], NSNotFound);
}

- (void)test_whenQueryingAdapter_withUnknownItem_thatSectionControllerIsNil {
    self.dataSource.objects = @[@0, @1, @2];
    [self.adapter performUpdatesAnimated:YES completion:nil];
    XCTAssertNil([self.adapter sectionControllerForObject:@3]);
}

- (void)test_whenAdapterUpdated_thatSectionControllerHasCorrectObject {
    self.dataSource.objects = @[@0, @1, @2];
    [self.adapter performUpdatesAnimated:YES completion:nil];
    IGListSectionController * list = [self.adapter sectionControllerForObject:@1];
    XCTAssertEqual([self.adapter objectForSectionController:list], @1);
}

- (void)test_whenQueryingAdapter_withUnknownItem_thatObjectForSectionControllerIsNil {
    self.dataSource.objects = @[@0, @1, @2];
    [self.adapter performUpdatesAnimated:YES completion:nil];
    IGListSectionController * randomList = [[IGListTestSection alloc] init];
    XCTAssertNil([self.adapter objectForSectionController:randomList]);
}

- (void)test_whenQueryingIndexPaths_withSectionController_thatPathsAreEqual {
    self.dataSource.objects = @[@0, @1, @2];
    [self.adapter performUpdatesAnimated:YES completion:nil];
    IGListSectionController * second = [self.adapter sectionControllerForObject:@1];
    NSArray *paths0 = [self.adapter indexPathsFromSectionController:second
                                                            indexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 4)]
                                                 usePreviousIfInUpdateBlock:NO];
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
    IGListSectionController * second = [self.adapter sectionControllerForObject:@1];

    __block BOOL executed = NO;
    [self.adapter performBatchAnimated:YES updates:^(id<IGListBatchContext> batchContext) {
        NSArray *paths = [self.adapter indexPathsFromSectionController:second
                                                               indexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 2)]
                                                    usePreviousIfInUpdateBlock:YES];
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
    NSString *identifier = IGListReusableViewIdentifier(UICollectionViewCell.class, nil, nil, nil);
    XCTAssertEqualObjects(identifier, @"UICollectionViewCell");
}

- (void)test_whenQueryingReusableIdentifierWithGivenIdentifier_tahtIdentifierEqualsGivenIdentifierAndClassName {
    NSString *identifier = IGListReusableViewIdentifier(UICollectionViewCell.class, nil, nil, @"MyCoolID");
    XCTAssertEqualObjects(identifier, @"MyCoolIDUICollectionViewCell");
}

- (void)test_whenQueryingReusableIdentifier_thatIdentifierEqualsClassNameAndSupplimentaryKind {
    NSString *identifier = IGListReusableViewIdentifier(UICollectionViewCell.class, nil, UICollectionElementKindSectionFooter, nil);
    XCTAssertEqualObjects(identifier, @"UICollectionElementKindSectionFooterUICollectionViewCell");
}

- (void)test_whenQueryingReusableIdentifier_thatIdentifierEqualsClassNameAndNibName {
    NSString *nibName = @"IGNibName";
    NSString *identifier = IGListReusableViewIdentifier(UICollectionViewCell.class, nibName, nil, nil);
    XCTAssertEqualObjects(identifier, @"IGNibNameUICollectionViewCell");
}

- (void)test_whenDataSourceChanges_thatBackgroundViewVisibilityChanges {
    self.dataSource.objects = @[@1];
    UIView *background = [[UIView alloc] init];
    ((IGListTestAdapterDataSource *)self.dataSource).backgroundView = background;
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

- (void)test_whenReloadingData_thatNewSectionControllersAreCreated {
    self.dataSource.objects = @[@0, @1, @2];
    [self.adapter reloadDataWithCompletion:nil];
    IGListSectionController *oldSectionController = [self.adapter sectionControllerForObject:@1];
    [self.adapter reloadDataWithCompletion:nil];
    IGListSectionController *newSectionController = [self.adapter sectionControllerForObject:@1];
    XCTAssertNotEqual(oldSectionController, newSectionController);
}

- (void)test_whenSettingCollectionView_thenSettingDataSource_thatViewControllerIsSet {
    self.dataSource.objects = @[@0, @1, @2];
    UIViewController *controller = [UIViewController new];
    IGListAdapter *adapter = [[IGListAdapter alloc] initWithUpdater:[IGListReloadDataUpdater new]
                                                     viewController:controller];
    adapter.collectionView = self.collectionView;
    adapter.dataSource = self.dataSource;
    IGListSectionController *sectionController = [adapter sectionControllerForObject:@1];
    XCTAssertEqual(controller, sectionController.viewController);
}

- (void)test_whenSettingCollectionView_thenSettingDataSource_thatCellExists {
    self.dataSource.objects = @[@1];
    IGListAdapter *adapter = [[IGListAdapter alloc] initWithUpdater:[IGListReloadDataUpdater new]
                                                     viewController:nil];
    adapter.collectionView = self.collectionView;
    adapter.dataSource = self.dataSource;
    [self.collectionView layoutIfNeeded];
    XCTAssertNotNil([self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]]);
}

- (void)test_whenSettingDataSource_thenSettingCollectionView_thatCellExists {
    self.dataSource.objects = @[@1];
    IGListAdapter *adapter = [[IGListAdapter alloc] initWithUpdater:[IGListReloadDataUpdater new]
                                                     viewController:nil];
    adapter.dataSource = self.dataSource;
    adapter.collectionView = self.collectionView;
    [self.collectionView layoutIfNeeded];
    XCTAssertNotNil([self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]]);
}

- (void)test_whenChangingCollectionViews_thatCellsExist {
    self.dataSource.objects = @[@1];
    IGListAdapterUpdater *updater = [[IGListAdapterUpdater alloc] init];
    IGListAdapter *adapter = [[IGListAdapter alloc] initWithUpdater:updater viewController:nil];
    adapter.dataSource = self.dataSource;
    adapter.collectionView = self.collectionView;
    [self.collectionView layoutIfNeeded];
    XCTAssertNotNil([self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]]);

    UICollectionView *otherCollectionView = [[UICollectionView alloc] initWithFrame:self.collectionView.frame collectionViewLayout:self.collectionView.collectionViewLayout];
    adapter.collectionView = otherCollectionView;
    [otherCollectionView layoutIfNeeded];
    XCTAssertNotNil([otherCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]]);
}

- (void)test_whenChangingCollectionViewsToACollectionViewInUseByAnotherAdapter_thatCollectionViewDelegateIsUpdated {
    IGListTestAdapterDataSource *dataSource1 = [[IGListTestAdapterDataSource alloc] init];
    dataSource1.objects = @[@1];
    IGListAdapterUpdater *updater1 = [[IGListAdapterUpdater alloc] init];
    IGListAdapter *adapter1 = [[IGListAdapter alloc] initWithUpdater:updater1 viewController:nil];
    adapter1.dataSource = dataSource1;

    IGListTestAdapterDataSource *dataSource2 = [[IGListTestAdapterDataSource alloc] init];
    dataSource1.objects = @[@1];
    IGListAdapterUpdater *updater2 = [[IGListAdapterUpdater alloc] init];
    IGListAdapter *adapter2 = [[IGListAdapter alloc] initWithUpdater:updater2 viewController:nil];
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

- (void)test_whenCellsExtendBeyondBounds_thatVisibleSectionControllersAreLimited {
    // # of items for each object == [item integerValue], so @2 has 2 items (cells)
    self.dataSource.objects = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10, @11, @12];
    [self.adapter reloadDataWithCompletion:nil];
    XCTAssertEqual([self.collectionView numberOfSections], 12);
    NSArray *visibleSectionControllers = [self.adapter visibleSectionControllers];
    // UIWindow is 100x100, each cell is 100x10 so should have the following section/cell count: 1 + 2 + 3 + 4 = 10 (100 tall)
    XCTAssertEqual(visibleSectionControllers.count, 4);
    XCTAssertTrue([visibleSectionControllers containsObject:[self.adapter sectionControllerForObject:@1]]);
    XCTAssertTrue([visibleSectionControllers containsObject:[self.adapter sectionControllerForObject:@2]]);
    XCTAssertTrue([visibleSectionControllers containsObject:[self.adapter sectionControllerForObject:@3]]);
    XCTAssertTrue([visibleSectionControllers containsObject:[self.adapter sectionControllerForObject:@4]]);
}

- (void)test_whenCellsExtendBeyondBounds_withFasterExperiment_thatVisibleSectionControllersAreLimited {
    // add experiment
    self.adapter.experiments |= IGListExperimentFasterVisibleSectionController;
    // # of items for each object == [item integerValue], so @2 has 2 items (cells)
    self.dataSource.objects = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10, @11, @12];
    [self.adapter reloadDataWithCompletion:nil];
    XCTAssertEqual([self.collectionView numberOfSections], 12);
    NSArray *visibleSectionControllers = [self.adapter visibleSectionControllers];
    // UIWindow is 100x100, each cell is 100x10 so should have the following section/cell count: 1 + 2 + 3 + 4 = 10 (100 tall)
    XCTAssertEqual(visibleSectionControllers.count, 4);
    XCTAssertTrue([visibleSectionControllers containsObject:[self.adapter sectionControllerForObject:@1]]);
    XCTAssertTrue([visibleSectionControllers containsObject:[self.adapter sectionControllerForObject:@2]]);
    XCTAssertTrue([visibleSectionControllers containsObject:[self.adapter sectionControllerForObject:@3]]);
    XCTAssertTrue([visibleSectionControllers containsObject:[self.adapter sectionControllerForObject:@4]]);
}

- (void) test_withEmptySectionPlusFooter_thatVisibleSectionControllersAreCorrect {
    self.dataSource.objects = @[@0];
    [self.adapter reloadDataWithCompletion:nil];
    IGTestSupplementarySource *supplementarySource = [IGTestSupplementarySource new];
    supplementarySource.dequeueFromNib = YES;
    supplementarySource.collectionContext = self.adapter;
    supplementarySource.supportedElementKinds = @[UICollectionElementKindSectionFooter];
    IGListSectionController *controller = [self.adapter sectionControllerForObject:@0];
    controller.supplementaryViewSource = supplementarySource;
    supplementarySource.sectionController = controller;
    [self.adapter performUpdatesAnimated:NO completion:nil];
    NSArray<IGListSectionController *> *visibleSectionControllers = [self.adapter visibleSectionControllers];

    XCTAssertTrue([visibleSectionControllers count] == 1);
    XCTAssertTrue(visibleSectionControllers.firstObject.supplementaryViewSource == supplementarySource);
}

- (void) test_withEmptySectionPlusFooter_withFasterExperiment_thatVisibleSectionControllersAreCorrect {
    // add experiment
    self.adapter.experiments |= IGListExperimentFasterVisibleSectionController;
    self.dataSource.objects = @[@0];
    [self.adapter reloadDataWithCompletion:nil];
    IGTestSupplementarySource *supplementarySource = [IGTestSupplementarySource new];
    supplementarySource.dequeueFromNib = YES;
    supplementarySource.collectionContext = self.adapter;
    supplementarySource.supportedElementKinds = @[UICollectionElementKindSectionFooter];
    IGListSectionController *controller = [self.adapter sectionControllerForObject:@0];
    controller.supplementaryViewSource = supplementarySource;
    supplementarySource.sectionController = controller;
    [self.adapter performUpdatesAnimated:NO completion:nil];
    NSArray<IGListSectionController *> *visibleSectionControllers = [self.adapter visibleSectionControllers];

    XCTAssertTrue([visibleSectionControllers count] == 1);
    XCTAssertTrue(visibleSectionControllers.firstObject.supplementaryViewSource == supplementarySource);
}

- (void)test_whenCellsExtendBeyondBounds_thatVisibleCellsExistForSectionControllers {
    self.dataSource.objects = @[@2, @3, @4, @5, @6];
    [self.adapter reloadDataWithCompletion:nil];
    id sectionController2 = [self.adapter sectionControllerForObject:@2];
    id sectionController3 = [self.adapter sectionControllerForObject:@3];
    id sectionController4 = [self.adapter sectionControllerForObject:@4];
    id sectionController5 = [self.adapter sectionControllerForObject:@5];
    id sectionController6 = [self.adapter sectionControllerForObject:@6];
    XCTAssertEqual([self.adapter visibleCellsForSectionController:sectionController2].count, 2);
    XCTAssertEqual([self.adapter visibleCellsForSectionController:sectionController3].count, 3);
    XCTAssertEqual([self.adapter visibleCellsForSectionController:sectionController4].count, 4);
    XCTAssertEqual([self.adapter visibleCellsForSectionController:sectionController5].count, 1);
    XCTAssertEqual([self.adapter visibleCellsForSectionController:sectionController6].count, 0);
}

- (void)test_whenCellsExtendBeyondBounds_thatVisibleIndexPathsExistForSectionControllers {
    self.dataSource.objects = @[@2, @3, @4, @5, @6];
    [self.adapter reloadDataWithCompletion:nil];
    id sectionController2 = [self.adapter sectionControllerForObject:@2];
    id sectionController3 = [self.adapter sectionControllerForObject:@3];
    id sectionController4 = [self.adapter sectionControllerForObject:@4];
    id sectionController5 = [self.adapter sectionControllerForObject:@5];
    id sectionController6 = [self.adapter sectionControllerForObject:@6];
    XCTAssertEqual([self.adapter visibleIndexPathsForSectionController:sectionController2].count, 2);
    XCTAssertEqual([self.adapter visibleIndexPathsForSectionController:sectionController3].count, 3);
    XCTAssertEqual([self.adapter visibleIndexPathsForSectionController:sectionController4].count, 4);
    XCTAssertEqual([self.adapter visibleIndexPathsForSectionController:sectionController5].count, 1);
    XCTAssertEqual([self.adapter visibleIndexPathsForSectionController:sectionController6].count, 0);
}

- (void)test_whenDataSourceAddsItems_thatEmptyViewBecomesVisible {
    self.dataSource.objects = @[];
    UIView *background = [UIView new];
    ((IGListTestAdapterDataSource *)self.dataSource).backgroundView = background;
    [self.adapter reloadDataWithCompletion:nil];
    XCTAssertEqual(self.collectionView.backgroundView, background);
    XCTAssertFalse(self.collectionView.backgroundView.hidden);
    self.dataSource.objects = @[@2];
    [self.adapter reloadDataWithCompletion:nil];
    XCTAssertTrue(self.collectionView.backgroundView.hidden);
}

- (void)test_whenInsertingIntoEmptySection_thatEmptyViewBecomesHidden {
    self.dataSource.objects = @[@0];
    ((IGListTestAdapterDataSource *)self.dataSource).backgroundView = [UIView new];
    [self.adapter reloadDataWithCompletion:nil];
    XCTAssertFalse(self.collectionView.backgroundView.hidden);
    IGListTestSection *sectionController = [self.adapter sectionControllerForObject:@(0)];
    sectionController.items = 1;
    [self.adapter insertInSectionController:sectionController atIndexes:[NSIndexSet indexSetWithIndex:0]];
    XCTAssertTrue(self.collectionView.backgroundView.hidden);
}

- (void)test_whenDeletingAllItemsFromSection_thatEmptyViewBecomesVisible {
    self.dataSource.objects = @[@1];
    ((IGListTestAdapterDataSource *)self.dataSource).backgroundView = [UIView new];
    [self.adapter reloadDataWithCompletion:nil];
    XCTAssertTrue(self.collectionView.backgroundView.hidden);
    IGListTestSection *sectionController = [self.adapter sectionControllerForObject:@(1)];
    sectionController.items = 0;
    [self.adapter deleteInSectionController:sectionController atIndexes:[NSIndexSet indexSetWithIndex:0]];
    XCTAssertFalse(self.collectionView.backgroundView.hidden);
}

- (void)test_whenEmptySectionAddsItems_thatEmptyViewBecomesHidden {
    self.dataSource.objects = @[@0];
    ((IGListTestAdapterDataSource *)self.dataSource).backgroundView = [UIView new];
    [self.adapter reloadDataWithCompletion:nil];
    XCTAssertFalse(self.collectionView.backgroundView.hidden);
    IGListTestSection *sectionController = [self.adapter sectionControllerForObject:@(0)];
    sectionController.items = 2;
    [self.adapter reloadSectionController:sectionController];
    XCTAssertTrue(self.collectionView.backgroundView.hidden);
}

- (void)test_whenSectionItemsAreDeletedAsBatch_thatEmptyViewBecomesVisible {
    self.dataSource.objects = @[@1, @2];
    ((IGListTestAdapterDataSource *)self.dataSource).backgroundView = [UIView new];
    [self.adapter reloadDataWithCompletion:nil];
    XCTAssertTrue(self.collectionView.backgroundView.hidden);
    IGListTestSection *firstSectionController = [self.adapter sectionControllerForObject:@(1)];
    IGListTestSection *secondSectionController = [self.adapter sectionControllerForObject:@(2)];
    XCTestExpectation *expectation =  [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self.adapter performBatchAnimated:YES updates:^(id<IGListBatchContext> batchContext) {
        firstSectionController.items = 0;
        [self.adapter deleteInSectionController:firstSectionController atIndexes:[NSIndexSet indexSetWithIndex:0]];
        secondSectionController.items = 0;
        NSIndexSet *indexesToDelete = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)];
        [self.adapter deleteInSectionController:secondSectionController atIndexes:indexesToDelete];
    } completion:^(BOOL finished) {
        XCTAssertFalse(self.collectionView.backgroundView.hidden);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:30 handler:nil];
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

    IGListSectionController *controller = [self.adapter sectionControllerForObject:@1];
    controller.supplementaryViewSource = supplementarySource;
    supplementarySource.sectionController = controller;

    [self.adapter performUpdatesAnimated:NO completion:nil];

    XCTAssertNotNil([self.collectionView supplementaryViewForElementKind:UICollectionElementKindSectionFooter atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]]);
    XCTAssertNil([self.collectionView supplementaryViewForElementKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]]);
    XCTAssertNil([self.collectionView supplementaryViewForElementKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:1]]);
    XCTAssertNil([self.collectionView supplementaryViewForElementKind:UICollectionElementKindSectionFooter atIndexPath:[NSIndexPath indexPathForItem:0 inSection:1]]);
}

- (void)test_whenSupplementarySourceSupportsFooter_withNibs_thatHeaderViewsAreNil {
    self.dataSource.objects = @[@1, @2];
    [self.adapter reloadDataWithCompletion:nil];

    IGTestSupplementarySource *supplementarySource = [IGTestSupplementarySource new];
    supplementarySource.dequeueFromNib = YES;
    supplementarySource.collectionContext = self.adapter;
    supplementarySource.supportedElementKinds = @[UICollectionElementKindSectionFooter];

    IGListSectionController *controller = [self.adapter sectionControllerForObject:@1];
    controller.supplementaryViewSource = supplementarySource;
    supplementarySource.sectionController = controller;

    [self.adapter performUpdatesAnimated:NO completion:nil];

    id view = [self.collectionView supplementaryViewForElementKind:UICollectionElementKindSectionFooter atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    XCTAssertTrue([view isKindOfClass:IGTestNibSupplementaryView.class]);
    XCTAssertEqualObjects([[(IGTestNibSupplementaryView *)view label] text], @"Foo bar baz");

    XCTAssertNil([self.collectionView supplementaryViewForElementKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]]);
    XCTAssertNil([self.collectionView supplementaryViewForElementKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:1]]);
    XCTAssertNil([self.collectionView supplementaryViewForElementKind:UICollectionElementKindSectionFooter atIndexPath:[NSIndexPath indexPathForItem:0 inSection:1]]);
}

- (void)test_whenAdapterReleased_withSectionControllerStrongRefToCell_thatSectionControllersRelease {
    __weak id weakCollectionView = nil, weakAdapter = nil, weakSectionController = nil;

    @autoreleasepool {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)
                                                                      collectionViewLayout:layout];
        weakCollectionView = collectionView;

        IGListTestAdapterDataSource *dataSource = [[IGListTestAdapterDataSource alloc] init];
        dataSource.objects = @[@0, @1, @2];

        IGListReloadDataUpdater *updater = [[IGListReloadDataUpdater alloc] init];
        IGListAdapter *adapter = [[IGListAdapter alloc] initWithUpdater:updater viewController:nil];
        adapter.collectionView = collectionView;
        adapter.dataSource = dataSource;
        weakAdapter = adapter;

        IGListSectionController *sectionController = [adapter sectionControllerForObject:@1];
        weakSectionController = sectionController;

        // force the collection view to layout and generate cells
        [collectionView layoutIfNeeded];

        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1]];
        XCTAssertNotNil(cell);
        // strongly attach the cell to an section controller
        objc_setAssociatedObject(sectionController, @"some_random_key", cell, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

        // weak refs should exist at this point
        XCTAssertNotNil(weakCollectionView);
        XCTAssertNotNil(weakAdapter);
        XCTAssertNotNil(weakSectionController);
    }

    XCTAssertNil(weakCollectionView);
    XCTAssertNil(weakAdapter);
    XCTAssertNil(weakSectionController);
}

- (void)test_whenAdapterReleased_withSectionControllerStrongRefToCollectionView_thatSectionControllersRelease {
    __weak id weakCollectionView = nil, weakAdapter = nil, weakSectionController = nil;

    @autoreleasepool {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)
                                                                      collectionViewLayout:layout];
        weakCollectionView = collectionView;

        IGListTestAdapterDataSource *dataSource = [[IGListTestAdapterDataSource alloc] init];
        dataSource.objects = @[@0, @1, @2];

        IGListReloadDataUpdater *updater = [[IGListReloadDataUpdater alloc] init];
        IGListAdapter *adapter = [[IGListAdapter alloc] initWithUpdater:updater viewController:nil];
        adapter.collectionView = collectionView;
        adapter.dataSource = dataSource;
        weakAdapter = adapter;

        IGListSectionController *sectionController = [adapter sectionControllerForObject:@1];
        weakSectionController = sectionController;

        // force the collection view to layout and generate cells
        [collectionView layoutIfNeeded];

        // strongly attach the cell to an section controller
        objc_setAssociatedObject(sectionController, @"some_random_key", collectionView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

        // weak refs should exist at this point
        XCTAssertNotNil(weakCollectionView);
        XCTAssertNotNil(weakAdapter);
        XCTAssertNotNil(weakSectionController);
    }

    XCTAssertNil(weakCollectionView);
    XCTAssertNil(weakAdapter);
    XCTAssertNil(weakSectionController);
}

- (void)test_whenAdapterUpdatedTwice_withThreeSections_thatSectionsUpdatedFirstLast {
    self.dataSource.objects = @[@0, @1, @2];
    [self.adapter reloadDataWithCompletion:nil];

    XCTAssertTrue([[self.adapter sectionControllerForObject:@0] isFirstSection]);
    XCTAssertFalse([[self.adapter sectionControllerForObject:@1] isFirstSection]);
    XCTAssertFalse([[self.adapter sectionControllerForObject:@2] isFirstSection]);

    XCTAssertFalse([[self.adapter sectionControllerForObject:@0] isLastSection]);
    XCTAssertFalse([[self.adapter sectionControllerForObject:@1] isLastSection]);
    XCTAssertTrue([[self.adapter sectionControllerForObject:@2] isLastSection]);

    // update and shift objects to test that first/last flags are also updated
    self.dataSource.objects = @[@2, @0, @1];
    [self.adapter performUpdatesAnimated:NO completion:nil];

    XCTAssertFalse([[self.adapter sectionControllerForObject:@0] isFirstSection]);
    XCTAssertFalse([[self.adapter sectionControllerForObject:@1] isFirstSection]);
    XCTAssertTrue([[self.adapter sectionControllerForObject:@2] isFirstSection]);

    XCTAssertFalse([[self.adapter sectionControllerForObject:@0] isLastSection]);
    XCTAssertTrue([[self.adapter sectionControllerForObject:@1] isLastSection]);
    XCTAssertFalse([[self.adapter sectionControllerForObject:@2] isLastSection]);
}

- (void)test_whenAdapterUpdated_withObjectsOverflow_thatVisibleObjectsIsSubsetOfAllObjects {
    // each section controller returns n items sized 100x10
    self.dataSource.objects = @[@1, @2, @3, @4, @5, @6];
    [self.adapter reloadDataWithCompletion:nil];
    self.collectionView.contentOffset = CGPointMake(0, 30);
    [self.collectionView layoutIfNeeded];

    NSArray *visibleObjects = [[self.adapter visibleObjects] sortedArrayUsingSelector:@selector(compare:)];
    NSArray *expectedObjects = @[@3, @4, @5];
    XCTAssertEqualObjects(visibleObjects, expectedObjects);
}

- (void)test_whenAdapterUpdated_thatVisibleCellsForObjectAreFound {
    // each section controller returns n items sized 100x10
    self.dataSource.objects = @[@2, @10, @5];
    [self.adapter reloadDataWithCompletion:nil];
    self.collectionView.contentOffset = CGPointMake(0, 80);
    [self.collectionView layoutIfNeeded];

    UICollectionView *collectionView = self.collectionView;
    NSArray *visibleCellsForObject = [[self.adapter visibleCellsForObject:@10] sortedArrayUsingComparator:^NSComparisonResult(UICollectionViewCell* lhs, UICollectionViewCell* rhs) {
        NSIndexPath *lhsIndexPath = [collectionView indexPathForCell:lhs];
        NSIndexPath *rhsIndexPath = [collectionView indexPathForCell:rhs];
        
        if (lhsIndexPath.section == rhsIndexPath.section) {
            return lhsIndexPath.item > rhsIndexPath.item;
        }
        
        return lhsIndexPath.section > rhsIndexPath.section;
    }];
    
    XCTAssertEqual(visibleCellsForObject.count, 4);
    XCTAssertEqual([self.collectionView indexPathForCell:visibleCellsForObject[0]].item, 6);
    XCTAssertEqual([self.collectionView indexPathForCell:visibleCellsForObject[1]].item, 7);
    XCTAssertEqual([self.collectionView indexPathForCell:visibleCellsForObject[2]].item, 8);
    XCTAssertEqual([self.collectionView indexPathForCell:visibleCellsForObject[3]].item, 9);
    
    NSArray *visibleCellsForObjectTwo = [self.adapter visibleCellsForObject:@5];
    XCTAssertEqual(visibleCellsForObjectTwo.count, 5);
}

- (void)test_whenAdapterUpdated_thatVisibleCellsForNilObjectIsEmpty {
    // each section controller returns n items sized 100x10
    self.dataSource.objects = @[@2, @10, @5];
    [self.adapter reloadDataWithCompletion:nil];
    self.collectionView.contentOffset = CGPointMake(0, 80);
    [self.collectionView layoutIfNeeded];
    
    NSArray *visibleCellsForObject = [self.adapter visibleCellsForObject:@3];
    XCTAssertEqual(visibleCellsForObject.count, 0);
}

- (void)test_whenScrollVerticallyToItem {
    // # of items for each object == [item integerValue], so @2 has 2 items (cells)
    self.dataSource.objects = @[@1, @2, @3, @4, @5, @6];
    [self.adapter reloadDataWithCompletion:nil];
    XCTAssertEqual([self.collectionView numberOfSections], 6);
    [self.adapter scrollToObject:@1 supplementaryKinds:nil scrollDirection:UICollectionViewScrollDirectionVertical scrollPosition:UICollectionViewScrollPositionNone animated:NO];
    IGAssertEqualPoint([self.collectionView contentOffset], 0, 0);
    [self.adapter scrollToObject:@2 supplementaryKinds:nil scrollDirection:UICollectionViewScrollDirectionVertical scrollPosition:UICollectionViewScrollPositionNone animated:NO];
    IGAssertEqualPoint([self.collectionView contentOffset], 0, 10);
    [self.adapter scrollToObject:@3 supplementaryKinds:nil scrollDirection:UICollectionViewScrollDirectionVertical scrollPosition:UICollectionViewScrollPositionNone animated:NO];
    IGAssertEqualPoint([self.collectionView contentOffset], 0, 30);
    [self.adapter scrollToObject:@6 supplementaryKinds:nil scrollDirection:UICollectionViewScrollDirectionVertical scrollPosition:UICollectionViewScrollPositionNone animated:NO];
    // Content height minus collection view height is 110, can't scroll more than that
    IGAssertEqualPoint([self.collectionView contentOffset], 0, 110);
    [self.adapter scrollToObject:@6 supplementaryKinds:nil scrollDirection:UICollectionViewScrollDirectionVertical scrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
    IGAssertEqualPoint([self.collectionView contentOffset], 0, 110);
    [self.adapter scrollToObject:@6 supplementaryKinds:nil scrollDirection:UICollectionViewScrollDirectionVertical scrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    IGAssertEqualPoint([self.collectionView contentOffset], 0, 110);
}

- (void)test_whenScrollVerticallyToItemInASectionWithNoCellsAndNoSupplymentaryView {
    self.dataSource.objects = @[@1, @0, @300];
    [self.adapter reloadDataWithCompletion:nil];
    XCTAssertEqual([self.collectionView numberOfSections], 3);
    [self.adapter scrollToObject:@1 supplementaryKinds:nil scrollDirection:UICollectionViewScrollDirectionVertical scrollPosition:UICollectionViewScrollPositionNone animated:NO];
    IGAssertEqualPoint([self.collectionView contentOffset], 0, 0);
    [self.adapter scrollToObject:@0 supplementaryKinds:nil scrollDirection:UICollectionViewScrollDirectionVertical scrollPosition:UICollectionViewScrollPositionNone animated:NO];
    IGAssertEqualPoint([self.collectionView contentOffset], 0, 0);
    [self.adapter scrollToObject:@300 supplementaryKinds:nil scrollDirection:UICollectionViewScrollDirectionVertical scrollPosition:UICollectionViewScrollPositionNone animated:NO];
    IGAssertEqualPoint([self.collectionView contentOffset], 0, 10);
}

- (void)test_whenScrollVerticallyToItemInASectionWithNoCellsButAHeaderSupplymentaryView {
    self.dataSource.objects = @[@1, @0, @300];
    [self.adapter reloadDataWithCompletion:nil];

    IGTestSupplementarySource *supplementarySource = [IGTestSupplementarySource new];
    supplementarySource.collectionContext = self.adapter;
    supplementarySource.supportedElementKinds = @[UICollectionElementKindSectionHeader];

    IGListSectionController *controller = [self.adapter sectionControllerForObject:@0];
    controller.supplementaryViewSource = supplementarySource;
    supplementarySource.sectionController = controller;

    [self.adapter performUpdatesAnimated:NO completion:nil];

    XCTAssertEqual([self.collectionView numberOfSections], 3);
    [self.adapter scrollToObject:@1 supplementaryKinds:nil scrollDirection:UICollectionViewScrollDirectionVertical scrollPosition:UICollectionViewScrollPositionNone animated:NO];
    IGAssertEqualPoint([self.collectionView contentOffset], 0, 0);
    [self.adapter scrollToObject:@0 supplementaryKinds:nil scrollDirection:UICollectionViewScrollDirectionVertical scrollPosition:UICollectionViewScrollPositionNone animated:NO];
    IGAssertEqualPoint([self.collectionView contentOffset], 0, 0);
    [self.adapter scrollToObject:@0 supplementaryKinds:@[UICollectionElementKindSectionHeader] scrollDirection:UICollectionViewScrollDirectionVertical scrollPosition:UICollectionViewScrollPositionTop animated:NO];
    IGAssertEqualPoint([self.collectionView contentOffset], 0, 10);
    [self.adapter scrollToObject:@300 supplementaryKinds:nil scrollDirection:UICollectionViewScrollDirectionVertical scrollPosition:UICollectionViewScrollPositionNone animated:NO];
    IGAssertEqualPoint([self.collectionView contentOffset], 0, 20);
}

- (void)test_whenScrollVerticallyToItemWithPositionning {
    self.dataSource.objects = @[@1, @100, @200];
    [self.adapter reloadDataWithCompletion:nil];
    [self.adapter scrollToObject:@1 supplementaryKinds:nil scrollDirection:UICollectionViewScrollDirectionVertical scrollPosition:UICollectionViewScrollPositionNone animated:NO];
    IGAssertEqualPoint([self.collectionView contentOffset], 0, 0);
    [self.adapter scrollToObject:@1 supplementaryKinds:nil scrollDirection:UICollectionViewScrollDirectionVertical scrollPosition:UICollectionViewScrollPositionTop animated:NO];
    IGAssertEqualPoint([self.collectionView contentOffset], 0, 0);
    [self.adapter scrollToObject:@1 supplementaryKinds:nil scrollDirection:UICollectionViewScrollDirectionVertical scrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
    IGAssertEqualPoint([self.collectionView contentOffset], 0, 0);
    [self.adapter scrollToObject:@1 supplementaryKinds:nil scrollDirection:UICollectionViewScrollDirectionVertical scrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    IGAssertEqualPoint([self.collectionView contentOffset], 0, 0);

    [self.adapter scrollToObject:@100 supplementaryKinds:nil scrollDirection:UICollectionViewScrollDirectionVertical scrollPosition:UICollectionViewScrollPositionNone animated:NO];
    IGAssertEqualPoint([self.collectionView contentOffset], 0, 10);
    [self.adapter scrollToObject:@100 supplementaryKinds:nil scrollDirection:UICollectionViewScrollDirectionVertical scrollPosition:UICollectionViewScrollPositionTop animated:NO];
    IGAssertEqualPoint([self.collectionView contentOffset], 0, 10);
    [self.adapter scrollToObject:@100 supplementaryKinds:nil scrollDirection:UICollectionViewScrollDirectionVertical scrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
    IGAssertEqualPoint([self.collectionView contentOffset], 0, 460);
    [self.adapter scrollToObject:@100 supplementaryKinds:nil scrollDirection:UICollectionViewScrollDirectionVertical scrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    IGAssertEqualPoint([self.collectionView contentOffset], 0, 910);

    [self.adapter scrollToObject:@200 supplementaryKinds:nil scrollDirection:UICollectionViewScrollDirectionVertical scrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    IGAssertEqualPoint([self.collectionView contentOffset], 0, self.collectionView.contentSize.height - self.collectionView.frame.size.height);
}

- (void)test_whenScrollVerticallyToBottom_withContentInsets_thatBottomFlushWithCollectionViewBounds {
    self.dataSource.objects = @[@100];
    [self.adapter reloadDataWithCompletion:nil];

    // no insets
    self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [self.collectionView layoutIfNeeded];
    [self.adapter scrollToObject:@100 supplementaryKinds:nil scrollDirection:UICollectionViewScrollDirectionVertical scrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    IGAssertEqualPoint([self.collectionView contentOffset], 0, 900);

    // top 100
    self.collectionView.contentInset = UIEdgeInsetsMake(100, 0, 0, 0);
    [self.adapter scrollToObject:@100 supplementaryKinds:nil scrollDirection:UICollectionViewScrollDirectionVertical scrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    IGAssertEqualPoint([self.collectionView contentOffset], 0, 900);

    // bottom 100
    self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 100, 0);
    [self.collectionView layoutIfNeeded];
    [self.adapter scrollToObject:@100 supplementaryKinds:nil scrollDirection:UICollectionViewScrollDirectionVertical scrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    IGAssertEqualPoint([self.collectionView contentOffset], 0, 900);

    // top 50, bottom 100
    self.collectionView.contentInset = UIEdgeInsetsMake(50, 0, 100, 0);
    [self.collectionView layoutIfNeeded];
    [self.adapter scrollToObject:@100 supplementaryKinds:nil scrollDirection:UICollectionViewScrollDirectionVertical scrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    IGAssertEqualPoint([self.collectionView contentOffset], 0, 900);
}

- (void)test_whenScrollHorizontallyToItem {
    // # of items for each object == [item integerValue], so @2 has 2 items (cells)
    IGListTestAdapterHorizontalDataSource *dataSource = [[IGListTestAdapterHorizontalDataSource alloc] init];
    self.adapter.dataSource = dataSource;
    dataSource.objects = @[@1, @2, @3, @4, @5, @6];
    self.layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [self.adapter reloadDataWithCompletion:nil];
    XCTAssertEqual([self.collectionView numberOfSections], 6);
    [self.adapter scrollToObject:@1 supplementaryKinds:nil scrollDirection:UICollectionViewScrollDirectionHorizontal scrollPosition:UICollectionViewScrollPositionNone animated:NO];
    IGAssertEqualPoint([self.collectionView contentOffset], 0, 0);
    [self.adapter scrollToObject:@2 supplementaryKinds:nil scrollDirection:UICollectionViewScrollDirectionHorizontal scrollPosition:UICollectionViewScrollPositionNone animated:NO];
    IGAssertEqualPoint([self.collectionView contentOffset], 10, 0);
    [self.adapter scrollToObject:@3 supplementaryKinds:nil scrollDirection:UICollectionViewScrollDirectionHorizontal scrollPosition:UICollectionViewScrollPositionNone animated:NO];
    IGAssertEqualPoint([self.collectionView contentOffset], 30, 0);
    [self.adapter scrollToObject:@6 supplementaryKinds:nil scrollDirection:UICollectionViewScrollDirectionHorizontal scrollPosition:UICollectionViewScrollPositionNone animated:NO];
    // Content width minus collection view width is 110, can't scroll more than that
    IGAssertEqualPoint([self.collectionView contentOffset], 110, 0);
    [self.adapter scrollToObject:@6 supplementaryKinds:nil scrollDirection:UICollectionViewScrollDirectionHorizontal scrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    IGAssertEqualPoint([self.collectionView contentOffset], 110, 0);
    [self.adapter scrollToObject:@6 supplementaryKinds:nil scrollDirection:UICollectionViewScrollDirectionHorizontal scrollPosition:UICollectionViewScrollPositionRight animated:NO];
    IGAssertEqualPoint([self.collectionView contentOffset], 110, 0);
    self.layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.adapter.dataSource = self.dataSource;
}

- (void)test_whenScrollToItem_thatSupplementarySourceSupportsSingleHeader {
    self.dataSource.objects = @[@1, @2];
    [self.adapter reloadDataWithCompletion:nil];

    IGTestSupplementarySource *supplementarySource = [IGTestSupplementarySource new];
    supplementarySource.collectionContext = self.adapter;
    supplementarySource.supportedElementKinds = @[UICollectionElementKindSectionHeader];

    IGListSectionController *controller = [self.adapter sectionControllerForObject:@1];
    controller.supplementaryViewSource = supplementarySource;
    supplementarySource.sectionController = controller;

    [self.adapter performUpdatesAnimated:NO completion:nil];

    XCTAssertNotNil([self.collectionView supplementaryViewForElementKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]]);
    [self.adapter scrollToObject:@1 supplementaryKinds:@[UICollectionElementKindSectionHeader] scrollDirection:UICollectionViewScrollDirectionVertical scrollPosition:UICollectionViewScrollPositionNone animated:NO];
    IGAssertEqualPoint([self.collectionView contentOffset], 0, 0);
    [self.adapter scrollToObject:@2 supplementaryKinds:@[UICollectionElementKindSectionHeader] scrollDirection:UICollectionViewScrollDirectionVertical scrollPosition:UICollectionViewScrollPositionNone animated:NO];
    // Content height smaller than collection view height, won't scroll
    IGAssertEqualPoint([self.collectionView contentOffset], 0, 0);
}

- (void)test_whenScrollToItem_thatSupplementarySourceSupportsHeaderAndFooter {
    self.dataSource.objects = @[@1, @2];
    [self.adapter reloadDataWithCompletion:nil];

    IGTestSupplementarySource *supplementarySource = [IGTestSupplementarySource new];
    supplementarySource.collectionContext = self.adapter;
    supplementarySource.supportedElementKinds = @[UICollectionElementKindSectionHeader, UICollectionElementKindSectionFooter];

    IGListSectionController *controller = [self.adapter sectionControllerForObject:@1];
    controller.supplementaryViewSource = supplementarySource;
    supplementarySource.sectionController = controller;

    [self.adapter performUpdatesAnimated:NO completion:nil];

    XCTAssertNotNil([self.collectionView supplementaryViewForElementKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]]);
    XCTAssertNotNil([self.collectionView supplementaryViewForElementKind:UICollectionElementKindSectionFooter atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]]);
    [self.adapter scrollToObject:@1 supplementaryKinds:@[UICollectionElementKindSectionHeader, UICollectionElementKindSectionFooter] scrollDirection:UICollectionViewScrollDirectionVertical scrollPosition:UICollectionViewScrollPositionNone animated:NO];
    IGAssertEqualPoint([self.collectionView contentOffset], 0, 0);
    [self.adapter scrollToObject:@2 supplementaryKinds:@[UICollectionElementKindSectionHeader, UICollectionElementKindSectionFooter] scrollDirection:UICollectionViewScrollDirectionVertical scrollPosition:UICollectionViewScrollPositionNone animated:NO];
    // Content height smaller than collection view height, won't scroll
    IGAssertEqualPoint([self.collectionView contentOffset], 0, 0);
}

- (void)test_whenScrollVerticallyToItem_thatFeedIsEmpty {
    self.dataSource.objects = @[];
    [self.adapter reloadDataWithCompletion:nil];
    XCTAssertEqual([self.collectionView numberOfSections], 0);
    [self.adapter scrollToObject:@1 supplementaryKinds:nil scrollDirection:UICollectionViewScrollDirectionVertical scrollPosition:UICollectionViewScrollPositionNone animated:NO];
    IGAssertEqualPoint([self.collectionView contentOffset], 0, 0);
}

- (void)test_whenScrollVerticallyToItem_thatItemNotInFeed {
    // # of items for each object == [item integerValue], so @2 has 2 items (cells)
    self.dataSource.objects = @[@1, @2, @3, @4];
    [self.adapter reloadDataWithCompletion:nil];
    XCTAssertEqual([self.collectionView numberOfSections], 4);
    [self.adapter scrollToObject:@1 supplementaryKinds:nil scrollDirection:UICollectionViewScrollDirectionVertical scrollPosition:UICollectionViewScrollPositionNone animated:NO];
    IGAssertEqualPoint([self.collectionView contentOffset], 0, 0);
    [self.adapter scrollToObject:@5 supplementaryKinds:nil scrollDirection:UICollectionViewScrollDirectionVertical scrollPosition:UICollectionViewScrollPositionNone animated:NO];
    IGAssertEqualPoint([self.collectionView contentOffset], 0, 0);
    [self.adapter scrollToObject:@2 supplementaryKinds:nil scrollDirection:UICollectionViewScrollDirectionVertical scrollPosition:UICollectionViewScrollPositionNone animated:NO];
    // Content height is smaller than collection view height, can't scroll
    IGAssertEqualPoint([self.collectionView contentOffset], 0, 0);
    [self.adapter scrollToObject:@5 supplementaryKinds:nil scrollDirection:UICollectionViewScrollDirectionVertical scrollPosition:UICollectionViewScrollPositionNone animated:NO];
    // Content height is smaller than collection view height, can't scroll
    IGAssertEqualPoint([self.collectionView contentOffset], 0, 0);
}

- (void)test_whenQueryingIndexPath_withOOBSectionController_thatNilReturned {
    self.dataSource.objects = @[@0, @1, @2];
    [self.adapter reloadDataWithCompletion:nil];

    id randomSectionController = [IGListSectionController new];
    XCTAssertNil([self.adapter indexPathForSectionController:randomSectionController index:0 usePreviousIfInUpdateBlock:NO]);
}

- (void)test_whenQueryingSectionForObject_thatSectionReturned {
    self.dataSource.objects = @[@0, @1, @2];
    [self.adapter reloadDataWithCompletion:nil];
    XCTAssertEqual([self.adapter sectionForObject:@0], 0);
    XCTAssertEqual([self.adapter sectionForObject:@1], 1);
    XCTAssertEqual([self.adapter sectionForObject:@2], 2);
    XCTAssertEqual([self.adapter sectionForObject:@3], NSNotFound);
}

- (void)test_whenQueryingSectionControllerForSection_thatControllerReturned {
	self.dataSource.objects = @[@0, @1, @2];
	[self.adapter reloadDataWithCompletion:nil];
	
	XCTAssertEqual([self.adapter sectionControllerForSection:0], [self.adapter sectionControllerForObject:@0]);
	XCTAssertEqual([self.adapter sectionControllerForSection:1], [self.adapter sectionControllerForObject:@1]);
	XCTAssertEqual([self.adapter sectionControllerForSection:2], [self.adapter sectionControllerForObject:@2]);
}

- (void)test_whenReloadingData_withNoDataSource_thatCompletionCalledWithNO {
    self.dataSource.objects = @[@1];
    IGListAdapter *adapter = [[IGListAdapter alloc] initWithUpdater:[IGListReloadDataUpdater new]
                                                     viewController:nil];
    adapter.collectionView = self.collectionView;

    __block BOOL executed = NO;
    [adapter reloadDataWithCompletion:^(BOOL finished) {
        executed = YES;
        XCTAssertFalse(finished);
    }];
    XCTAssertTrue(executed);
}

- (void)test_whenReloadingData_withNoCollectionView_thatCompletionCalledWithNO {
    self.dataSource.objects = @[@1];
    IGListAdapter *adapter = [[IGListAdapter alloc] initWithUpdater:[IGListReloadDataUpdater new]
                                                     viewController:nil];
    adapter.dataSource = self.dataSource;

    __block BOOL executed = NO;
    [adapter reloadDataWithCompletion:^(BOOL finished) {
        executed = YES;
        XCTAssertFalse(finished);
    }];
    XCTAssertTrue(executed);
}

- (void)test_whenSectionControllerDeleting_withEmptyIndexes_thatNoUpdatesHappen {
    self.dataSource.objects = @[@0, @1, @2];
    [self.adapter reloadDataWithCompletion:nil];

    id mockDelegate = [OCMockObject mockForProtocol:@protocol(IGListUpdatingDelegate)];
    [[mockDelegate reject] deleteItemsFromCollectionView:[OCMArg any] indexPaths:[OCMArg any]];
    self.adapter.updater = mockDelegate;

    id sectionController = [self.adapter sectionControllerForObject:@1];
    [self.adapter deleteInSectionController:sectionController atIndexes:[NSIndexSet new]];

    [mockDelegate verify];
}

- (void)test_whenSectionControllerInserting_withEmptyIndexes_thatNoUpdatesHappen {
    self.dataSource.objects = @[@0, @1, @2];
    [self.adapter reloadDataWithCompletion:nil];

    id mockDelegate = [OCMockObject mockForProtocol:@protocol(IGListUpdatingDelegate)];
    [[mockDelegate reject] insertItemsIntoCollectionView:[OCMArg any] indexPaths:[OCMArg any]];
    self.adapter.updater = mockDelegate;

    id sectionController = [self.adapter sectionControllerForObject:@1];
    [self.adapter insertInSectionController:sectionController atIndexes:[NSIndexSet new]];

    [mockDelegate verify];
}

- (void)test_whenReloading_withSectionControllerNotFound_thatNoUpdatesHappen {
    self.dataSource.objects = @[@0, @1, @2];
    [self.adapter reloadDataWithCompletion:nil];

    id mockDelegate = [OCMockObject mockForProtocol:@protocol(IGListUpdatingDelegate)];
    [[mockDelegate reject] reloadCollectionView:[OCMArg any] sections:[OCMArg any]];
    self.adapter.updater = mockDelegate;

    id sectionController = [IGListSectionController new];
    [self.adapter reloadSectionController:sectionController];

    [mockDelegate verify];
}

- (void)test_whenSelectingCell_thatCollectionViewDelegateReceivesMethod {
    self.dataSource.objects = @[@0, @1, @2];
    [self.adapter reloadDataWithCompletion:nil];

    id mockDelegate = [OCMockObject mockForProtocol:@protocol(UICollectionViewDelegate)];
    self.adapter.collectionViewDelegate = mockDelegate;

    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [[mockDelegate expect] collectionView:self.collectionView didSelectItemAtIndexPath:indexPath];

    // simulates the collectionview telling its delegate that it was tapped
    [self.adapter collectionView:self.collectionView didSelectItemAtIndexPath:indexPath];

    [mockDelegate verify];
}

- (void)test_whenSelectingCell_thatSectionControllerReceivesMethod {
    self.dataSource.objects = @[@0, @1, @2];
    [self.adapter reloadDataWithCompletion:nil];

    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];

    // simulates the collectionview telling its delegate that it was tapped
    [self.adapter collectionView:self.collectionView didSelectItemAtIndexPath:indexPath];

    IGListTestSection *s0 = [self.adapter sectionControllerForObject:@0];
    IGListTestSection *s1 = [self.adapter sectionControllerForObject:@1];
    IGListTestSection *s2 = [self.adapter sectionControllerForObject:@2];

    XCTAssertTrue(s0.wasSelected);
    XCTAssertFalse(s1.wasSelected);
    XCTAssertFalse(s2.wasSelected);
}

- (void)test_whenDeselectingCell_thatCollectionViewDelegateReceivesMethod {
    self.dataSource.objects = @[@0, @1, @2];
    [self.adapter reloadDataWithCompletion:nil];

    id mockDelegate = [OCMockObject mockForProtocol:@protocol(UICollectionViewDelegate)];
    self.adapter.collectionViewDelegate = mockDelegate;

    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [[mockDelegate expect] collectionView:self.collectionView didDeselectItemAtIndexPath:indexPath];

    // simulates the collectionview telling its delegate that it was tapped
    [self.adapter collectionView:self.collectionView didDeselectItemAtIndexPath:indexPath];

    [mockDelegate verify];
}

- (void)test_whenDeselectingCell_thatSectionControllerReceivesMethod {
    self.dataSource.objects = @[@0, @1, @2];
    [self.adapter reloadDataWithCompletion:nil];

    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];

    // simulates the collectionview telling its delegate that it was tapped
    [self.adapter collectionView:self.collectionView didDeselectItemAtIndexPath:indexPath];

    IGListTestSection *s0 = [self.adapter sectionControllerForObject:@0];
    IGListTestSection *s1 = [self.adapter sectionControllerForObject:@1];
    IGListTestSection *s2 = [self.adapter sectionControllerForObject:@2];

    XCTAssertTrue(s0.wasDeselected);
    XCTAssertFalse(s1.wasDeselected);
    XCTAssertFalse(s2.wasDeselected);
}

- (void)test_whenDisplayingCell_thatCollectionViewDelegateReceivesMethod {
    self.dataSource.objects = @[@0, @1, @2];
    [self.adapter reloadDataWithCompletion:nil];

    id mockDelegate = [OCMockObject mockForProtocol:@protocol(UICollectionViewDelegate)];
    self.adapter.collectionViewDelegate = mockDelegate;

    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    UICollectionViewCell *cell = [UICollectionViewCell new];
    [[mockDelegate expect] collectionView:self.collectionView willDisplayCell:cell forItemAtIndexPath:indexPath];

    // simulates the collectionview telling its delegate that a cell will be displayed
    [self.adapter collectionView:self.collectionView willDisplayCell:cell forItemAtIndexPath:indexPath];

    [mockDelegate verify];
}

- (void)test_whenWillBeginDragging_thatScrollViewDelegateReceivesMethod {
    self.dataSource.objects = @[@0, @1, @2];
    [self.adapter reloadDataWithCompletion:nil];

    id mockCollectionDelegate = [OCMockObject mockForProtocol:@protocol(UICollectionViewDelegate)];
    id mockScrollDelegate = [OCMockObject mockForProtocol:@protocol(UIScrollViewDelegate)];
    self.adapter.collectionViewDelegate = mockCollectionDelegate;
    self.adapter.scrollViewDelegate = mockScrollDelegate;

    [[mockCollectionDelegate reject] scrollViewWillBeginDragging:self.collectionView];
    [[mockScrollDelegate expect] scrollViewWillBeginDragging:self.collectionView];

    // simulates the scrollview delegate telling the adapter that it will begin dragging
    [self.adapter scrollViewWillBeginDragging:self.collectionView];

    [mockCollectionDelegate verify];
    [mockScrollDelegate verify];
}

- (void)test_whenDidEndDragging_thatScrollViewDelegateReceivesMethod {
    self.dataSource.objects = @[@0, @1, @2];
    [self.adapter reloadDataWithCompletion:nil];

    id mockCollectionDelegate = [OCMockObject mockForProtocol:@protocol(UICollectionViewDelegate)];
    id mockScrollDelegate = [OCMockObject mockForProtocol:@protocol(UIScrollViewDelegate)];
    self.adapter.collectionViewDelegate = mockCollectionDelegate;
    self.adapter.scrollViewDelegate = mockScrollDelegate;

    [[mockCollectionDelegate reject] scrollViewDidEndDragging:self.collectionView willDecelerate:NO];
    [[mockScrollDelegate expect] scrollViewDidEndDragging:self.collectionView willDecelerate:NO];

    // simulates the scrollview delegate telling the adapter that it will end dragging
    [self.adapter scrollViewDidEndDragging:self.collectionView willDecelerate:NO];

    [mockCollectionDelegate verify];
    [mockScrollDelegate verify];
}

- (void)test_whenDidEndDecelerating_thatScrollViewDelegateReceivesMethod {
    self.dataSource.objects = @[@0, @1, @2];
    [self.adapter reloadDataWithCompletion:nil];

    id mockCollectionDelegate = [OCMockObject mockForProtocol:@protocol(UICollectionViewDelegate)];
    id mockScrollDelegate = [OCMockObject mockForProtocol:@protocol(UIScrollViewDelegate)];
    self.adapter.collectionViewDelegate = mockCollectionDelegate;
    self.adapter.scrollViewDelegate = mockScrollDelegate;

    [[mockCollectionDelegate reject] scrollViewDidEndDecelerating:self.collectionView];
    [[mockScrollDelegate expect] scrollViewDidEndDecelerating:self.collectionView];

    // simulates the scrollview delegate telling the adapter that it ended decelerating
    [self.adapter scrollViewDidEndDecelerating:self.collectionView];

    [mockCollectionDelegate verify];
    [mockScrollDelegate verify];
}

- (void)test_whenReloadingObjectsThatDontExist_thatAdapterContinues {
    self.dataSource.objects = @[@0, @1, @2];
    [self.adapter reloadDataWithCompletion:nil];
    [self.adapter reloadObjects:@[@1, @3]];
    XCTAssertEqual(self.collectionView.numberOfSections, 3);
}

- (void)test_whenDeselectingThroughContext_thatCellDeselected {
    self.dataSource.objects = @[@1, @2, @3];
    [self.adapter reloadDataWithCompletion:nil];

    NSIndexPath *path = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.collectionView selectItemAtIndexPath:path animated:NO scrollPosition:UICollectionViewScrollPositionTop];
    XCTAssertTrue([[self.collectionView cellForItemAtIndexPath:path] isSelected]);

    id section = [self.adapter sectionControllerForObject:@1];
    [self.adapter deselectItemAtIndex:0 sectionController:section animated:NO];
    XCTAssertFalse([[self.collectionView cellForItemAtIndexPath:path] isSelected]);
}

- (void)test_whenSelectingThroughContext_thatCellSelected {
    self.dataSource.objects = @[@1, @2, @3];
    [self.adapter reloadDataWithCompletion:nil];
    
    NSIndexPath *path = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.adapter selectItemAtIndex:0 sectionController:[self.adapter sectionControllerForObject:@1] animated:NO scrollPosition:UICollectionViewScrollPositionTop];
    XCTAssertTrue([[self.collectionView cellForItemAtIndexPath:path] isSelected]);
}

- (void)test_whenScrollingToIndex_withSectionController_thatPositionCorrect {
    self.dataSource.objects = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10, @11, @12, @13, @14, @15, @16, @17, @18, @19];
    [self.adapter reloadDataWithCompletion:nil];
    
    IGListSectionController *section = [self.adapter sectionControllerForObject:@8];
    [section.collectionContext scrollToSectionController:section atIndex:0 scrollPosition:UICollectionViewScrollPositionTop animated:NO];
    XCTAssertEqual(self.collectionView.contentOffset.x, 0);
    XCTAssertEqual(self.collectionView.contentOffset.y, 280);
}

- (void)test_whenDisplayingSectionController_withOnlySupplementaryView_thatDisplayEventStillSent {
    self.dataSource.objects = @[@0];
    [self.adapter reloadDataWithCompletion:nil];
    XCTAssertNil([self.collectionView supplementaryViewForElementKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]]);

    IGTestSupplementarySource *supplementarySource = [IGTestSupplementarySource new];
    supplementarySource.collectionContext = self.adapter;
    supplementarySource.supportedElementKinds = @[UICollectionElementKindSectionHeader];

    IGListSectionController *controller = [self.adapter sectionControllerForObject:@0];
    controller.supplementaryViewSource = supplementarySource;
    supplementarySource.sectionController = controller;

    id mockDisplayDelegate = [OCMockObject mockForProtocol:@protocol(IGListDisplayDelegate)];
    [[mockDisplayDelegate expect] listAdapter:self.adapter willDisplaySectionController:controller];
    [[mockDisplayDelegate reject] listAdapter:self.adapter willDisplaySectionController:controller cell:[OCMArg any] atIndex:0];

    controller.displayDelegate = mockDisplayDelegate;

    [self.adapter performUpdatesAnimated:NO completion:nil];
    XCTAssertNotNil([self.collectionView supplementaryViewForElementKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]]);

    [mockDisplayDelegate verify];
}

- (void)test_whenEndingDisplayOfSectionController_withOnlySupplementaryView_thatDisplayEventStillSent {
    self.dataSource.objects = @[@0];
    [self.adapter reloadDataWithCompletion:nil];
    XCTAssertNil([self.collectionView supplementaryViewForElementKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]]);

    IGTestSupplementarySource *supplementarySource = [IGTestSupplementarySource new];
    supplementarySource.collectionContext = self.adapter;
    supplementarySource.supportedElementKinds = @[UICollectionElementKindSectionHeader];

    IGListSectionController *controller = [self.adapter sectionControllerForObject:@0];
    controller.supplementaryViewSource = supplementarySource;
    supplementarySource.sectionController = controller;

    [self.adapter performUpdatesAnimated:NO completion:nil];
    XCTAssertNotNil([self.collectionView supplementaryViewForElementKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]]);

    id mockDisplayDelegate = [OCMockObject mockForProtocol:@protocol(IGListDisplayDelegate)];
    [[mockDisplayDelegate expect] listAdapter:self.adapter didEndDisplayingSectionController:controller];
    [[mockDisplayDelegate reject] listAdapter:self.adapter didEndDisplayingSectionController:controller cell:[OCMArg any] atIndex:0];

    controller.displayDelegate = mockDisplayDelegate;

    controller.supplementaryViewSource = nil;
    [self.adapter performUpdatesAnimated:NO completion:nil];
    XCTAssertNil([self.collectionView supplementaryViewForElementKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]]);

    [mockDisplayDelegate verify];
}

- (void)test_whenWillDisplaySupplementaryView_thatCollectionViewDelegateReceivesEvents {
    // silence display handler asserts
    self.dataSource.objects = @[@1, @2];
    [self.adapter reloadDataWithCompletion:nil];
    
    id mockDelegate = [OCMockObject mockForProtocol:@protocol(UICollectionViewDelegate)];
    self.adapter.collectionViewDelegate = mockDelegate;
    UICollectionReusableView *view = [UICollectionReusableView new];
    NSString *kind = @"kind";
    NSIndexPath *path = [NSIndexPath indexPathForItem:0 inSection:0];
    [[mockDelegate expect] collectionView:self.collectionView willDisplaySupplementaryView:view forElementKind:kind atIndexPath:path];
    [self.adapter collectionView:self.collectionView willDisplaySupplementaryView:view forElementKind:kind atIndexPath:path];
    [mockDelegate verify];
}

- (void)test_whenEndDisplayingSupplementaryView_thatCollectionViewDelegateReceivesEvents {
    // silence display handler asserts
    self.dataSource.objects = @[@1, @2];
    [self.adapter reloadDataWithCompletion:nil];

    id mockDelegate = [OCMockObject mockForProtocol:@protocol(UICollectionViewDelegate)];
    self.adapter.collectionViewDelegate = mockDelegate;
    UICollectionReusableView *view = [UICollectionReusableView new];
    NSString *kind = @"kind";
    NSIndexPath *path = [NSIndexPath indexPathForItem:0 inSection:0];
    [[mockDelegate expect] collectionView:self.collectionView didEndDisplayingSupplementaryView:view forElementOfKind:kind atIndexPath:path];
    [self.adapter collectionView:self.collectionView didEndDisplayingSupplementaryView:view forElementOfKind:kind atIndexPath:path];
    [mockDelegate verify];
}

- (void)test_whenHighlightingCell_thatCollectionViewDelegateReceivesMethod {
    self.dataSource.objects = @[@0, @1, @2];
    [self.adapter reloadDataWithCompletion:nil];

    id mockDelegate = [OCMockObject mockForProtocol:@protocol(UICollectionViewDelegate)];
    self.adapter.collectionViewDelegate = mockDelegate;

    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [[mockDelegate expect] collectionView:self.collectionView didHighlightItemAtIndexPath:indexPath];

    // simulates the collectionview telling its delegate that it was highlighted
    [self.adapter collectionView:self.collectionView didHighlightItemAtIndexPath:indexPath];

    [mockDelegate verify];
}

- (void)test_whenHighlightingCell_thatSectionControllerReceivesMethod {
    self.dataSource.objects = @[@0, @1, @2];
    [self.adapter reloadDataWithCompletion:nil];

    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];

    // simulates the collectionview telling its delegate that it was highlighted
    [self.adapter collectionView:self.collectionView didHighlightItemAtIndexPath:indexPath];

    IGListTestSection *s0 = [self.adapter sectionControllerForObject:@0];
    IGListTestSection *s1 = [self.adapter sectionControllerForObject:@1];
    IGListTestSection *s2 = [self.adapter sectionControllerForObject:@2];

    XCTAssertTrue(s0.wasHighlighted);
    XCTAssertFalse(s1.wasHighlighted);
    XCTAssertFalse(s2.wasHighlighted);
}

- (void)test_whenUnhighlightingCell_thatCollectionViewDelegateReceivesMethod {
    self.dataSource.objects = @[@0, @1, @2];
    [self.adapter reloadDataWithCompletion:nil];

    id mockDelegate = [OCMockObject mockForProtocol:@protocol(UICollectionViewDelegate)];
    self.adapter.collectionViewDelegate = mockDelegate;

    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [[mockDelegate expect] collectionView:self.collectionView didUnhighlightItemAtIndexPath:indexPath];

    // simulates the collectionview telling its delegate that it was unhighlighted
    [self.adapter collectionView:self.collectionView didUnhighlightItemAtIndexPath:indexPath];

    [mockDelegate verify];
}

- (void)test_whenUnlighlightingCell_thatSectionControllerReceivesMethod {
    self.dataSource.objects = @[@0, @1, @2];
    [self.adapter reloadDataWithCompletion:nil];

    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];

    // simulates the collectionview telling its delegate that it was unhighlighted
    [self.adapter collectionView:self.collectionView didUnhighlightItemAtIndexPath:indexPath];

    IGListTestSection *s0 = [self.adapter sectionControllerForObject:@0];
    IGListTestSection *s1 = [self.adapter sectionControllerForObject:@1];
    IGListTestSection *s2 = [self.adapter sectionControllerForObject:@2];

    XCTAssertTrue(s0.wasUnhighlighted);
    XCTAssertFalse(s1.wasUnhighlighted);
    XCTAssertFalse(s2.wasUnhighlighted);
}

- (void)test_whenDataSourceDoesntHandleObject_thatObjectIsDropped {
    // IGListTestAdapterDataSource does not handle NSStrings
    self.dataSource.objects = @[@1, @"dog", @2];
    [self.adapter reloadDataWithCompletion:nil];
    NSArray *expected = @[@1, @2];
    XCTAssertEqualObjects(self.adapter.objects, expected);
}

- (void)test_whenSectionEdgeInsetIsNotZero {
    // IGListTestAdapterDataSource does not handle NSStrings
    self.dataSource.objects = @[@42];
    [self.adapter reloadDataWithCompletion:nil];
    IGListSectionController *controller = [self.adapter sectionControllerForObject:@42];
    IGAssertEqualSize([self.adapter containerSizeForSectionController:controller], 98, 98);
}

- (void)test_whenSectionControllerReturnsNegativeSize_thatAdapterReturnsZero {
    self.dataSource.objects = @[@1];
    IGListTestSection *section = [self.adapter sectionControllerForObject:self.dataSource.objects[0]];
    section.size = CGSizeMake(-1, -1);
    const CGSize size = [self.adapter sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    XCTAssertEqual(size.width, 0.0);
    XCTAssertEqual(size.height, 0.0);
}

- (void)test_whenSupplementarySourceReturnsNegativeSize_thatAdapterReturnsZero {
    self.dataSource.objects = @[@1];
    [self.adapter reloadDataWithCompletion:nil];
    
    IGTestSupplementarySource *supplementarySource = [IGTestSupplementarySource new];
    supplementarySource.collectionContext = self.adapter;
    supplementarySource.supportedElementKinds = @[UICollectionElementKindSectionFooter];
    supplementarySource.size = CGSizeMake(-1, -1);
    
    IGListSectionController *controller = [self.adapter sectionControllerForObject:@1];
    controller.supplementaryViewSource = supplementarySource;
    supplementarySource.sectionController = controller;
    
    const CGSize size = [self.adapter sizeForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                         atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    XCTAssertEqual(size.width, 0.0);
    XCTAssertEqual(size.height, 0.0);
}

- (void)test_whenQueryingContainerInset_thatMatchesCollectionView {
    self.dataSource.objects = @[@2];
    [self.adapter reloadDataWithCompletion:nil];
    self.collectionView.contentInset = UIEdgeInsetsMake(1, 2, 3, 4);
    IGListSectionController *controller = [self.adapter sectionControllerForObject:@2];
    const UIEdgeInsets inset = [controller.collectionContext containerInset];
    XCTAssertEqual(inset.top, 1);
    XCTAssertEqual(inset.left, 2);
    XCTAssertEqual(inset.bottom, 3);
    XCTAssertEqual(inset.right, 4);
}

- (void)test_whenQueryingInsetContainerSize_thatResultIsBoundsInsetByContent {
    self.dataSource.objects = @[@2];
    [self.adapter reloadDataWithCompletion:nil];
    self.collectionView.contentInset = UIEdgeInsetsMake(1, 2, 3, 4);
    IGListSectionController *controller = [self.adapter sectionControllerForObject:@2];
    const CGSize size = [controller.collectionContext insetContainerSize];
    XCTAssertEqual(size.width, 94);
    XCTAssertEqual(size.height, 96);
}

- (void)test_whenInsertingAtBeginning_thatAllSectionControllerIndexesUpdateCorrectly_forInsertAtHead {
    NSNumber *zero = @0;
    NSNumber *one = @1;
    NSNumber *two = @2;
    NSNumber *three = @3;
    self.dataSource.objects = @[one, two, three];
    [self.adapter performUpdatesAnimated:NO completion:nil];

    IGListSectionController *controller1a = [self.adapter sectionControllerForObject:one];
    XCTAssertEqual(controller1a.section, 0);
    XCTAssertTrue(controller1a.isFirstSection);

    XCTAssertEqual([self.adapter sectionControllerForObject:two].section, 1);
    XCTAssertEqual([self.adapter sectionControllerForObject:three].section, 2);
    XCTAssertTrue([self.adapter sectionControllerForObject:three].isLastSection);

    self.dataSource.objects = @[zero, one, two, three];
    [self.adapter performUpdatesAnimated:NO completion:nil];

    IGListSectionController *controller0 = [self.adapter sectionControllerForObject:zero];
    XCTAssertEqual(controller0.section, 0);
    XCTAssertTrue(controller0.isFirstSection);

    IGListSectionController *controller1b = [self.adapter sectionControllerForObject:one];
    XCTAssertEqual(controller1b.section, 1);
    XCTAssertFalse(controller1b.isFirstSection);

    XCTAssertEqual([self.adapter sectionControllerForObject:two].section, 2);
    XCTAssertEqual([self.adapter sectionControllerForObject:three].section, 3);
    XCTAssertTrue([self.adapter sectionControllerForObject:three].isLastSection);
}

- (void)test_whenRemovingFromHead_thatAllSectionControllerIndexesUpdateCorrectly_RemovedSectionControllerIsNotFound {
    NSNumber *zero = @0;
    NSNumber *one = @1;
    NSNumber *two = @2;
    NSNumber *three = @3;
    self.dataSource.objects = @[zero, one, two, three];
    [self.adapter performUpdatesAnimated:NO completion:nil];

    IGListSectionController *zeroController = [self.adapter sectionControllerForSection:0];
    XCTAssertEqual(zeroController.section, 0);
    XCTAssertTrue(zeroController.isFirstSection);

    IGListSectionController *oneController = [self.adapter sectionControllerForSection:1];
    XCTAssertEqual(oneController.section, 1);
    XCTAssertFalse(oneController.isFirstSection);

    IGListSectionController *threeController = [self.adapter sectionControllerForSection:3];
    XCTAssertEqual(threeController.section, 3);
    XCTAssertTrue(threeController.isLastSection);

    self.dataSource.objects = @[one, two, three];
    [self.adapter performUpdatesAnimated:NO completion:nil];

    XCTAssertEqual(zeroController.section, NSNotFound);
    XCTAssertFalse(zeroController.isFirstSection);

    XCTAssertEqual(oneController.section, 0);
    XCTAssertTrue(oneController.isFirstSection);

    XCTAssertEqual(threeController.section, 2);
    XCTAssertTrue(threeController.isLastSection);
}

- (void)test_whenRemovingFromMiddle_thatAllSectionControllerIndexesUpdateCorrectly_removedSectionControllerIsNotFound {
    NSNumber *zero = @0;
    NSNumber *one = @1;
    NSNumber *two = @2;
    NSNumber *three = @3;
    self.dataSource.objects = @[zero, one, two, three];
    [self.adapter performUpdatesAnimated:NO completion:nil];

    IGListSectionController *zeroController = [self.adapter sectionControllerForSection:0];
    XCTAssertEqual(zeroController.section, 0);
    XCTAssertTrue(zeroController.isFirstSection);

    IGListSectionController *oneController = [self.adapter sectionControllerForSection:1];
    XCTAssertEqual(oneController.section, 1);
    XCTAssertFalse(oneController.isFirstSection);

    IGListSectionController *threeController = [self.adapter sectionControllerForSection:3];
    XCTAssertEqual(threeController.section, 3);
    XCTAssertTrue(threeController.isLastSection);

    self.dataSource.objects = @[zero, two, three];
    [self.adapter performUpdatesAnimated:NO completion:nil];

    XCTAssertEqual(zeroController.section, 0);
    XCTAssertTrue(zeroController.isFirstSection);

    XCTAssertEqual(oneController.section, NSNotFound);
    XCTAssertFalse(oneController.isFirstSection);

    XCTAssertEqual(threeController.section, 2);
    XCTAssertTrue(threeController.isLastSection);
}

- (void)test_withStrongRefToSectionController_thatAdaptersectionIsZero_thatSectionControllerIndexDoesNotChange {
    IGListSectionController *sc = nil;

    // hold a weak reference to simulate what would happen to the collectionContext object on a section controller
    // if the section controller were held strongly by an async block and the rest of the infra was deallocated
    __weak IGListAdapter *wAdapter = nil;

    @autoreleasepool {
        IGListTestAdapterDataSource *dataSource = [IGListTestAdapterDataSource new];
        IGListReloadDataUpdater *updater = [IGListReloadDataUpdater new];
        IGListAdapter *adapter = [[IGListAdapter alloc] initWithUpdater:updater
                                                         viewController:nil];
        adapter.dataSource = dataSource;
        adapter.collectionView = self.collectionView;
        wAdapter = adapter;

        dataSource.objects = @[@0, @1, @2];
        [adapter performUpdatesAnimated:NO completion:nil];

        sc = [adapter sectionControllerForSection:1];
        XCTAssertEqual(sc.section, 1);
    }

    XCTAssertEqual(sc.section, NSNotFound);
    XCTAssertEqual([wAdapter sectionForSectionController:sc], 0);
}

- (void)test_whenSwappingCollectionViews_withMultipleAdapters_thatDoesntNilOtherAdaptersCollectionView {
    IGListTestAdapterDataSource *dataSource1 = [IGListTestAdapterDataSource new];
    IGListAdapter *adapter1 = [[IGListAdapter alloc] initWithUpdater:[IGListAdapterUpdater new] viewController:nil];
    adapter1.dataSource = dataSource1;

    IGListTestAdapterDataSource *dataSource2 = [IGListTestAdapterDataSource new];
    IGListAdapter *adapter2 = [[IGListAdapter alloc] initWithUpdater:[IGListAdapterUpdater new] viewController:nil];
    adapter2.dataSource = dataSource2;

    UICollectionView *collectionView1 = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[UICollectionViewFlowLayout new]];
    UICollectionView *collectionView2 = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[UICollectionViewFlowLayout new]];

    adapter1.collectionView = collectionView1;
    adapter2.collectionView = collectionView2;

    XCTAssertEqual(adapter1.collectionView, collectionView1);
    XCTAssertEqual(collectionView1.dataSource, adapter1);
    XCTAssertEqual(adapter2.collectionView, collectionView2);
    XCTAssertEqual(collectionView2.dataSource, adapter2);

    adapter2.collectionView = collectionView1;

    XCTAssertEqual(adapter2.collectionView, collectionView1);
    XCTAssertEqual(collectionView1.dataSource, adapter2);
    XCTAssertNil(adapter1.collectionView);

    adapter1.collectionView = collectionView2;

    XCTAssertEqual(adapter1.collectionView, collectionView2);
    XCTAssertEqual(collectionView2.dataSource, adapter1);
    XCTAssertEqual(adapter2.collectionView, collectionView1);
    XCTAssertEqual(collectionView1.dataSource, adapter2);
}

- (void)test_whenPrefetchingEnabled_thatSetterDisables {
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[UICollectionViewFlowLayout new]];
    collectionView.prefetchingEnabled = YES;

    IGListAdapter *adapter = [[IGListAdapter alloc] initWithUpdater:[IGListAdapterUpdater new] viewController:nil];
    adapter.collectionView = collectionView;

    XCTAssertFalse(collectionView.prefetchingEnabled);
}

- (void)test_whenSectionControllerReorderDisabled_thatAdapterReorderDisabled {
    BOOL isReorderable = NO;

    IGListTestAdapterReorderingDataSource *dataSource = [IGListTestAdapterReorderingDataSource new];
    dataSource.objects = @[@0, @1, @2];
    self.adapter.dataSource = dataSource;
    self.adapter.moveDelegate = dataSource;

    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    IGTestReorderableSection *section = (IGTestReorderableSection *)[self.adapter sectionControllerForSection:0];
    section.isReorderable = isReorderable;

    [self.adapter performUpdatesAnimated:NO completion:nil];
    
    BOOL canMove = [self.adapter collectionView:self.collectionView canMoveItemAtIndexPath:indexPath];
    XCTAssertFalse(canMove);
}

- (void)test_whenSectionControllerReorderEnabled_thatAdapterReorderEnabled {
    BOOL isReorderable = YES;

    IGListTestAdapterReorderingDataSource *dataSource = [IGListTestAdapterReorderingDataSource new];
    dataSource.objects = @[@0, @1, @2];
    self.adapter.dataSource = dataSource;
    self.adapter.moveDelegate = dataSource;

    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    IGTestReorderableSection *section = (IGTestReorderableSection *)[self.adapter sectionControllerForSection:0];
    section.isReorderable = isReorderable;

    [self.adapter performUpdatesAnimated:NO completion:nil];

    BOOL canMove = [self.adapter collectionView:self.collectionView canMoveItemAtIndexPath:indexPath];
    XCTAssertTrue(canMove);
}

- (NSIndexPath *)interpretedIndexPathFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    UICollectionViewLayout *layout = self.collectionView.collectionViewLayout;
    NSIndexPath *updatedIndexPath = [layout updatedTargetForInteractivelyMovingItem:fromIndexPath
                                                                        toIndexPath:toIndexPath
                                                                            adapter:self.adapter];
    if (!updatedIndexPath) {
        return toIndexPath;
    }
    return updatedIndexPath;
}

- (void)test_whenSectionIsInteractivelyReordered_thatIndexesUpdateCorrectly {
    IGListTestAdapterReorderingDataSource *dataSource = [IGListTestAdapterReorderingDataSource new];
    dataSource.objects = @[@0, @1, @2];
    self.adapter.dataSource = dataSource;
    self.adapter.moveDelegate = dataSource;

    IGTestReorderableSection *section0 = (IGTestReorderableSection *)[self.adapter sectionControllerForSection:0];
    IGTestReorderableSection *section1 = (IGTestReorderableSection *)[self.adapter sectionControllerForSection:1];
    IGTestReorderableSection *section2 = (IGTestReorderableSection *)[self.adapter sectionControllerForSection:2];
    section0.sectionObject = [IGTestReorderableSectionObject sectionWithObjects:@[@0]];
    section1.sectionObject = [IGTestReorderableSectionObject sectionWithObjects:@[@0]];
    section2.sectionObject = [IGTestReorderableSectionObject sectionWithObjects:@[@0]];
    section2.isReorderable = YES;

    [self.adapter performUpdatesAnimated:NO completion:nil];

    NSIndexPath *fromIndexPath, *toIndexPath, *interpretedPath;

    // move the last section into the first position, dropping into the end of the first section
    fromIndexPath = [NSIndexPath indexPathForItem:0 inSection:2];
    toIndexPath = [NSIndexPath indexPathForItem:1 inSection:0];
    interpretedPath = [self interpretedIndexPathFromIndexPath:fromIndexPath toIndexPath:toIndexPath];
    [self.adapter collectionView:self.collectionView moveItemAtIndexPath:fromIndexPath toIndexPath:interpretedPath];

    XCTAssertEqual(section0, [self.adapter sectionControllerForSection:0]);
    XCTAssertEqual(section2, [self.adapter sectionControllerForSection:1]);
    XCTAssertEqual(section1, [self.adapter sectionControllerForSection:2]);

    // move the last section into the first position, dropping into the start of the first section
    fromIndexPath = [NSIndexPath indexPathForItem:0 inSection:2];
    toIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    interpretedPath = [self interpretedIndexPathFromIndexPath:fromIndexPath toIndexPath:toIndexPath];
    [self.adapter collectionView:self.collectionView moveItemAtIndexPath:fromIndexPath toIndexPath:interpretedPath];

    XCTAssertEqual(section1, [self.adapter sectionControllerForSection:0]);
    XCTAssertEqual(section0, [self.adapter sectionControllerForSection:1]);
    XCTAssertEqual(section2, [self.adapter sectionControllerForSection:2]);

    // move the first section into the last position, dropping into the start of the last section
    fromIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    toIndexPath = [NSIndexPath indexPathForItem:0 inSection:2];
    interpretedPath = [self interpretedIndexPathFromIndexPath:fromIndexPath toIndexPath:toIndexPath];
    [self.adapter collectionView:self.collectionView moveItemAtIndexPath:fromIndexPath toIndexPath:interpretedPath];

    XCTAssertEqual(section0, [self.adapter sectionControllerForSection:0]);
    XCTAssertEqual(section1, [self.adapter sectionControllerForSection:1]);
    XCTAssertEqual(section2, [self.adapter sectionControllerForSection:2]);

    // move the first section into the last position, dropping into the end of the last section
    fromIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    toIndexPath = [NSIndexPath indexPathForItem:1 inSection:2];
    interpretedPath = [self interpretedIndexPathFromIndexPath:fromIndexPath toIndexPath:toIndexPath];
    [self.adapter collectionView:self.collectionView moveItemAtIndexPath:fromIndexPath toIndexPath:interpretedPath];

    XCTAssertEqual(section1, [self.adapter sectionControllerForSection:0]);
    XCTAssertEqual(section2, [self.adapter sectionControllerForSection:1]);
    XCTAssertEqual(section0, [self.adapter sectionControllerForSection:2]);
}

- (void)test_whenItemsInSectionAreInteractivelyReordered_thatIndexesUpdateCorrectly {
    IGListTestAdapterReorderingDataSource *dataSource = [IGListTestAdapterReorderingDataSource new];
    dataSource.objects = @[@0];
    self.adapter.dataSource = dataSource;
    self.adapter.moveDelegate = dataSource;

    NSArray *sectionObjects = @[@0, @1, @2];

    IGTestReorderableSection *section = (IGTestReorderableSection *)[self.adapter sectionControllerForSection:0];
    section.sectionObject = [IGTestReorderableSectionObject sectionWithObjects:sectionObjects];
    section.isReorderable = YES;

    [self.adapter performUpdatesAnimated:NO completion:nil];

    NSIndexPath *fromIndexPath, *toIndexPath;

    // move the last item into the first position
    fromIndexPath = [NSIndexPath indexPathForItem:2 inSection:0];
    toIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.adapter collectionView:self.collectionView moveItemAtIndexPath:fromIndexPath toIndexPath:toIndexPath];

    XCTAssertEqual(sectionObjects[2], section.sectionObject.objects[0]);
    XCTAssertEqual(sectionObjects[0], section.sectionObject.objects[1]);
    XCTAssertEqual(sectionObjects[1], section.sectionObject.objects[2]);

    // move the last item into the middle position
    fromIndexPath = [NSIndexPath indexPathForItem:2 inSection:0];
    toIndexPath = [NSIndexPath indexPathForItem:1 inSection:0];
    [self.adapter collectionView:self.collectionView moveItemAtIndexPath:fromIndexPath toIndexPath:toIndexPath];

    XCTAssertEqual(sectionObjects[2], section.sectionObject.objects[0]);
    XCTAssertEqual(sectionObjects[1], section.sectionObject.objects[1]);
    XCTAssertEqual(sectionObjects[0], section.sectionObject.objects[2]);
}

- (void)test_whenItemsAreInteractivelyReorderedAcrossSections_thatIndexesRevertToOriginalState {
    IGListTestAdapterReorderingDataSource *dataSource = [IGListTestAdapterReorderingDataSource new];
    dataSource.objects = @[@0, @1];
    self.adapter.dataSource = dataSource;
    self.adapter.moveDelegate = dataSource;

    NSArray *section0Objects = @[@0, @1, @2];
    NSArray *section1Objects = @[@3, @4, @5];

    IGTestReorderableSection *section0 = (IGTestReorderableSection *)[self.adapter sectionControllerForSection:0];
    section0.sectionObject = [IGTestReorderableSectionObject sectionWithObjects:section0Objects];
    IGTestReorderableSection *section1 = (IGTestReorderableSection *)[self.adapter sectionControllerForSection:1];
    section1.sectionObject = [IGTestReorderableSectionObject sectionWithObjects:section1Objects];
    section1.isReorderable = YES;

    [self.adapter performUpdatesAnimated:NO completion:nil];

    NSIndexPath *fromIndexPath, *toIndexPath;

    // move an item from section 1 to section 0 and check that they are reverted
    fromIndexPath = [NSIndexPath indexPathForItem:0 inSection:1];
    toIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];

    [self.collectionView performBatchUpdates:^{
        [self.collectionView moveItemAtIndexPath:fromIndexPath toIndexPath:toIndexPath];

        [self.collectionView.dataSource collectionView:self.collectionView
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
