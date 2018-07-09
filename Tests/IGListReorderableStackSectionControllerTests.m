/**
 * Copyright (c) 2016-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import <IGListKit/IGListKit.h>
#import <IGListKit/IGListReloadDataUpdater.h>

#import "IGListAdapterInternal.h"
#import "IGListDisplayHandler.h"
#import "IGListStackedSectionControllerInternal.h"
#import "IGListTestAdapterStackedReorderingDataSource.h"
#import "IGListTestSection.h"
#import "IGListTestContainerSizeSection.h"
#import "IGTestCell.h"
#import "IGTestReorderableSection.h"
#import "IGTestStackedDataSource.h"
#import "IGTestStoryboardCell.h"
#import "IGTestStoryboardViewController.h"
#import "IGTestSupplementarySource.h"
#import "IGTestSupplementarySource.h"
#import "IGTestStoryboardSupplementarySource.h"
#import "IGListTestHelpers.h"

static const CGRect kStackTestFrame = (CGRect){{0.0, 0.0}, {100.0, 100.0}};

@interface IGListReorderableStackSectionControllerTests : XCTestCase

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) IGListAdapter *adapter;
@property (nonatomic, strong) IGListTestAdapterStackedReorderingDataSource *dataSource;

@end

@implementation IGListReorderableStackSectionControllerTests

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
}

- (void)tearDown {
    [super tearDown];

    self.adapter = nil;
    self.collectionView = nil;
    self.dataSource = nil;
}

- (void)setupWithObjects:(NSArray<IGTestObject *> *)objects numSections:(NSInteger)numSections {
    NSMutableArray<IGTestReorderableSectionObject *> *sectionObjects = [NSMutableArray new];
    NSMutableArray<IGTestReorderableSection *> *sections = [NSMutableArray new];

    for (NSInteger i=0; i<numSections; i++) {
        IGTestReorderableSectionObject *sectionObject = [IGTestReorderableSectionObject sectionWithObjects:objects];
        IGTestReorderableSection *section = [[IGTestReorderableSection alloc] initWithSectionObject:sectionObject];

        [sectionObjects addObject:sectionObject];
        [sections addObject:section];
    }

    self.dataSource = [[IGListTestAdapterStackedReorderingDataSource alloc] initWithSectionControllers:sections];
    self.adapter = [[IGListAdapter alloc] initWithUpdater:[IGListAdapterUpdater new] viewController:nil workingRangeSize:1];

    self.dataSource.objects = objects;
    self.adapter.collectionView = self.collectionView;
    self.adapter.dataSource = self.dataSource;
    self.adapter.moveDelegate = self.dataSource;
    [self.collectionView layoutIfNeeded];
}

#pragma mark - Base

- (void)test_whenSectionControllerReorderDisabled_thatAdapterReorderDisabled {
    BOOL isReorderable = NO;

    NSArray<IGTestObject *> *objects = @[[[IGTestObject alloc] initWithKey:@"0" value:@"0"],
                                         [[IGTestObject alloc] initWithKey:@"1" value:@"1"]];
    [self setupWithObjects:objects numSections:2];

    IGListStackedSectionController *stack = [self.adapter sectionControllerForObject:self.dataSource.objects[0]];
    IGTestReorderableSection *section = (IGTestReorderableSection *)stack.sectionControllers[0];
    section.isReorderable = isReorderable;

    [self.adapter performUpdatesAnimated:NO completion:nil];

    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];

    BOOL canMove = [self.adapter collectionView:self.collectionView canMoveItemAtIndexPath:indexPath];
    XCTAssertFalse(canMove);
}

- (void)test_whenSectionControllerReorderEnabled_thatAdapterReorderEnabled {
    BOOL isReorderable = YES;

    NSArray<IGTestObject *> *objects = @[[[IGTestObject alloc] initWithKey:@"0" value:@"0"],
                                         [[IGTestObject alloc] initWithKey:@"1" value:@"1"]];
    [self setupWithObjects:objects numSections:2];

    IGListStackedSectionController *stack = [self.adapter sectionControllerForObject:self.dataSource.objects[0]];
    IGTestReorderableSection *section = (IGTestReorderableSection *)stack.sectionControllers[0];
    section.isReorderable = isReorderable;

    [self.adapter performUpdatesAnimated:NO completion:nil];

    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];

    BOOL canMove = [self.adapter collectionView:self.collectionView canMoveItemAtIndexPath:indexPath];
    XCTAssertTrue(canMove);
}

- (void)test_whenSectionIsInteractivelyReordered_thatIndexesUpdateCorrectly {
    NSArray<IGTestObject *> *objects = @[[[IGTestObject alloc] initWithKey:@"0" value:@"0"]]; // one object per section

    [self setupWithObjects:objects numSections:3];

    [self.adapter performUpdatesAnimated:NO completion:nil];

    IGListStackedSectionController *stack = [self.adapter sectionControllerForObject:self.dataSource.objects[0]];
    IGTestReorderableSection *section0 = (IGTestReorderableSection *)stack.sectionControllers[0];
    section0.isReorderable = YES;
    IGTestReorderableSection *section1 = (IGTestReorderableSection *)stack.sectionControllers[1];
    section1.isReorderable = YES;
    IGTestReorderableSection *section2 = (IGTestReorderableSection *)stack.sectionControllers[2];
    section2.isReorderable = YES;

    NSIndexPath *fromIndexPath = [NSIndexPath indexPathForItem:2 inSection:0];
    NSIndexPath *toIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];

    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];

    [self.adapter performBatchAnimated:NO updates:^(id<IGListBatchContext> _Nonnull batchContext) {
        [self.adapter collectionView:self.collectionView moveItemAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
    } completion:^(BOOL finished) {
        XCTAssertEqual([stack sectionControllerForObjectIndex:0], section2);
        XCTAssertEqual([stack sectionControllerForObjectIndex:1], section0);
        XCTAssertEqual([stack sectionControllerForObjectIndex:2], section1);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)test_whenItemsInSectionAreInteractivelyReordered_thatIndexesUpdateCorrectly {
    // 3 objects in the section
    NSArray<IGTestObject *> *objects = @[[[IGTestObject alloc] initWithKey:@"0" value:@"0"],
                                         [[IGTestObject alloc] initWithKey:@"1" value:@"1"],
                                         [[IGTestObject alloc] initWithKey:@"2" value:@"2"]];

    [self setupWithObjects:objects numSections:1];

    [self.adapter performUpdatesAnimated:NO completion:nil];

    IGListStackedSectionController *stack = [self.adapter sectionControllerForObject:self.dataSource.objects[0]];
    IGTestReorderableSection *section = (IGTestReorderableSection *)stack.sectionControllers[0];
    section.isReorderable = YES;

    // move the last item into the first position
    NSIndexPath *fromIndexPath = [NSIndexPath indexPathForItem:2 inSection:0];
    NSIndexPath *toIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];

    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];

    [self.adapter performBatchAnimated:NO updates:^(id<IGListBatchContext> _Nonnull batchContext) {
        [self.adapter collectionView:self.collectionView moveItemAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
    } completion:^(BOOL finished) {
        XCTAssertEqual(section.sectionObject.objects[0], objects[2]);
        XCTAssertEqual(section.sectionObject.objects[1], objects[0]);
        XCTAssertEqual(section.sectionObject.objects[2], objects[1]);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)test_whenItemsAreInteractivelyReorderedAcrossSections_thatIndexesRevertToOriginalState {
    NSArray<IGTestObject *> *objects0 = @[[[IGTestObject alloc] initWithKey:@"0" value:@"0"],
                                          [[IGTestObject alloc] initWithKey:@"1" value:@"1"],
                                          [[IGTestObject alloc] initWithKey:@"2" value:@"2"]];
    IGTestReorderableSectionObject *section0Object = [IGTestReorderableSectionObject sectionWithObjects:objects0];
    IGTestReorderableSection *section0 = [[IGTestReorderableSection alloc] initWithSectionObject:section0Object];
    section0.isReorderable = YES;

    NSArray<IGTestObject *> *objects1 = @[[[IGTestObject alloc] initWithKey:@"3" value:@"3"],
                                          [[IGTestObject alloc] initWithKey:@"4" value:@"4"],
                                          [[IGTestObject alloc] initWithKey:@"5" value:@"5"]];
    IGTestReorderableSectionObject *section1Object = [IGTestReorderableSectionObject sectionWithObjects:objects1];
    IGTestReorderableSection *section1 = [[IGTestReorderableSection alloc] initWithSectionObject:section1Object];
    section1.isReorderable = YES;

    IGListTestAdapterStackedReorderingDataSource *dataSource =
    [[IGListTestAdapterStackedReorderingDataSource alloc] initWithSectionControllers:@[section0, section1]];

    IGListAdapter *adapter = [[IGListAdapter alloc] initWithUpdater:[IGListAdapterUpdater new]
                                                     viewController:nil
                                                   workingRangeSize:1];

    adapter.collectionView = self.collectionView;
    dataSource.objects = [objects0 arrayByAddingObjectsFromArray:objects1];
    adapter.dataSource = dataSource;
    adapter.moveDelegate = dataSource;
    [self.collectionView layoutIfNeeded];

    [adapter performUpdatesAnimated:NO completion:nil];

    NSIndexPath *fromIndexPath = [NSIndexPath indexPathForItem:2 inSection:0];
    NSIndexPath *toIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];

    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];

    // move an item from one sub-section to another, and check that they are reverted
    fromIndexPath = [NSIndexPath indexPathForItem:5 inSection:0];
    toIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];

    NSArray *originalSection0Objects = [section0.sectionObject.objects copy];
    NSArray *originalSection1Objects = [section1.sectionObject.objects copy];

    [self.collectionView performBatchUpdates:^{
        [self.collectionView moveItemAtIndexPath:fromIndexPath toIndexPath:toIndexPath];

        [self.collectionView.dataSource collectionView:self.collectionView
                                   moveItemAtIndexPath:fromIndexPath
                                           toIndexPath:toIndexPath];

    } completion:^(BOOL finished) {
        XCTAssertEqual(section0.sectionObject.objects[0], originalSection0Objects[0]);
        XCTAssertEqual(section0.sectionObject.objects[1], originalSection0Objects[1]);
        XCTAssertEqual(section0.sectionObject.objects[2], originalSection0Objects[2]);
        XCTAssertEqual(section1.sectionObject.objects[0], originalSection1Objects[0]);
        XCTAssertEqual(section1.sectionObject.objects[1], originalSection1Objects[1]);
        XCTAssertEqual(section1.sectionObject.objects[2], originalSection1Objects[2]);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:30 handler:nil];
}

@end
