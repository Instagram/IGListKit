/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <XCTest/XCTest.h>

#import <IGListKit/IGListKit.h>

#import "IGListAdapterInternal.h"
#import "IGListGridCollectionViewLayout.h"
#import "IGTestCell.h"
#import "IGListTestAdapterGridLayoutDataSource.h"


#define genTestObject(k, v) [[IGTestObject alloc] initWithKey:k value:v]

#define genExpectation [self expectationWithDescription:NSStringFromSelector(_cmd)]

#define IGAssertEqualFrame(frame, x, y, w, h, ...) \
do { \
CGRect expected = CGRectMake(x, y, w, h); \
XCTAssertEqual(CGRectGetMinX(expected), CGRectGetMinX(frame)); \
XCTAssertEqual(CGRectGetMinY(expected), CGRectGetMinY(frame)); \
XCTAssertEqual(CGRectGetWidth(expected), CGRectGetWidth(frame)); \
XCTAssertEqual(CGRectGetHeight(expected), CGRectGetHeight(frame)); \
} while(0)

@interface IGListGridCollectionViewLayoutTests : XCTestCase

@property (nonatomic, strong) IGListCollectionView *collectionView;
@property (nonatomic, strong) IGListAdapter *adapter;
@property (nonatomic, strong) IGListAdapterUpdater *updater;
@property (nonatomic, strong) IGListTestAdapterGridLayoutDataSource *dataSource;
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) IGListGridCollectionViewLayout *layout;

@end

@implementation IGListGridCollectionViewLayoutTests

- (void)setUp {
    [super setUp];
    
    // minimum line spacing, item size, and minimum interim spacing are all set in IGListTestSection
    self.window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    
    self.layout = [[IGListGridCollectionViewLayout alloc] init];
    self.collectionView = [[IGListCollectionView alloc] initWithFrame:self.window.bounds collectionViewLayout:self.layout];
    
    [self.window addSubview:self.collectionView];
    
    // syncronous reloads so we dont have to do expectations or other nonsense
    IGListReloadDataUpdater *updater = [[IGListReloadDataUpdater alloc] init];
    
    self.dataSource = [[IGListTestAdapterGridLayoutDataSource alloc] init];
    self.adapter = [[IGListAdapter alloc] initWithUpdater:updater
                                           viewController:nil
                                         workingRangeSize:0];
    self.adapter.collectionView = self.collectionView;
    self.adapter.dataSource = self.dataSource;
}


- (void)tearDown {
    [super tearDown];
    self.window = nil;
    self.collectionView = nil;
    self.adapter = nil;
    self.dataSource = nil;
    self.layout = nil;
}

- (void)test_whenDisplayingCollectionView_thatHasOneItem {
    self.dataSource.objects = @[@1];
    [self.adapter performUpdatesAnimated:YES completion:nil];
    CGSize contentSize = self.layout.collectionViewContentSize;
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    UICollectionViewLayoutAttributes *attributes = [self.layout layoutAttributesForItemAtIndexPath:indexPath];
    XCTAssertEqual(contentSize.width, 100.0f);
    XCTAssertEqual(contentSize.height, 44.0f);
    IGAssertEqualFrame(attributes.frame, 0, 0, 44, 44);
}

- (void)test_whenDisplayingCollectionView_thatLayoutHasItemSize {
    self.layout.itemSize = CGSizeMake(44.0f, 44.0f);
    self.dataSource.objects = @[@1];
    [self.adapter performUpdatesAnimated:YES completion:nil];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    UICollectionViewLayoutAttributes *attributes = [self.layout layoutAttributesForItemAtIndexPath:indexPath];
    IGAssertEqualFrame(attributes.frame, 0, 0, 44, 44);
}

- (void)test_whenDisplayingCollectionView_thatHasMultipleItems {
    self.layout.itemSize = CGSizeMake(44.0f, 44.0f);
    self.layout.minimumInteritemSpacing = 6.0f;
    self.layout.minimumLineSpacing = 6.0f;
    self.dataSource.objects = @[@1, @2, @3];
    [self.adapter performUpdatesAnimated:YES completion:nil];
    CGSize contentSize = self.layout.collectionViewContentSize;
    NSIndexPath *indexPath0 = [NSIndexPath indexPathForItem:0 inSection:0];
    NSIndexPath *indexPath1 = [NSIndexPath indexPathForItem:0 inSection:1];
    NSIndexPath *indexPath2 = [NSIndexPath indexPathForItem:1 inSection:1];
    NSIndexPath *indexPath3 = [NSIndexPath indexPathForItem:0 inSection:2];
    NSIndexPath *indexPath5 = [NSIndexPath indexPathForItem:2 inSection:2];
    UICollectionViewLayoutAttributes *attributes0 = [self.layout layoutAttributesForItemAtIndexPath:indexPath0];
    UICollectionViewLayoutAttributes *attributes1 = [self.layout layoutAttributesForItemAtIndexPath:indexPath1];
    UICollectionViewLayoutAttributes *attributes2 = [self.layout layoutAttributesForItemAtIndexPath:indexPath2];
    UICollectionViewLayoutAttributes *attributes3 = [self.layout layoutAttributesForItemAtIndexPath:indexPath3];
    UICollectionViewLayoutAttributes *attributes5 = [self.layout layoutAttributesForItemAtIndexPath:indexPath5];
    XCTAssertEqual(contentSize.width, 100.0f);
    XCTAssertEqual(contentSize.height, 144.0f);
    IGAssertEqualFrame(attributes0.frame, 0, 0, 44, 44);
    IGAssertEqualFrame(attributes1.frame, 50, 0, 44, 44);
    IGAssertEqualFrame(attributes2.frame, 0, 50, 44, 44);
    IGAssertEqualFrame(attributes3.frame, 50, 50, 44, 44);
    IGAssertEqualFrame(attributes5.frame, 50, 100, 44, 44);
}

- (void)test_whenDisplayingCollectionView_thatHasMultipleItems_withCenterAlignment {
    self.layout.itemSize = CGSizeMake(44.0f, 44.0f);
    self.layout.alignment = IGListGridCollectionViewLayoutAlignmentCenter;
    self.layout.minimumInteritemSpacing = 6.0f;
    self.layout.minimumLineSpacing = 6.0f;
    self.dataSource.objects = @[@1, @2, @3];
    [self.adapter performUpdatesAnimated:YES completion:nil];
    CGSize contentSize = self.layout.collectionViewContentSize;
    NSIndexPath *indexPath0 = [NSIndexPath indexPathForItem:0 inSection:0];
    NSIndexPath *indexPath1 = [NSIndexPath indexPathForItem:0 inSection:1];
    NSIndexPath *indexPath2 = [NSIndexPath indexPathForItem:1 inSection:1];
    NSIndexPath *indexPath3 = [NSIndexPath indexPathForItem:0 inSection:2];
    NSIndexPath *indexPath5 = [NSIndexPath indexPathForItem:2 inSection:2];
    UICollectionViewLayoutAttributes *attributes0 = [self.layout layoutAttributesForItemAtIndexPath:indexPath0];
    UICollectionViewLayoutAttributes *attributes1 = [self.layout layoutAttributesForItemAtIndexPath:indexPath1];
    UICollectionViewLayoutAttributes *attributes2 = [self.layout layoutAttributesForItemAtIndexPath:indexPath2];
    UICollectionViewLayoutAttributes *attributes3 = [self.layout layoutAttributesForItemAtIndexPath:indexPath3];
    UICollectionViewLayoutAttributes *attributes5 = [self.layout layoutAttributesForItemAtIndexPath:indexPath5];
    XCTAssertEqual(contentSize.width, 100.0f);
    XCTAssertEqual(contentSize.height, 144.0f);
    IGAssertEqualFrame(attributes0.frame, 0, 0, 44, 44);
    IGAssertEqualFrame(attributes1.frame, 56, 0, 44, 44);
    IGAssertEqualFrame(attributes2.frame, 0, 50, 44, 44);
    IGAssertEqualFrame(attributes3.frame, 56, 50, 44, 44);
    IGAssertEqualFrame(attributes5.frame, 56, 100, 44, 44);
}

- (void)test_whenDisplayingCollectionView_thatHasMultipleItems_withRightAlignment {
    self.layout.itemSize = CGSizeMake(44.0f, 44.0f);
    self.layout.alignment = IGListGridCollectionViewLayoutAlignmentRight;
    self.layout.minimumInteritemSpacing = 6.0f;
    self.layout.minimumLineSpacing = 6.0f;
    self.dataSource.objects = @[@1, @2, @3];
    [self.adapter performUpdatesAnimated:YES completion:nil];
    CGSize contentSize = self.layout.collectionViewContentSize;
    NSIndexPath *indexPath0 = [NSIndexPath indexPathForItem:0 inSection:0];
    NSIndexPath *indexPath1 = [NSIndexPath indexPathForItem:0 inSection:1];
    NSIndexPath *indexPath2 = [NSIndexPath indexPathForItem:1 inSection:1];
    NSIndexPath *indexPath3 = [NSIndexPath indexPathForItem:0 inSection:2];
    NSIndexPath *indexPath5 = [NSIndexPath indexPathForItem:2 inSection:2];
    UICollectionViewLayoutAttributes *attributes0 = [self.layout layoutAttributesForItemAtIndexPath:indexPath0];
    UICollectionViewLayoutAttributes *attributes1 = [self.layout layoutAttributesForItemAtIndexPath:indexPath1];
    UICollectionViewLayoutAttributes *attributes2 = [self.layout layoutAttributesForItemAtIndexPath:indexPath2];
    UICollectionViewLayoutAttributes *attributes3 = [self.layout layoutAttributesForItemAtIndexPath:indexPath3];
    UICollectionViewLayoutAttributes *attributes5 = [self.layout layoutAttributesForItemAtIndexPath:indexPath5];
    XCTAssertEqual(contentSize.width, 100.0f);
    XCTAssertEqual(contentSize.height, 144.0f);
    IGAssertEqualFrame(attributes0.frame, 6, 0, 44, 44);
    IGAssertEqualFrame(attributes1.frame, 56, 0, 44, 44);
    IGAssertEqualFrame(attributes2.frame, 6, 50, 44, 44);
    IGAssertEqualFrame(attributes3.frame, 56, 50, 44, 44);
    IGAssertEqualFrame(attributes5.frame, 56, 100, 44, 44);
}


- (void)test_whenDisplayingCollectionView_thatUsesDelegateSize {
    self.layout.itemSize = CGSizeMake(0.0f, 0.0f);
    self.layout.minimumInteritemSpacing = 6.0f;
    self.layout.minimumLineSpacing = 6.0f;
    self.dataSource.objects = @[@1, @2, @3];
    [self.adapter performUpdatesAnimated:YES completion:nil];
    CGSize contentSize = self.layout.collectionViewContentSize;
    NSIndexPath *indexPath0 = [NSIndexPath indexPathForItem:0 inSection:0];
    NSIndexPath *indexPath1 = [NSIndexPath indexPathForItem:0 inSection:1];
    NSIndexPath *indexPath2 = [NSIndexPath indexPathForItem:1 inSection:1];
    NSIndexPath *indexPath3 = [NSIndexPath indexPathForItem:0 inSection:2];
    NSIndexPath *indexPath5 = [NSIndexPath indexPathForItem:2 inSection:2];
    UICollectionViewLayoutAttributes *attributes0 = [self.layout layoutAttributesForItemAtIndexPath:indexPath0];
    UICollectionViewLayoutAttributes *attributes1 = [self.layout layoutAttributesForItemAtIndexPath:indexPath1];
    UICollectionViewLayoutAttributes *attributes2 = [self.layout layoutAttributesForItemAtIndexPath:indexPath2];
    UICollectionViewLayoutAttributes *attributes3 = [self.layout layoutAttributesForItemAtIndexPath:indexPath3];
    UICollectionViewLayoutAttributes *attributes5 = [self.layout layoutAttributesForItemAtIndexPath:indexPath5];
    XCTAssertEqual(contentSize.width, 100.0f);
    XCTAssertEqual(contentSize.height, 144.0f);
    IGAssertEqualFrame(attributes0.frame, 0, 0, 44, 44);
    IGAssertEqualFrame(attributes1.frame, 50, 0, 44, 44);
    IGAssertEqualFrame(attributes2.frame, 0, 50, 44, 44);
    IGAssertEqualFrame(attributes3.frame, 50, 50, 44, 44);
    IGAssertEqualFrame(attributes5.frame, 50, 100, 44, 44);
}

- (void)test_whenDisplayingCollectionView_thatUsesDelegateSize_withCenterAlignment {
    self.layout.itemSize = CGSizeMake(0.0f, 0.0f);
    self.layout.alignment = IGListGridCollectionViewLayoutAlignmentCenter;
    self.layout.minimumInteritemSpacing = 6.0f;
    self.layout.minimumLineSpacing = 6.0f;
    self.dataSource.objects = @[@1, @2, @3];
    [self.adapter performUpdatesAnimated:YES completion:nil];
    CGSize contentSize = self.layout.collectionViewContentSize;
    NSIndexPath *indexPath0 = [NSIndexPath indexPathForItem:0 inSection:0];
    NSIndexPath *indexPath1 = [NSIndexPath indexPathForItem:0 inSection:1];
    NSIndexPath *indexPath2 = [NSIndexPath indexPathForItem:1 inSection:1];
    NSIndexPath *indexPath3 = [NSIndexPath indexPathForItem:0 inSection:2];
    NSIndexPath *indexPath5 = [NSIndexPath indexPathForItem:2 inSection:2];
    UICollectionViewLayoutAttributes *attributes0 = [self.layout layoutAttributesForItemAtIndexPath:indexPath0];
    UICollectionViewLayoutAttributes *attributes1 = [self.layout layoutAttributesForItemAtIndexPath:indexPath1];
    UICollectionViewLayoutAttributes *attributes2 = [self.layout layoutAttributesForItemAtIndexPath:indexPath2];
    UICollectionViewLayoutAttributes *attributes3 = [self.layout layoutAttributesForItemAtIndexPath:indexPath3];
    UICollectionViewLayoutAttributes *attributes5 = [self.layout layoutAttributesForItemAtIndexPath:indexPath5];
    XCTAssertEqual(contentSize.width, 100.0f);
    XCTAssertEqual(contentSize.height, 144.0f);
    IGAssertEqualFrame(attributes0.frame, 0, 0, 44, 44);
    IGAssertEqualFrame(attributes1.frame, 56, 0, 44, 44);
    IGAssertEqualFrame(attributes2.frame, 0, 50, 44, 44);
    IGAssertEqualFrame(attributes3.frame, 56, 50, 44, 44);
    IGAssertEqualFrame(attributes5.frame, 56, 100, 44, 44);
}

- (void)test_whenDisplayingCollectionView_thatUsesDelegateSize_withRightAlignment {
    self.layout.itemSize = CGSizeMake(0.0f, 0.0f);
    self.layout.alignment = IGListGridCollectionViewLayoutAlignmentRight;
    self.layout.minimumInteritemSpacing = 6.0f;
    self.layout.minimumLineSpacing = 6.0f;
    self.dataSource.objects = @[@1, @2, @3];
    [self.adapter performUpdatesAnimated:YES completion:nil];
    CGSize contentSize = self.layout.collectionViewContentSize;
    NSIndexPath *indexPath0 = [NSIndexPath indexPathForItem:0 inSection:0];
    NSIndexPath *indexPath1 = [NSIndexPath indexPathForItem:0 inSection:1];
    NSIndexPath *indexPath2 = [NSIndexPath indexPathForItem:1 inSection:1];
    NSIndexPath *indexPath3 = [NSIndexPath indexPathForItem:0 inSection:2];
    NSIndexPath *indexPath5 = [NSIndexPath indexPathForItem:2 inSection:2];
    UICollectionViewLayoutAttributes *attributes0 = [self.layout layoutAttributesForItemAtIndexPath:indexPath0];
    UICollectionViewLayoutAttributes *attributes1 = [self.layout layoutAttributesForItemAtIndexPath:indexPath1];
    UICollectionViewLayoutAttributes *attributes2 = [self.layout layoutAttributesForItemAtIndexPath:indexPath2];
    UICollectionViewLayoutAttributes *attributes3 = [self.layout layoutAttributesForItemAtIndexPath:indexPath3];
    UICollectionViewLayoutAttributes *attributes5 = [self.layout layoutAttributesForItemAtIndexPath:indexPath5];
    XCTAssertEqual(contentSize.width, 100.0f);
    XCTAssertEqual(contentSize.height, 144.0f);
    IGAssertEqualFrame(attributes0.frame, 6, 0, 44, 44);
    IGAssertEqualFrame(attributes1.frame, 56, 0, 44, 44);
    IGAssertEqualFrame(attributes2.frame, 6, 50, 44, 44);
    IGAssertEqualFrame(attributes3.frame, 56, 50, 44, 44);
    IGAssertEqualFrame(attributes5.frame, 56, 100, 44, 44);
}

@end
