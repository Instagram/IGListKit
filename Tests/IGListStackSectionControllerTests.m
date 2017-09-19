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
#import "IGListTestContainerSizeSection.h"
#import "IGTestCell.h"
#import "IGTestStackedDataSource.h"
#import "IGTestStoryboardCell.h"
#import "IGTestStoryboardViewController.h"
#import "IGTestSupplementarySource.h"
#import "IGTestSupplementarySource.h"
#import "IGTestStoryboardSupplementarySource.h"
#import "IGListTestHelpers.h"

static const CGRect kStackTestFrame = (CGRect){{0.0, 0.0}, {100.0, 100.0}};

@interface IGListStackSectionControllerTests : XCTestCase

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) IGListAdapter *adapter;
@property (nonatomic, strong) IGTestStackedDataSource *dataSource;

@end

@implementation IGListStackSectionControllerTests

- (void)setUp {
    [super setUp];

    self.window = [[UIWindow alloc] initWithFrame:kStackTestFrame];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"IGTestStoryboard" bundle:[NSBundle bundleForClass:self.class]];
    IGTestStoryboardViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"testVC"];
    self.window.rootViewController = vc;
    [self.window addSubview:vc.view];
    [vc performSelectorOnMainThread:@selector(loadView) withObject:nil waitUntilDone:YES];
    self.collectionView = vc.collectionView;

    vc.view.frame = kStackTestFrame;
    self.collectionView.frame = kStackTestFrame;

    self.dataSource = [[IGTestStackedDataSource alloc] init];
    self.adapter = [[IGListAdapter alloc] initWithUpdater:[IGListAdapterUpdater new] viewController:nil workingRangeSize:1];
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
    [stack reloadData];
    
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
    [stack reloadData];
    
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
    [stack reloadData];

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

- (void)test_whenSectionEdgeInsetIsNotZero {
    [self setupWithObjects:@[
                             [[IGTestObject alloc] initWithKey:@0 value:@[@42]]
                             ]];
    IGListStackedSectionController *stack = [self.adapter sectionControllerForObject:self.dataSource.objects[0]];
    IGListTestContainerSizeSection *section1 = stack.sectionControllers[0];
    IGAssertEqualSize([stack containerSizeForSectionController:section1], 98, 98);
}

- (void)test_whenQueryingContainerInset_thatMatchesCollectionView {
    self.collectionView.contentInset = UIEdgeInsetsMake(1, 2, 3, 4);
    [self setupWithObjects:@[
                             [[IGTestObject alloc] initWithKey:@0 value:@[@42]]
                             ]];
    IGListStackedSectionController *stack = [self.adapter sectionControllerForObject:self.dataSource.objects[0]];
    IGListTestContainerSizeSection *section1 = stack.sectionControllers[0];
    const UIEdgeInsets inset = [section1.collectionContext containerInset];
    XCTAssertEqual(inset.top, 1);
    XCTAssertEqual(inset.left, 2);
    XCTAssertEqual(inset.bottom, 3);
    XCTAssertEqual(inset.right, 4);
}

- (void)test_whenQueryingInsetContainerSize_thatBoundsInsetByContent {
    self.collectionView.contentInset = UIEdgeInsetsMake(1, 2, 3, 4);
    [self setupWithObjects:@[
                             [[IGTestObject alloc] initWithKey:@0 value:@[@42]]
                             ]];
    IGListStackedSectionController *stack = [self.adapter sectionControllerForObject:self.dataSource.objects[0]];
    IGListTestContainerSizeSection *section1 = stack.sectionControllers[0];
    const CGSize size = [section1.collectionContext insetContainerSize];
    XCTAssertEqual(size.width, 94);
    XCTAssertEqual(size.height, 96);
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

    XCTAssertEqual(stack1.section, 0);
    XCTAssertEqual(stack2.section, 1);
    XCTAssertEqual(section11.section, 0);
    XCTAssertEqual(section12.section, 0);
    XCTAssertEqual(section21.section, 1);
    XCTAssertEqual(section22.section, 1);
}

- (void)test_whenReloadingItems_thatCollectionViewReloadsRelativeIndexPaths {
    [self setupWithObjects:@[
                             [[IGTestObject alloc] initWithKey:@0 value:@[@2, @2]]
                             ]];

    id mockCollectionView = [OCMockObject niceMockForClass:[UICollectionView class]];
    self.adapter.collectionView = mockCollectionView;

    IGListStackedSectionController *stack = [self.adapter sectionControllerForObject:self.dataSource.objects[0]];
    
    id mockBatchContext = [OCMockObject mockForProtocol:@protocol(IGListBatchContext)];
    stack.forwardingBatchContext = mockBatchContext;
    
    IGListTestSection *section2 = stack.sectionControllers[1];

    [[mockBatchContext expect] reloadInSectionController:stack atIndexes:[NSIndexSet indexSetWithIndex:3]];
    [stack reloadInSectionController:section2 atIndexes:[NSIndexSet indexSetWithIndex:1]];
    [mockBatchContext verify];
}

- (void)test_whenInsertingItems_thatCollectionViewReloadsRelativeIndexPaths {
    [self setupWithObjects:@[
                             [[IGTestObject alloc] initWithKey:@0 value:@[@2, @2]]
                             ]];

    id mockCollectionView = [OCMockObject niceMockForClass:[UICollectionView class]];
    self.adapter.collectionView = mockCollectionView;

    IGListStackedSectionController *stack = [self.adapter sectionControllerForObject:self.dataSource.objects[0]];
    
    id mockBatchContext = [OCMockObject mockForProtocol:@protocol(IGListBatchContext)];
    stack.forwardingBatchContext = mockBatchContext;
    
    IGListTestSection *section2 = stack.sectionControllers[1];
    section2.items = 3;

    [[mockBatchContext expect] insertInSectionController:stack atIndexes:[NSIndexSet indexSetWithIndex:4]];
    [stack insertInSectionController:section2 atIndexes:[NSIndexSet indexSetWithIndex:2]];
    [mockBatchContext verify];

    XCTAssertEqual([stack numberOfItems], 5);
}

- (void)test_whenDeletingItems_thatCollectionViewReloadsRelativeIndexPaths {
    [self setupWithObjects:@[
                             [[IGTestObject alloc] initWithKey:@0 value:@[@2, @2]]
                             ]];

    id mockCollectionView = [OCMockObject niceMockForClass:[UICollectionView class]];
    self.adapter.collectionView = mockCollectionView;

    IGListStackedSectionController *stack = [self.adapter sectionControllerForObject:self.dataSource.objects[0]];
    
    id mockBatchContext = [OCMockObject mockForProtocol:@protocol(IGListBatchContext)];
    stack.forwardingBatchContext = mockBatchContext;
    
    IGListTestSection *section2 = stack.sectionControllers[1];
    section2.items = 1;

    [[mockBatchContext expect] deleteInSectionController:stack atIndexes:[NSIndexSet indexSetWithIndex:3]];
    [stack deleteInSectionController:section2 atIndexes:[NSIndexSet indexSetWithIndex:1]];
    [mockBatchContext verify];

    XCTAssertEqual([stack numberOfItems], 3);
}

- (void)test_whenReloadingSectionController_thatCollectionViewReloadsStack {
    [self setupWithObjects:@[
                             [[IGTestObject alloc] initWithKey:@0 value:@[@2, @2]]
                             ]];

    id mockCollectionView = [OCMockObject niceMockForClass:[UICollectionView class]];
    self.adapter.collectionView = mockCollectionView;

    IGListStackedSectionController *stack = [self.adapter sectionControllerForObject:self.dataSource.objects[0]];
    
    id mockBatchContext = [OCMockObject mockForProtocol:@protocol(IGListBatchContext)];
    stack.forwardingBatchContext = mockBatchContext;
    
    IGListTestSection *section2 = stack.sectionControllers[1];
    section2.items = 3;

    // section 0 b/c any controller doing a full reload will queue reload of the entire stack
    [[mockBatchContext expect] reloadSectionController:stack];
    [stack reloadSectionController:section2];
    [mockBatchContext verify];

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
    [stack reloadData];

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
    [stack reloadData];

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
    [self waitForExpectationsWithTimeout:30 handler:nil];
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

- (void)test_whenQueryingVisibleSectionControllers_withIndexPathsOffscreen_thatOnlyVisibleReturned {
    [self setupWithObjects:@[
                             [[IGTestObject alloc] initWithKey:@0 value:@[@3, @4, @0, @5, @6]]
                             ]];
    IGListStackedSectionController *stack = [self.adapter sectionControllerForObject:self.dataSource.objects[0]];
    
    IGListTestSection *section1 = stack.sectionControllers[0];
    IGListTestSection *section2 = stack.sectionControllers[1];
    IGListTestSection *section3 = stack.sectionControllers[2];
    IGListTestSection *section4 = stack.sectionControllers[3];
    IGListTestSection *section5 = stack.sectionControllers[4];
    
    NSSet *visible1 = [NSSet setWithArray:[stack visibleIndexPathsForSectionController:section1]];
    NSSet *expected1 = [NSSet setWithArray:@[
                                             [NSIndexPath indexPathForItem:0 inSection:0],
                                             [NSIndexPath indexPathForItem:1 inSection:0],
                                             [NSIndexPath indexPathForItem:2 inSection:0],
                                             ]];
    XCTAssertEqualObjects(visible1, expected1);
    
    NSSet *visible2 = [NSSet setWithArray:[stack visibleIndexPathsForSectionController:section2]];
    NSSet *expected2 = [NSSet setWithArray:@[
                                             [NSIndexPath indexPathForItem:3 inSection:0],
                                             [NSIndexPath indexPathForItem:4 inSection:0],
                                             [NSIndexPath indexPathForItem:5 inSection:0],
                                             [NSIndexPath indexPathForItem:6 inSection:0],
                                             ]];
    XCTAssertEqualObjects(visible2, expected2);
    
    NSSet *visible3 = [NSSet setWithArray:[stack visibleIndexPathsForSectionController:section3]];
    NSSet *expected3 = [NSSet setWithArray:@[]];
    XCTAssertEqualObjects(visible3, expected3);
    
    NSSet *visible4 = [NSSet setWithArray:[stack visibleIndexPathsForSectionController:section4]];
    NSSet *expected4 = [NSSet setWithArray:@[
                                             [NSIndexPath indexPathForItem:7 inSection:0],
                                             [NSIndexPath indexPathForItem:8 inSection:0],
                                             [NSIndexPath indexPathForItem:9 inSection:0],
                                             ]];
    XCTAssertEqualObjects(visible4, expected4);
    
    NSSet *visible5 = [NSSet setWithArray:[stack visibleIndexPathsForSectionController:section5]];
    NSSet *expected5 = [NSSet setWithArray:@[]];
    XCTAssertEqualObjects(visible5, expected5);
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
    [section1.collectionContext performBatchAnimated:YES updates:^(id<IGListBatchContext> batchContext) {
        section1.items = 3;
        [batchContext insertInSectionController:section1 atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)]];
    } completion:^(BOOL finished2) {
        XCTAssertEqual([self.collectionView numberOfSections], 3);
        XCTAssertEqual([self.collectionView numberOfItemsInSection:0], 6);
        XCTAssertEqual([self.collectionView numberOfItemsInSection:1], 7);
        XCTAssertEqual([self.collectionView numberOfItemsInSection:2], 2);
        [expectation fulfill];
    }];

    [section2.collectionContext performBatchAnimated:YES updates:^(id<IGListBatchContext> batchContext) {
        section2.items = 1;
        [batchContext deleteInSectionController:section2 atIndexes:[NSIndexSet indexSetWithIndex:0]];
    } completion:nil];

    [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)test_whenSelectingItems_thatChildSectionControllersSelected {
    [self setupWithObjects:@[
                             [[IGTestObject alloc] initWithKey:@0 value:@[@1, @2, @3]],
                             [[IGTestObject alloc] initWithKey:@1 value:@[@1, @2, @3]],
                             [[IGTestObject alloc] initWithKey:@2 value:@[@1, @1]]
                             ]];

    [self.adapter collectionView:self.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    [self.adapter collectionView:self.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:1]];
    [self.adapter collectionView:self.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:2]];

    IGListStackedSectionController *stack0 = [self.adapter sectionControllerForObject:self.dataSource.objects[0]];
    IGListStackedSectionController *stack1 = [self.adapter sectionControllerForObject:self.dataSource.objects[1]];
    IGListStackedSectionController *stack2 = [self.adapter sectionControllerForObject:self.dataSource.objects[2]];

    XCTAssertTrue([stack0.sectionControllers[0] wasSelected]);
    XCTAssertFalse([stack0.sectionControllers[1] wasSelected]);
    XCTAssertFalse([stack0.sectionControllers[2] wasSelected]);
    XCTAssertFalse([stack1.sectionControllers[0] wasSelected]);
    XCTAssertTrue([stack1.sectionControllers[1] wasSelected]);
    XCTAssertFalse([stack1.sectionControllers[2] wasSelected]);
    XCTAssertFalse([stack2.sectionControllers[0] wasSelected]);
    XCTAssertTrue([stack2.sectionControllers[1] wasSelected]);
}

- (void)test_whenDeselectingItems_thatChildSectionControllersSelected {
    [self setupWithObjects:@[
                             [[IGTestObject alloc] initWithKey:@0 value:@[@1, @2, @3]],
                             [[IGTestObject alloc] initWithKey:@1 value:@[@1, @2, @3]],
                             [[IGTestObject alloc] initWithKey:@2 value:@[@1, @1]]
                             ]];

    [self.adapter collectionView:self.collectionView didDeselectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    [self.adapter collectionView:self.collectionView didDeselectItemAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:1]];
    [self.adapter collectionView:self.collectionView didDeselectItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:2]];

    IGListStackedSectionController *stack0 = [self.adapter sectionControllerForObject:self.dataSource.objects[0]];
    IGListStackedSectionController *stack1 = [self.adapter sectionControllerForObject:self.dataSource.objects[1]];
    IGListStackedSectionController *stack2 = [self.adapter sectionControllerForObject:self.dataSource.objects[2]];

    XCTAssertTrue([stack0.sectionControllers[0] wasDeselected]);
    XCTAssertFalse([stack0.sectionControllers[1] wasDeselected]);
    XCTAssertFalse([stack0.sectionControllers[2] wasDeselected]);
    XCTAssertFalse([stack1.sectionControllers[0] wasDeselected]);
    XCTAssertTrue([stack1.sectionControllers[1] wasDeselected]);
    XCTAssertFalse([stack1.sectionControllers[2] wasDeselected]);
    XCTAssertFalse([stack2.sectionControllers[0] wasDeselected]);
    XCTAssertTrue([stack2.sectionControllers[1] wasDeselected]);
}

- (void)test_whenHighlightingItems_thatChildSectionControllersSelected {
    [self setupWithObjects:@[
                             [[IGTestObject alloc] initWithKey:@0 value:@[@1, @2, @3]],
                             [[IGTestObject alloc] initWithKey:@1 value:@[@1, @2, @3]],
                             [[IGTestObject alloc] initWithKey:@2 value:@[@1, @1]]
                             ]];

    [self.adapter collectionView:self.collectionView didHighlightItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    [self.adapter collectionView:self.collectionView didHighlightItemAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:1]];
    [self.adapter collectionView:self.collectionView didHighlightItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:2]];

    IGListStackedSectionController *stack0 = [self.adapter sectionControllerForObject:self.dataSource.objects[0]];
    IGListStackedSectionController *stack1 = [self.adapter sectionControllerForObject:self.dataSource.objects[1]];
    IGListStackedSectionController *stack2 = [self.adapter sectionControllerForObject:self.dataSource.objects[2]];

    XCTAssertTrue([stack0.sectionControllers[0] wasHighlighted]);
    XCTAssertFalse([stack0.sectionControllers[1] wasHighlighted]);
    XCTAssertFalse([stack0.sectionControllers[2] wasHighlighted]);
    XCTAssertFalse([stack1.sectionControllers[0] wasHighlighted]);
    XCTAssertTrue([stack1.sectionControllers[1] wasHighlighted]);
    XCTAssertFalse([stack1.sectionControllers[2] wasHighlighted]);
    XCTAssertFalse([stack2.sectionControllers[0] wasHighlighted]);
    XCTAssertTrue([stack2.sectionControllers[1] wasHighlighted]);
}

- (void)test_whenUnhighlightingItems_thatChildSectionControllersUnhighlighted {
    [self setupWithObjects:@[
                             [[IGTestObject alloc] initWithKey:@0 value:@[@1, @2, @3]],
                             [[IGTestObject alloc] initWithKey:@1 value:@[@1, @2, @3]],
                             [[IGTestObject alloc] initWithKey:@2 value:@[@1, @1]]
                             ]];

    [self.adapter collectionView:self.collectionView didUnhighlightItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    [self.adapter collectionView:self.collectionView didUnhighlightItemAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:1]];
    [self.adapter collectionView:self.collectionView didUnhighlightItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:2]];

    IGListStackedSectionController *stack0 = [self.adapter sectionControllerForObject:self.dataSource.objects[0]];
    IGListStackedSectionController *stack1 = [self.adapter sectionControllerForObject:self.dataSource.objects[1]];
    IGListStackedSectionController *stack2 = [self.adapter sectionControllerForObject:self.dataSource.objects[2]];

    XCTAssertTrue([stack0.sectionControllers[0] wasUnhighlighted]);
    XCTAssertFalse([stack0.sectionControllers[1] wasUnhighlighted]);
    XCTAssertFalse([stack0.sectionControllers[2] wasUnhighlighted]);
    XCTAssertFalse([stack1.sectionControllers[0] wasUnhighlighted]);
    XCTAssertTrue([stack1.sectionControllers[1] wasUnhighlighted]);
    XCTAssertFalse([stack1.sectionControllers[2] wasUnhighlighted]);
    XCTAssertFalse([stack2.sectionControllers[0] wasUnhighlighted]);
    XCTAssertTrue([stack2.sectionControllers[1] wasUnhighlighted]);
}

- (void)test_whenUsingNibs_withStoryboards_thatCellsAreConfigured {
    [self setupWithObjects:@[
                             [[IGTestObject alloc] initWithKey:@0 value:@[@1, @"nib", @"storyboard"]],
                             ]];

    UICollectionViewCell *cell0 = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    IGTestCell *cell1 = (IGTestCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];
    IGTestStoryboardCell *cell2 = (IGTestStoryboardCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:0]];

    XCTAssertEqualObjects(cell0.class, [UICollectionViewCell class]);
    XCTAssertEqualObjects(cell1.class, [IGTestCell class]);
    XCTAssertEqualObjects(cell2.class, [IGTestStoryboardCell class]);

    XCTAssertEqualObjects(cell1.label.text, @"nib");
    XCTAssertEqualObjects(cell2.label.text, @"storyboard");
}

- (void)test_whenForwardingDidScrollEvent_thatChildSectionControllersReceiveEvent {
    [self setupWithObjects:@[
                             [[IGTestObject alloc] initWithKey:@0 value:@[@1, @2, @3]],
                             [[IGTestObject alloc] initWithKey:@2 value:@[@1, @1]]
                             ]];

    id mockScrollDelegate = [OCMockObject mockForProtocol:@protocol(IGListScrollDelegate)];

    IGListStackedSectionController *stack0 = [self.adapter sectionControllerForObject:self.dataSource.objects[0]];
    IGListStackedSectionController *stack1 = [self.adapter sectionControllerForObject:self.dataSource.objects[1]];

    [stack0.sectionControllers[0] setScrollDelegate:mockScrollDelegate];
    [stack0.sectionControllers[1] setScrollDelegate:mockScrollDelegate];
    [stack0.sectionControllers[2] setScrollDelegate:mockScrollDelegate];
    [stack1.sectionControllers[0] setScrollDelegate:mockScrollDelegate];
    [stack1.sectionControllers[1] setScrollDelegate:mockScrollDelegate];

    [[mockScrollDelegate expect] listAdapter:self.adapter didScrollSectionController:stack0.sectionControllers[0]];
    [[mockScrollDelegate expect] listAdapter:self.adapter didScrollSectionController:stack0.sectionControllers[1]];
    [[mockScrollDelegate expect] listAdapter:self.adapter didScrollSectionController:stack0.sectionControllers[2]];
    [[mockScrollDelegate expect] listAdapter:self.adapter didScrollSectionController:stack1.sectionControllers[0]];
    [[mockScrollDelegate expect] listAdapter:self.adapter didScrollSectionController:stack1.sectionControllers[1]];

    [self.adapter scrollViewDidScroll:self.collectionView];

    [mockScrollDelegate verify];
}

- (void)test_whenForwardingWillBeginDraggingEvent_thatChildSectionControllersReceiveEvent {
    [self setupWithObjects:@[
                             [[IGTestObject alloc] initWithKey:@0 value:@[@1, @2, @3]],
                             [[IGTestObject alloc] initWithKey:@2 value:@[@1, @1]]
                             ]];

    id mockScrollDelegate = [OCMockObject mockForProtocol:@protocol(IGListScrollDelegate)];

    IGListStackedSectionController *stack0 = [self.adapter sectionControllerForObject:self.dataSource.objects[0]];
    IGListStackedSectionController *stack1 = [self.adapter sectionControllerForObject:self.dataSource.objects[1]];

    [stack0.sectionControllers[0] setScrollDelegate:mockScrollDelegate];
    [stack0.sectionControllers[1] setScrollDelegate:mockScrollDelegate];
    [stack0.sectionControllers[2] setScrollDelegate:mockScrollDelegate];
    [stack1.sectionControllers[0] setScrollDelegate:mockScrollDelegate];
    [stack1.sectionControllers[1] setScrollDelegate:mockScrollDelegate];

    [[mockScrollDelegate expect] listAdapter:self.adapter willBeginDraggingSectionController:stack0.sectionControllers[0]];
    [[mockScrollDelegate expect] listAdapter:self.adapter willBeginDraggingSectionController:stack0.sectionControllers[1]];
    [[mockScrollDelegate expect] listAdapter:self.adapter willBeginDraggingSectionController:stack0.sectionControllers[2]];
    [[mockScrollDelegate expect] listAdapter:self.adapter willBeginDraggingSectionController:stack1.sectionControllers[0]];
    [[mockScrollDelegate expect] listAdapter:self.adapter willBeginDraggingSectionController:stack1.sectionControllers[1]];

    [self.adapter scrollViewWillBeginDragging:self.collectionView];

    [mockScrollDelegate verify];
}

- (void)test_whenForwardingDidEndDraggingEvent_thatChildSectionControllersReceiveEvent {
    [self setupWithObjects:@[
                             [[IGTestObject alloc] initWithKey:@0 value:@[@1, @2, @3]],
                             [[IGTestObject alloc] initWithKey:@2 value:@[@1, @1]]
                             ]];

    id mockScrollDelegate = [OCMockObject mockForProtocol:@protocol(IGListScrollDelegate)];

    IGListStackedSectionController *stack0 = [self.adapter sectionControllerForObject:self.dataSource.objects[0]];
    IGListStackedSectionController *stack1 = [self.adapter sectionControllerForObject:self.dataSource.objects[1]];

    [stack0.sectionControllers[0] setScrollDelegate:mockScrollDelegate];
    [stack0.sectionControllers[1] setScrollDelegate:mockScrollDelegate];
    [stack0.sectionControllers[2] setScrollDelegate:mockScrollDelegate];
    [stack1.sectionControllers[0] setScrollDelegate:mockScrollDelegate];
    [stack1.sectionControllers[1] setScrollDelegate:mockScrollDelegate];

    [[mockScrollDelegate expect] listAdapter:self.adapter didEndDraggingSectionController:stack0.sectionControllers[0] willDecelerate:NO];
    [[mockScrollDelegate expect] listAdapter:self.adapter didEndDraggingSectionController:stack0.sectionControllers[1] willDecelerate:NO];
    [[mockScrollDelegate expect] listAdapter:self.adapter didEndDraggingSectionController:stack0.sectionControllers[2] willDecelerate:NO];
    [[mockScrollDelegate expect] listAdapter:self.adapter didEndDraggingSectionController:stack1.sectionControllers[0] willDecelerate:NO];
    [[mockScrollDelegate expect] listAdapter:self.adapter didEndDraggingSectionController:stack1.sectionControllers[1] willDecelerate:NO];

    [self.adapter scrollViewDidEndDragging:self.collectionView willDecelerate:NO];

    [mockScrollDelegate verify];
}

- (void)test_whenForwardingDidEndDeceleratingEvent_thatChildSectionControllersReceiveEvent {
    [self setupWithObjects:@[
                             [[IGTestObject alloc] initWithKey:@0 value:@[@1, @2, @3]],
                             [[IGTestObject alloc] initWithKey:@2 value:@[@1, @1]]
                             ]];

    id mockScrollDelegate = [OCMockObject mockForProtocol:@protocol(IGListScrollDelegate)];

    IGListStackedSectionController *stack0 = [self.adapter sectionControllerForObject:self.dataSource.objects[0]];
    IGListStackedSectionController *stack1 = [self.adapter sectionControllerForObject:self.dataSource.objects[1]];

    [stack0.sectionControllers[0] setScrollDelegate:mockScrollDelegate];
    [stack0.sectionControllers[1] setScrollDelegate:mockScrollDelegate];
    [stack0.sectionControllers[2] setScrollDelegate:mockScrollDelegate];
    [stack1.sectionControllers[0] setScrollDelegate:mockScrollDelegate];
    [stack1.sectionControllers[1] setScrollDelegate:mockScrollDelegate];

    [[mockScrollDelegate expect] listAdapter:self.adapter didEndDeceleratingSectionController:stack0.sectionControllers[0]];
    [[mockScrollDelegate expect] listAdapter:self.adapter didEndDeceleratingSectionController:stack0.sectionControllers[1]];
    [[mockScrollDelegate expect] listAdapter:self.adapter didEndDeceleratingSectionController:stack0.sectionControllers[2]];
    [[mockScrollDelegate expect] listAdapter:self.adapter didEndDeceleratingSectionController:stack1.sectionControllers[0]];
    [[mockScrollDelegate expect] listAdapter:self.adapter didEndDeceleratingSectionController:stack1.sectionControllers[1]];

    [self.adapter scrollViewDidEndDecelerating:self.collectionView];

    [mockScrollDelegate verify];
}

- (void)test_whenUsingSupplementary_withCode_thatSupplementaryViewExists {
    // updater that uses reloadData so we can rebuild all views/sizes
    IGListAdapter *adapter = [[IGListAdapter alloc] initWithUpdater:[IGListReloadDataUpdater new] viewController:nil];

    self.dataSource.objects = @[
                                [[IGTestObject alloc] initWithKey:@0 value:@[@1, @2, @3]],
                                [[IGTestObject alloc] initWithKey:@2 value:@[@1, @1]]
                                ];

    adapter.collectionView = self.collectionView;
    adapter.dataSource = self.dataSource;
    [self.collectionView layoutIfNeeded];

    IGListStackedSectionController *stack = [adapter sectionControllerForObject:self.dataSource.objects[1]];
    IGListTestSection *section = stack.sectionControllers.lastObject;

    IGTestSupplementarySource *supplementarySource = [IGTestSupplementarySource new];
    // the stack acts as the collection context. manually assign it.
    supplementarySource.collectionContext = stack;
    // however the actual section controller the supplementary serves is a child of the stack
    supplementarySource.sectionController = section;
    supplementarySource.supportedElementKinds = @[UICollectionElementKindSectionFooter];

    section.supplementaryViewSource = supplementarySource;

    [adapter performUpdatesAnimated:NO completion:nil];

    XCTAssertNotNil([self.collectionView supplementaryViewForElementKind:UICollectionElementKindSectionFooter
                                                             atIndexPath:[NSIndexPath indexPathForItem:0 inSection:1]]);
    XCTAssertNotNil(supplementarySource);
}

- (void)test_whenUsingSupplementary_withNib_thatSupplementaryViewExists {
    // updater that uses reloadData so we can rebuild all views/sizes
    IGListAdapter *adapter = [[IGListAdapter alloc] initWithUpdater:[IGListReloadDataUpdater new] viewController:nil];

    self.dataSource.objects = @[
                                [[IGTestObject alloc] initWithKey:@0 value:@[@1, @2, @3]],
                                [[IGTestObject alloc] initWithKey:@2 value:@[@1, @1]]
                                ];

    adapter.collectionView = self.collectionView;
    adapter.dataSource = self.dataSource;
    [self.collectionView layoutIfNeeded];

    IGListStackedSectionController *stack = [adapter sectionControllerForObject:self.dataSource.objects[1]];
    IGListTestSection *section = stack.sectionControllers.lastObject;

    IGTestSupplementarySource *supplementarySource = [IGTestSupplementarySource new];
    // the stack acts as the collection context. manually assign it.
    supplementarySource.collectionContext = stack;
    // however the actual section controller the supplementary serves is a child of the stack
    supplementarySource.sectionController = section;
    supplementarySource.supportedElementKinds = @[UICollectionElementKindSectionFooter];
    supplementarySource.dequeueFromNib = YES;

    section.supplementaryViewSource = supplementarySource;

    [adapter performUpdatesAnimated:NO completion:nil];

    XCTAssertNotNil([self.collectionView supplementaryViewForElementKind:UICollectionElementKindSectionFooter
                                                             atIndexPath:[NSIndexPath indexPathForItem:0 inSection:1]]);
    XCTAssertNotNil(supplementarySource);
}

- (void)test_whenUsingSupplementary_withStoryboard_thatSupplementaryViewExists {
    // updater that uses reloadData so we can rebuild all views/sizes
    IGListAdapter *adapter = [[IGListAdapter alloc] initWithUpdater:[IGListReloadDataUpdater new] viewController:nil];

    self.dataSource.objects = @[
                                [[IGTestObject alloc] initWithKey:@0 value:@[@1, @2, @3]],
                                [[IGTestObject alloc] initWithKey:@2 value:@[@1, @1]]
                                ];

    adapter.collectionView = self.collectionView;
    adapter.dataSource = self.dataSource;
    [self.collectionView layoutIfNeeded];

    IGListStackedSectionController *stack = [adapter sectionControllerForObject:self.dataSource.objects[1]];
    IGListTestSection *section = stack.sectionControllers.lastObject;

    IGTestStoryboardSupplementarySource *supplementarySource = [IGTestStoryboardSupplementarySource new];
    // the stack acts as the collection context. manually assign it.
    supplementarySource.collectionContext = stack;
    // however the actual section controller the supplementary serves is a child of the stack
    supplementarySource.sectionController = section;

    // the "section header" property of the parent collection view must be checked
    supplementarySource.supportedElementKinds = @[UICollectionElementKindSectionHeader];

    section.supplementaryViewSource = supplementarySource;

    [adapter performUpdatesAnimated:NO completion:nil];

    XCTAssertNotNil([self.collectionView supplementaryViewForElementKind:UICollectionElementKindSectionHeader
                                                             atIndexPath:[NSIndexPath indexPathForItem:0 inSection:1]]);
    XCTAssertNotNil(supplementarySource);
}

- (void)test_whenScrollingFromChildSectionController_thatScrollsToCorrectPosition {
    // pad with enough items that we can freely scroll to the middle without accounting for content size
    [self setupWithObjects:@[
                             [[IGTestObject alloc] initWithKey:@0 value:@[@4, @5, @6]],
                             [[IGTestObject alloc] initWithKey:@1 value:@[@1, @2, @3]],
                             [[IGTestObject alloc] initWithKey:@2 value:@[@4, @5, @6]]
                             ]];

    IGListStackedSectionController *stack = [self.adapter sectionControllerForObject:self.dataSource.objects[1]];
    IGListTestSection *section = stack.sectionControllers[1];

    [section.collectionContext scrollToSectionController:section atIndex:1 scrollPosition:UICollectionViewScrollPositionTop animated:NO];

    // IGListTestSection cells are 100x10
    XCTAssertEqual(self.collectionView.contentOffset.x, 0);
    XCTAssertEqual(self.collectionView.contentOffset.y, 170);
}

- (void)test_whenDeselectingChildSectionControllerIndex_thatCorrectCellDeselected {
    [self setupWithObjects:@[
                             [[IGTestObject alloc] initWithKey:@0 value:@[@1, @2, @3]],
                             [[IGTestObject alloc] initWithKey:@1 value:@[@1, @1]]
                             ]];

    NSIndexPath *path = [NSIndexPath indexPathForItem:1 inSection:1];
    [self.collectionView selectItemAtIndexPath:path animated:NO scrollPosition:UICollectionViewScrollPositionTop];
    XCTAssertTrue([[self.collectionView cellForItemAtIndexPath:path] isSelected]);

    IGListStackedSectionController *stack = [self.adapter sectionControllerForObject:self.dataSource.objects.lastObject];
    IGListSectionController *section = stack.sectionControllers.lastObject;
    [section.collectionContext deselectItemAtIndex:0 sectionController:section animated:NO];
    XCTAssertFalse([[self.collectionView cellForItemAtIndexPath:path] isSelected]);
}

- (void)test_whenSelectingChildSectionControllerIndex_thatCorrectCellSelected {
    [self setupWithObjects:@[
                             [[IGTestObject alloc] initWithKey:@0 value:@[@1, @2, @3]],
                             [[IGTestObject alloc] initWithKey:@1 value:@[@1, @1]]
                             ]];
    
    NSIndexPath *path = [NSIndexPath indexPathForItem:1 inSection:1];
    
    IGListStackedSectionController *stack = [self.adapter sectionControllerForObject:self.dataSource.objects.lastObject];
    IGListSectionController *section = stack.sectionControllers.lastObject;
    [section.collectionContext selectItemAtIndex:0 sectionController:section animated:NO scrollPosition:UICollectionViewScrollPositionTop];
    XCTAssertTrue([[self.collectionView cellForItemAtIndexPath:path] isSelected]);
}

- (void)test_whenRemovingSection_withWorkingRange_thatChildSectionControllersReceiveEvents {
    [self setupWithObjects:@[
                             [[IGTestObject alloc] initWithKey:@0 value:@[@1, @2, @3]],
                             [[IGTestObject alloc] initWithKey:@1 value:@[@1, @1]]
                             ]];

    IGListStackedSectionController *stack = [self.adapter sectionControllerForObject:self.dataSource.objects.firstObject];
    IGListTestSection *section = stack.sectionControllers.firstObject;

    id mockDelegate = [OCMockObject mockForProtocol:@protocol(IGListWorkingRangeDelegate)];
    [[mockDelegate expect] listAdapter:self.adapter sectionControllerDidExitWorkingRange:section];

    section.workingRangeDelegate = mockDelegate;

    self.dataSource.objects = @[
                                [[IGTestObject alloc] initWithKey:@1 value:@[@1, @1]],
                                ];

    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];

    [self.adapter performUpdatesAnimated:YES completion:^(BOOL finished) {
        [mockDelegate verify];
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)test_whenScrolling_withWorkingRange_thatChildSectionControllersReceiveEvents {
    [self setupWithObjects:@[
                             [[IGTestObject alloc] initWithKey:@0 value:@[@1, @2, @3]],
                             [[IGTestObject alloc] initWithKey:@1 value:@[@1, @2, @3]],
                             [[IGTestObject alloc] initWithKey:@2 value:@[@1, @2, @3]],
                             [[IGTestObject alloc] initWithKey:@3 value:@[@1, @2, @3]],
                             [[IGTestObject alloc] initWithKey:@4 value:@[@1, @1]]
                             ]];

    IGListStackedSectionController *stack = [self.adapter sectionControllerForObject:self.dataSource.objects.lastObject];
    IGListTestSection *section = stack.sectionControllers.firstObject;

    id mockDelegate = [OCMockObject mockForProtocol:@protocol(IGListWorkingRangeDelegate)];
    [[mockDelegate expect] listAdapter:self.adapter sectionControllerWillEnterWorkingRange:section];

    section.workingRangeDelegate = mockDelegate;

    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:4] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    [self.collectionView layoutIfNeeded];

    [mockDelegate verify];
}

- (void)test_whenRemovingCellsFromChild_thatStackSendsDisplayEventsCorrectly {
    IGTestObject *object = [[IGTestObject alloc] initWithKey:@0 value:@[@1, @2]];
    [self setupWithObjects:@[object]];

    IGListStackedSectionController *stack = [self.adapter sectionControllerForObject:object];
    IGListTestSection *section = stack.sectionControllers.lastObject;

    XCTAssertEqual([self.collectionView numberOfSections], 1);
    XCTAssertEqual([self.collectionView numberOfItemsInSection:0], 3);

    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [section.collectionContext performBatchAnimated:YES updates:^(id<IGListBatchContext> batchContext) {
        section.items = 1;
        [batchContext deleteInSectionController:section atIndexes:[NSIndexSet indexSetWithIndex:1]];
    } completion:^(BOOL finished) {
        XCTAssertEqual([self.collectionView numberOfSections], 1);
        XCTAssertEqual([self.collectionView numberOfItemsInSection:0], 2);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)test_whenMovingItemsInChild_thatCorrectCellsAreMoved {
    [self setupWithObjects:@[
                             [[IGTestObject alloc] initWithKey:@0 value:@[@1, @2, @3]],
                             [[IGTestObject alloc] initWithKey:@1 value:@[@1, @2, @3]],
                             [[IGTestObject alloc] initWithKey:@2 value:@[@1, @2, @3]],
                             ]];

    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:1]];
    cell.tag = 42;

    IGListStackedSectionController *stack = [self.adapter sectionControllerForObject:self.dataSource.objects[1]];
    IGListTestSection *section = stack.sectionControllers[1];

    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [section.collectionContext performBatchAnimated:YES updates:^(id<IGListBatchContext> batchContext) {
        [batchContext moveInSectionController:section fromIndex:1 toIndex:0];
    } completion:^(BOOL finished) {
        XCTAssertEqual([self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1]].tag, 0);
        XCTAssertEqual([self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:1]].tag, 42);
        XCTAssertEqual([self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:1]].tag, 0);

        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:30 handler:nil];
}

@end
