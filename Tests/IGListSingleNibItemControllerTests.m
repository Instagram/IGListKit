/**
 * Copyright (c) 2016-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <XCTest/XCTest.h>

#import "IGTestCell.h"
#import "IGTestSingleNibItemDataSource.h"
#import "IGListTestCase.h"

@interface IGListSingleNibSectionControllerTests : IGListTestCase
@end

@implementation IGListSingleNibSectionControllerTests

- (void)setUp {
    self.dataSource = [IGTestSingleNibItemDataSource new];
    [super setUp];
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
    IGTestCell *cell1 = (IGTestCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    IGTestCell *cell2 = (IGTestCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1]];
    IGTestCell *cell3 = (IGTestCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:2]];
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
    IGTestCell *cell1 = (IGTestCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    IGTestCell *cell2 = (IGTestCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1]];
    IGTestCell *cell3 = (IGTestCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:2]];
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
    self.dataSource.objects = @[
                                genTestObject(@1, @"Foo"),
                                genTestObject(@2, @"Qux"), // new value
                                genTestObject(@3, @"Baz"),
                                ];
    XCTestExpectation *expectation = genExpectation;
    [self.adapter performUpdatesAnimated:YES completion:^(BOOL finished) {
        IGTestCell *cell2 = (IGTestCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1]];
        XCTAssertEqualObjects(cell2.label.text, @"Qux");
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:30 handler:nil];
}

@end
