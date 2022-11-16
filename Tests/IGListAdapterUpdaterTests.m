/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>

#import <IGListKit/IGListKit.h>

#import "IGListAdapterUpdaterHelpers.h"
#import "IGListAdapterUpdaterInternal.h"
#import "IGListMoveIndexInternal.h"
#import "IGListTestUICollectionViewDataSource.h"
#import "IGListTransitionData.h"
#import "IGTestObject.h"

#define genExpectation [self expectationWithDescription:NSStringFromSelector(_cmd)]
#define waitExpectation [self waitForExpectationsWithTimeout:30 handler:nil]
#define genToBlock ^NSArray *{ return to; }

@interface IGListAdapterUpdaterTests : XCTestCase

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) IGListTestUICollectionViewDataSource *dataSource;
@property (nonatomic, strong) IGListAdapterUpdater *updater;
@property (nonatomic, strong) IGListTransitionDataApplyBlock applySectionDataBlock;

@end

@implementation IGListAdapterUpdaterTests

- (IGListCollectionViewBlock)collectionViewBlock {
    return ^UICollectionView *{ return self.collectionView; };
}

- (IGListTransitionDataBlock)dataBlockFromObjects:(NSArray *)fromObjects toObjects:(NSArray *)toObjects {
    return ^IGListTransitionData *{
        return [[IGListTransitionData alloc] initFromObjects:fromObjects toObjects:toObjects toSectionControllers:@[]];
    };
}

- (void)setUp {
    [super setUp];

    self.window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.window.frame collectionViewLayout:layout];

    [self.window addSubview:self.collectionView];

    self.dataSource = [[IGListTestUICollectionViewDataSource alloc] initWithCollectionView:self.collectionView];
    self.updater = [IGListAdapterUpdater new];
    __weak __typeof__(self) weakSelf = self;
    self.applySectionDataBlock = ^(IGListTransitionData *data) {
        weakSelf.dataSource.sections = data.toObjects;
    };
}

- (void)tearDown {
    [super tearDown];

    self.collectionView = nil;
    self.dataSource = nil;
    self.updater = nil;
}

- (void)test_whenUpdatingtoObjects_thatUpdaterHasChanges {
    [self.updater performUpdateWithCollectionViewBlock:[self collectionViewBlock]
                                              animated:YES
                                      sectionDataBlock:[self dataBlockFromObjects:@[] toObjects:@[@0]]
                                 applySectionDataBlock:self.applySectionDataBlock
                                            completion:nil];
    XCTAssertTrue([self.updater hasChanges]);
}

- (void)test_whenUpdatingfromObjects_thatUpdaterHasChanges {
    [self.updater performUpdateWithCollectionViewBlock:[self collectionViewBlock]
                                              animated:YES
                                      sectionDataBlock:[self dataBlockFromObjects:@[@0] toObjects:@[]]
                                 applySectionDataBlock:self.applySectionDataBlock
                                            completion:nil];
    XCTAssertTrue([self.updater hasChanges]);
}

- (void)test_whenUpdatingtoObjects_withfromObjects_thatUpdaterHasChanges {
    [self.updater performUpdateWithCollectionViewBlock:[self collectionViewBlock]
                                              animated:YES
                                      sectionDataBlock:[self dataBlockFromObjects:@[@0] toObjects:@[@1]]
                                 applySectionDataBlock:self.applySectionDataBlock
                                            completion:nil];
    XCTAssertTrue([self.updater hasChanges]);
}

- (void)test_whenReloadingData_thatCollectionViewUpdates {
    self.dataSource.sections = @[[IGSectionObject sectionWithObjects:@[]]];
    [self.updater reloadDataWithCollectionViewBlock:[self collectionViewBlock] reloadUpdateBlock:^{} completion:nil];
    [self.updater update];
    XCTAssertEqual([self.collectionView numberOfSections], 1);
    self.dataSource.sections = @[];
    [self.updater reloadDataWithCollectionViewBlock:[self collectionViewBlock] reloadUpdateBlock:^{} completion:nil];
    [self.updater update];
    XCTAssertEqual([self.collectionView numberOfSections], 0);
}

- (void)test_whenReloadingDataWithNilDataSourceBefore_thatCollectionViewNotCrash {
    self.dataSource.sections = @[[IGSectionObject sectionWithObjects:@[@1]], [IGSectionObject sectionWithObjects:@[@2]]];
    [self.updater reloadDataWithCollectionViewBlock:[self collectionViewBlock] reloadUpdateBlock:^{} completion:nil];
    [self.updater update];
    XCTAssertEqual([self.collectionView numberOfSections], 2);

    self.collectionView.dataSource = nil;
    self.dataSource.sections = @[];
    [self.updater reloadDataWithCollectionViewBlock:[self collectionViewBlock] reloadUpdateBlock:^{} completion:nil];
    [self.updater update];
    XCTAssertEqual([self.collectionView numberOfSections], 1); // Setting collectionView's dataSource to nil would yield a single section by default.
}

- (void)test_whenInsertingSection_thatCollectionViewUpdates {
    NSArray *from = @[
        [IGSectionObject sectionWithObjects:@[]]
    ];
    NSArray *to = @[
        [IGSectionObject sectionWithObjects:@[]],
        [IGSectionObject sectionWithObjects:@[]]
    ];

    self.dataSource.sections = from;
    [self.updater reloadDataWithCollectionViewBlock:[self collectionViewBlock] reloadUpdateBlock:^{} completion:nil];
    [self.updater update];
    XCTAssertEqual([self.collectionView numberOfSections], 1);

    XCTestExpectation *expectation = genExpectation;
    [self.updater performUpdateWithCollectionViewBlock:[self collectionViewBlock]
                                              animated:YES
                                      sectionDataBlock:[self dataBlockFromObjects:from toObjects:to]
                                 applySectionDataBlock:self.applySectionDataBlock
                                            completion:^(BOOL finished) {
        XCTAssertEqual([self.collectionView numberOfSections], 2);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)test_whenDeletingSection_thatCollectionViewUpdates {
    NSArray *from = @[
        [IGSectionObject sectionWithObjects:@[]],
        [IGSectionObject sectionWithObjects:@[]]
    ];
    NSArray *to = @[
        [IGSectionObject sectionWithObjects:@[]]
    ];

    self.dataSource.sections = from;
    [self.updater reloadDataWithCollectionViewBlock:[self collectionViewBlock] reloadUpdateBlock:^{} completion:nil];
    [self.updater update];
    XCTAssertEqual([self.collectionView numberOfSections], 2);

    XCTestExpectation *expectation = genExpectation;
    [self.updater performUpdateWithCollectionViewBlock:[self collectionViewBlock]
                                              animated:YES
                                      sectionDataBlock:[self dataBlockFromObjects:from toObjects:to]
                                 applySectionDataBlock:self.applySectionDataBlock
                                            completion:^(BOOL finished) {
        XCTAssertEqual([self.collectionView numberOfSections], 1);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)test_whenInsertingSection_withItemChanges_thatCollectionViewUpdates {
    NSArray *from = @[
        [IGSectionObject sectionWithObjects:@[@0]]
    ];
    NSArray *to = @[
        [IGSectionObject sectionWithObjects:@[@0, @1]],
        [IGSectionObject sectionWithObjects:@[@0, @1]]
    ];

    self.dataSource.sections = from;
    [self.updater reloadDataWithCollectionViewBlock:[self collectionViewBlock] reloadUpdateBlock:^{} completion:nil];
    [self.updater update];
    XCTAssertEqual([self.collectionView numberOfSections], 1);
    XCTAssertEqual([self.collectionView numberOfItemsInSection:0], 1);

    XCTestExpectation *expectation = genExpectation;
    [self.updater performUpdateWithCollectionViewBlock:[self collectionViewBlock]
                                              animated:YES
                                      sectionDataBlock:[self dataBlockFromObjects:from toObjects:to]
                                 applySectionDataBlock:self.applySectionDataBlock
                                            completion:^(BOOL finished) {
        XCTAssertEqual([self.collectionView numberOfSections], 2);
        XCTAssertEqual([self.collectionView numberOfItemsInSection:0], 2);
        XCTAssertEqual([self.collectionView numberOfItemsInSection:1], 2);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)test_whenInsertingSection_withDeletedSection_thatCollectionViewUpdates {
    NSArray *from = @[
        [IGSectionObject sectionWithObjects:@[@0, @1, @2]],
        [IGSectionObject sectionWithObjects:@[]]
    ];
    NSArray *to = @[
        [IGSectionObject sectionWithObjects:@[@1, @1]],
        [IGSectionObject sectionWithObjects:@[@0]],
        [IGSectionObject sectionWithObjects:@[@0, @2, @3]]
    ];

    self.dataSource.sections = from;
    [self.updater reloadDataWithCollectionViewBlock:[self collectionViewBlock] reloadUpdateBlock:^{} completion:nil];
    [self.updater update];

    XCTAssertEqual([self.collectionView numberOfSections], 2);
    XCTAssertEqual([self.collectionView numberOfItemsInSection:0], 3);

    XCTestExpectation *expectation = genExpectation;
    [self.updater performUpdateWithCollectionViewBlock:[self collectionViewBlock]
                                              animated:NO
                                      sectionDataBlock:[self dataBlockFromObjects:from toObjects:to]
                                 applySectionDataBlock:self.applySectionDataBlock
                                            completion:^(BOOL finished) {
        XCTAssertEqual([self.collectionView numberOfSections], 3);
        XCTAssertEqual([self.collectionView numberOfItemsInSection:0], 2);
        XCTAssertEqual([self.collectionView numberOfItemsInSection:1], 1);
        XCTAssertEqual([self.collectionView numberOfItemsInSection:2], 3);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)test_whenReloadingSections_thatCollectionViewUpdates {
    self.dataSource.sections = @[
        [IGSectionObject sectionWithObjects:@[@0, @1]],
        [IGSectionObject sectionWithObjects:@[@0, @1]]
    ];
    [self.updater reloadDataWithCollectionViewBlock:[self collectionViewBlock] reloadUpdateBlock:^{} completion:nil];
    [self.updater update];
    XCTAssertEqual([self.collectionView numberOfSections], 2);
    XCTAssertEqual([self.collectionView numberOfItemsInSection:0], 2);
    XCTAssertEqual([self.collectionView numberOfItemsInSection:1], 2);

    self.dataSource.sections = @[
        [IGSectionObject sectionWithObjects:@[@0, @1, @2]],
        [IGSectionObject sectionWithObjects:@[@0, @1]]
    ];
    [self.updater reloadCollectionView:self.collectionView sections:[NSIndexSet indexSetWithIndex:0]];

    XCTAssertEqual([self.collectionView numberOfSections], 2);
    XCTAssertEqual([self.collectionView numberOfItemsInSection:0], 3);
    XCTAssertEqual([self.collectionView numberOfItemsInSection:1], 2);
}

- (void)test_whenCollectionViewNeedsLayout_thatPerformBatchUpdateWorks {
    NSArray *from = @[
        [IGSectionObject sectionWithObjects:@[]],
        [IGSectionObject sectionWithObjects:@[]]
    ];
    NSArray *to = @[
        [IGSectionObject sectionWithObjects:@[]]
    ];

    self.dataSource.sections = from;
    [self.updater reloadDataWithCollectionViewBlock:[self collectionViewBlock] reloadUpdateBlock:^{} completion:nil];
    [self.updater update];

    // the collection view has been setup with 1 section and now needs layout
    // calling performBatchUpdates: on a collection view needing layout will force layout
    // we need to ensure that our data source is not changed until the update block is executed
    [self.collectionView setNeedsLayout];

    XCTestExpectation *expectation = genExpectation;
    [self.updater performUpdateWithCollectionViewBlock:[self collectionViewBlock]
                                              animated:NO
                                      sectionDataBlock:[self dataBlockFromObjects:from toObjects:to]
                                 applySectionDataBlock:self.applySectionDataBlock
                                            completion:^(BOOL finished) {
        XCTAssertEqual([self.collectionView numberOfSections], 1);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)test_whenUpdatesAreReentrant_thatUpdatesExecuteSerially {
    NSArray *from = @[
        [IGSectionObject sectionWithObjects:@[]],
    ];
    NSArray *to = @[
        [IGSectionObject sectionWithObjects:@[]],
        [IGSectionObject sectionWithObjects:@[]],
    ];

    self.dataSource.sections = from;
    [self.updater reloadDataWithCollectionViewBlock:[self collectionViewBlock] reloadUpdateBlock:^{} completion:nil];
    [self.updater update];

    __block NSInteger completionCounter = 0;

    XCTestExpectation *expectation1 = genExpectation;
    void (^preUpdateBlock)(void) = ^{
        NSArray *anotherTo = @[
            [IGSectionObject sectionWithObjects:@[]],
            [IGSectionObject sectionWithObjects:@[]],
            [IGSectionObject sectionWithObjects:@[]]
        ];
        [self.updater performUpdateWithCollectionViewBlock:[self collectionViewBlock]
                                                  animated:YES
                                          sectionDataBlock:[self dataBlockFromObjects:to toObjects:anotherTo]
                                     applySectionDataBlock:self.applySectionDataBlock
                                                completion:^(BOOL finished) {
            completionCounter++;
            XCTAssertEqual([self.collectionView numberOfSections], 3);
            XCTAssertEqual(completionCounter, 2);
            [expectation1 fulfill];
        }];
    };

    XCTestExpectation *expectation2 = genExpectation;
    [self.updater performUpdateWithCollectionViewBlock:[self collectionViewBlock]
                                              animated:YES
                                      sectionDataBlock:[self dataBlockFromObjects:from toObjects:to]
                                 applySectionDataBlock:^(IGListTransitionData *data) {
        // executing this block within the updater is just before performBatchUpdates: are applied
        // should be able to queue another update here, similar to an update being queued between it beginning and executing
        // the performBatchUpdates: block
        preUpdateBlock();

        self.dataSource.sections = data.toObjects;
    }
                                            completion:^(BOOL finished) {
        completionCounter++;
        XCTAssertEqual([self.collectionView numberOfSections], 2);
        XCTAssertEqual(completionCounter, 1);
        [expectation2 fulfill];
    }];
    [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)test_whenQueuingItemUpdates_thatUpdaterHasChanges {
    [self.updater performUpdateWithCollectionViewBlock:[self collectionViewBlock] animated:YES itemUpdates:^{} completion:nil];
    XCTAssertTrue([self.updater hasChanges]);
}

- (void)test_whenOnlyQueueingItemUpdates_thatUpdateBlockExecutes {
    XCTestExpectation *expectation = genExpectation;
    [self.updater performUpdateWithCollectionViewBlock:[self collectionViewBlock] animated:YES itemUpdates:^{
        // expectation should be triggered. test failure is a timeout
        [expectation fulfill];
    } completion:nil];
    [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)test_whenQueueingItemUpdates_withBatchUpdate_thatItemUpdateBlockExecutes {
    __block BOOL itemUpdateBlockExecuted = NO;
    __block BOOL sectionUpdateBlockExecuted = NO;

    [self.updater performUpdateWithCollectionViewBlock:[self collectionViewBlock]
                                              animated:YES
                                      sectionDataBlock:[self dataBlockFromObjects:@[] toObjects:@[[IGSectionObject sectionWithObjects:@[@1]]]]
                                 applySectionDataBlock:^(IGListTransitionData * data) {
        self.dataSource.sections = data.toObjects;
        sectionUpdateBlockExecuted = YES;
    }
                                            completion:nil];

    XCTestExpectation *expectation = genExpectation;
    [self.updater performUpdateWithCollectionViewBlock:[self collectionViewBlock] animated:YES itemUpdates:^{
        itemUpdateBlockExecuted = YES;
    } completion:^(BOOL finished) {
        // test in the item completion block that the SECTION operations have been performed
        XCTAssertEqual([self.collectionView numberOfSections], 1);
        XCTAssertEqual([self.collectionView numberOfItemsInSection:0], 1);
        XCTAssertTrue(itemUpdateBlockExecuted);
        XCTAssertTrue(sectionUpdateBlockExecuted);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)test_whenItemsMoveAndUpdate_thatCollectionViewWorks {
    NSArray<IGSectionObject *> *from = @[
        [IGSectionObject sectionWithObjects:@[]],
        [IGSectionObject sectionWithObjects:@[]],
        [IGSectionObject sectionWithObjects:@[]],
    ];

    // change the number of items in the section, which a move would be unable to handle and would throw
    // keep the same pointers so that the objects are equal
    [from[2] setObjects:@[@1]];
    [from[0] setObjects:@[@1, @1]];
    [from[1] setObjects:@[@1, @1, @1]];

    NSArray *to = @[
        from[2],
        from[0],
        from[1]
    ];

    self.dataSource.sections = from;
    [self.updater reloadDataWithCollectionViewBlock:[self collectionViewBlock] reloadUpdateBlock:^{} completion:nil];
    [self.updater update];

    // without moves as inserts, we would assert b/c the # of items in each section changes
    self.updater.sectionMovesAsDeletesInserts = YES;

    XCTestExpectation *expectation = genExpectation;
    [self.updater performUpdateWithCollectionViewBlock:[self collectionViewBlock]
                                              animated:YES
                                      sectionDataBlock:[self dataBlockFromObjects:from toObjects:to]
                                 applySectionDataBlock:self.applySectionDataBlock
                                            completion:^(BOOL finished) {
        XCTAssertEqual([self.collectionView numberOfSections], 3);
        XCTAssertEqual([self.collectionView numberOfItemsInSection:0], 1);
        XCTAssertEqual([self.collectionView numberOfItemsInSection:1], 2);
        XCTAssertEqual([self.collectionView numberOfItemsInSection:2], 3);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)test_whenConvertingReloads_withoutChanges_thatOriginalIndexUsed {
    NSArray *from = @[];
    NSArray *to = @[];
    IGListIndexSetResult *result = IGListDiff(from, to, IGListDiffEquality);
    NSMutableIndexSet *reloads = [result.updates mutableCopy];
    [reloads addIndex:2];
    NSMutableIndexSet *deletes = [result.deletes mutableCopy];
    NSMutableIndexSet *inserts = [result.inserts mutableCopy];
    IGListConvertReloadToDeleteInsert(reloads, deletes, inserts, result, from);
    XCTAssertEqual(reloads.count, 0);
    XCTAssertEqual(deletes.count, 1);
    XCTAssertEqual(inserts.count, 1);
    XCTAssertTrue([deletes containsIndex:2]);
    XCTAssertTrue([inserts containsIndex:2]);
}

- (void)test_whenConvertingReloads_withChanges_thatIndexMoves {
    NSArray *from = @[@1, @2, @3];
    NSArray *to = @[@3, @2, @1];
    IGListIndexSetResult *result = IGListDiff(from, to, IGListDiffEquality);
    NSMutableIndexSet *reloads = [result.updates mutableCopy];
    [reloads addIndex:2];
    NSMutableIndexSet *deletes = [result.deletes mutableCopy];
    NSMutableIndexSet *inserts = [result.inserts mutableCopy];
    IGListConvertReloadToDeleteInsert(reloads, deletes, inserts, result, from);
    XCTAssertEqual(reloads.count, 0);
    XCTAssertEqual(deletes.count, 1);
    XCTAssertEqual(inserts.count, 1);
    XCTAssertTrue([deletes containsIndex:2]);
    XCTAssertTrue([inserts containsIndex:0]);
}

- (void)test_whenReloadingSection_whenSectionRemoved_thatConvertMethodCorrects {
    NSArray *from = @[@"a", @"b", @"c"];
    NSArray *to = @[@"a", @"c"];
    IGListIndexSetResult *result = IGListDiff(from, to, IGListDiffEquality);
    NSMutableIndexSet *reloads = [NSMutableIndexSet indexSetWithIndex:1];
    NSMutableIndexSet *deletes = [NSMutableIndexSet new];
    NSMutableIndexSet *inserts = [NSMutableIndexSet new];
    IGListConvertReloadToDeleteInsert(reloads, deletes, inserts, result, from);
    XCTAssertEqual(reloads.count, 0);
    XCTAssertEqual(deletes.count, 0);
    XCTAssertEqual(inserts.count, 0);
}

- (void)test_whenReloadingData_withNilCollectionView_thatDelegateFinishesWithoutUpdates {
    id mockDelegate = [OCMockObject mockForProtocol:@protocol(IGListAdapterUpdaterDelegate)];
    self.updater.delegate = mockDelegate;
    id compilerFriendlyNil = nil;
    [[mockDelegate expect] listAdapterUpdater:self.updater didFinishWithoutUpdatesWithCollectionView:nil];
    [self.updater reloadDataWithCollectionViewBlock:^UICollectionView *{ return compilerFriendlyNil; } reloadUpdateBlock:^{} completion:nil];
    [self.updater update];
    [mockDelegate verify];
}

- (void)test_whenPerformingUpdates_withNilCollectionView_thatDelegateFinishesWithoutUpdates {
    id mockDelegate = [OCMockObject mockForProtocol:@protocol(IGListAdapterUpdaterDelegate)];
    self.updater.delegate = mockDelegate;
    id compilerFriendlyNil = nil;
    [[mockDelegate expect] listAdapterUpdater:self.updater didFinishWithoutUpdatesWithCollectionView:nil];
    [self.updater reloadDataWithCollectionViewBlock:^UICollectionView *{ return compilerFriendlyNil; } reloadUpdateBlock:^{} completion:nil];
    [self.updater update];
    [mockDelegate verify];
}

- (void)test_whenCallingReloadData_withUICollectionViewFlowLayout_withEstimatedSize_thatSectionItemCountsCorrect {
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    // setting the estimated size of a layout causes UICollectionView to requery layout attributes during reloadData
    // this becomes out of sync with the data source if the section/item count changes
    layout.estimatedItemSize = CGSizeMake(100, 10);

    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 100, 100) collectionViewLayout:layout];
    IGListTestUICollectionViewDataSource *dataSource = [[IGListTestUICollectionViewDataSource alloc] initWithCollectionView:collectionView];

    // 2 sections, 1 item in 1st, 4 items in 2nd
    dataSource.sections = @[
        [IGSectionObject sectionWithObjects:@[@1]],
        [IGSectionObject sectionWithObjects:@[@1, @2, @3, @4]]
    ];

    // assert the initial state of the collection view WITHOUT any layoutSubviews or anything
    XCTAssertEqual([collectionView numberOfSections], 2);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], 1);
    XCTAssertEqual([collectionView numberOfItemsInSection:1], 4);

    dataSource.sections = @[
        [IGSectionObject sectionWithObjects:@[@1]],
    ];

    IGListAdapterUpdater *updater = [IGListAdapterUpdater new];
    [updater reloadDataWithCollectionViewBlock:^UICollectionView *{ return collectionView; } reloadUpdateBlock:^{} completion:nil];
    [updater update];

    XCTAssertEqual([collectionView numberOfSections], 1);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], 1);

    dataSource.sections = @[
        [IGSectionObject sectionWithObjects:@[@1]],
        [IGSectionObject sectionWithObjects:@[@1, @2, @3, @4]]
    ];
    [updater reloadDataWithCollectionViewBlock:^UICollectionView *{ return collectionView; } reloadUpdateBlock:^{} completion:nil];
    [updater update];

    XCTAssertEqual([collectionView numberOfSections], 2);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], 1);
    XCTAssertEqual([collectionView numberOfItemsInSection:1], 4);
}

- (void)test_whenCollectionViewNotInWindow_andBackgroundReloadFlag_isSetNO_diffHappens {
    [self.collectionView removeFromSuperview];

    id mockDelegate = [OCMockObject niceMockForProtocol:@protocol(IGListAdapterUpdaterDelegate)];
    self.updater.delegate = mockDelegate;
    [mockDelegate setExpectationOrderMatters:YES];
    NSArray<IGSectionObject *> *to = @[[IGSectionObject sectionWithObjects:@[]]];
    [[mockDelegate expect] listAdapterUpdater:self.updater willPerformBatchUpdatesWithCollectionView:self.collectionView fromObjects:self.dataSource.sections toObjects:to listIndexSetResult:[OCMArg checkWithBlock:^BOOL(IGListIndexSetResult *result) {
        return result.inserts.firstIndex == 0 && result.moves.count == 0 && result.updates.count == 0 && result.deletes.count == 0;
    }] animated:NO];
    [[mockDelegate expect] listAdapterUpdater:self.updater didPerformBatchUpdates:OCMOCK_ANY collectionView:self.collectionView];

    XCTestExpectation *expectation = genExpectation;
    [self.updater performUpdateWithCollectionViewBlock:[self collectionViewBlock]
                                              animated:NO
                                      sectionDataBlock:[self dataBlockFromObjects:self.dataSource.sections toObjects:to]
                                 applySectionDataBlock:self.applySectionDataBlock
                                            completion:^(BOOL finished) {
        [expectation fulfill];
    }];
    waitExpectation;
    [mockDelegate verify];
}

- (void)test_whenReloadBatchedWithUpdate_thatCompletionBlockStillExecuted {
    IGSectionObject *object = [IGSectionObject sectionWithObjects:@[@0, @1, @2]];
    self.dataSource.sections = @[object];

    __block BOOL reloadDataCompletionExecuted = NO;
    [self.updater reloadDataWithCollectionViewBlock:[self collectionViewBlock] reloadUpdateBlock:^{} completion:^(BOOL finished) {
        reloadDataCompletionExecuted = YES;
    }];

    XCTestExpectation *expectation = genExpectation;
    [self.updater performUpdateWithCollectionViewBlock:[self collectionViewBlock]
                                              animated:YES itemUpdates:^{
        object.objects = @[@2, @1, @4, @5];
        [self.updater insertItemsIntoCollectionView:self.collectionView indexPaths:@[
            [NSIndexPath indexPathForItem:2 inSection:0],
            [NSIndexPath indexPathForItem:3 inSection:0],
        ]];
        [self.updater deleteItemsFromCollectionView:self.collectionView indexPaths:@[
            [NSIndexPath indexPathForItem:0 inSection:0],
        ]];
        [self.updater moveItemInCollectionView:self.collectionView
                                 fromIndexPath:[NSIndexPath indexPathForItem:2 inSection:0]
                                   toIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    } completion:^(BOOL finished) {
        XCTAssertTrue(reloadDataCompletionExecuted);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)test_whenPerformingItemUpdateInMiddleOfReload_thatCompletionBlockStillExecuted {
    IGSectionObject *object = [IGSectionObject sectionWithObjects:@[@0, @1, @2]];
    self.dataSource.sections = @[object];

    XCTestExpectation *expectation = genExpectation;

    // Section-controllers can schedule item updates in -didUpdateToObject, so lets make sure the completion block works.
    IGListReloadUpdateBlock reloadUpdateBlock = ^{
        [self.updater performUpdateWithCollectionViewBlock:[self collectionViewBlock]
                                                  animated:YES
                                               itemUpdates:^{}
                                                completion:^(BOOL finished) {
            [expectation fulfill];
        }];
    };

    [self.updater reloadDataWithCollectionViewBlock:[self collectionViewBlock]
                                  reloadUpdateBlock:reloadUpdateBlock
                                         completion:nil];

    [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)test_whenPerformingItemUpdateInMiddleOfUpdate_thatCompletionBlockStillExecuted {
    IGSectionObject *object = [IGSectionObject sectionWithObjects:@[@0, @1, @2]];
    self.dataSource.sections = @[object];

    XCTestExpectation *expectation = genExpectation;

    // Section-controllers can schedule item updates in -didUpdateToObject, so lets make sure the completion block works.
    void (^updateItemBlock)(void) = ^{
        [self.updater performUpdateWithCollectionViewBlock:[self collectionViewBlock]
                                                  animated:YES
                                               itemUpdates:^{}
                                                completion:^(BOOL finished) {
            [expectation fulfill];
        }];
    };

    [self.updater performUpdateWithCollectionViewBlock:[self collectionViewBlock]
                                              animated:NO
                                      sectionDataBlock:[self dataBlockFromObjects:self.dataSource.sections toObjects:self.dataSource.sections]
                                 applySectionDataBlock:^(IGListTransitionData * _Nonnull data) {
        updateItemBlock();
    }
                                            completion:nil];

    [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)test_whenNotInViewHierarchy_thatUpdatesStillExecuteBlocks {
    [self.collectionView removeFromSuperview];

    IGSectionObject *object = [IGSectionObject sectionWithObjects:@[@0, @1, @2]];
    self.dataSource.sections = @[object];

    __block BOOL objectTransitionBlockExecuted = NO;
    __block BOOL completionBlockExecuted = NO;
    [self.updater performUpdateWithCollectionViewBlock:[self collectionViewBlock]
                                              animated:YES
                                      sectionDataBlock:[self dataBlockFromObjects:self.dataSource.sections toObjects:self.dataSource.sections]
                                 applySectionDataBlock:^(IGListTransitionData *data) {
        objectTransitionBlockExecuted = YES;
    }
                                            completion:^(BOOL finished) {
        completionBlockExecuted = YES;
    }];

    XCTestExpectation *expectation = genExpectation;
    [self.updater performUpdateWithCollectionViewBlock:[self collectionViewBlock] animated:YES itemUpdates:^{
        object.objects = @[@2, @1, @4, @5];
        [self.updater insertItemsIntoCollectionView:self.collectionView indexPaths:@[
            [NSIndexPath indexPathForItem:2 inSection:0],
            [NSIndexPath indexPathForItem:3 inSection:0],
        ]];
        [self.updater deleteItemsFromCollectionView:self.collectionView indexPaths:@[
            [NSIndexPath indexPathForItem:0 inSection:0],
        ]];
        [self.updater moveItemInCollectionView:self.collectionView
                                 fromIndexPath:[NSIndexPath indexPathForItem:2 inSection:0]
                                   toIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    } completion:^(BOOL finished) {
        XCTAssertTrue(objectTransitionBlockExecuted);
        XCTAssertTrue(completionBlockExecuted);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)test_whenNotBatchUpdate_thatDelegateEventsSent {
    IGSectionObject *object = [IGSectionObject sectionWithObjects:@[@0, @1, @2]];
    self.dataSource.sections = @[object];
    [self.collectionView reloadData];

    id mockDelegate = [OCMockObject niceMockForProtocol:@protocol(IGListAdapterUpdaterDelegate)];
    self.updater.delegate = mockDelegate;
    [mockDelegate setExpectationOrderMatters:YES];
    [[mockDelegate expect] listAdapterUpdater:self.updater willDeleteIndexPaths:OCMOCK_ANY collectionView:self.collectionView];
    [[mockDelegate expect] listAdapterUpdater:self.updater willInsertIndexPaths:OCMOCK_ANY collectionView:self.collectionView];
    [[mockDelegate expect] listAdapterUpdater:self.updater
                        willMoveFromIndexPath:OCMOCK_ANY
                                  toIndexPath:OCMOCK_ANY
                               collectionView:self.collectionView];
    [[mockDelegate expect] listAdapterUpdater:self.updater willReloadIndexPaths:OCMOCK_ANY collectionView:self.collectionView];

    // This code is of no use, but it will let UICollectionView synchronize number of items,
    // so it will not crash in following updates. https://stackoverflow.com/a/46751421/2977647
    [self.collectionView numberOfItemsInSection:0];

    object.objects = @[@1, @2];
    [self.updater deleteItemsFromCollectionView:self.collectionView indexPaths:@[
        [NSIndexPath indexPathForItem:0 inSection:0],
    ]];
    object.objects = @[@1, @2, @4, @5];
    [self.updater insertItemsIntoCollectionView:self.collectionView indexPaths:@[
        [NSIndexPath indexPathForItem:2 inSection:0],
        [NSIndexPath indexPathForItem:3 inSection:0],
    ]];
    object.objects = @[@2, @1, @4, @5];
    [self.updater moveItemInCollectionView:self.collectionView
                             fromIndexPath:[NSIndexPath indexPathForItem:2 inSection:0]
                               toIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];

    [self.updater reloadItemInCollectionView:self.collectionView
                               fromIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]
                                 toIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    [mockDelegate verify];
}

- (void)test_whenObjectIdentifiersCollide_withDifferentTypes_thatLookupReturnsNil {
    id testObject = [[IGTestObject alloc] initWithKey:@"foo" value:@"bar"];
    id collision = @"foo";
    XCTAssertEqual(collision, [testObject diffIdentifier]);

    IGListAdapterUpdater *updater = [IGListAdapterUpdater new];

    // mimic internal map setup in IGListAdapter
    NSPointerFunctions *keyFunctions = [updater objectLookupPointerFunctions];
    NSPointerFunctions *valueFunctions = [NSPointerFunctions pointerFunctionsWithOptions:NSPointerFunctionsStrongMemory];
    NSMapTable *table = [[NSMapTable alloc] initWithKeyPointerFunctions:keyFunctions valuePointerFunctions:valueFunctions capacity:0];

    [table setObject:@1 forKey:testObject];
    XCTAssertNotNil([table objectForKey:testObject]);
    XCTAssertNil([table objectForKey:collision]);
}

- (void)test_whenReloadIsCalledWithSameItemCount_deleteInsertSectionHappen {
    IGListBatchUpdateData *expectedBatchUpdateData = [[IGListBatchUpdateData alloc] initWithInsertSections:[NSIndexSet indexSetWithIndex:0]
                                                                                            deleteSections:[NSIndexSet indexSetWithIndex:0]
                                                                                              moveSections:[NSSet new]
                                                                                          insertIndexPaths:@[]
                                                                                          deleteIndexPaths:@[]
                                                                                          updateIndexPaths:@[]
                                                                                            moveIndexPaths:@[]];
    NSArray<IGSectionObject *> *from = @[[IGSectionObject sectionWithObjects:@[@1] identifier:@"id"]];
    NSArray<IGSectionObject *> *to = @[[IGSectionObject sectionWithObjects:@[@2] identifier:@"id"]];
    self.dataSource.sections = from;

    id mockDelegate = [OCMockObject niceMockForProtocol:@protocol(IGListAdapterUpdaterDelegate)];
    self.updater.delegate = mockDelegate;
    [mockDelegate setExpectationOrderMatters:YES];
    [[mockDelegate expect] listAdapterUpdater:self.updater willPerformBatchUpdatesWithCollectionView:self.collectionView fromObjects:from toObjects:to listIndexSetResult:[OCMArg checkWithBlock:^BOOL(IGListIndexSetResult *result) {
        return result.inserts.count == 0 && result.deletes.count == 0 && result.moves.count == 0 && result.updates.firstIndex == 0;
    }] animated:NO];
    [[mockDelegate expect] listAdapterUpdater:self.updater didPerformBatchUpdates:expectedBatchUpdateData collectionView:self.collectionView];

    XCTestExpectation *expectation = genExpectation;

    [self.updater performUpdateWithCollectionViewBlock:[self collectionViewBlock]
                                              animated:NO
                                      sectionDataBlock:[self dataBlockFromObjects:from toObjects:to]
                                 applySectionDataBlock:self.applySectionDataBlock
                                            completion:^(BOOL finished) {
        [expectation fulfill];
    }];
    waitExpectation;
    [mockDelegate verify];
}

- (void)test_whenPerformUpdates_dataSourceWasSetToNil_shouldNotCrash {
    NSArray<IGSectionObject *> *from = @[[IGSectionObject sectionWithObjects:@[@1] identifier:@"id1"]];
    NSArray<IGSectionObject *> *to = @[[IGSectionObject sectionWithObjects:@[@2] identifier:@"id1"],
                                       [IGSectionObject sectionWithObjects:@[@22] identifier:@"id2"]];
    self.dataSource.sections = from;
    id mockDelegate = [OCMockObject niceMockForProtocol:@protocol(IGListAdapterUpdaterDelegate)];
    self.updater.delegate = mockDelegate;
    [mockDelegate setExpectationOrderMatters:YES];
    [[mockDelegate expect] listAdapterUpdater:self.updater didFinishWithoutUpdatesWithCollectionView:self.collectionView];

    XCTestExpectation *expectation = genExpectation;

    // Manually set the data source to be nil.
    self->_collectionView.dataSource = nil;

    [self.updater performUpdateWithCollectionViewBlock:[self collectionViewBlock]
                                              animated:NO
                                      sectionDataBlock:[self dataBlockFromObjects:from toObjects:to]
                                 applySectionDataBlock:^(IGListTransitionData *data) {
    }
                                            completion:^(BOOL finished) {
        [expectation fulfill];
    }];
    waitExpectation;
    [mockDelegate verify];
}

- (void)test_whenPerformIndexPathUpdates_reloadingTheSameIndexPathMultipleTimes_shouldNotCrash {
    // Set up data
    NSArray<IGSectionObject *> *from = @[[IGSectionObject sectionWithObjects:@[@1] identifier:@"id"]];
    self.dataSource.sections = from;

    // Mock delegate to confirm update did work
    id mockDelegate = [OCMockObject niceMockForProtocol:@protocol(IGListAdapterUpdaterDelegate)];
    self.updater.delegate = mockDelegate;
    [mockDelegate setExpectationOrderMatters:YES];
    [[mockDelegate expect] listAdapterUpdater:self.updater didPerformBatchUpdates:OCMOCK_ANY collectionView:self.collectionView];

    // Expectation to wait for performUpdate to finish
    XCTestExpectation *expectation = genExpectation;

    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.updater performUpdateWithCollectionViewBlock:[self collectionViewBlock]
                                              animated:NO
                                           itemUpdates:^{
        [self.updater reloadItemInCollectionView:self.collectionView fromIndexPath:indexPath toIndexPath:indexPath];
        [self.updater reloadItemInCollectionView:self.collectionView fromIndexPath:indexPath toIndexPath:indexPath];
    }
                                            completion:^(BOOL finished) {
        [expectation fulfill];
    }];

    waitExpectation;

    [mockDelegate verify];
}

- (void)test_whenPerformingUpdatesMultipleTimesInARow_thenUpdateWorks {
    NSArray *objects1 = @[
        [IGSectionObject sectionWithObjects:@[@0]]
    ];
    NSArray *objects2 = @[
        [IGSectionObject sectionWithObjects:@[@0, @1]],
        [IGSectionObject sectionWithObjects:@[@0, @1]]
    ];
    NSArray *objects3 = @[
        [IGSectionObject sectionWithObjects:@[@0, @1]],
        [IGSectionObject sectionWithObjects:@[@0, @1]],
        [IGSectionObject sectionWithObjects:@[@0, @1]]
    ];

    self.dataSource.sections = objects1;
    [self.updater reloadDataWithCollectionViewBlock:[self collectionViewBlock] reloadUpdateBlock:^{} completion:nil];
    [self.updater update];

    XCTestExpectation *expectation = genExpectation;
    [self.updater performUpdateWithCollectionViewBlock:[self collectionViewBlock]
                                              animated:YES
                                      sectionDataBlock:[self dataBlockFromObjects:objects1 toObjects:objects2]
                                 applySectionDataBlock:self.applySectionDataBlock
                                            completion:^(BOOL finished) {
        XCTAssertEqual([self.collectionView numberOfSections], 2);
        XCTAssertEqual([self.collectionView numberOfItemsInSection:0], 2);
        XCTAssertEqual([self.collectionView numberOfItemsInSection:1], 2);

        [self.updater performUpdateWithCollectionViewBlock:[self collectionViewBlock]
                                                  animated:YES
                                          sectionDataBlock:[self dataBlockFromObjects:objects2 toObjects:objects3]
                                     applySectionDataBlock:self.applySectionDataBlock
                                                completion:^(BOOL finished2) {
            XCTAssertEqual([self.collectionView numberOfSections], 3);
            XCTAssertEqual([self.collectionView numberOfItemsInSection:0], 2);
            XCTAssertEqual([self.collectionView numberOfItemsInSection:1], 2);
            XCTAssertEqual([self.collectionView numberOfItemsInSection:2], 2);
            [expectation fulfill];
        }];
    }];
    [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)test_whenPerformingUpdate_thatCallsDiffingDelegate {
    self.updater.allowsBackgroundDiffing = YES;

    NSArray *from = @[
        [IGSectionObject sectionWithObjects:@[] identifier:@"0"]
    ];
    NSArray *to = @[
        [IGSectionObject sectionWithObjects:@[] identifier:@"0"],
        [IGSectionObject sectionWithObjects:@[] identifier:@"1"]
    ];

    self.dataSource.sections = from;
    [self.updater reloadDataWithCollectionViewBlock:[self collectionViewBlock] reloadUpdateBlock:^{} completion:nil];
    [self.updater update];

    id mockDelegate = [OCMockObject niceMockForProtocol:@protocol(IGListAdapterUpdaterDelegate)];
    self.updater.delegate = mockDelegate;
    [mockDelegate setExpectationOrderMatters:YES];
    [[mockDelegate expect] listAdapterUpdater:self.updater willDiffFromObjects:from toObjects:to];
    [[mockDelegate expect] listAdapterUpdater:self.updater didDiffWithResults:[OCMArg checkWithBlock:^BOOL(IGListIndexSetResult *result) {
        return [result.inserts isEqualToIndexSet:[NSIndexSet indexSetWithIndex:1]]
        && result.deletes.count == 0
        && result.updates.count == 0
        && result.moves.count == 0;
    }] onBackgroundThread:YES];

    XCTestExpectation *expectation = genExpectation;

    [self.updater performUpdateWithCollectionViewBlock:[self collectionViewBlock]
                                              animated:NO
                                      sectionDataBlock:[self dataBlockFromObjects:from toObjects:to]
                                 applySectionDataBlock:self.applySectionDataBlock
                                            completion:^(BOOL finished) {
        [expectation fulfill];
    }];
    waitExpectation;
    [mockDelegate verify];
}

- (void)_test_whenCollectionViewSectionCountIsIncorrect_thatDoesNotCrash {
    NSArray *from = @[
        [IGSectionObject sectionWithObjects:@[]]
    ];
    NSArray *to = @[
        [IGSectionObject sectionWithObjects:@[]],
        [IGSectionObject sectionWithObjects:@[]]
    ];

    self.dataSource.sections = from;
    [self.updater reloadDataWithCollectionViewBlock:[self collectionViewBlock] reloadUpdateBlock:^{} completion:nil];
    [self.updater update];
    XCTAssertEqual([self.collectionView numberOfSections], 1);

    XCTestExpectation *expectation = genExpectation;
    [self.updater performUpdateWithCollectionViewBlock:[self collectionViewBlock]
                                              animated:YES
                                      sectionDataBlock:[self dataBlockFromObjects:from toObjects:to]
                                 applySectionDataBlock:self.applySectionDataBlock
                                            completion:^(BOOL finished) {
        XCTAssertEqual([self.collectionView numberOfSections], 2);
        [expectation fulfill];
    }];

    // Lets say we change the dataSource without the updater on accident.
    self.dataSource.sections =  @[
        [IGSectionObject sectionWithObjects:@[]],
        [IGSectionObject sectionWithObjects:@[]],
        [IGSectionObject sectionWithObjects:@[]]
    ];

    // Lets force the collectionView to sync
    [self.collectionView reloadData];
    [self.collectionView layoutIfNeeded];
    XCTAssertEqual([self.collectionView numberOfSections], 3);

    // No we wait for the update, which should fallback to a reload.

    [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)test_whenNoChanges_thatPerformUpdateExitsEarly {
    self.updater.experiments |= IGListExperimentSkipPerformUpdateIfPossible;

    NSArray *from = @[
        [IGSectionObject sectionWithObjects:@[] identifier:@"Foo"]
    ];
    NSArray *to = @[
        [IGSectionObject sectionWithObjects:@[] identifier:@"Foo"]
    ];

    self.dataSource.sections = from;
    [self.updater reloadDataWithCollectionViewBlock:[self collectionViewBlock] reloadUpdateBlock:^{} completion:nil];
    [self.updater update];

    id mockDelegate = [OCMockObject niceMockForProtocol:@protocol(IGListAdapterUpdaterDelegate)];
    self.updater.delegate = mockDelegate;
    [mockDelegate setExpectationOrderMatters:YES];

    [[mockDelegate expect] listAdapterUpdater:self.updater
    willPerformBatchUpdatesWithCollectionView:self.collectionView
                                  fromObjects:from
                                    toObjects:to
                           listIndexSetResult:OCMOCK_ANY
                                     animated:NO];

    [[mockDelegate expect] listAdapterUpdater:self.updater didFinishWithoutUpdatesWithCollectionView:self.collectionView];

    XCTestExpectation *expectation = genExpectation;
    [self.updater performUpdateWithCollectionViewBlock:[self collectionViewBlock]
                                              animated:NO
                                      sectionDataBlock:[self dataBlockFromObjects:from toObjects:to]
                                 applySectionDataBlock:self.applySectionDataBlock
                                            completion:^(BOOL finished) {
        XCTAssertTrue(finished);
        XCTAssertEqual([self.collectionView numberOfSections], 1);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:30 handler:nil];
    [mockDelegate verify];
}

# pragma mark - preferItemReloadsFroSectionReloads

- (void)test_whenReloadIsCalledWithSameItemCount_andPreferItemReload_updateIndexPathsHappen {
    self.updater.preferItemReloadsForSectionReloads = YES;

    IGListBatchUpdateData *expectedBatchUpdateData = [[IGListBatchUpdateData alloc] initWithInsertSections:[NSIndexSet new]
                                                                                            deleteSections:[NSIndexSet new]
                                                                                              moveSections:[NSSet new]
                                                                                          insertIndexPaths:@[]
                                                                                          deleteIndexPaths:@[]
                                                                                          updateIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]]
                                                                                            moveIndexPaths:@[]];
    NSArray<IGSectionObject *> *from = @[[IGSectionObject sectionWithObjects:@[@1] identifier:@"id"]];
    // Update the items
    NSArray<IGSectionObject *> *to = @[[IGSectionObject sectionWithObjects:@[@2] identifier:@"id"]];
    self.dataSource.sections = from;
    id mockDelegate = [OCMockObject niceMockForProtocol:@protocol(IGListAdapterUpdaterDelegate)];
    self.updater.delegate = mockDelegate;
    [mockDelegate setExpectationOrderMatters:YES];
    [[mockDelegate expect] listAdapterUpdater:self.updater willPerformBatchUpdatesWithCollectionView:self.collectionView fromObjects:from toObjects:to listIndexSetResult:[OCMArg checkWithBlock:^BOOL(IGListIndexSetResult *result) {
        return result.inserts.count == 0 && result.deletes.count == 0 && result.moves.count == 0 && result.updates.firstIndex == 0;
    }] animated:NO];
    [[mockDelegate expect] listAdapterUpdater:self.updater didPerformBatchUpdates:expectedBatchUpdateData collectionView:self.collectionView];

    XCTestExpectation *expectation = genExpectation;

    [self.updater performUpdateWithCollectionViewBlock:[self collectionViewBlock]
                                              animated:NO
                                      sectionDataBlock:[self dataBlockFromObjects:from toObjects:to]
                                 applySectionDataBlock:self.applySectionDataBlock
                                            completion:^(BOOL finished) {
        [expectation fulfill];
    }];
    waitExpectation;
    [mockDelegate verify];
}

- (void)test_whenReloadIsCalledWithDifferentItemCount_andPreferItemReload_deleteInsertSectionHappen {
    self.updater.preferItemReloadsForSectionReloads = YES;

    IGListBatchUpdateData *expectedBatchUpdateData = [[IGListBatchUpdateData alloc] initWithInsertSections:[NSIndexSet indexSetWithIndex:0]
                                                                                            deleteSections:[NSIndexSet indexSetWithIndex:0]
                                                                                              moveSections:[NSSet new]
                                                                                          insertIndexPaths:@[]
                                                                                          deleteIndexPaths:@[]
                                                                                          updateIndexPaths:@[]
                                                                                            moveIndexPaths:@[]];
    NSArray<IGSectionObject *> *from = @[[IGSectionObject sectionWithObjects:@[@1] identifier:@"id"]];
    // more items in the section
    NSArray<IGSectionObject *> *to = @[[IGSectionObject sectionWithObjects:@[@1, @2] identifier:@"id"]];
    self.dataSource.sections = from;

    id mockDelegate = [OCMockObject niceMockForProtocol:@protocol(IGListAdapterUpdaterDelegate)];
    self.updater.delegate = mockDelegate;
    [mockDelegate setExpectationOrderMatters:YES];
    [[mockDelegate expect] listAdapterUpdater:self.updater willPerformBatchUpdatesWithCollectionView:self.collectionView fromObjects:from toObjects:to listIndexSetResult:[OCMArg checkWithBlock:^BOOL(IGListIndexSetResult *result) {
        return result.inserts.count == 0 && result.deletes.count == 0 && result.moves.count == 0 && result.updates.firstIndex == 0;
    }] animated:NO];
    [[mockDelegate expect] listAdapterUpdater:self.updater didPerformBatchUpdates:expectedBatchUpdateData collectionView:self.collectionView];

    XCTestExpectation *expectation = genExpectation;

    [self.updater performUpdateWithCollectionViewBlock:[self collectionViewBlock]
                                              animated:NO
                                      sectionDataBlock:[self dataBlockFromObjects:from toObjects:to]
                                 applySectionDataBlock:self.applySectionDataBlock
                                            completion:^(BOOL finished) {
        [expectation fulfill];
    }];
    waitExpectation;
    [mockDelegate verify];
}

- (void)test_whenReloadIsCalledWithSectionMoveAndUpdate_andPreferItemReload_deleteInsertMoveHappens {
    self.updater.preferItemReloadsForSectionReloads = YES;

    IGListBatchUpdateData *expectedBatchUpdateData = [[IGListBatchUpdateData alloc] initWithInsertSections:[NSIndexSet indexSetWithIndex:0]
                                                                                            deleteSections:[NSIndexSet indexSetWithIndex:1]
                                                                                              moveSections:[NSSet setWithArray:@[[[IGListMoveIndex alloc] initWithFrom:0 to:1]]]
                                                                                          insertIndexPaths:@[]
                                                                                          deleteIndexPaths:@[]
                                                                                          updateIndexPaths:@[]
                                                                                            moveIndexPaths:@[]];
    NSArray<IGSectionObject *> *from = @[[IGSectionObject sectionWithObjects:@[@1] identifier:@"id1"],
                                         [IGSectionObject sectionWithObjects:@[@2] identifier:@"id2"]];
    // move section, and also update the item for "id2"
    NSArray<IGSectionObject *> *to = @[[IGSectionObject sectionWithObjects:@[@22] identifier:@"id2"],
                                       [IGSectionObject sectionWithObjects:@[@1] identifier:@"id1"]];
    self.dataSource.sections = from;

    id mockDelegate = [OCMockObject niceMockForProtocol:@protocol(IGListAdapterUpdaterDelegate)];
    self.updater.delegate = mockDelegate;
    [mockDelegate setExpectationOrderMatters:YES];
    [[mockDelegate expect] listAdapterUpdater:self.updater willPerformBatchUpdatesWithCollectionView:self.collectionView fromObjects:from toObjects:to listIndexSetResult:[OCMArg checkWithBlock:^BOOL(IGListIndexSetResult *result) {
        if (result.inserts.count != 0 || result.deletes.count != 0) {
            return NO;
        }
        // Make sure we note that index 1 is updated (id2 from @[@2] -> @[@22], "id1" moved from section 0 -> 1, and "id2" moved from section 1 -> 0
        return result.updates.firstIndex == 1 && result.moves.count == 2 && [result.moves containsObject:[[IGListMoveIndex alloc] initWithFrom:0 to:1]] && [result.moves containsObject:[[IGListMoveIndex alloc] initWithFrom:1 to:0]];
    }] animated:NO];
    [[mockDelegate expect] listAdapterUpdater:self.updater didPerformBatchUpdates:expectedBatchUpdateData collectionView:self.collectionView];

    XCTestExpectation *expectation = genExpectation;

    [self.updater performUpdateWithCollectionViewBlock:[self collectionViewBlock]
                                              animated:NO
                                      sectionDataBlock:[self dataBlockFromObjects:from toObjects:to]
                                 applySectionDataBlock:self.applySectionDataBlock
                                            completion:^(BOOL finished) {
        [expectation fulfill];
    }];
    waitExpectation;
    [mockDelegate verify];
}

- (void)test_whenReloadIsCalledWithSectionMoveAndUpdate_withDifferentSectionLength_andPreferItemReload_deleteInsertMoveHappens {
    self.updater.preferItemReloadsForSectionReloads = YES;

    IGListBatchUpdateData *expectedBatchUpdateData = [[IGListBatchUpdateData alloc] initWithInsertSections:[NSIndexSet indexSetWithIndex:0]
                                                                                            deleteSections:[NSIndexSet indexSetWithIndex:1]
                                                                                              moveSections:[NSSet setWithArray:@[[[IGListMoveIndex alloc] initWithFrom:0 to:1]]]
                                                                                          insertIndexPaths:@[]
                                                                                          deleteIndexPaths:@[]
                                                                                          updateIndexPaths:@[]
                                                                                            moveIndexPaths:@[]];
    NSArray<IGSectionObject *> *from = @[[IGSectionObject sectionWithObjects:@[@1, @2, @3] identifier:@"id1"],
                                         [IGSectionObject sectionWithObjects:@[@2] identifier:@"id2"]];
    // move section, and also update the item for "id2"
    NSArray<IGSectionObject *> *to = @[[IGSectionObject sectionWithObjects:@[@22] identifier:@"id2"],
                                       [IGSectionObject sectionWithObjects:@[@1, @2, @3] identifier:@"id1"]];
    self.dataSource.sections = from;

    id mockDelegate = [OCMockObject niceMockForProtocol:@protocol(IGListAdapterUpdaterDelegate)];
    self.updater.delegate = mockDelegate;
    [mockDelegate setExpectationOrderMatters:YES];
    [[mockDelegate expect] listAdapterUpdater:self.updater willPerformBatchUpdatesWithCollectionView:self.collectionView fromObjects:from toObjects:to listIndexSetResult:[OCMArg checkWithBlock:^BOOL(IGListIndexSetResult *result) {
        if (result.inserts.count != 0 || result.deletes.count != 0) {
            return NO;
        }
        // Make sure we note that index 1 is updated (id2 from @[@2] -> @[@22], "id1" moved from section 0 -> 1, and "id2" moved from section 1 -> 0
        return result.updates.firstIndex == 1 && result.moves.count == 2 && [result.moves containsObject:[[IGListMoveIndex alloc] initWithFrom:0 to:1]] && [result.moves containsObject:[[IGListMoveIndex alloc] initWithFrom:1 to:0]];
    }] animated:NO];
    [[mockDelegate expect] listAdapterUpdater:self.updater didPerformBatchUpdates:expectedBatchUpdateData collectionView:self.collectionView];

    XCTestExpectation *expectation = genExpectation;

    [self.updater performUpdateWithCollectionViewBlock:[self collectionViewBlock]
                                              animated:NO
                                      sectionDataBlock:[self dataBlockFromObjects:from toObjects:to]
                                 applySectionDataBlock:self.applySectionDataBlock
                                            completion:^(BOOL finished) {
        [expectation fulfill];
    }];
    waitExpectation;
    [mockDelegate verify];
}


- (void)test_whenReloadIsCalledWithSectionMoveAndUpdate_withThreeSections_deleteInsertMoveHappens {
    self.updater.preferItemReloadsForSectionReloads = YES;

    IGListBatchUpdateData *expectedBatchUpdateData = [[IGListBatchUpdateData alloc] initWithInsertSections:[NSIndexSet indexSetWithIndex:0]
                                                                                            deleteSections:[NSIndexSet indexSetWithIndex:1]
                                                                                              moveSections:[NSSet setWithArray:@[[[IGListMoveIndex alloc] initWithFrom:0 to:1]]]
                                                                                          insertIndexPaths:@[]
                                                                                          deleteIndexPaths:@[]
                                                                                          updateIndexPaths:@[]
                                                                                            moveIndexPaths:@[]];
    NSArray<IGSectionObject *> *from = @[[IGSectionObject sectionWithObjects:@[@1] identifier:@"id1"],
                                         [IGSectionObject sectionWithObjects:@[@2] identifier:@"id2"],
                                         [IGSectionObject sectionWithObjects:@[@3] identifier:@"id3"]];
    // move section, and also update the items for "id2"
    NSArray<IGSectionObject *> *to = @[[IGSectionObject sectionWithObjects:@[@22, @23] identifier:@"id2"],
                                       [IGSectionObject sectionWithObjects:@[@1] identifier:@"id1"],
                                       [IGSectionObject sectionWithObjects:@[@3] identifier:@"id3"]];
    self.dataSource.sections = from;
    id mockDelegate = [OCMockObject niceMockForProtocol:@protocol(IGListAdapterUpdaterDelegate)];
    self.updater.delegate = mockDelegate;
    [mockDelegate setExpectationOrderMatters:YES];
    [[mockDelegate expect] listAdapterUpdater:self.updater willPerformBatchUpdatesWithCollectionView:self.collectionView fromObjects:from toObjects:to listIndexSetResult:[OCMArg checkWithBlock:^BOOL(IGListIndexSetResult *result) {
        if (result.inserts.count != 0 || result.deletes.count != 0) {
            return NO;
        }
        // Make sure we note that index 1 is updated (id2 from @[@2] -> @[@22], "id1" moved from section 0 -> 1, "id2" moved from section 1 -> 0
        return result.updates.firstIndex == 1 && result.moves.count == 2 && [result.moves containsObject:[[IGListMoveIndex alloc] initWithFrom:0 to:1]] && [result.moves containsObject:[[IGListMoveIndex alloc] initWithFrom:1 to:0]];
    }] animated:NO];
    [[mockDelegate expect] listAdapterUpdater:self.updater didPerformBatchUpdates:expectedBatchUpdateData collectionView:self.collectionView];

    XCTestExpectation *expectation = genExpectation;

    [self.updater performUpdateWithCollectionViewBlock:[self collectionViewBlock]
                                              animated:NO
                                      sectionDataBlock:[self dataBlockFromObjects:from toObjects:to]
                                 applySectionDataBlock:self.applySectionDataBlock
                                            completion:^(BOOL finished) {
        [expectation fulfill];
    }];
    waitExpectation;
    [mockDelegate verify];
}

- (void)test_whenReloadIsCalledWithSectionInsertAndUpdate_andPreferItemReload_noItemReloads {
    self.updater.preferItemReloadsForSectionReloads = YES;

    IGListBatchUpdateData *expectedBatchUpdateData = [[IGListBatchUpdateData alloc] initWithInsertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)]
                                                                                            deleteSections:[NSIndexSet indexSetWithIndex:0]
                                                                                              moveSections:[NSSet new]
                                                                                          insertIndexPaths:@[]
                                                                                          deleteIndexPaths:@[]
                                                                                          updateIndexPaths:@[]
                                                                                            moveIndexPaths:@[]];
    NSArray<IGSectionObject *> *from = @[[IGSectionObject sectionWithObjects:@[@1] identifier:@"id1"]];
    NSArray<IGSectionObject *> *to = @[[IGSectionObject sectionWithObjects:@[@2] identifier:@"id1"],
                                       [IGSectionObject sectionWithObjects:@[@22] identifier:@"id2"]];
    self.dataSource.sections = from;
    id mockDelegate = [OCMockObject niceMockForProtocol:@protocol(IGListAdapterUpdaterDelegate)];
    self.updater.delegate = mockDelegate;
    [mockDelegate setExpectationOrderMatters:YES];
    [[mockDelegate expect] listAdapterUpdater:self.updater willPerformBatchUpdatesWithCollectionView:self.collectionView fromObjects:from toObjects:to listIndexSetResult:[OCMArg checkWithBlock:^BOOL(IGListIndexSetResult *result) {
        if (result.deletes.count != 0 || result.moves.count != 0) {
            return NO;
        }
        // Make sure we note that index 1 is updated (id1 from @[@1] -> @[@2]), and "id2" was inserted at index 1
        return result.updates.firstIndex == 0 && result.inserts.firstIndex == 1;
    }] animated:NO];
    [[mockDelegate expect] listAdapterUpdater:self.updater didPerformBatchUpdates:expectedBatchUpdateData collectionView:self.collectionView];

    XCTestExpectation *expectation = genExpectation;

    [self.updater performUpdateWithCollectionViewBlock:[self collectionViewBlock]
                                              animated:NO
                                      sectionDataBlock:[self dataBlockFromObjects:from toObjects:to]
                                 applySectionDataBlock:self.applySectionDataBlock
                                            completion:^(BOOL finished) {
        [expectation fulfill];
    }];
    waitExpectation;
    [mockDelegate verify];
}

@end
