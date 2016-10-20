/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <XCTest/XCTest.h>

#import "IGTestStoryboardCell.h"
#import "IGTestSingleStoryboardViewController.h"

#define genTestObject(k, v) [[IGTestObject alloc] initWithKey:k value:v]

#define genExpectation [self expectationWithDescription:NSStringFromSelector(_cmd)]

@interface IGListSingleStoryboardItemControllerTests : XCTestCase

@property (nonatomic, strong) IGListCollectionView *collectionView;
@property (nonatomic, strong) IGListAdapter *adapter;
@property (nonatomic, strong) IGListAdapterUpdater *updater;
@property (nonatomic, strong) IGTestSingleStoryboardViewController *viewController;

@end

@implementation IGListSingleStoryboardItemControllerTests

- (void)setUp {
    [super setUp];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"IGTestStoryboard" bundle:[NSBundle bundleForClass:self.class]];
    self.viewController = [storyboard instantiateViewControllerWithIdentifier:@"testVC"];
    [self.viewController performSelectorOnMainThread:@selector(loadView) withObject:nil waitUntilDone:YES];
    XCTAssertNotNil(self.viewController.collectionView, @"collectionView should be connected");
    self.collectionView = self.viewController.collectionView;
    self.updater = [[IGListAdapterUpdater alloc] init];
    self.adapter = [[IGListAdapter alloc] initWithUpdater:self.updater viewController:self.viewController workingRangeSize:2];
}

- (void)tearDown {
    [super tearDown];
    self.viewController = nil;
    self.collectionView = nil;
    self.adapter = nil;
}

- (void)setupWithObjects:(NSArray *)objects {
    self.viewController.objects = objects;
    self.adapter.collectionView = self.collectionView;
    self.adapter.dataSource = self.viewController;
    [self.collectionView layoutIfNeeded];
}

- (void)test_whenDisplayingCollectionView_thatSectionsHaveOneItem {
    [self setupWithObjects:@[
                             genTestObject(@1, @"Foo"),
                             genTestObject(@2, @"Bar"),
                             genTestObject(@3, @"Baz"),
                             ]];
    XCTAssertEqual([self.collectionView numberOfSections], 3);
    XCTAssertEqual([self.collectionView numberOfItemsInSection:0], 1);
    XCTAssertEqual([self.collectionView numberOfItemsInSection:1], 1);
    XCTAssertEqual([self.collectionView numberOfItemsInSection:2], 1);
}

- (void)test_whenDisplayingCollectionView_thatCellsAreConfigured {
    [self setupWithObjects:@[
                             genTestObject(@1, @"Foo"),
                             genTestObject(@2, @"Bar"),
                             genTestObject(@3, @"Baz"),
                             ]];
    IGTestStoryboardCell *cell1 = (IGTestStoryboardCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    IGTestStoryboardCell *cell2 = (IGTestStoryboardCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1]];
    IGTestStoryboardCell *cell3 = (IGTestStoryboardCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:2]];
    XCTAssertEqualObjects(cell1.label.text, @"Foo");
    XCTAssertEqualObjects(cell2.label.text, @"Bar");
    XCTAssertEqualObjects(cell3.label.text, @"Baz");
}

- (void)test_whenDisplayingCollectionView_thatCellsAreSized {
    [self setupWithObjects:@[
                             genTestObject(@1, @"Foo"),
                             genTestObject(@2, @"Bar"),
                             genTestObject(@3, @"Baz"),
                             ]];
    IGTestStoryboardCell *cell1 = (IGTestStoryboardCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    IGTestStoryboardCell *cell2 = (IGTestStoryboardCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1]];
    IGTestStoryboardCell *cell3 = (IGTestStoryboardCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:2]];
    XCTAssertEqual(cell1.frame.size.height, 44);
    XCTAssertEqual(cell2.frame.size.height, 44);
    XCTAssertEqual(cell3.frame.size.height, 44);
    XCTAssertEqual(cell1.frame.size.width, 100);
    XCTAssertEqual(cell2.frame.size.width, 100);
    XCTAssertEqual(cell3.frame.size.width, 100);
}

- (void)test_whenItemUpdated_thatCellIsConfigured {
    [self setupWithObjects:@[
                             genTestObject(@1, @"Foo"),
                             genTestObject(@2, @"Bar"),
                             genTestObject(@3, @"Baz"),
                             ]];
    self.viewController.objects = @[
                                genTestObject(@1, @"Foo"),
                                genTestObject(@2, @"Qux"), // new value
                                genTestObject(@3, @"Baz"),
                                ];
    XCTestExpectation *expectation = genExpectation;
    [self.adapter performUpdatesAnimated:YES completion:^(BOOL finished) {
        IGTestStoryboardCell *cell2 = (IGTestStoryboardCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1]];
        XCTAssertEqualObjects(cell2.label.text, @"Qux");
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:15 handler:nil];
}

@end
