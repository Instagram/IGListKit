/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant 
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import <IGListKit/IGListKit.h>
#import <IGListKit/IGListReloadDataUpdater.h>

#import "IGListAdapterInternal.h"
#import "IGListDisplayHandler.h"
#import "IGListStackedSectionControllerInternal.h"
#import "IGListTestSection.h"
#import "IGTestStackedDataSource.h"

static const CGRect kStackTestFrame = (CGRect){{0.0, 0.0}, {100.0, 100.0}};

@interface IGListStackSectionControllerTests : XCTestCase

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) IGListCollectionView *collectionView;
@property (nonatomic, strong) IGListAdapter *adapter;
@property (nonatomic, strong) IGTestStackedDataSource *dataSource;

@end

@implementation IGListStackSectionControllerTests

- (void)setUp {
    [super setUp];

    self.window = [[UIWindow alloc] initWithFrame:kStackTestFrame];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionView = [[IGListCollectionView alloc] initWithFrame:kStackTestFrame collectionViewLayout:layout];
    [self.window addSubview:self.collectionView];

    self.dataSource = [[IGTestStackedDataSource alloc] init];
    self.adapter = [[IGListAdapter alloc] initWithUpdater:[IGListAdapterUpdater new] viewController:nil workingRangeSize:0];
}

- (void)tearDown {
    [super tearDown];

    self.adapter = nil;
    self.collectionView = nil;
    self.dataSource = nil;
}

- (void)setupWithObjects:(NSArray *)objects {
    self.dataSource.objects = objects;
    self.adapter.collectionView = self.collectionView;
    self.adapter.dataSource = self.dataSource;
    [self.collectionView layoutIfNeeded];
}

#pragma mark - Base

- (void)test_whenInitializingStack_thatNumberOfItemsMatches {
    IGListTestSection *section1 = [[IGListTestSection alloc] init];
    section1.items = 2;
    IGListTestSection *section2 = [[IGListTestSection alloc] init];
    section2.items = 3;
    IGListTestSection *section3 = [[IGListTestSection alloc] init];
    section3.items = 0;
    IGListTestSection *section4 = [[IGListTestSection alloc] init];
    section4.items = 1;

    IGListStackedSectionController *stack = [[IGListStackedSectionController alloc] initWithSectionControllers:@[section1, section2, section3, section4]];

    XCTAssertEqual([stack numberOfItems], 6);
}

- (void)test_whenInitializingStack_thatSectionControllerIndexesMatch {
    IGListTestSection *section1 = [[IGListTestSection alloc] init];
    section1.items = 2;
    IGListTestSection *section2 = [[IGListTestSection alloc] init];
    section2.items = 3;
    IGListTestSection *section3 = [[IGListTestSection alloc] init];
    section3.items = 0;
    IGListTestSection *section4 = [[IGListTestSection alloc] init];
    section4.items = 1;

    IGListStackedSectionController *stack = [[IGListStackedSectionController alloc] initWithSectionControllers:@[section1, section2, section3, section4]];

    XCTAssertEqualObjects([stack sectionControllerForObjectIndex:0], section1);
    XCTAssertEqualObjects([stack sectionControllerForObjectIndex:1], section1);
    XCTAssertEqualObjects([stack sectionControllerForObjectIndex:2], section2);
    XCTAssertEqualObjects([stack sectionControllerForObjectIndex:3], section2);
    XCTAssertEqualObjects([stack sectionControllerForObjectIndex:4], section2);
    XCTAssertEqualObjects([stack sectionControllerForObjectIndex:5], section4);
}

- (void)test_whenInitializingStack_thatSectionControllerOffsetsMatch {
    IGListTestSection *section1 = [[IGListTestSection alloc] init];
    section1.items = 2;
    IGListTestSection *section2 = [[IGListTestSection alloc] init];
    section2.items = 3;
    IGListTestSection *section3 = [[IGListTestSection alloc] init];
    section3.items = 0;
    IGListTestSection *section4 = [[IGListTestSection alloc] init];
    section4.items = 1;

    IGListStackedSectionController *stack = [[IGListStackedSectionController alloc] initWithSectionControllers:@[section1, section2, section3, section4]];
    XCTAssertEqual([stack offsetForSectionController:section1], 0);
    XCTAssertEqual([stack offsetForSectionController:section2], 2);
    XCTAssertEqual([stack offsetForSectionController:section3], 5);
    XCTAssertEqual([stack offsetForSectionController:section4], 5);
}


#pragma mark - IGListCollectionContext

- (void)test_whenReloadingStack_thatSectionControllerContainerMatchesCollectionView {
    [self setupWithObjects:@[
                             [[IGTestObject alloc] initWithKey:@0 value:@[@1]]
                             ]];
    IGListStackedSectionController *stack = [self.adapter sectionControllerForObject:self.dataSource.objects[0]];
    IGListTestSection *section1 = stack.sectionControllers[0];
    XCTAssertTrue(CGSizeEqualToSize([section1.collectionContext containerSize], kStackTestFrame.size));
}

- (void)test_whenQueryingCellIndex_thatIndexIsRelativeToSectionController {
    [self setupWithObjects:@[
                             [[IGTestObject alloc] initWithKey:@0 value:@[@1, @1, @2]]
                             ]];

    IGListStackedSectionController *stack = [self.adapter sectionControllerForObject:self.dataSource.objects[0]];

    IGListTestSection *section1 = stack.sectionControllers[0];
    UICollectionViewCell *cell1 = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];

    IGListTestSection *section2 = stack.sectionControllers[1];
    UICollectionViewCell *cell2 = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];

    IGListTestSection *section3 = stack.sectionControllers[2];
    UICollectionViewCell *cell30 = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:0]];
    UICollectionViewCell *cell31 = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:3 inSection:0]];

    // each controller in the stack has one cell, even though the item indexes are 0, 1, 2, 3
    XCTAssertEqual([section1.collectionContext indexForCell:cell1 sectionController:section1], 0);
    XCTAssertEqual([section2.collectionContext indexForCell:cell2 sectionController:section2], 0);
    XCTAssertEqual([section3.collectionContext indexForCell:cell30 sectionController:section3], 0);
    XCTAssertEqual([section3.collectionContext indexForCell:cell31 sectionController:section3], 1);
}

- (void)test_whenQueryingCells_thatCellIsRelativeToSectionController {
    [self setupWithObjects:@[
                             [[IGTestObject alloc] initWithKey:@0 value:@[@1, @1, @2]]
                             ]];

    IGListStackedSectionController *stack = [self.adapter sectionControllerForObject:self.dataSource.objects[0]];

    IGListTestSection *section1 = stack.sectionControllers[0];
    UICollectionViewCell *cell1 = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];

    IGListTestSection *section2 = stack.sectionControllers[1];
    UICollectionViewCell *cell2 = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];

    IGListTestSection *section3 = stack.sectionControllers[2];
    UICollectionViewCell *cell30 = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:0]];
    UICollectionViewCell *cell31 = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:3 inSection:0]];

    // each controller in the stack has one cell, even though the item indexes are 0, 1, 2, 3
    XCTAssertEqualObjects([section1.collectionContext cellForItemAtIndex:0 sectionController:section1], cell1);
    XCTAssertEqualObjects([section2.collectionContext cellForItemAtIndex:0 sectionController:section2], cell2);
    XCTAssertEqualObjects([section3.collectionContext cellForItemAtIndex:0 sectionController:section3], cell30);
    XCTAssertEqualObjects([section3.collectionContext cellForItemAtIndex:1 sectionController:section3], cell31);
}

- (void)test_whenQueryingSectionControllerSection_thatSectionMatchesStackSection {
    [self setupWithObjects:@[
                             [[IGTestObject alloc] initWithKey:@0 value:@[@1, @1]],
                             [[IGTestObject alloc] initWithKey:@1 value:@[@1, @1]]
                             ]];

    IGListStackedSectionController *stack1 = [self.adapter sectionControllerForObject:self.dataSource.objects[0]];
    IGListStackedSectionController *stack2 = [self.adapter sectionControllerForObject:self.dataSource.objects[1]];

    IGListTestSection *section11 = stack1.sectionControllers[0];
    IGListTestSection *section12 = stack1.sectionControllers[1];
    IGListTestSection *section21 = stack2.sectionControllers[0];
    IGListTestSection *section22 = stack2.sectionControllers[1];

    XCTAssertEqual([stack1.collectionContext sectionForSectionController:stack1], 0);
    XCTAssertEqual([stack2.collectionContext sectionForSectionController:stack2], 1);
    XCTAssertEqual([section11.collectionContext sectionForSectionController:section11], 0);
    XCTAssertEqual([section12.collectionContext sectionForSectionController:section12], 0);
    XCTAssertEqual([section21.collectionContext sectionForSectionController:section21], 1);
    XCTAssertEqual([section22.collectionContext sectionForSectionController:section22], 1);
}

- (void)test_whenReloadingItems_thatCollectionViewReloadsRelativeIndexPaths {
    [self setupWithObjects:@[
                             [[IGTestObject alloc] initWithKey:@0 value:@[@2, @2]]
                             ]];

    id mockCollectionView = [OCMockObject niceMockForClass:[IGListCollectionView class]];
    self.adapter.collectionView = mockCollectionView;

    IGListStackedSectionController *stack = [self.adapter sectionControllerForObject:self.dataSource.objects[0]];
    IGListTestSection *section2 = stack.sectionControllers[1];

    [[mockCollectionView expect] reloadItemsAtIndexPaths:@[
                                                           [NSIndexPath indexPathForItem:3 inSection:0]
                                                           ]];
    [section2.collectionContext reloadInSectionController:section2 atIndexes:[NSIndexSet indexSetWithIndex:1]];
    [mockCollectionView verify];
}

- (void)test_whenInsertingItems_thatCollectionViewReloadsRelativeIndexPaths {
    [self setupWithObjects:@[
                             [[IGTestObject alloc] initWithKey:@0 value:@[@2, @2]]
                             ]];

    id mockCollectionView = [OCMockObject niceMockForClass:[IGListCollectionView class]];
    self.adapter.collectionView = mockCollectionView;

    IGListStackedSectionController *stack = [self.adapter sectionControllerForObject:self.dataSource.objects[0]];
    IGListTestSection *section2 = stack.sectionControllers[1];
    section2.items = 3;

    [[mockCollectionView expect] insertItemsAtIndexPaths:@[
                                                           [NSIndexPath indexPathForItem:4 inSection:0]
                                                           ]];
    [section2.collectionContext insertInSectionController:section2 atIndexes:[NSIndexSet indexSetWithIndex:2]];
    [mockCollectionView verify];

    XCTAssertEqual([stack numberOfItems], 5);
}

- (void)test_whenDeletingItems_thatCollectionViewReloadsRelativeIndexPaths {
    [self setupWithObjects:@[
                             [[IGTestObject alloc] initWithKey:@0 value:@[@2, @2]]
                             ]];

    id mockCollectionView = [OCMockObject niceMockForClass:[IGListCollectionView class]];
    self.adapter.collectionView = mockCollectionView;

    IGListStackedSectionController *stack = [self.adapter sectionControllerForObject:self.dataSource.objects[0]];
    IGListTestSection *section2 = stack.sectionControllers[1];
    section2.items = 1;

    [[mockCollectionView expect] deleteItemsAtIndexPaths:@[
                                                           [NSIndexPath indexPathForItem:3 inSection:0]
                                                           ]];
    [section2.collectionContext deleteInSectionController:section2 atIndexes:[NSIndexSet indexSetWithIndex:1]];
    [mockCollectionView verify];

    XCTAssertEqual([stack numberOfItems], 3);
}

- (void)test_whenReloadingSectionController_thatCollectionViewReloadsStack {
    [self setupWithObjects:@[
                             [[IGTestObject alloc] initWithKey:@0 value:@[@2, @2]]
                             ]];

    id mockCollectionView = [OCMockObject niceMockForClass:[IGListCollectionView class]];
    self.adapter.collectionView = mockCollectionView;

    IGListStackedSectionController *stack = [self.adapter sectionControllerForObject:self.dataSource.objects[0]];
    IGListTestSection *section2 = stack.sectionControllers[1];
    section2.items = 3;

    // section 0 b/c any controller doing a full reload will queue reload of the entire stack
    [[mockCollectionView expect] reloadSections:[NSIndexSet indexSetWithIndex:0]];
    [section2.collectionContext reloadSectionController:section2];
    [mockCollectionView verify];

    XCTAssertEqual([stack numberOfItems], 5);
}

- (void)test_whenDisplayingCell_thatEventsForwardedToSectionControllers {
    id mock1Delegate = [OCMockObject mockForProtocol:@protocol(IGListDisplayDelegate)];
    id mock2Delegate = [OCMockObject mockForProtocol:@protocol(IGListDisplayDelegate)];
    IGListTestSection *section1 = [[IGListTestSection alloc] init];
    section1.items = 2;
    section1.displayDelegate = mock1Delegate;
    IGListTestSection *section2 = [[IGListTestSection alloc] init];
    section2.displayDelegate = mock2Delegate;
    section2.items = 2;
    UICollectionViewCell *cell1 = [UICollectionViewCell new];
    UICollectionViewCell *cell2 = [UICollectionViewCell new];

    [[mock1Delegate expect] listAdapter:self.adapter willDisplaySectionController:section1];
    [[mock1Delegate expect] listAdapter:self.adapter willDisplaySectionController:section1 cell:cell1 atIndex:0];
    [[mock1Delegate expect] listAdapter:self.adapter willDisplaySectionController:section1 cell:cell2 atIndex:1];
    [[mock2Delegate reject] listAdapter:self.adapter willDisplaySectionController:section2];

    IGListDisplayHandler *display = [[IGListDisplayHandler alloc] init];
    IGListStackedSectionController *stack = [[IGListStackedSectionController alloc] initWithSectionControllers:@[section1, section2]];

    [display willDisplayCell:cell1 forListAdapter:self.adapter sectionController:stack object:@"a" indexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    [display willDisplayCell:cell2 forListAdapter:self.adapter sectionController:stack object:@"a" indexPath:[NSIndexPath indexPathForItem:1 inSection:0]];

    [mock1Delegate verify];
    [mock2Delegate verify];
}

- (void)test_whenEndDisplayingCell_thatEventsForwardedToSectionControllers {
    id mock1Delegate = [OCMockObject mockForProtocol:@protocol(IGListDisplayDelegate)];
    id mock2Delegate = [OCMockObject mockForProtocol:@protocol(IGListDisplayDelegate)];
    IGListTestSection *section1 = [[IGListTestSection alloc] init];
    section1.items = 2;
    IGListTestSection *section2 = [[IGListTestSection alloc] init];
    section2.items = 2;
    UICollectionViewCell *cell1 = [UICollectionViewCell new];
    UICollectionViewCell *cell2 = [UICollectionViewCell new];
    UICollectionViewCell *cell3 = [UICollectionViewCell new];
    UICollectionViewCell *cell4 = [UICollectionViewCell new];

    IGListDisplayHandler *display = [[IGListDisplayHandler alloc] init];
    IGListStackedSectionController *stack = [[IGListStackedSectionController alloc] initWithSectionControllers:@[section1, section2]];

    // display all 4 cells (2 per child section controller)
    [display willDisplayCell:cell1 forListAdapter:self.adapter sectionController:stack object:@"a" indexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    [display willDisplayCell:cell2 forListAdapter:self.adapter sectionController:stack object:@"a" indexPath:[NSIndexPath indexPathForItem:1 inSection:0]];
    [display willDisplayCell:cell3 forListAdapter:self.adapter sectionController:stack object:@"a" indexPath:[NSIndexPath indexPathForItem:2 inSection:0]];
    [display willDisplayCell:cell4 forListAdapter:self.adapter sectionController:stack object:@"a" indexPath:[NSIndexPath indexPathForItem:3 inSection:0]];

    section1.displayDelegate = mock1Delegate;
    section2.displayDelegate = mock2Delegate;

    [[mock1Delegate expect] listAdapter:self.adapter didEndDisplayingSectionController:section1];
    [[mock1Delegate expect] listAdapter:self.adapter didEndDisplayingSectionController:section1 cell:cell1 atIndex:0];
    [[mock1Delegate expect] listAdapter:self.adapter didEndDisplayingSectionController:section1 cell:cell2 atIndex:1];
    [[mock2Delegate reject] listAdapter:self.adapter didEndDisplayingSectionController:section2];

    [display didEndDisplayingCell:cell1 forListAdapter:self.adapter sectionController:stack indexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    [display didEndDisplayingCell:cell2 forListAdapter:self.adapter sectionController:stack indexPath:[NSIndexPath indexPathForItem:1 inSection:0]];

    [mock1Delegate verify];
    [mock2Delegate verify];
}

- (void)test_whenRemovingCell_thatEventsForwardedToSectionControllers {
    [self setupWithObjects:@[
                             [[IGTestObject alloc] initWithKey:@0 value:@[@1, @2]],
                             [[IGTestObject alloc] initWithKey:@1 value:@[@1, @2]]
                             ]];

    IGTestObject *obj1 = self.dataSource.objects[0];
    IGTestObject *obj2 = self.dataSource.objects[1];

    self.dataSource.objects = @[obj1];

    id mockDelegate = [OCMockObject mockForProtocol:@protocol(IGListDisplayDelegate)];

    IGListStackedSectionController *stack = [self.adapter sectionControllerForObject:obj2];

    IGListTestSection *section1 = stack.sectionControllers[0];
    IGListTestSection *section2 = stack.sectionControllers[1];

    section1.displayDelegate = mockDelegate;
    section2.displayDelegate = mockDelegate;

    UICollectionViewCell *cell1 = [self.adapter.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1]];
    UICollectionViewCell *cell2 = [self.adapter.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:1]];
    UICollectionViewCell *cell3 = [self.adapter.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:1]];

    [[mockDelegate expect] listAdapter:self.adapter didEndDisplayingSectionController:section1];
    [[mockDelegate expect] listAdapter:self.adapter didEndDisplayingSectionController:section2];
    [[mockDelegate expect] listAdapter:self.adapter didEndDisplayingSectionController:section1 cell:cell1 atIndex:0];
    [[mockDelegate expect] listAdapter:self.adapter didEndDisplayingSectionController:section2 cell:cell2 atIndex:0];
    [[mockDelegate expect] listAdapter:self.adapter didEndDisplayingSectionController:section2 cell:cell3 atIndex:1];

    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self.adapter reloadDataWithCompletion:^(BOOL finished) {
        [mockDelegate verify];
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:15 handler:nil];
}

- (void)test_whenQueryingVisibleSectionControllers_withCellsOffscreen_thatOnlyVisibleReturned {
    [self setupWithObjects:@[
                             [[IGTestObject alloc] initWithKey:@0 value:@[@3, @4, @0, @5, @6]]
                             ]];
    IGListStackedSectionController *stack = [self.adapter sectionControllerForObject:self.dataSource.objects[0]];

    IGListTestSection *section1 = stack.sectionControllers[0];
    IGListTestSection *section2 = stack.sectionControllers[1];
    IGListTestSection *section3 = stack.sectionControllers[2];
    IGListTestSection *section4 = stack.sectionControllers[3];
    IGListTestSection *section5 = stack.sectionControllers[4];

    XCTAssertEqual([self.adapter visibleCellsForSectionController:stack].count, 10);
    XCTAssertEqual([stack visibleCellsForSectionController:section1].count, 3);
    XCTAssertEqual([stack visibleCellsForSectionController:section2].count, 4);
    XCTAssertEqual([stack visibleCellsForSectionController:section3].count, 0);
    XCTAssertEqual([stack visibleCellsForSectionController:section4].count, 3);
    XCTAssertEqual([stack visibleCellsForSectionController:section5].count, 0);
}

- (void)test_whenPerformingItemUpdates_thatMutationsMapToSectionControllers {
    [self setupWithObjects:@[
                             [[IGTestObject alloc] initWithKey:@0 value:@[@1, @2, @3]],
                             [[IGTestObject alloc] initWithKey:@1 value:@[@1, @2, @3]],
                             [[IGTestObject alloc] initWithKey:@2 value:@[@1, @1]]
                             ]];

    IGTestObject *object = self.dataSource.objects[1];

    IGListStackedSectionController *stack = [self.adapter sectionControllerForObject:object];
    IGListTestSection *section1 = stack.sectionControllers[0];
    IGListTestSection *section2 = stack.sectionControllers[1];

    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [section1.collectionContext performBatchAnimated:YES updates:^{
        section1.items = 3;
        [section1.collectionContext insertInSectionController:section1 atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)]];
    } completion:^(BOOL finished2) {
        XCTAssertEqual([self.collectionView numberOfSections], 3);
        XCTAssertEqual([self.collectionView numberOfItemsInSection:0], 6);
        XCTAssertEqual([self.collectionView numberOfItemsInSection:1], 7);
        XCTAssertEqual([self.collectionView numberOfItemsInSection:2], 2);
        [expectation fulfill];
    }];

    [section2.collectionContext performBatchAnimated:YES updates:^{
        section2.items = 1;
        [section2.collectionContext deleteInSectionController:section2 atIndexes:[NSIndexSet indexSetWithIndex:0]];
    } completion:nil];

    [self waitForExpectationsWithTimeout:15 handler:nil];
}

@end
