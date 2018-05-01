/**
 * Copyright (c) 2016-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import <IGListKit/IGListKit.h>

#import "IGListAdapterUpdaterInternal.h"
#import "IGListTestUICollectionViewDataSource.h"
#import "IGTestObject.h"

#define genExpectation [self expectationWithDescription:NSStringFromSelector(_cmd)]
#define waitExpectation [self waitForExpectationsWithTimeout:30 handler:nil]

@interface IGListAdapterUpdaterTests : XCTestCase

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) IGListTestUICollectionViewDataSource *dataSource;
@property (nonatomic, strong) IGListAdapterUpdater *updater;
@property (nonatomic, strong) IGListObjectTransitionBlock updateBlock;

@end

@implementation IGListAdapterUpdaterTests

- (void)setUp {
    [super setUp];

    self.window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.window.frame collectionViewLayout:layout];

    [self.window addSubview:self.collectionView];

    self.dataSource = [[IGListTestUICollectionViewDataSource alloc] initWithCollectionView:self.collectionView];
    self.updater = [[IGListAdapterUpdater alloc] init];
    __weak __typeof__(self) weakSelf = self;
    self.updateBlock = ^(NSArray *obj) {
        weakSelf.dataSource.sections = obj;
    };
}

- (void)tearDown {
    [super tearDown];

    self.collectionView = nil;
    self.dataSource = nil;
    self.updater = nil;
}

- (void)test_whenUpdatingWithNil_thatUpdaterHasNoChanges {
    [self.updater performUpdateWithCollectionView:self.collectionView fromObjects:nil toObjectsBlock:nil animated:YES objectTransitionBlock:self.updateBlock completion:nil];
    XCTAssertFalse([self.updater hasChanges]);
}

- (void)test_whenUpdatingtoObjects_thatUpdaterHasChanges {
    [self.updater performUpdateWithCollectionView:self.collectionView fromObjects:nil toObjectsBlock:^NSArray *{return @[@0];} animated:YES objectTransitionBlock:self.updateBlock completion:nil];
    XCTAssertTrue([self.updater hasChanges]);
}

- (void)test_whenUpdatingfromObjects_thatUpdaterHasChanges {
    [self.updater performUpdateWithCollectionView:self.collectionView fromObjects:@[@0] toObjectsBlock:^NSArray *{return nil;} animated:YES objectTransitionBlock:self.updateBlock completion:nil];
    XCTAssertTrue([self.updater hasChanges]);
}

- (void)test_whenUpdatingtoObjects_withfromObjects_thatUpdaterHasChanges {
    [self.updater performUpdateWithCollectionView:self.collectionView fromObjects:@[@0] toObjectsBlock:^NSArray *{return @[@1];} animated:YES objectTransitionBlock:self.updateBlock completion:nil];
    XCTAssertTrue([self.updater hasChanges]);
}

- (void)test_whenCleaningUpState_withChanges_thatUpdaterHasNoChanges {
    [self.updater performUpdateWithCollectionView:self.collectionView fromObjects:nil toObjectsBlock:^NSArray *{return @[@0];} animated:YES objectTransitionBlock:self.updateBlock completion:nil];
    XCTAssertTrue([self.updater hasChanges]);
    [self.updater cleanStateBeforeUpdates];
    XCTAssertFalse([self.updater hasChanges]);
}

- (void)test_whenReloadingData_thatCollectionViewUpdates {
    self.dataSource.sections = @[[IGSectionObject sectionWithObjects:@[]]];
    [self.updater performReloadDataWithCollectionView:self.collectionView];
    XCTAssertEqual([self.collectionView numberOfSections], 1);
    self.dataSource.sections = @[];
    [self.updater performReloadDataWithCollectionView:self.collectionView];
    XCTAssertEqual([self.collectionView numberOfSections], 0);
}

- (void)test_whenInsertingSection_thatCollectionViewUpdates {
    NSArray *from = @[
                      [IGSectionObject sectionWithObjects:@[]]
                      ];
    IGListToObjectBlock to = ^NSArray *{
        return @[
                 [IGSectionObject sectionWithObjects:@[]],
                 [IGSectionObject sectionWithObjects:@[]]
                 ];
    };

    self.dataSource.sections = from;
    [self.updater performReloadDataWithCollectionView:self.collectionView];
    XCTAssertEqual([self.collectionView numberOfSections], 1);

    XCTestExpectation *expectation = genExpectation;
    [self.updater performUpdateWithCollectionView:self.collectionView fromObjects:from toObjectsBlock:to animated:YES objectTransitionBlock:self.updateBlock completion:^(BOOL finished) {
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
    IGListToObjectBlock to = ^NSArray *{
        return @[
                 [IGSectionObject sectionWithObjects:@[]]
                 ];
    };

    self.dataSource.sections = from;
    [self.updater performReloadDataWithCollectionView:self.collectionView];
    XCTAssertEqual([self.collectionView numberOfSections], 2);

    XCTestExpectation *expectation = genExpectation;
    [self.updater performUpdateWithCollectionView:self.collectionView fromObjects:from toObjectsBlock:to animated:YES objectTransitionBlock:self.updateBlock completion:^(BOOL finished) {
        XCTAssertEqual([self.collectionView numberOfSections], 1);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)test_whenInsertingSection_withItemChanges_thatCollectionViewUpdates {
    NSArray *from = @[
                      [IGSectionObject sectionWithObjects:@[@0]]
                      ];
    IGListToObjectBlock to = ^NSArray *{
        return @[
                 [IGSectionObject sectionWithObjects:@[@0, @1]],
                 [IGSectionObject sectionWithObjects:@[@0, @1]]
                 ];
    };

    self.dataSource.sections = from;
    [self.updater performReloadDataWithCollectionView:self.collectionView];
    XCTAssertEqual([self.collectionView numberOfSections], 1);
    XCTAssertEqual([self.collectionView numberOfItemsInSection:0], 1);

    XCTestExpectation *expectation = genExpectation;
    [self.updater performUpdateWithCollectionView:self.collectionView fromObjects:from toObjectsBlock:to animated:YES objectTransitionBlock:self.updateBlock completion:^(BOOL finished) {
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
    IGListToObjectBlock to = ^NSArray *{
        return @[
                 [IGSectionObject sectionWithObjects:@[@1, @1]],
                 [IGSectionObject sectionWithObjects:@[@0]],
                 [IGSectionObject sectionWithObjects:@[@0, @2, @3]]
                 ];
    };

    self.dataSource.sections = from;
    [self.updater performReloadDataWithCollectionView:self.collectionView];

    XCTAssertEqual([self.collectionView numberOfSections], 2);
    XCTAssertEqual([self.collectionView numberOfItemsInSection:0], 3);

    XCTestExpectation *expectation = genExpectation;
    [self.updater performUpdateWithCollectionView:self.collectionView fromObjects:from toObjectsBlock:to animated:NO objectTransitionBlock:self.updateBlock completion:^(BOOL finished) {
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
    [self.updater performReloadDataWithCollectionView:self.collectionView];
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
    IGListToObjectBlock to = ^NSArray *{
        return @[
                 [IGSectionObject sectionWithObjects:@[]]
                 ];
    };

    self.dataSource.sections = from;
    [self.updater performReloadDataWithCollectionView:self.collectionView];

    // the collection view has been setup with 1 section and now needs layout
    // calling performBatchUpdates: on a collection view needing layout will force layout
    // we need to ensure that our data source is not changed until the update block is executed
    [self.collectionView setNeedsLayout];

    XCTestExpectation *expectation = genExpectation;
    [self.updater performUpdateWithCollectionView:self.collectionView fromObjects:from toObjectsBlock:to animated:NO objectTransitionBlock:self.updateBlock completion:^(BOOL finished) {
        XCTAssertEqual([self.collectionView numberOfSections], 1);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)test_whenUpdatesAreReentrant_thatUpdatesExecuteSerially {
    NSArray *from = @[
                      [IGSectionObject sectionWithObjects:@[]],
                      ];
    IGListToObjectBlock to = ^NSArray *{
        return @[
                 [IGSectionObject sectionWithObjects:@[]],
                 [IGSectionObject sectionWithObjects:@[]],
                 ];
    };

    self.dataSource.sections = from;
    [self.updater performReloadDataWithCollectionView:self.collectionView];

    __block NSInteger completionCounter = 0;

    XCTestExpectation *expectation1 = genExpectation;
    void (^preUpdateBlock)(void) = ^{
        NSArray *(^anotherTo)(void) = ^NSArray *{
            return @[
                     [IGSectionObject sectionWithObjects:@[]],
                     [IGSectionObject sectionWithObjects:@[]],
                     [IGSectionObject sectionWithObjects:@[]]
                     ];
        };
        [self.updater performUpdateWithCollectionView:self.collectionView fromObjects:from toObjectsBlock:anotherTo animated:YES objectTransitionBlock:self.updateBlock completion:^(BOOL finished) {
            completionCounter++;
            XCTAssertEqual([self.collectionView numberOfSections], 3);
            XCTAssertEqual(completionCounter, 2);
            [expectation1 fulfill];
        }];
    };

    XCTestExpectation *expectation2 = genExpectation;
    [self.updater performUpdateWithCollectionView:self.collectionView fromObjects:from toObjectsBlock:to animated:YES objectTransitionBlock:^(NSArray *toObjects) {
        // executing this block within the updater is just before performBatchUpdates: are applied
        // should be able to queue another update here, similar to an update being queued between it beginning and executing
        // the performBatchUpdates: block
        preUpdateBlock();

        self.dataSource.sections = toObjects;
    } completion:^(BOOL finished) {
        completionCounter++;
        XCTAssertEqual([self.collectionView numberOfSections], 2);
        XCTAssertEqual(completionCounter, 1);
        [expectation2 fulfill];
    }];
    [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)test_whenQueuingItemUpdates_thatUpdaterHasChanges {
    [self.updater performUpdateWithCollectionView:self.collectionView animated:YES itemUpdates:^{} completion:nil];
    XCTAssertTrue([self.updater hasChanges]);
}

- (void)test_whenOnlyQueueingItemUpdates_thatUpdateBlockExecutes {
    XCTestExpectation *expectation = genExpectation;
    [self.updater performUpdateWithCollectionView:self.collectionView animated:YES itemUpdates:^{
        // expectation should be triggered. test failure is a timeout
        [expectation fulfill];
    } completion:nil];
    [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)test_whenQueueingItemUpdates_withBatchUpdate_thatItemUpdateBlockExecutes {
    __block BOOL itemUpdateBlockExecuted = NO;
    __block BOOL sectionUpdateBlockExecuted = NO;

    [self.updater performUpdateWithCollectionView:self.collectionView
                                      fromObjects:nil
                                   toObjectsBlock:^NSArray *{return @[[IGSectionObject sectionWithObjects:@[@1]]];}
                                         animated:YES objectTransitionBlock:^(NSArray * toObjects) {
                                             self.dataSource.sections = toObjects;
                                             sectionUpdateBlockExecuted = YES;
                                         }
                                       completion:nil];

    XCTestExpectation *expectation = genExpectation;
    [self.updater performUpdateWithCollectionView:self.collectionView animated:YES itemUpdates:^{
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

    IGListToObjectBlock to = ^NSArray *{
        // rearrange the modified objects
        return @[
                 from[2],
                 from[0],
                 from[1]
                 ];
    };

    self.dataSource.sections = from;
    [self.updater performReloadDataWithCollectionView:self.collectionView];

    // without moves as inserts, we would assert b/c the # of items in each section changes
    self.updater.movesAsDeletesInserts = YES;

    XCTestExpectation *expectation = genExpectation;
    [self.updater performUpdateWithCollectionView:self.collectionView fromObjects:from toObjectsBlock:to animated:YES objectTransitionBlock:self.updateBlock completion:^(BOOL finished) {
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
    convertReloadToDeleteInsert(reloads, deletes, inserts, result, from);
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
    convertReloadToDeleteInsert(reloads, deletes, inserts, result, from);
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
    convertReloadToDeleteInsert(reloads, deletes, inserts, result, from);
    XCTAssertEqual(reloads.count, 0);
    XCTAssertEqual(deletes.count, 0);
    XCTAssertEqual(inserts.count, 0);
}

- (void)test_whenReloadingData_withNilCollectionView_thatDelegateEventNotSent {
    id mockDelegate = [OCMockObject mockForProtocol:@protocol(IGListAdapterUpdaterDelegate)];
    self.updater.delegate = mockDelegate;
    id compilerFriendlyNil = nil;
    [[mockDelegate reject] listAdapterUpdater:self.updater willReloadDataWithCollectionView:compilerFriendlyNil];
    [[mockDelegate reject] listAdapterUpdater:self.updater didReloadDataWithCollectionView:compilerFriendlyNil];
    [self.updater performReloadDataWithCollectionView:compilerFriendlyNil];
    [mockDelegate verify];
}

- (void)test_whenPerformingUpdates_withNilCollectionView_thatDelegateEventNotSent {
    id mockDelegate = [OCMockObject mockForProtocol:@protocol(IGListAdapterUpdaterDelegate)];
    self.updater.delegate = mockDelegate;
    id compilerFriendlyNil = nil;
    [[mockDelegate reject] listAdapterUpdater:self.updater willPerformBatchUpdatesWithCollectionView:compilerFriendlyNil];
    [[mockDelegate reject] listAdapterUpdater:self.updater didPerformBatchUpdates:[OCMArg any] collectionView:compilerFriendlyNil];
    [self.updater performBatchUpdatesWithCollectionView:compilerFriendlyNil];
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
    [updater performReloadDataWithCollectionView:collectionView];

    XCTAssertEqual([collectionView numberOfSections], 1);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], 1);

    dataSource.sections = @[
                            [IGSectionObject sectionWithObjects:@[@1]],
                            [IGSectionObject sectionWithObjects:@[@1, @2, @3, @4]]
                            ];
    [updater performReloadDataWithCollectionView:collectionView];

    XCTAssertEqual([collectionView numberOfSections], 2);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], 1);
    XCTAssertEqual([collectionView numberOfItemsInSection:1], 4);
}

- (void)test_whenCollectionViewNotInWindow_andBackgroundReloadFlag_isSetNO_diffHappens {
    self.updater.allowsBackgroundReloading = NO;
    [self.collectionView removeFromSuperview];

    id mockDelegate = [OCMockObject niceMockForProtocol:@protocol(IGListAdapterUpdaterDelegate)];
    self.updater.delegate = mockDelegate;
    [mockDelegate setExpectationOrderMatters:YES];
    [[mockDelegate expect] listAdapterUpdater:self.updater willPerformBatchUpdatesWithCollectionView:self.collectionView];
    [[mockDelegate expect] listAdapterUpdater:self.updater didPerformBatchUpdates:OCMOCK_ANY collectionView:self.collectionView];

    XCTestExpectation *expectation = genExpectation;
    IGListToObjectBlock to = ^NSArray *{
        return @[
                 [IGSectionObject sectionWithObjects:@[]]
                 ];
    };
    [self.updater performUpdateWithCollectionView:self.collectionView fromObjects:self.dataSource.sections toObjectsBlock:to animated:NO objectTransitionBlock:self.updateBlock completion:^(BOOL finished) {
        [expectation fulfill];
    }];
    waitExpectation;
    [mockDelegate verify];
}

- (void)test_whenCollectionViewNotInWindow_andBackgroundReloadFlag_isDefaultYES_diffDoesNotHappen {
    [self.collectionView removeFromSuperview];

    id mockDelegate = [OCMockObject niceMockForProtocol:@protocol(IGListAdapterUpdaterDelegate)];
    self.updater.delegate = mockDelegate;

    // NOTE: The current behavior in this case is for the adapter updater
    // simply not to call any delegate methods at all. This may change
    // in the future, but we configure the mock delegate to allow any call
    // except the batch updates calls.

    [[mockDelegate reject] listAdapterUpdater:self.updater willPerformBatchUpdatesWithCollectionView:self.collectionView];
    [[mockDelegate reject] listAdapterUpdater:self.updater didPerformBatchUpdates:OCMOCK_ANY collectionView:self.collectionView];

    XCTestExpectation *expectation = genExpectation;
    IGListToObjectBlock to = ^NSArray *{
        return @[
                 [IGSectionObject sectionWithObjects:@[]]
                 ];
    };
    [self.updater performUpdateWithCollectionView:self.collectionView fromObjects:self.dataSource.sections toObjectsBlock:to animated:NO objectTransitionBlock:self.updateBlock completion:^(BOOL finished) {
        [expectation fulfill];
    }];
    waitExpectation;
    [mockDelegate verify];
}

- (void)test_whenReloadBatchedWithUpdate_thatCompletionBlockStillExecuted {
    IGSectionObject *object = [IGSectionObject sectionWithObjects:@[@0, @1, @2]];
    self.dataSource.sections = @[object];

    __block BOOL reloadDataCompletionExecuted = NO;
    [self.updater reloadDataWithCollectionView:self.collectionView reloadUpdateBlock:^{} completion:^(BOOL finished) {
        reloadDataCompletionExecuted = YES;
    }];

    XCTestExpectation *expectation = genExpectation;
    [self.updater performUpdateWithCollectionView:self.collectionView animated:YES itemUpdates:^{
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

- (void)test_whenNotInViewHierarchy_thatUpdatesStillExecuteBlocks {
    [self.collectionView removeFromSuperview];

    IGSectionObject *object = [IGSectionObject sectionWithObjects:@[@0, @1, @2]];
    self.dataSource.sections = @[object];

    __block BOOL objectTransitionBlockExecuted = NO;
    __block BOOL completionBlockExecuted = NO;
    [self.updater performUpdateWithCollectionView:self.collectionView
                                      fromObjects:self.dataSource.sections
                                   toObjectsBlock:^NSArray *{return self.dataSource.sections;}
                                         animated:YES
                            objectTransitionBlock:^(NSArray *toObjects) {
                                objectTransitionBlockExecuted = YES;
                            }
                                       completion:^(BOOL finished) {
                                           completionBlockExecuted = YES;
                                       }];

    XCTestExpectation *expectation = genExpectation;
    [self.updater performUpdateWithCollectionView:self.collectionView animated:YES itemUpdates:^{
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

@end


