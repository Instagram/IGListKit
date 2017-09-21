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

#import "IGTestDiffingDataSource.h"
#import "IGTestDiffingObject.h"
#import "IGTestDiffingSectionController.h"
#import "IGTestStringBindableCell.h"
#import "IGTestNumberBindableCell.h"
#import "IGListAdapterInternal.h"
#import "IGTestObject.h"
#import "IGTestCell.h"
#import "IGListTestCase.h"
#import "IGTestBindingWithoutDeselectionDelegate.h"

@interface IGListBindingSectionControllerTests : IGListTestCase

@end

@implementation IGListBindingSectionControllerTests

- (void)setUp {
    self.dataSource = [IGTestDiffingDataSource new];

    // give us more room to show cells
    self.frame = CGRectMake(0, 0, 100, 1000);

    [super setUp];
}

- (id)cellAtSection:(NSInteger)section item:(NSInteger)item {
    return [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:section]];
}

- (void)test_whenInitialLoad_withEmptyViewModels_thatCollectionViewEmpty {
    [self setupWithObjects:@[
                             [[IGTestDiffingObject alloc] initWithKey:@1 objects:@[]]
                             ]];
    XCTAssertEqual([self.collectionView numberOfSections], 1);
    XCTAssertEqual([self.collectionView numberOfItemsInSection:0], 0);
}

- (void)test_whenInitialLoad_withMultipleViewModels_thatCellsMappedAndConfigured {
    [self setupWithObjects:@[
                             [[IGTestDiffingObject alloc] initWithKey:@1 objects:@[@7, @"seven"]],
                             [[IGTestDiffingObject alloc] initWithKey:@2 objects:@[@"foo", @"bar", @42]],
                             [[IGTestDiffingObject alloc] initWithKey:@3 objects:@[]],
                             ]];

    XCTAssertEqual([self.collectionView numberOfSections], 3);
    XCTAssertEqual([self.collectionView numberOfItemsInSection:0], 2);
    XCTAssertEqual([self.collectionView numberOfItemsInSection:1], 3);
    XCTAssertEqual([self.collectionView numberOfItemsInSection:2], 0);

    IGTestNumberBindableCell *cell00 = [self cellAtSection:0 item:0];
    IGTestStringBindableCell *cell01 = [self cellAtSection:0 item:1];
    IGTestStringBindableCell *cell10 = [self cellAtSection:1 item:0];
    IGTestStringBindableCell *cell11 = [self cellAtSection:1 item:1];
    IGTestNumberBindableCell *cell12 = [self cellAtSection:1 item:2];

    XCTAssertEqualObjects(cell00.textField.text, @"7");
    XCTAssertEqualObjects(cell01.label.text, @"seven");
    XCTAssertEqualObjects(cell10.label.text, @"foo");
    XCTAssertEqualObjects(cell11.label.text, @"bar");
    XCTAssertEqualObjects(cell12.textField.text, @"42");
}

- (void)test_whenUpdating_withAddedModels_thatCellsCorrectAndConfigured {
    [self setupWithObjects:@[
                             [[IGTestDiffingObject alloc] initWithKey:@1 objects:@[@7, @"seven"]],
                             ]];

    self.dataSource.objects = @[
                                [[IGTestDiffingObject alloc] initWithKey:@1 objects:@[@7, @"seven", @8, @"eight"]],
                                ];

    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self.adapter performUpdatesAnimated:YES completion:^(BOOL finished) {
        XCTAssertEqual([self.collectionView numberOfSections], 1);
        XCTAssertEqual([self.collectionView numberOfItemsInSection:0], 4);

        IGTestNumberBindableCell *cell00 = [self cellAtSection:0 item:0];
        IGTestStringBindableCell *cell01 = [self cellAtSection:0 item:1];
        IGTestNumberBindableCell *cell02 = [self cellAtSection:0 item:2];
        IGTestStringBindableCell *cell03 = [self cellAtSection:0 item:3];

        XCTAssertEqualObjects(cell00.textField.text, @"7");
        XCTAssertEqualObjects(cell01.label.text, @"seven");
        XCTAssertEqualObjects(cell02.textField.text, @"8");
        XCTAssertEqualObjects(cell03.label.text, @"eight");

        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)test_whenUpdating_withNotUniqueModels_thatCellsCorrectAndConfigured {
    [self setupWithObjects:@[
                             [[IGTestDiffingObject alloc] initWithKey:@1 objects:@[@7, @"seven"]],
                             ]];
    [self.adapter reloadObjects:@[[[IGTestDiffingObject alloc] initWithKey:@1 objects:@[@"four", @4, @"seven", @7, @"seven", @10]]]];

    IGTestNumberBindableCell *cell00 = [self cellAtSection:0 item:0];
    IGTestStringBindableCell *cell01 = [self cellAtSection:0 item:1];

    XCTAssertEqualObjects(cell00.textField.text, @"7");
    XCTAssertEqualObjects(cell01.label.text, @"seven");
    XCTAssertNil([self cellAtSection:0 item:2]);
    XCTAssertNil([self cellAtSection:0 item:3]);

    // "fake" batch updates to make sure that calling reload triggers a diffed batch update
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self.adapter performBatchAnimated:YES updates:^(id<IGListBatchContext> batchContext){} completion:^(BOOL finished) {
        IGTestStringBindableCell *batchedCell00 = [self cellAtSection:0 item:0];
        IGTestNumberBindableCell *batchedCell01 = [self cellAtSection:0 item:1];
        IGTestStringBindableCell *batchedCell02 = [self cellAtSection:0 item:2];
        IGTestNumberBindableCell *batchedCell03 = [self cellAtSection:0 item:3];
        IGTestNumberBindableCell *batchedCell04 = [self cellAtSection:0 item:4];

        XCTAssertEqualObjects(batchedCell00.label.text, @"four");
        XCTAssertEqualObjects(batchedCell01.textField.text, @"4");
        XCTAssertEqualObjects(batchedCell02.label.text, @"seven");
        XCTAssertEqualObjects(batchedCell03.textField.text, @"7");
        XCTAssertEqualObjects(batchedCell04.textField.text, @"10");

        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)test_whenSelectingCell_thatCorrectViewModelSelected {
    [self setupWithObjects:@[
                             [[IGTestDiffingObject alloc] initWithKey:@1 objects:@[@7, @"seven"]],
                             ]];
    [self.adapter collectionView:self.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];
    IGTestDiffingSectionController *section = [self.adapter sectionControllerForObject:self.dataSource.objects.firstObject];
    XCTAssertEqualObjects(section.selectedViewModel, @"seven");
}

- (void)test_whenDeselectingCell_thatCorrectViewModelSelected {
    [self setupWithObjects:@[
                             [[IGTestDiffingObject alloc] initWithKey:@1 objects:@[@7, @"seven"]],
                             ]];
    [self.adapter collectionView:self.collectionView didDeselectItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];
    IGTestDiffingSectionController *section = [self.adapter sectionControllerForObject:self.dataSource.objects.firstObject];
    XCTAssertEqualObjects(section.deselectedViewModel, @"seven");
}

- (void)test_whenHighlightingCell_thatCorrectViewModelHighlighted {
    [self setupWithObjects:@[
                             [[IGTestDiffingObject alloc] initWithKey:@1 objects:@[@7, @"seven"]],
                             ]];
    [self.adapter collectionView:self.collectionView didHighlightItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];
    IGTestDiffingSectionController *section = [self.adapter sectionControllerForObject:self.dataSource.objects.firstObject];
    XCTAssertEqualObjects(section.highlightedViewModel, @"seven");
}

- (void)test_whenUnhighlightingCell_thatCorrectViewModelUnhighlighted {
    [self setupWithObjects:@[
                             [[IGTestDiffingObject alloc] initWithKey:@1 objects:@[@7, @"seven"]],
                             ]];
    [self.adapter collectionView:self.collectionView didUnhighlightItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];
    IGTestDiffingSectionController *section = [self.adapter sectionControllerForObject:self.dataSource.objects.firstObject];
    XCTAssertEqualObjects(section.unhighlightedViewModel, @"seven");
}

- (void)test_whenDeselectingCell_withoutImplementation_thatNoOps {
    [self setupWithObjects:@[
                             [[IGTestDiffingObject alloc] initWithKey:@1 objects:@[@7, @"seven"]],
                             ]];

    IGTestBindingWithoutDeselectionDelegate *delegate = [IGTestBindingWithoutDeselectionDelegate new];
    IGTestDiffingSectionController *section = [self.adapter sectionControllerForObject:self.dataSource.objects.firstObject];
    section.selectionDelegate = delegate;

    [self.adapter collectionView:self.collectionView didDeselectItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];
    XCTAssertFalse(delegate.selected);

    [self.adapter collectionView:self.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];
    XCTAssertTrue(delegate.selected);
}

- (void)test_whenAdapterReloadsObjects_thatSectionUpdated {
    [self setupWithObjects:@[
                             [[IGTestDiffingObject alloc] initWithKey:@1 objects:@[@7, @"seven"]],
                             ]];
    [self.adapter reloadObjects:@[[[IGTestDiffingObject alloc] initWithKey:@1 objects:@[@"four", @4, @"seven", @7]]]];

    IGTestNumberBindableCell *cell00 = [self cellAtSection:0 item:0];
    IGTestStringBindableCell *cell01 = [self cellAtSection:0 item:1];

    XCTAssertEqualObjects(cell00.textField.text, @"7");
    XCTAssertEqualObjects(cell01.label.text, @"seven");
    XCTAssertNil([self cellAtSection:0 item:2]);
    XCTAssertNil([self cellAtSection:0 item:3]);

    // "fake" batch updates to make sure that calling reload triggers a diffed batch update
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self.adapter performBatchAnimated:YES updates:^(id<IGListBatchContext> batchContext){} completion:^(BOOL finished) {
        IGTestStringBindableCell *batchedCell00 = [self cellAtSection:0 item:0];
        IGTestNumberBindableCell *batchedCell01 = [self cellAtSection:0 item:1];
        IGTestStringBindableCell *batchedCell02 = [self cellAtSection:0 item:2];
        IGTestNumberBindableCell *batchedCell03 = [self cellAtSection:0 item:3];

        XCTAssertEqualObjects(batchedCell00.label.text, @"four");
        XCTAssertEqualObjects(batchedCell01.textField.text, @"4");
        XCTAssertEqualObjects(batchedCell02.label.text, @"seven");
        XCTAssertEqualObjects(batchedCell03.textField.text, @"7");

        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)test_whenUpdating_withViewModelMovesAndReloads_thatCellUpdatedAndInstanceSame {
    NSArray *initObjects = @[
                             @"foo",
                             @"bar",
                             [[IGTestObject alloc] initWithKey:@42 value:@"baz"]
                             ];
    [self setupWithObjects:@[
                             [[IGTestDiffingObject alloc] initWithKey:@1 objects:initObjects]
                             ]];

    XCTAssertEqual([self.collectionView numberOfItemsInSection:0], 3);

    IGTestStringBindableCell *cell00 = [self cellAtSection:0 item:0];
    IGTestStringBindableCell *cell01 = [self cellAtSection:0 item:1];
    IGTestCell *cell02 = [self cellAtSection:0 item:2];

    XCTAssertEqualObjects(cell00.label.text, @"foo");
    XCTAssertEqualObjects(cell01.label.text, @"bar");
    XCTAssertEqualObjects(cell02.label.text, @"baz");

    NSArray *newObjects = @[
                            [[IGTestObject alloc] initWithKey:@42 value:@"bang"], // moved to section 0 and value changed
                            @"foo",
                            @"bar",
                            ];
    self.dataSource.objects = @[
                                [[IGTestDiffingObject alloc] initWithKey:@1 objects:newObjects]
                                ];

    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self.adapter performUpdatesAnimated:YES completion:^(BOOL finished) {
        IGTestCell *batchedCell00 = [self cellAtSection:0 item:0];
        IGTestStringBindableCell *batchedCell01 = [self cellAtSection:0 item:1];
        IGTestStringBindableCell *batchedCell02 = [self cellAtSection:0 item:2];

        XCTAssertEqualObjects(batchedCell00.label.text, @"bang");
        XCTAssertEqualObjects(batchedCell01.label.text, @"foo");
        XCTAssertEqualObjects(batchedCell02.label.text, @"bar");

        XCTAssertEqual(cell00, batchedCell01);
        XCTAssertEqual(cell01, batchedCell02);
        XCTAssertEqual(cell02, batchedCell00);

        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)test_whenUpdatingManually_with2Updates_thatBothCompletionBlocksCalled {
    [self setupWithObjects:@[
                             [[IGTestDiffingObject alloc] initWithKey:@1 objects:@[@7, @"seven"]],
                             ]];
    IGTestDiffingSectionController *section = [self.adapter sectionControllerForObject:self.dataSource.objects[0]];

    XCTestExpectation *expectation1 = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [section updateAnimated:YES completion:^(BOOL updated) {
        XCTAssertTrue(updated);
        [expectation1 fulfill];
    }];

    XCTestExpectation *expectation2 = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [section updateAnimated:YES completion:^(BOOL updated) {
        // queued second, shouldn't execute update block
        XCTAssertFalse(updated);
        [expectation2 fulfill];
    }];

    [self waitForExpectationsWithTimeout:30 handler:nil];
}

@end

