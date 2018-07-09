/**
 * Copyright (c) 2016-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <XCTest/XCTest.h>

#import <IGListKit/IGListCollectionView.h>

#import "IGLayoutTestItem.h"
#import "IGLayoutTestSection.h"
#import "IGLayoutTestDataSource.h"
#import "IGListTestHelpers.h"

@interface IGListCollectionViewTests : XCTestCase

@property (nonatomic, strong) IGListCollectionView *collectionView;
@property (nonatomic, strong) IGLayoutTestDataSource *dataSource;

@end

@implementation IGListCollectionViewTests

- (void)setUp {
    [super setUp];
    self.dataSource = [IGLayoutTestDataSource new];
    self.collectionView = [[IGListCollectionView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    self.collectionView.dataSource = self.dataSource;
    self.collectionView.delegate = self.dataSource;
    [self.dataSource configCollectionView:self.collectionView];
}

#pragma mark - Reload All

- (void)test_whenReloadData_thatEntireLayoutUpdates {
    self.dataSource.sections = @[
                                 genLayoutTestSection(@[genLayoutTestItem(CGSizeMake(10, 10))])
                                 ];
    [self.collectionView reloadData];
    [self.collectionView layoutIfNeeded];

    self.dataSource.sections = @[
                                 genLayoutTestSection(@[genLayoutTestItem(CGSizeMake(20, 20))]),
                                 genLayoutTestSection(@[genLayoutTestItem(CGSizeMake(10, 10))])
                                 ];
    [self.collectionView reloadData];
    [self.collectionView layoutIfNeeded];

    IGAssertEqualFrame([self cellForSection:0 item:0].frame, 0, 0, 20, 20);
    IGAssertEqualFrame([self cellForSection:1 item:0].frame, 20, 0, 10, 10);
}

#pragma mark - Insert/Delete/Reload/Move

- (void)test_whenInsertingSection_thatLayoutPartiallyUpdates {
    self.dataSource.sections = @[
                                 genLayoutTestSection(@[genLayoutTestItem(CGSizeMake(10, 10))])
                                 ];
    [self.collectionView reloadData];
    [self.collectionView layoutIfNeeded];

    self.dataSource.sections = @[
                                 genLayoutTestSection(@[genLayoutTestItem(CGSizeMake(20, 20))]),
                                 genLayoutTestSection(@[genLayoutTestItem(CGSizeMake(10, 10))])
                                 ];
    [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:1]];

    // check that section 0 wasn't updated
    IGAssertEqualFrame([self cellForSection:0 item:0].frame, 0, 0, 10, 10);
    // check that section 1 was updated
    IGAssertEqualFrame([self cellForSection:1 item:0].frame, 10, 0, 10, 10);
}

- (void)test_whenDeletingSection_thatLayoutPartiallyUpdates {
    self.dataSource.sections = @[
                                 genLayoutTestSection(@[genLayoutTestItem(CGSizeMake(10, 10))]),
                                 genLayoutTestSection(@[genLayoutTestItem(CGSizeMake(10, 10))])
                                 ];
    [self.collectionView reloadData];
    [self.collectionView layoutIfNeeded];

    self.dataSource.sections = @[
                                 genLayoutTestSection(@[genLayoutTestItem(CGSizeMake(20, 20))]),
                                 ];
    [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:1]];

    // check that section 0 wasn't updated
    IGAssertEqualFrame([self cellForSection:0 item:0].frame, 0, 0, 10, 10);
}

- (void)test_whenReloadingSection_thatLayoutPartiallyUpdates {
    self.dataSource.sections = @[
                                 genLayoutTestSection(@[genLayoutTestItem(CGSizeMake(10, 10))]),
                                 genLayoutTestSection(@[genLayoutTestItem(CGSizeMake(10, 10))])
                                 ];
    [self.collectionView reloadData];
    [self.collectionView layoutIfNeeded];

    self.dataSource.sections = @[
                                 genLayoutTestSection(@[genLayoutTestItem(CGSizeMake(20, 20))]),
                                 genLayoutTestSection(@[genLayoutTestItem(CGSizeMake(20, 20))]),
                                 ];
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:1]];

    // check that section 0 wasn't updated
    IGAssertEqualFrame([self cellForSection:0 item:0].frame, 0, 0, 10, 10);
    // check that section 1 was updated
    IGAssertEqualFrame([self cellForSection:1 item:0].frame, 10, 0, 20, 20);
}

- (void)test_whenMoveSection_thatLayoutPartiallyUpdates {
    self.dataSource.sections = @[
                                 genLayoutTestSection(@[genLayoutTestItem(CGSizeMake(10, 10))]),
                                 genLayoutTestSection(@[genLayoutTestItem(CGSizeMake(20, 20))]),
                                 genLayoutTestSection(@[genLayoutTestItem(CGSizeMake(30, 30))])
                                 ];
    [self.collectionView reloadData];
    [self.collectionView layoutIfNeeded];

    self.dataSource.sections = @[
                                 genLayoutTestSection(@[genLayoutTestItem(CGSizeMake(40, 40))]),
                                 genLayoutTestSection(@[genLayoutTestItem(CGSizeMake(30, 30))]),
                                 genLayoutTestSection(@[genLayoutTestItem(CGSizeMake(20, 20))]),
                                 ];
    [self.collectionView moveSection:1 toSection:2];

    // check that section 0 wasn't updated
    IGAssertEqualFrame([self cellForSection:0 item:0].frame, 0, 0, 10, 10);
    // check that section 1 was updated
    IGAssertEqualFrame([self cellForSection:1 item:0].frame, 10, 0, 30, 30);
    // check that section 2 was updated
    IGAssertEqualFrame([self cellForSection:2 item:0].frame, 40, 0, 20, 20);
}

#pragma mark - Batch

- (void)test_whenInsertDeleteMoveSection_thatLayoutPartiallyUpdates {
    self.dataSource.sections = @[
                                 genLayoutTestSection(@[genLayoutTestItem(CGSizeMake(1, 1))]),
                                 genLayoutTestSection(@[genLayoutTestItem(CGSizeMake(2, 2))]),
                                 genLayoutTestSection(@[genLayoutTestItem(CGSizeMake(3, 3))]),
                                 genLayoutTestSection(@[genLayoutTestItem(CGSizeMake(4, 4))]),
                                 ];
    [self.collectionView reloadData];
    [self.collectionView layoutIfNeeded];

    self.dataSource.sections = @[
                                 genLayoutTestSection(@[genLayoutTestItem(CGSizeMake(0, 0))]),
                                 genLayoutTestSection(@[genLayoutTestItem(CGSizeMake(4, 4))]),
                                 genLayoutTestSection(@[genLayoutTestItem(CGSizeMake(3, 3))]),
                                 genLayoutTestSection(@[genLayoutTestItem(CGSizeMake(5, 5))]),
                                 ];

    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];

    [self.collectionView performBatchUpdates:^{
        [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:1]]; // deleted (2, 2)
        [self.collectionView moveSection:3 toSection:1]; // move (4, 4)
        [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:3]]; // inserted (5, 5)
    } completion:^(BOOL finished) {
        [self.collectionView layoutIfNeeded];
        [expectation fulfill];

        // check that section 0 wasn't updated
        IGAssertEqualFrame([self cellForSection:0 item:0].frame, 0, 0, 1, 1);
        // check that section 1 was updated
        IGAssertEqualFrame([self cellForSection:1 item:0].frame, 1, 0, 4, 4);
        // check that section 2 was updated
        IGAssertEqualFrame([self cellForSection:2 item:0].frame, 5, 0, 3, 3);
        // check that section 3 was updated
        IGAssertEqualFrame([self cellForSection:3 item:0].frame, 8, 0, 5, 5);
    }];

    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
}

#pragma mark - Helpers

- (UICollectionViewCell *)cellForSection:(NSInteger)section item:(NSInteger)item {
    return [self.collectionView cellForItemAtIndexPath:genIndexPath(section, item)];
}

@end
