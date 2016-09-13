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

#import "IGListAdapterInternal.h"
#import "IGListTestOffsettingLayout.h"
#import "IGTestCell.h"
#import "IGTestDelegateController.h"
#import "IGTestDelegateDataSource.h"
#import "IGTestObject.h"

#define genIndexPath(s) [NSIndexPath indexPathForItem:0 inSection:s]
#define genTestObject(k, v) [[IGTestObject alloc] initWithKey:k value:v]

#define genExpectation [self expectationWithDescription:NSStringFromSelector(_cmd)]

@interface IGListAdapterE2ETests : XCTestCase

@property (nonatomic, strong) IGListCollectionView *collectionView;
@property (nonatomic, strong) IGListAdapter *adapter;
@property (nonatomic, strong) IGListAdapterUpdater *updater;
@property (nonatomic, strong) IGTestDelegateDataSource *dataSource;
@property (nonatomic, strong) UIWindow *window;

@end

@implementation IGListAdapterE2ETests

- (void)setUp {
    [super setUp];

    self.window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionView = [[IGListCollectionView alloc] initWithFrame:CGRectMake(0, 0, 100, 100) collectionViewLayout:layout];

    [self.window addSubview:self.collectionView];

    self.dataSource = [[IGTestDelegateDataSource alloc] init];

    self.updater = [[IGListAdapterUpdater alloc] init];
    self.adapter = [[IGListAdapter alloc] initWithUpdatingDelegate:self.updater viewController:nil workingRangeSize:2];
}

- (void)tearDown {
    [super tearDown];

    self.window = nil;
    self.collectionView = nil;
    self.adapter = nil;
    self.dataSource = nil;
}

- (void)setupWithObjects:(NSArray *)objects {
    self.dataSource.objects = objects;
    self.adapter.collectionView = self.collectionView;
    self.adapter.dataSource = self.dataSource;
    [self.collectionView layoutIfNeeded];
}

- (void)test_whenSettingUpTest_thenCollectionViewIsLoaded {
    [self setupWithObjects:@[
                             genTestObject(@1, @2),
                             genTestObject(@2, @3)
                             ]];
    XCTAssertEqual(self.collectionView.numberOfSections, 2);
    XCTAssertEqual([self.collectionView numberOfItemsInSection:0], 2);
    XCTAssertEqual([self.collectionView numberOfItemsInSection:1], 3);
}

- (void)test_whenUsingStringValue_thenCellLabelsAreConfigured {
    [self setupWithObjects:@[
                             genTestObject(@0, @"Foo"),
                             genTestObject(@1, @"Bar")
                             ]];

    IGTestCell *cell = (IGTestCell*)[self.collectionView cellForItemAtIndexPath:genIndexPath(0)];
    XCTAssertEqualObjects(cell.label.text, @"Foo");
    XCTAssertEqual(cell.delegate, [self.adapter itemControllerForItem:self.dataSource.objects[0]]);
}

- (void)test_whenUpdating_withEqualObjects_thatCellConfigurationDoesntChange {
    [self setupWithObjects:@[
                             genTestObject(@0, @"Foo"),
                             genTestObject(@1, @"Bar")
                             ]];

    // Get the item controller before we change the data source or perform updates
    id c0 = [self.adapter itemControllerForItem:self.dataSource.objects[0]];

    // Set equal but new-instance objects on the data source
    self.dataSource.objects = @[
                                genTestObject(@0, @"Foo"),
                                genTestObject(@1, @"Bar")
                                ];

    // Perform updates on the adapter and check that the cell config uses the same item controller as before the updates
    XCTestExpectation *expectation = genExpectation;
    [self.adapter performUpdatesAnimated:YES completion:^(BOOL finished) {
        IGTestCell *cell = (IGTestCell*)[self.collectionView cellForItemAtIndexPath:genIndexPath(0)];
        XCTAssertEqualObjects(cell.label.text, @"Foo");
        XCTAssertNotNil(cell.delegate);
        XCTAssertEqual(cell.delegate, c0);
        XCTAssertEqual(cell.delegate, [self.adapter itemControllerForItem:self.dataSource.objects[0]]);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:15 handler:nil];
}

- (void)test_whenReloadingItem_cellConfigurationChanges {
    [self setupWithObjects:@[
                             genTestObject(@0, @"Foo"),
                             genTestObject(@1, @"Bar")
                             ]];

    // make sure our cells are propertly configured
    IGTestCell *cell1 = (IGTestCell*)[self.collectionView cellForItemAtIndexPath:genIndexPath(0)];
    IGTestCell *cell2 = (IGTestCell*)[self.collectionView cellForItemAtIndexPath:genIndexPath(1)];
    XCTAssertEqualObjects(cell1.label.text, @"Foo");
    XCTAssertEqualObjects(cell2.label.text, @"Bar");

    // Change the string value of both instances in the data source
    IGTestObject *item1 = self.dataSource.objects[0];
    item1.value = @"Baz";
    IGTestObject *item2 = self.dataSource.objects[1];
    item2.value = @"Quz";

    // Only reload the first item, not the second
    [self.adapter reloadItems:@[item1]];

    // The collection view will likely create new cells
    cell1 = (IGTestCell*)[self.collectionView cellForItemAtIndexPath:genIndexPath(0)];
    cell2 = (IGTestCell*)[self.collectionView cellForItemAtIndexPath:genIndexPath(1)];

    // Make sure that the cell in the first section was reloaded
    XCTAssertEqualObjects(cell1.label.text, @"Baz");
    // The cell in the second section should not be reloaded and should equal the string value from setup
    XCTAssertEqualObjects(cell2.label.text, @"Bar");
}

- (void)test_whenObjectEqualityChanges_thatSectionCountChanges {
    [self setupWithObjects:@[
                             genTestObject(@1, @2),
                             genTestObject(@2, @2)
                             ]];

    self.dataSource.objects = @[
                                genTestObject(@1, @2),
                                genTestObject(@2, @3), // updated to 3 items (from 2)
                                genTestObject(@3, @2), // insert new object
                                ];

    XCTestExpectation *expectation = genExpectation;
    [self.adapter performUpdatesAnimated:YES completion:^(BOOL finished2) {
        XCTAssertEqual(self.collectionView.numberOfSections, 3);
        XCTAssertEqual([self.collectionView numberOfItemsInSection:0], 2);
        XCTAssertEqual([self.collectionView numberOfItemsInSection:1], 3);
        XCTAssertEqual([self.collectionView numberOfItemsInSection:2], 2);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:15 handler:nil];
}

- (void)test_whenUpdatesComplete_thatCellsExist {
    [self setupWithObjects:@[
                             genTestObject(@1, @2),
                             genTestObject(@2, @2),
                             ]];
    XCTestExpectation *expectation = genExpectation;
    [self.adapter performUpdatesAnimated:YES completion:^(BOOL finished) {
        XCTAssertNotNil([self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]]);
        XCTAssertNotNil([self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]]);
        XCTAssertNotNil([self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1]]);
        XCTAssertNotNil([self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:1]]);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:15 handler:nil];
}

- (void)test_whenReloadDataCompletes_thatCellsExist {
    [self setupWithObjects:@[
                            genTestObject(@1, @2),
                            genTestObject(@2, @2)
                            ]];
    XCTestExpectation *expectation = genExpectation;
    [self.adapter reloadDataWithCompletion:^(BOOL finished) {
        XCTAssertNotNil([self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]]);
        XCTAssertNotNil([self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]]);
        XCTAssertNotNil([self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1]]);
        XCTAssertNotNil([self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:1]]);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:15 handler:nil];
}

- (void)test_whenItemControllerInsertsIndexes_thatCountsAreUpdated {
    [self setupWithObjects:@[
                             genTestObject(@1, @2),
                             genTestObject(@2, @2)
                             ]];

    IGTestObject *object = self.dataSource.objects[0];
    IGListItemController<IGListItemType> *itemController = [self.adapter itemControllerForItem:object];

    XCTestExpectation *expectation = genExpectation;
    [itemController.collectionContext performBatchAnimated:YES updates:^{
        object.value = @3;
        [itemController.collectionContext insertItemsInItemController:itemController atIndexes:[NSIndexSet indexSetWithIndex:2]];
    } completion:^(BOOL finished2) {
        XCTAssertEqual([self.collectionView numberOfSections], 2);
        XCTAssertEqual([self.collectionView numberOfItemsInSection:0], 3);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:15 handler:nil];
}

- (void)test_whenItemControllerDeletesIndexes_thatCountsAreUpdated {
    // 2 sections each with 2 objects
    [self setupWithObjects:@[
                             genTestObject(@1, @2),
                             genTestObject(@2, @2)
                             ]];

    IGTestObject *object = self.dataSource.objects[0];
    IGListItemController<IGListItemType> *itemController = [self.adapter itemControllerForItem:object];

    XCTestExpectation *expectation = genExpectation;
    [itemController.collectionContext performBatchAnimated:YES updates:^{
        object.value = @1;
        [itemController.collectionContext deleteItemsInItemController:itemController atIndexes:[NSIndexSet indexSetWithIndex:0]];
    } completion:^(BOOL finished2) {
        XCTAssertEqual([self.collectionView numberOfSections], 2);
        XCTAssertEqual([self.collectionView numberOfItemsInSection:0], 1);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:15 handler:nil];
}

- (void)test_whenItemControllerReloadsIndexes_thatCellConfigurationUpdates {
    [self setupWithObjects:@[
                             genTestObject(@1, @"a"),
                             genTestObject(@2, @"b")
                             ]];
    XCTAssertEqual([self.collectionView numberOfSections], 2);
    IGTestCell *cell = (IGTestCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    XCTAssertEqualObjects(cell.label.text, @"a");

    IGTestObject *object = self.dataSource.objects[0];
    IGListItemController<IGListItemType> *itemController = [self.adapter itemControllerForItem:object];

    XCTestExpectation *expectation = genExpectation;
    [itemController.collectionContext performBatchAnimated:YES updates:^{
        object.value = @"c";
        [itemController.collectionContext reloadItemsInItemController:itemController atIndexes:[NSIndexSet indexSetWithIndex:0]];
    } completion:^(BOOL finished2) {
        XCTAssertEqual([self.collectionView numberOfSections], 2);
        IGTestCell *updatedCell = (IGTestCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        XCTAssertEqualObjects(updatedCell.label.text, @"c");
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:15 handler:nil];
}

- (void)test_whenItemControllerReloads_thatCountsAreUpdated {
    [self setupWithObjects:@[
                             genTestObject(@1, @2),
                             genTestObject(@2, @2)
                             ]];

    IGTestObject *object = self.dataSource.objects[0];
    IGListItemController<IGListItemType> *itemController = [self.adapter itemControllerForItem:object];

    XCTestExpectation *expectation = genExpectation;
    [itemController.collectionContext performBatchAnimated:YES updates:^{
        object.value = @3;
        [itemController.collectionContext reloadItemController:itemController];
    } completion:^(BOOL finished2) {
        XCTAssertEqual([self.collectionView numberOfSections], 2);
        XCTAssertEqual([self.collectionView numberOfItemsInSection:0], 3);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:15 handler:nil];
}

- (void)test_whenPerformingUpdates_withItemControllerMutations_thatCollectionCountsAreUpdated {
    [self setupWithObjects:@[
                             genTestObject(@1, @2),
                             genTestObject(@2, @2)
                             ]];
    IGTestObject *object1 = self.dataSource.objects[0];
    IGTestObject *object2 = self.dataSource.objects[1];

    // insert a new object in front of the one we are doing an item-level insert on
    self.dataSource.objects = @[
                                genTestObject(@3, @1), // new
                                object1,
                                object2,
                                ];

    IGListItemController<IGListItemType> *itemController1 = [self.adapter itemControllerForItem:object1];
    IGListItemController<IGListItemType> *itemController2 = [self.adapter itemControllerForItem:object2];

    [self.adapter performUpdatesAnimated:YES completion:nil];

    XCTestExpectation *expectation = genExpectation;
    [itemController1.collectionContext performBatchAnimated:YES updates:^{
        object1.value = @1;
        object2.value = @3;
        [itemController1.collectionContext deleteItemsInItemController:itemController1 atIndexes:[NSIndexSet indexSetWithIndex:0]];
        [itemController2.collectionContext insertItemsInItemController:itemController2 atIndexes:[NSIndexSet indexSetWithIndex:2]];
        [itemController2.collectionContext reloadItemsInItemController:itemController2 atIndexes:[NSIndexSet indexSetWithIndex:0]];
    } completion:^(BOOL finished2) {
        // 3 sections now b/c of the insert
        XCTAssertEqual([self.collectionView numberOfSections], 3);
        XCTAssertEqual([self.collectionView numberOfItemsInSection:0], 1);
        XCTAssertEqual([self.collectionView numberOfItemsInSection:1], 1);
        XCTAssertEqual([self.collectionView numberOfItemsInSection:2], 3);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:15 handler:nil];
}

- (void)test_whenItemControllerMoves_withItemControllerMutations_thatCollectionViewWorks {
    [self setupWithObjects:@[
                             genTestObject(@1, @2),
                             genTestObject(@2, @2)
                             ]];

    IGTestObject *object = self.dataSource.objects[0];
    self.dataSource.objects = @[
                                genTestObject(@2, @2),
                                object, // moved from 0 to 1
                                ];

    IGListItemController<IGListItemType> *itemController = [self.adapter itemControllerForItem:object];

    // queue the update that performs the section move
    [self.adapter performUpdatesAnimated:YES completion:nil];

    XCTestExpectation *expectation = genExpectation;

    // queue an item update that gets batched with the section move
    [itemController.collectionContext performBatchAnimated:YES updates:^{
        object.value = @3;
        [itemController.collectionContext insertItemsInItemController:itemController atIndexes:[NSIndexSet indexSetWithIndex:2]];
    } completion:^(BOOL finished2) {
        XCTAssertEqual([self.collectionView numberOfSections], 2);
        // the object we are tracking should now be in section 1 and have 3 items
        XCTAssertEqual([self.collectionView numberOfItemsInSection:1], 3);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:15 handler:nil];
}

- (void)test_whenItemIsRemoved_withItemControllerMutations_thatCollectionViewWorks {
    // 2 sections each with 2 objects
    [self setupWithObjects:@[
                             genTestObject(@2, @2),
                             genTestObject(@1, @2)
                             ]];
    IGTestObject *object = self.dataSource.objects[1];

    // object at index 1 deleted
    self.dataSource.objects = @[
                                genTestObject(@2, @2),
                                ];

    IGListItemController<IGListItemType> *itemController = [self.adapter itemControllerForItem:object];

    [self.adapter performUpdatesAnimated:YES completion:nil];

    XCTestExpectation *expectation = genExpectation;
    [itemController.collectionContext performBatchAnimated:YES updates:^{
        object.value = @1;
        [itemController.collectionContext deleteItemsInItemController:itemController atIndexes:[NSIndexSet indexSetWithIndex:0]];
    } completion:^(BOOL finished2) {
        XCTAssertEqual([self.collectionView numberOfSections], 1);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:15 handler:nil];
}

- (void)test_whenPerformingUpdates_withUnequalItem_withItemMoving_thatCollectionViewCountsUpdate {
    [self setupWithObjects:@[
                            genTestObject(@1, @2),
                            genTestObject(@2, @2),
                            ]];

    self.dataSource.objects = @[
                                genTestObject(@3, @2),
                                genTestObject(@1, @3), // moved from index 0 to 1, value changed from 2 to 3
                                genTestObject(@2, @2),
                                ];

    XCTestExpectation *expectation = genExpectation;
    [self.adapter performUpdatesAnimated:YES completion:^(BOOL finished2) {
        XCTAssertEqual([self.collectionView numberOfSections], 3);
        XCTAssertEqual([self.collectionView numberOfItemsInSection:1], 3);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:15 handler:nil];
}

- (void)test_whenPerformingUpdates_withItemMoving_withItemControllerReloadIndexes_thatCollectionViewCountsUpdate {
    [self setupWithObjects:@[
                            genTestObject(@1, @2),
                            genTestObject(@2, @3),
                            ]];

    IGListItemController<IGListItemType> *itemController = [self.adapter itemControllerForItem:self.dataSource.objects[0]];

    self.dataSource.objects = @[
                                genTestObject(@2, @3),
                                genTestObject(@1, @2), // moved from index 0 to 1
                                ];

    [self.adapter performUpdatesAnimated:YES completion:nil];

    XCTestExpectation *expectation = genExpectation;
    [itemController.collectionContext performBatchAnimated:YES updates:^{
        [itemController.collectionContext reloadItemsInItemController:itemController atIndexes:[NSIndexSet indexSetWithIndex:0]];
    } completion:^(BOOL finished2) {
        XCTAssertEqual([self.collectionView numberOfSections], 2);
        XCTAssertEqual([self.collectionView numberOfItemsInSection:0], 3);
        XCTAssertEqual([self.collectionView numberOfItemsInSection:1], 2);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:15 handler:nil];
}

- (void)test_whenPerformingUpdates_withItemControllerReloadIndexes_withItemDeleted_thatCollectionViewCountsUpdate {
    [self setupWithObjects:@[
                             genTestObject(@1, @2), // item that will be deleted
                             genTestObject(@2, @3),
                             ]];

    IGListItemController<IGListItemType> *itemController = [self.adapter itemControllerForItem:self.dataSource.objects[0]];

    self.dataSource.objects = @[
                                genTestObject(@2, @3),
                                ];

    [self.adapter performUpdatesAnimated:YES completion:nil];

    XCTestExpectation *expectation = genExpectation;
    [itemController.collectionContext performBatchAnimated:YES updates:^{
        [itemController.collectionContext reloadItemsInItemController:itemController atIndexes:[NSIndexSet indexSetWithIndex:0]];
    } completion:^(BOOL finished2) {
        XCTAssertEqual([self.collectionView numberOfSections], 1);
        XCTAssertEqual([self.collectionView numberOfItemsInSection:0], 3);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:15 handler:nil];
}

- (void)test_whenPerformingUpdates_withNewItemInstances_thatItemControllersEqual {
    [self setupWithObjects:@[
                            genTestObject(@1, @2),
                            genTestObject(@2, @2)
                            ]];

    // grab item controllers before updating the objects
    NSArray *beforeUpdateItems = self.dataSource.objects;
    IGListItemController<IGListItemType> *itemController1 = [self.adapter itemControllerForItem:beforeUpdateItems.firstObject];
    IGListItemController<IGListItemType> *itemController2 = [self.adapter itemControllerForItem:beforeUpdateItems.lastObject];

    self.dataSource.objects = @[
                                genTestObject(@1, @3), // new instance, value changed from 2 to 3
                                genTestObject(@2, @2), // new instance but unchanged
                                ];

    XCTestExpectation *expectation = genExpectation;
    [self.adapter performUpdatesAnimated:YES completion:^(BOOL finished2) {
        XCTAssertEqual([self.collectionView numberOfSections], 2);
        XCTAssertEqual([self.collectionView numberOfItemsInSection:0], 3);
        XCTAssertEqual([self.collectionView numberOfItemsInSection:1], 2);

        NSArray *afterUpdateItems = [self.adapter items];
        // pointer equality
        XCTAssertEqual([self.adapter itemControllerForItem:afterUpdateItems.firstObject], itemController1);
        XCTAssertEqual([self.adapter itemControllerForItem:afterUpdateItems.lastObject], itemController2);

        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:15 handler:nil];
}

- (void)test_whenPerformingMultipleUpdates_withNewItemInstances_thatItemControllersReceiveNewInstances {
    [self setupWithObjects:@[
                             genTestObject(@1, @2),
                             genTestObject(@2, @2),
                             ]];

    id object = self.dataSource.objects[0];
    IGTestDelegateController *itemController = [self.adapter itemControllerForItem:object];

    // test delegate controller counts the number of times it receives -didUpdateToItem:
    XCTAssertEqual(itemController.updateCount, 1);

    self.dataSource.objects = @[
                                object, // same object instance
                                genTestObject(@3, @2),
                                ];

    XCTestExpectation *expectation = genExpectation;
    [self.adapter performUpdatesAnimated:YES completion:^(BOOL finished2) {
        XCTAssertEqual(itemController, [self.adapter itemControllerForItem:[self.adapter items][0]]);

        // should not have received -didUpdateToItem: since the instance did not change
        XCTAssertEqual(itemController.updateCount, 1);

        self.dataSource.objects = @[
                                    genTestObject(@1, @2), // new instance but equal
                                    genTestObject(@3, @2),
                                    ];

        [self.adapter performUpdatesAnimated:YES completion:^(BOOL finished3) {
            XCTAssertEqual(itemController, [self.adapter itemControllerForItem:[self.adapter items][0]]);

            // a new instance was used, make sure the item controller was updated
            XCTAssertEqual(itemController.updateCount, 2);

            [expectation fulfill];
        }];
    }];
    [self waitForExpectationsWithTimeout:15 handler:nil];
}

- (void)test_whenQueryingCollectionContext_withNewItemInstances_thatSectionMatchesCurrentIndex {
    [self setupWithObjects:@[
                             genTestObject(@1, @2),
                             genTestObject(@2, @2),
                             ]];

    IGTestDelegateController *itemController = [self.adapter itemControllerForItem:self.dataSource.objects[0]];

    XCTestExpectation *expectation = genExpectation;
    [self.adapter performUpdatesAnimated:YES completion:^(BOOL finished2) {
        self.dataSource.objects = @[
                                    genTestObject(@2, @2),
                                    genTestObject(@1, @2), // new instance but equal
                                    genTestObject(@3, @2),
                                    ];

        __block BOOL executedUpdateBlock = NO;
        __weak __typeof__(itemController) weakItemController = itemController;
        itemController.itemUpdateBlock = ^{
            executedUpdateBlock = YES;
            XCTAssertEqual([weakItemController.collectionContext sectionForItemController:weakItemController], 1);
        };

        [self.adapter performUpdatesAnimated:YES completion:^(BOOL finished3) {
            XCTAssertTrue(executedUpdateBlock);

            [expectation fulfill];
        }];
    }];

    [self waitForExpectationsWithTimeout:15 handler:nil];
}

- (void)test_whenItemControllerMutates_withReloadData_thatItemControllerMutationIsApplied {
    [self setupWithObjects:@[
                             genTestObject(@1, @2),
                             genTestObject(@2, @2),
                             ]];
    IGTestObject *object = self.dataSource.objects[0];
    IGListItemController<IGListItemType> *itemController = [self.adapter itemControllerForItem:object];

    [itemController.collectionContext performBatchAnimated:YES updates:^{
        object.value = @3;
        [itemController.collectionContext insertItemsInItemController:itemController atIndexes:[NSIndexSet indexSetWithIndex:2]];
    } completion:nil];

    XCTestExpectation *expectation = genExpectation;
    [self.adapter reloadDataWithCompletion:^(BOOL finished2) {
        XCTAssertEqual([self.collectionView numberOfSections], 2);

        // check that the count of items in section 0 was updated from the previous batch update block
        XCTAssertEqual([self.collectionView numberOfItemsInSection:0], 3);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:15 handler:nil];
}

- (void)test_whenContentOffsetChanges_withPerformUpdates_thatCollectionViewWorks {
    // this test layout changes the offset in -prepareLayout which occurs somewhere between the update block being
    // applied and the completion block
    self.collectionView.collectionViewLayout = [IGListTestOffsettingLayout new];

    [self setupWithObjects:@[
                             genTestObject(@1, @2),
                             genTestObject(@2, @2),
                             genTestObject(@3, @2),
                             ]];

    // remove the last object to check that we don't access OOB item controller when the layout changes the offset
    self.dataSource.objects = @[
                                genTestObject(@1, @2),
                                genTestObject(@2, @2),
                                ];

    XCTestExpectation *expectation = genExpectation;
    [self.adapter performUpdatesAnimated:YES completion:^(BOOL finished2) {
        XCTAssertEqual([self.collectionView numberOfSections], 2);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:15 handler:nil];
}

- (void)test_whenReloadingItems_withNewItemInstances_thatItemControllersReceiveNewInstances {
    [self setupWithObjects:@[
                             genTestObject(@1, @2),
                             genTestObject(@2, @2),
                             genTestObject(@3, @2),
                             ]];

    IGTestDelegateController *itemController1 = [self.adapter itemControllerForItem:genTestObject(@1, @2)];
    IGTestDelegateController *itemController2 = [self.adapter itemControllerForItem:genTestObject(@2, @2)];

    NSArray *newObjects = @[
                            genTestObject(@1, @3),
                            genTestObject(@2, @3),
                            ];
    [self.adapter reloadItems:newObjects];

    XCTAssertEqual(itemController1.item, newObjects[0]);
    XCTAssertEqual(itemController2.item, newObjects[1]);
    XCTAssertTrue([[self.adapter.itemMap items] indexOfObjectIdenticalTo:newObjects[0]] != NSNotFound);
    XCTAssertTrue([[self.adapter.itemMap items] indexOfObjectIdenticalTo:newObjects[1]] != NSNotFound);
}

- (void)test_whenReloadingItems_withPerformUpdates_thatReloadIsApplied {
    [self setupWithObjects:@[
                             genTestObject(@1, @1),
                             genTestObject(@2, @2),
                             genTestObject(@3, @3),
                             ]];

    IGTestObject *object = self.dataSource.objects[0];
    IGTestDelegateController *itemController = [self.adapter itemControllerForItem:object];

    // using performBatchAnimated: to mimic re-entrant item reload
    [itemController.collectionContext performBatchAnimated:YES updates:^{
        object.value = @4; // from @1
        [self.adapter reloadItems:@[object]];
    } completion:nil];

    // object is moved from position 0 to 1
    // it is also mutated in the previous update block AND queued for a reload
    self.dataSource.objects = @[
                                genTestObject(@3, @3),
                                object,
                                genTestObject(@2, @2),
                                ];

    XCTestExpectation *expectation = genExpectation;
    [self.adapter performUpdatesAnimated:YES completion:^(BOOL finished2) {
        XCTAssertEqual([self.collectionView numberOfItemsInSection:0], 3);
        XCTAssertEqual([self.collectionView numberOfItemsInSection:1], 4); // reloaded section
        XCTAssertEqual([self.collectionView numberOfItemsInSection:2], 2);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:15 handler:nil];
}

- (void)test_whenItemControllerMutates_whenThereIsNoWindow_thatCollectionViewCountsAreUpdated {
    // remove the collection view from self.window so that we use reloadData
    [self.collectionView removeFromSuperview];

    [self setupWithObjects:@[
                             genTestObject(@1, @8)
                             ]];
    IGTestObject *object = self.dataSource.objects[0];

    IGTestDelegateController *itemController = [self.adapter itemControllerForItem:object];

    XCTestExpectation *expectation = genExpectation;
    // using performBatchAnimated: to mimic re-entrant item reload
    [itemController.collectionContext performBatchAnimated:YES updates:^{
        object.value = @6; // from @1

        [itemController.collectionContext reloadItemsInItemController:itemController atIndexes:[NSIndexSet indexSetWithIndex:0]];
        [itemController.collectionContext deleteItemsInItemController:itemController atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(5, 3)]];
        [itemController.collectionContext insertItemsInItemController:itemController atIndexes:[NSIndexSet indexSetWithIndex:0]];

    } completion:^(BOOL finished2) {
        XCTAssertEqual([self.collectionView numberOfItemsInSection:0], 6);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:15 handler:nil];
}

- (void)test_whenPerformingUpdates_withoutSettingDataSource_thatCompletionBlockExecutes {
    IGListCollectionView *collectionView = [[IGListCollectionView alloc] initWithFrame:self.window.frame collectionViewLayout:[UICollectionViewFlowLayout new]];
    [self.window addSubview:collectionView];
    IGListAdapter *adapter = [[IGListAdapter alloc] initWithUpdatingDelegate:[IGListAdapterUpdater new] viewController:nil workingRangeSize:0];
    adapter.collectionView = collectionView;

    self.dataSource.objects = @[
                                genTestObject(@1, @1)
                                ];

    XCTestExpectation *expectation = genExpectation;

    // call -performUpdatesAnimated: before we have set the data source
    [adapter performUpdatesAnimated:YES completion:^(BOOL finished) {

        // since the data source isnt set, we complete syncronously. dispatch_async simulates setting the data source
        // in a different runloop from the completion block so it should be set by the time we make our subsequent
        // -performUpdatesAnimated: call
        dispatch_async(dispatch_get_main_queue(), ^{
            self.dataSource.objects = @[
                                        genTestObject(@1, @1),
                                        genTestObject(@2, @2)
                                        ];
            [adapter performUpdatesAnimated:YES completion:^(BOOL finished2) {
                XCTAssertEqual([collectionView numberOfSections], 2);
                [expectation fulfill];
            }];
        });
    }];

    // setting the data source immediately queries it, since the collection view is also set
    adapter.dataSource = self.dataSource;
    // simulate display reloading data on the collection view
    [collectionView layoutIfNeeded];

    [self waitForExpectationsWithTimeout:15 handler:nil];
}

- (void)test_whenPerformingUpdates_withItemsMovingInBlocks_thatCollectionViewWorks {
    [self setupWithObjects:@[
                             genTestObject(@1, @0),
                             genTestObject(@2, @7),
                             genTestObject(@3, @8),
                             genTestObject(@4, @8),
                             genTestObject(@5, @8),
                             genTestObject(@6, @5),
                             genTestObject(@7, @8),
                             genTestObject(@8, @8),
                             genTestObject(@9, @8),
                             ]];

    IGListCollectionView *collectionView = [[IGListCollectionView alloc] initWithFrame:self.window.frame collectionViewLayout:[UICollectionViewFlowLayout new]];
    [self.window addSubview:collectionView];
    IGListAdapterUpdater *updater = [IGListAdapterUpdater new];
    IGListAdapter *adapter = [[IGListAdapter alloc] initWithUpdatingDelegate:updater viewController:nil workingRangeSize:0];
    adapter.dataSource = self.dataSource;
    adapter.collectionView = collectionView;
    [collectionView layoutSubviews];

    XCTAssertEqual([collectionView numberOfSections], 9);

    self.dataSource.objects = @[
                                genTestObject(@1, @0),
                                genTestObject(@10, @5),
                                genTestObject(@11, @7),
                                genTestObject(@2, @7),
                                genTestObject(@3, @8),
                                genTestObject(@6, @5), // "moves" in front of 4, 5 but doesn't change index in array
                                genTestObject(@4, @8),
                                genTestObject(@5, @8),
                                genTestObject(@7, @8),
                                genTestObject(@8, @8),
                                ];

    XCTestExpectation *expectation = genExpectation;
    [adapter performUpdatesAnimated:YES completion:^(BOOL finished) {
        XCTAssertEqual([collectionView numberOfSections], 10);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:15 handler:nil];
}

- (void)test_whenReleasingObjects_thatAssertDoesntFire {
    [self setupWithObjects:@[
                             genTestObject(@1, @1)
                             ]];

    // if the adapter keeps a strong ref to self and uses an async method, this will hit asserts that a list item
    // controller is nil. the adapter should be released and the completion block never called.
    @autoreleasepool {
        IGListAdapterUpdater *updater = [[IGListAdapterUpdater alloc] init];
        IGListAdapter *adapter = [[IGListAdapter alloc] initWithUpdatingDelegate:updater viewController:nil workingRangeSize:2];
        adapter.collectionView = self.collectionView;
        adapter.dataSource = self.dataSource;
        [adapter performUpdatesAnimated:NO completion:^(BOOL finished) {
            XCTAssertTrue(NO, @"Should not reach completion block for adapter");
        }];
    }

    self.collectionView = nil;
    self.dataSource = nil;

    // queued after perform updates
    XCTestExpectation *expectation = genExpectation;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:15 handler:nil];
}

- (void)test_whenItemDeleted_withDisplayDelegate_thatDelegateReceivesDeletedItem {
    [self setupWithObjects:@[
                             genTestObject(@1, @1),
                             genTestObject(@2, @2),
                             ]];
    IGTestObject *object = self.dataSource.objects[0];

    self.dataSource.objects = @[
                                genTestObject(@2, @2),
                                ];

    id mockDisplayHandler = [OCMockObject mockForProtocol:@protocol(IGListAdapterDelegate)];
    self.adapter.delegate = mockDisplayHandler;

    [[mockDisplayHandler expect] listAdapter:self.adapter didEndDisplayingItem:object atIndex:0];

    XCTestExpectation *expectation = genExpectation;
    [self.adapter performUpdatesAnimated:YES completion:^(BOOL finished2) {
        [mockDisplayHandler verify];
        XCTAssertTrue(finished2);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:15 handler:nil];
}

- (void)test_whenItemReloaded_withDisplacingMutations_thatCollectionViewWorks {
    [self setupWithObjects:@[
                             genTestObject(@1, @1),
                             genTestObject(@2, @1),
                             genTestObject(@3, @1),
                             genTestObject(@4, @1),
                             genTestObject(@5, @1),
                             ]];

    self.dataSource.objects = @[
                                genTestObject(@1, @1),
                                genTestObject(@2, @2), // reloaded
                                genTestObject(@5, @2), // reloaded
                                genTestObject(@4, @2), // reloaded
                                genTestObject(@3, @1),
                                ];

    XCTestExpectation *expectation = genExpectation;
    [self.adapter performUpdatesAnimated:YES completion:^(BOOL finished) {
        XCTAssertTrue(finished);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:15 handler:nil];
}

- (void)test_whenCollectionViewAppears_thatWillDisplayEventsAreSent {
    [self setupWithObjects:@[
                             genTestObject(@1, @1),
                             genTestObject(@2, @2),
                             ]];
    IGTestDelegateController *ic1 = [self.adapter itemControllerForItem:self.dataSource.objects[0]];
    XCTAssertEqual(ic1.willDisplayCount, 1);
    XCTAssertEqual(ic1.didEndDisplayCount, 0);
    XCTAssertEqual([ic1.willDisplayCellIndexes countForObject:@0], 1);
    XCTAssertEqual([ic1.didEndDisplayCellIndexes countForObject:@0], 0);

    IGTestDelegateController *ic2 = [self.adapter itemControllerForItem:self.dataSource.objects[1]];
    XCTAssertEqual(ic2.willDisplayCount, 1);
    XCTAssertEqual(ic2.didEndDisplayCount, 0);
    XCTAssertEqual([ic2.willDisplayCellIndexes countForObject:@0], 1);
    XCTAssertEqual([ic2.willDisplayCellIndexes countForObject:@1], 1);
    XCTAssertEqual([ic2.didEndDisplayCellIndexes countForObject:@0], 0);
    XCTAssertEqual([ic2.didEndDisplayCellIndexes countForObject:@1], 0);
}

- (void)test_whenAdapterUpdates_withItemUpdated_thatdidEndDisplayEventsAreSent {
    [self setupWithObjects:@[
                             genTestObject(@1, @1),
                             genTestObject(@2, @2),
                             ]];
    IGTestDelegateController *ic1 = [self.adapter itemControllerForItem:self.dataSource.objects[0]];
    IGTestDelegateController *ic2 = [self.adapter itemControllerForItem:self.dataSource.objects[1]];

    self.dataSource.objects = @[
                                genTestObject(@1, @1),
                                genTestObject(@2, @1), // reloaded w/ 1 cell removed
                                ];

    XCTestExpectation *expectation = genExpectation;
    [self.adapter performUpdatesAnimated:YES completion:^(BOOL finished) {
        XCTAssertEqual(ic1.willDisplayCount, 1);
        XCTAssertEqual(ic1.didEndDisplayCount, 0);
        XCTAssertEqual([ic1.willDisplayCellIndexes countForObject:@0], 1);
        XCTAssertEqual([ic1.didEndDisplayCellIndexes countForObject:@0], 0);

        XCTAssertEqual(ic2.willDisplayCount, 1);
        XCTAssertEqual(ic2.didEndDisplayCount, 0);
        XCTAssertEqual([ic2.willDisplayCellIndexes countForObject:@1], 1);
        XCTAssertEqual([ic2.didEndDisplayCellIndexes countForObject:@1], 1);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:15 handler:nil];
}

- (void)test_whenAdapterUpdates_withItemRemoved_thatdidEndDisplayEventsAreSent {
    [self setupWithObjects:@[
                             genTestObject(@1, @1),
                             genTestObject(@2, @2),
                             ]];
    IGTestDelegateController *ic1 = [self.adapter itemControllerForItem:self.dataSource.objects[0]];
    IGTestDelegateController *ic2 = [self.adapter itemControllerForItem:self.dataSource.objects[1]];

    self.dataSource.objects = @[
                                genTestObject(@1, @1)
                                ];

    XCTestExpectation *expectation = genExpectation;
    [self.adapter performUpdatesAnimated:YES completion:^(BOOL finished) {
        XCTAssertEqual(ic1.willDisplayCount, 1);
        XCTAssertEqual(ic1.didEndDisplayCount, 0);
        XCTAssertEqual([ic1.willDisplayCellIndexes countForObject:@0], 1);
        XCTAssertEqual([ic1.didEndDisplayCellIndexes countForObject:@0], 0);

        XCTAssertEqual(ic2.willDisplayCount, 1);
        XCTAssertEqual(ic2.didEndDisplayCount, 1);
        XCTAssertEqual([ic2.willDisplayCellIndexes countForObject:@0], 1);
        XCTAssertEqual([ic2.willDisplayCellIndexes countForObject:@1], 1);
        XCTAssertEqual([ic2.didEndDisplayCellIndexes countForObject:@0], 1);
        XCTAssertEqual([ic2.didEndDisplayCellIndexes countForObject:@1], 1);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:15 handler:nil];
}

- (void)test_whenAdapterUpdates_withEmptyItems_thatdidEndDisplayEventsAreSent {
    [self setupWithObjects:@[
                             genTestObject(@1, @1),
                             genTestObject(@2, @2),
                             ]];
    IGTestDelegateController *ic1 = [self.adapter itemControllerForItem:self.dataSource.objects[0]];
    IGTestDelegateController *ic2 = [self.adapter itemControllerForItem:self.dataSource.objects[1]];

    self.dataSource.objects = @[];

    XCTestExpectation *expectation = genExpectation;
    [self.adapter performUpdatesAnimated:YES completion:^(BOOL finished) {
        XCTAssertEqual(ic1.didEndDisplayCount, 1);
        XCTAssertEqual([ic1.didEndDisplayCellIndexes countForObject:@0], 1);

        XCTAssertEqual(ic2.didEndDisplayCount, 1);
        XCTAssertEqual([ic2.didEndDisplayCellIndexes countForObject:@0], 1);
        XCTAssertEqual([ic2.didEndDisplayCellIndexes countForObject:@1], 1);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:15 handler:nil];
}

@end
