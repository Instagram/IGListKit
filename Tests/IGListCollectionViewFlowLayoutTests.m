/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <XCTest/XCTest.h>

#import "IGListCollectionViewFlowLayout.h"
#import "IGTestCell.h"
#import "IGTestSingleItemDataSource.h"


#define genTestObject(k, v) [[IGTestObject alloc] initWithKey:k value:v]

#define genExpectation [self expectationWithDescription:NSStringFromSelector(_cmd)]

@interface IGListCollectionViewFlowLayoutTests : XCTestCase

@property (nonatomic, strong) IGListCollectionView *collectionView;
@property (nonatomic, strong) IGListAdapter *adapter;
@property (nonatomic, strong) IGListAdapterUpdater *updater;
@property (nonatomic, strong) IGTestSingleItemDataSource *dataSource;
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) IGListCollectionViewFlowLayout *layout;

@end

@implementation IGListCollectionViewFlowLayoutTests

- (void)setUp {
    [super setUp];
    self.window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    self.layout = [[IGListCollectionViewFlowLayout alloc] init];
    self.collectionView = [[IGListCollectionView alloc] initWithFrame:CGRectMake(0, 0, 100, 100) collectionViewLayout:self.layout];
    [self.window addSubview:self.collectionView];
    self.dataSource = [[IGTestSingleItemDataSource alloc] init];
    self.updater = [[IGListAdapterUpdater alloc] init];
    self.adapter = [[IGListAdapter alloc] initWithUpdater:self.updater viewController:nil workingRangeSize:2];
}

- (void)tearDown {
    [super tearDown];
    self.window = nil;
    self.collectionView = nil;
    self.adapter = nil;
    self.dataSource = nil;
    self.layout = nil;
}

- (void)setupWithObjects:(NSArray *)objects {
    self.dataSource.objects = objects;
    self.adapter.collectionView = self.collectionView;
    self.adapter.dataSource = self.dataSource;
    [self.collectionView layoutIfNeeded];
}

- (void)test_whenDisplayingCollectionView_thatSectionsHaveOneItem {
    [self setupWithObjects:@[genTestObject(@1, @"Foo")]];
    CGSize contentSize = self.layout.collectionViewContentSize;
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    UICollectionViewLayoutAttributes *attributes = [self.layout layoutAttributesForItemAtIndexPath:indexPath];
    XCTAssertEqual(contentSize.width, 100.0f);
    XCTAssertEqual(contentSize.height, 44.0f);
    XCTAssertEqual(CGRectGetMinX(attributes.frame), 0.0f);
    XCTAssertEqual(CGRectGetMinY(attributes.frame), 0.0f);
    XCTAssertEqual(CGRectGetWidth(attributes.frame), 100.0f);
    XCTAssertEqual(CGRectGetHeight(attributes.frame), 44.0f);
}

- (void)test_whenDisplayingCollectionView_thatLayouHasItemSize {
    self.layout.itemSize = CGSizeMake(44.0f, 44.0f);
    [self setupWithObjects:@[genTestObject(@1, @"Foo")]];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    UICollectionViewLayoutAttributes *attributes = [self.layout layoutAttributesForItemAtIndexPath:indexPath];
    XCTAssertEqual(CGRectGetMinX(attributes.frame), 0.0f);
    XCTAssertEqual(CGRectGetMinY(attributes.frame), 0.0f);
    XCTAssertEqual(CGRectGetWidth(attributes.frame), 44.0f);
    XCTAssertEqual(CGRectGetHeight(attributes.frame), 44.0f);
}

@end
