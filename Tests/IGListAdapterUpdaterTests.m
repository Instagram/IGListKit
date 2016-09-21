/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <XCTest/XCTest.h>

#import "IGListAdapterUpdaterInternal.h"
#import "IGListTestUICollectionViewDataSource.h"

#define genTestObject(k, v) [[IGSectionObject alloc] initWithKey:k value:v]

#define genExpectation [self expectationWithDescription:NSStringFromSelector(_cmd)]
#define waitExpectation [self waitForExpectationsWithTimeout:15 handler:nil]

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
    [self.updater performUpdateWithCollectionView:self.collectionView fromObjects:nil toObjects:nil animated:YES objectTransitionBlock:self.updateBlock completion:nil];
    XCTAssertFalse([self.updater hasChanges]);
}

- (void)test_whenUpdatingtoObjects_thatUpdaterHasChanges {
    [self.updater performUpdateWithCollectionView:self.collectionView fromObjects:nil toObjects:@[@0] animated:YES objectTransitionBlock:self.updateBlock completion:nil];
    XCTAssertTrue([self.updater hasChanges]);
}

- (void)test_whenUpdatingfromObjects_thatUpdaterHasChanges {
    [self.updater performUpdateWithCollectionView:self.collectionView fromObjects:@[@0] toObjects:nil animated:YES objectTransitionBlock:self.updateBlock completion:nil];
    XCTAssertTrue([self.updater hasChanges]);
}

- (void)test_whenUpdatingtoObjects_withfromObjects_thatUpdaterHasChanges {
    [self.updater performUpdateWithCollectionView:self.collectionView fromObjects:@[@0] toObjects:@[@1] animated:YES objectTransitionBlock:self.updateBlock completion:nil];
    XCTAssertTrue([self.updater hasChanges]);
}

- (void)test_whenCleaningUpState_withChanges_thatUpdaterHasNoChanges {
    [self.updater performUpdateWithCollectionView:self.collectionView fromObjects:nil toObjects:@[@0] animated:YES objectTransitionBlock:self.updateBlock completion:nil];
    XCTAssertTrue([self.updater hasChanges]);
    [self.updater cleanupState];
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
    NSArray *to = @[
                    [IGSectionObject sectionWithObjects:@[]],
                    [IGSectionObject sectionWithObjects:@[]]
                    ];

    self.dataSource.sections = from;
    [self.updater performReloadDataWithCollectionView:self.collectionView];
    XCTAssertEqual([self.collectionView numberOfSections], 1);

    XCTestExpectation *expectation = genExpectation;
    [self.updater performUpdateWithCollectionView:self.collectionView fromObjects:from toObjects:to animated:YES objectTransitionBlock:self.updateBlock completion:^(BOOL finished) {
        XCTAssertEqual([self.collectionView numberOfSections], 2);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:15 handler:nil];
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
    [self.updater performReloadDataWithCollectionView:self.collectionView];
    XCTAssertEqual([self.collectionView numberOfSections], 2);

    XCTestExpectation *expectation = genExpectation;
    [self.updater performUpdateWithCollectionView:self.collectionView fromObjects:from toObjects:to animated:YES objectTransitionBlock:self.updateBlock completion:^(BOOL finished) {
        XCTAssertEqual([self.collectionView numberOfSections], 1);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:15 handler:nil];
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
    [self.updater performReloadDataWithCollectionView:self.collectionView];
    XCTAssertEqual([self.collectionView numberOfSections], 1);
    XCTAssertEqual([self.collectionView numberOfItemsInSection:0], 1);

    XCTestExpectation *expectation = genExpectation;
    [self.updater performUpdateWithCollectionView:self.collectionView fromObjects:from toObjects:to animated:YES objectTransitionBlock:self.updateBlock completion:^(BOOL finished) {
        XCTAssertEqual([self.collectionView numberOfSections], 2);
        XCTAssertEqual([self.collectionView numberOfItemsInSection:0], 2);
        XCTAssertEqual([self.collectionView numberOfItemsInSection:1], 2);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:15 handler:nil];
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
    [self.updater performReloadDataWithCollectionView:self.collectionView];

    XCTAssertEqual([self.collectionView numberOfSections], 2);
    XCTAssertEqual([self.collectionView numberOfItemsInSection:0], 3);

    XCTestExpectation *expectation = genExpectation;
    [self.updater performUpdateWithCollectionView:self.collectionView fromObjects:from toObjects:to animated:YES objectTransitionBlock:self.updateBlock completion:^(BOOL finished) {
        XCTAssertEqual([self.collectionView numberOfSections], 3);
        XCTAssertEqual([self.collectionView numberOfItemsInSection:0], 2);
        XCTAssertEqual([self.collectionView numberOfItemsInSection:1], 1);
        XCTAssertEqual([self.collectionView numberOfItemsInSection:2], 3);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:15 handler:nil];
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
    NSArray *to = @[
                    [IGSectionObject sectionWithObjects:@[]]
                    ];

    self.dataSource.sections = from;
    [self.updater performReloadDataWithCollectionView:self.collectionView];

    // the collection view has been setup with 1 section and now needs layout
    // calling performBatchUpdates: on a collection view needing layout will force layout
    // we need to ensure that our data source is not changed until the update block is executed
    [self.collectionView setNeedsLayout];

    XCTestExpectation *expectation = genExpectation;
    [self.updater performUpdateWithCollectionView:self.collectionView fromObjects:from toObjects:to animated:YES objectTransitionBlock:self.updateBlock completion:^(BOOL finished) {
        XCTAssertEqual([self.collectionView numberOfSections], 1);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:15 handler:nil];
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
    [self.updater performReloadDataWithCollectionView:self.collectionView];

    __block NSInteger completionCounter = 0;

    XCTestExpectation *expectation = genExpectation;
    void (^preUpdateBlock)() = ^{
        NSArray *anotherTo = @[
                               [IGSectionObject sectionWithObjects:@[]],
                               [IGSectionObject sectionWithObjects:@[]],
                               [IGSectionObject sectionWithObjects:@[]]
                               ];
        [self.updater performUpdateWithCollectionView:self.collectionView fromObjects:from toObjects:anotherTo animated:YES objectTransitionBlock:self.updateBlock completion:^(BOOL finished) {
            completionCounter++;
            XCTAssertEqual([self.collectionView numberOfSections], 3);
            XCTAssertEqual(completionCounter, 2);
            [expectation fulfill];
        }];
    };

    [self.updater performUpdateWithCollectionView:self.collectionView fromObjects:from toObjects:to animated:YES objectTransitionBlock:^(NSArray *toObjects) {
        // executing this block within the updater is just before performBatchUpdates: are applied
        // should be able to queue another update here, similar to an update being queued between it beginning and executing
        // the performBatchUpdates: block
        preUpdateBlock();

        self.dataSource.sections = toObjects;
    } completion:^(BOOL finished) {
        completionCounter++;
        XCTAssertEqual(completionCounter, 1);
    }];
    [self waitForExpectationsWithTimeout:15 handler:nil];
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
    [self waitForExpectationsWithTimeout:15 handler:nil];
}

- (void)test_whenQueueingItemUpdates_withBatchUpdate_thatItemUpdateBlockExecutes {
    __block BOOL itemUpdateBlockExecuted = NO;
    __block BOOL sectionUpdateBlockExecuted = NO;

    [self.updater performUpdateWithCollectionView:self.collectionView
                                      fromObjects:nil
                                        toObjects:@[[IGSectionObject sectionWithObjects:@[@1]]]
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
    [self waitForExpectationsWithTimeout:15 handler:nil];
}

- (void)test_whenItemsMoveAndUpdate_thatCollectionViewWorks {
    NSArray *from = @[
                      [IGSectionObject sectionWithObjects:@[]],
                      [IGSectionObject sectionWithObjects:@[]],
                      [IGSectionObject sectionWithObjects:@[]],
                      ];

    // change the number of items in the section, which a move would be unable to handle and would throw
    // keep the same pointers so that the objects are equal
    [from[2] setObjects:@[@1]];
    [from[0] setObjects:@[@1, @1]];
    [from[1] setObjects:@[@1, @1, @1]];

    // rearrange the modified objects
    NSArray *to = @[
                    from[2],
                    from[0],
                    from[1]
                    ];

    self.dataSource.sections = from;
    [self.updater performReloadDataWithCollectionView:self.collectionView];

    // without moves as inserts, we would assert b/c the # of items in each section changes
    self.updater.movesAsDeletesInserts = YES;

    XCTestExpectation *expectation = genExpectation;
    [self.updater performUpdateWithCollectionView:self.collectionView fromObjects:from toObjects:to animated:YES objectTransitionBlock:self.updateBlock completion:^(BOOL finished) {
        XCTAssertEqual([self.collectionView numberOfSections], 3);
        XCTAssertEqual([self.collectionView numberOfItemsInSection:0], 1);
        XCTAssertEqual([self.collectionView numberOfItemsInSection:1], 2);
        XCTAssertEqual([self.collectionView numberOfItemsInSection:2], 3);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:15 handler:nil];
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

@end
