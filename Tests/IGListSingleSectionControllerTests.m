/**
 * Copyright (c) 2016-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "IGListAdapterInternal.h"
#import "IGTestCell.h"
#import "IGTestSingleItemDataSource.h"
#import "IGListTestCase.h"
#import "IGTestSingleWithoutDeselectionDelegate.h"

@interface IGListSingleSectionControllerTests : IGListTestCase

@end

@implementation IGListSingleSectionControllerTests

- (void)setUp {
    self.dataSource = [IGTestSingleItemDataSource new];
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

- (void)test_whenSelected_thatDelegateReceivesEvent {
    [self setupWithObjects:@[
                             genTestObject(@1, @"a")
                             ]];
    IGListSingleSectionController *section = [self.adapter sectionControllerForObject:self.dataSource.objects.firstObject];
    id mockDelegate = [OCMockObject mockForProtocol:@protocol(IGListSingleSectionControllerDelegate)];
    section.selectionDelegate = mockDelegate;
    [[mockDelegate expect] didSelectSectionController:section withObject:self.dataSource.objects.firstObject];
    [self.adapter collectionView:self.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    [mockDelegate verify];
}

- (void)test_whenDeselected_thatDelegateReceivesEvent {
    [self setupWithObjects:@[
                             genTestObject(@1, @"a")
                             ]];
    IGListSingleSectionController *section = [self.adapter sectionControllerForObject:self.dataSource.objects.firstObject];
    id mockDelegate = [OCMockObject mockForProtocol:@protocol(IGListSingleSectionControllerDelegate)];
    section.selectionDelegate = mockDelegate;
    [[mockDelegate expect] didDeselectSectionController:section withObject:self.dataSource.objects.firstObject];
    [self.adapter collectionView:self.collectionView didDeselectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    [mockDelegate verify];
}

- (void)test_whenDeselected_withoutImplementation_thatNoOps {
    [self setupWithObjects:@[
                             genTestObject(@1, @"a")
                             ]];
    IGListSingleSectionController *section = [self.adapter sectionControllerForObject:self.dataSource.objects.firstObject];
    IGTestSingleWithoutDeselectionDelegate *delegate = [IGTestSingleWithoutDeselectionDelegate new];
    section.selectionDelegate = delegate;

    [self.adapter collectionView:self.collectionView didDeselectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    XCTAssertFalse(delegate.selected);

    [self.adapter collectionView:self.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    XCTAssertTrue(delegate.selected);
}

@end
