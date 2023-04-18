/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>

#import "IGTestObject.h"
#import "IGListTestCase.h"
#import "IGTestDelegateDataSource.h"
#import "UICollectionViewLayout+InteractiveReordering.h"

@interface UICollectionViewLayout (Tests)

- (void)ig_invalidateAccessoryElementsWithSupplementaryIndexPaths:(NSDictionary<NSString *, NSArray<NSIndexPath *> *> *)supplementaryIndexPaths
                                             decorationIndexPaths:(NSDictionary<NSString *, NSArray<NSIndexPath *> *> *)decorationIndexPaths
                                                        inContext:(UICollectionViewLayoutInvalidationContext *)context;

@end

@interface IGListInteractiveMovingTests : IGListTestCase

@end

@implementation IGListInteractiveMovingTests

- (void)setUp {
    self.workingRangeSize = 2;
    self.dataSource = [IGTestDelegateDataSource new];
    [super setUp];
}

- (void)test_withDetachedLayout_whenQueryingForInteractiveMovingItem_thatOriginalIndexPathIsReturned {
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:1 inSection:1];
    NSIndexPath *targetIndexPath = [layout targetIndexPathForInteractivelyMovingItem:indexPath
                                                                        withPosition:CGPointMake(100, 100)];
    XCTAssertEqual(indexPath.item, targetIndexPath.item);
    XCTAssertEqual(indexPath.section, targetIndexPath.section);
}

- (void)test_withDetachedLayout_thatCleanupInvalidationContextExitsEarly {
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    NSIndexPath *sourceIndexPath = [NSIndexPath indexPathForItem:1 inSection:1];
    NSIndexPath *targetIndexPath = [NSIndexPath indexPathForItem:1 inSection:1];
    UICollectionViewLayoutInvalidationContext *context = [layout invalidationContextForInteractivelyMovingItems:@[targetIndexPath]
                                                                                             withTargetPosition:CGPointMake(0, 0)
                                                                                             previousIndexPaths:@[sourceIndexPath]
                                                                                               previousPosition:CGPointZero];
    XCTAssertTrue(context.invalidatedItemIndexPaths.count > 0);
}

- (void)test_whenCollectionViewIsSet_thatTargetIndexPathIsValid {
    [self setupWithObjects:@[genTestObject(@1, @2)]];
    UICollectionViewLayout *layout = self.collectionView.collectionViewLayout;
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:1 inSection:1];
    NSIndexPath *targetIndexPath = [layout targetIndexPathForInteractivelyMovingItem:indexPath
                                                                        withPosition:CGPointMake(100, 100)];
    XCTAssertEqual(indexPath.item, targetIndexPath.item);
    XCTAssertEqual(indexPath.section, targetIndexPath.section);
}

- (void)test_whenCollectionViewIsSet_thatInvalidationContextForInteractivelyMovingItemsPasses {
    [self setupWithObjects:@[genTestObject(@1, @2), genTestObject(@4, @5)]];
    UICollectionViewLayout *layout = self.collectionView.collectionViewLayout;
    NSIndexPath *sourceIndexPath = [NSIndexPath indexPathForItem:1 inSection:1];
    NSIndexPath *targetIndexPath = [NSIndexPath indexPathForItem:1 inSection:1];
    UICollectionViewLayoutInvalidationContext *context = [layout invalidationContextForInteractivelyMovingItems:@[targetIndexPath]
                                                                                             withTargetPosition:CGPointMake(0, 0)
                                                                                             previousIndexPaths:@[sourceIndexPath]
                                                                                               previousPosition:CGPointZero];
    XCTAssertTrue(context.invalidatedItemIndexPaths.count > 0);
}

- (void)test_whenCollectionViewIsSet_andIndexPathIsInsideBounds_thatValidationContextForEndingInteractiveMovementOfItemsToFinalIndexPathsPasses {
    [self setupWithObjects:@[genTestObject(@1, @2), genTestObject(@4, @5), genTestObject(@6, @7)]];
    UICollectionViewLayout *layout = self.collectionView.collectionViewLayout;
    NSIndexPath *sourceIndexPath = [NSIndexPath indexPathForItem:1 inSection:0];
    NSIndexPath *targetIndexPath = [NSIndexPath indexPathForItem:1 inSection:0];
    UICollectionViewLayoutInvalidationContext *context = [layout invalidationContextForEndingInteractiveMovementOfItemsToFinalIndexPaths:@[sourceIndexPath]
                                                                                                                      previousIndexPaths:@[targetIndexPath]
                                                                                                                       movementCancelled:NO];
    XCTAssertTrue(context.invalidatedItemIndexPaths.count > 0);
}

- (void)test_whenCollectionViewIsSet_andIndexPathIsOutOfBounds_thatValidationContextForEndingInteractiveMovementOfItemsToFinalIndexPathsPasses {
    [self setupWithObjects:@[genTestObject(@1, @2), genTestObject(@4, @5), genTestObject(@6, @7)]];
    UICollectionViewLayout *layout = self.collectionView.collectionViewLayout;
    NSIndexPath *sourceIndexPath = [NSIndexPath indexPathForItem:8 inSection:2];
    NSIndexPath *targetIndexPath = [NSIndexPath indexPathForItem:8 inSection:2];
    UICollectionViewLayoutInvalidationContext *context = [layout invalidationContextForEndingInteractiveMovementOfItemsToFinalIndexPaths:@[sourceIndexPath]
                                                                                                                      previousIndexPaths:@[targetIndexPath]
                                                                                                                       movementCancelled:NO];
    XCTAssertTrue(context.invalidatedItemIndexPaths.count == 0);
}

- (void)test_whenCollectionViewIsSetWithBaseLayout_andIndexPathIsOutOfBounds_thatValidationContextForEndingInteractiveMovementOfItemsToFinalIndexPathsPasses {
    [self setupWithObjects:@[genTestObject(@1, @2), genTestObject(@4, @5), genTestObject(@6, @7)]];
    UICollectionViewLayout *layout = [UICollectionViewLayout new];
    [layout ig_hijackLayoutInteractiveReorderingMethodForAdapter:self.adapter];
    self.collectionView.collectionViewLayout = layout;
    NSIndexPath *sourceIndexPath = [NSIndexPath indexPathForItem:8 inSection:2];
    NSIndexPath *targetIndexPath = [NSIndexPath indexPathForItem:8 inSection:2];
    UICollectionViewLayoutInvalidationContext *context = [layout invalidationContextForEndingInteractiveMovementOfItemsToFinalIndexPaths:@[sourceIndexPath]
                                                                                                                      previousIndexPaths:@[targetIndexPath]
                                                                                                                       movementCancelled:NO];
    XCTAssertTrue(context.invalidatedItemIndexPaths.count == 0);
}

- (void)test_withInvalidationContext_thatSupplementaryAndDecorationIndexPathsAreInvalidated {
    UICollectionViewLayout *layout = [UICollectionViewLayout new];

    NSDictionary *supplementaryDictionary = @{@"supplementary": @[[NSIndexPath indexPathForItem:1 inSection:1]]};
    NSDictionary *decorationDictionary = @{@"decoration": @[[NSIndexPath indexPathForItem:2 inSection:2]]};

    id contextMock = [OCMockObject mockForClass:[UICollectionViewLayoutInvalidationContext class]];
    [[contextMock expect] invalidateSupplementaryElementsOfKind:@"supplementary" atIndexPaths:supplementaryDictionary[@"supplementary"]];
    [[contextMock expect] invalidateDecorationElementsOfKind:@"decoration" atIndexPaths:decorationDictionary[@"decoration"]];

    [layout ig_invalidateAccessoryElementsWithSupplementaryIndexPaths:supplementaryDictionary
                                                 decorationIndexPaths:decorationDictionary
                                                            inContext:contextMock];
    [contextMock verify];
}

@end
