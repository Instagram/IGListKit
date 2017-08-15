/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "IGListAdapter+UICollectionView.h"

#import <IGListKit/IGListAdapterInternal.h>
#import <IGListKit/IGListAssert.h>
#import <IGListKit/IGListSectionController.h>

@implementation IGListAdapter (UICollectionView)

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.sectionMap.objects.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    IGListSectionController * sectionController = [self sectionControllerForSection:section];
    IGAssert(sectionController != nil, @"Nil section controller for section %zi for item %@. Check your -diffIdentifier and -isEqual: implementations.",
            section, [self.sectionMap objectForSection:section]);
    const NSInteger numberOfItems = [sectionController numberOfItems];
    IGAssert(numberOfItems >= 0, @"Cannot return negative number of items %zi for section controller %@.", numberOfItems, sectionController);
    return numberOfItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    IGListSectionController *sectionController = [self sectionControllerForSection:indexPath.section];

    // flag that a cell is being dequeued in case it tries to access a cell in the process
    _isDequeuingCell = YES;
    UICollectionViewCell *cell = [sectionController cellForItemAtIndex:indexPath.item];
    _isDequeuingCell = NO;

    IGAssert(cell != nil, @"Returned a nil cell at indexPath <%@> from section controller: <%@>", indexPath, sectionController);

    // associate the section controller with the cell so that we know which section controller is using it
    [self mapView:cell toSectionController:sectionController];

    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    IGListSectionController *sectionController = [self sectionControllerForSection:indexPath.section];
    id <IGListSupplementaryViewSource> supplementarySource = [sectionController supplementaryViewSource];
    UICollectionReusableView *view = [supplementarySource viewForSupplementaryElementOfKind:kind atIndex:indexPath.item];
    IGAssert(view != nil, @"Returned a nil supplementary view at indexPath <%@> from section controller: <%@>, supplementary source: <%@>", indexPath, sectionController, supplementarySource);

    // associate the section controller with the cell so that we know which section controller is using it
    [self mapView:view toSectionController:sectionController];

    return view;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // forward this method to the delegate b/c this implementation will steal the message from the proxy
    id<UICollectionViewDelegate> collectionViewDelegate = self.collectionViewDelegate;
    if ([collectionViewDelegate respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)]) {
        [collectionViewDelegate collectionView:collectionView didSelectItemAtIndexPath:indexPath];
    }

    IGListSectionController * sectionController = [self sectionControllerForSection:indexPath.section];
    [sectionController didSelectItemAtIndex:indexPath.item];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // forward this method to the delegate b/c this implementation will steal the message from the proxy
    id<UICollectionViewDelegate> collectionViewDelegate = self.collectionViewDelegate;
    if ([collectionViewDelegate respondsToSelector:@selector(collectionView:didDeselectItemAtIndexPath:)]) {
        [collectionViewDelegate collectionView:collectionView didDeselectItemAtIndexPath:indexPath];
    }

    IGListSectionController * sectionController = [self sectionControllerForSection:indexPath.section];
    [sectionController didDeselectItemAtIndex:indexPath.item];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    // forward this method to the delegate b/c this implementation will steal the message from the proxy
    id<UICollectionViewDelegate> collectionViewDelegate = self.collectionViewDelegate;
    if ([collectionViewDelegate respondsToSelector:@selector(collectionView:willDisplayCell:forItemAtIndexPath:)]) {
        [collectionViewDelegate collectionView:collectionView willDisplayCell:cell forItemAtIndexPath:indexPath];
    }

    IGListSectionController *sectionController = [self sectionControllerForView:cell];
    // if the section controller relationship was destroyed, reconnect it
    // this happens with iOS 10 UICollectionView display range changes
    if (sectionController == nil) {
        sectionController = [self sectionControllerForSection:indexPath.section];
        [self mapView:cell toSectionController:sectionController];
    }

    id object = [self.sectionMap objectForSection:indexPath.section];
    [self.displayHandler willDisplayCell:cell forListAdapter:self sectionController:sectionController object:object indexPath:indexPath];

    _isSendingWorkingRangeDisplayUpdates = YES;
    [self.workingRangeHandler willDisplayItemAtIndexPath:indexPath forListAdapter:self];
    _isSendingWorkingRangeDisplayUpdates = NO;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    // forward this method to the delegate b/c this implementation will steal the message from the proxy
    id<UICollectionViewDelegate> collectionViewDelegate = self.collectionViewDelegate;
    if ([collectionViewDelegate respondsToSelector:@selector(collectionView:didEndDisplayingCell:forItemAtIndexPath:)]) {
        [collectionViewDelegate collectionView:collectionView didEndDisplayingCell:cell forItemAtIndexPath:indexPath];
    }

    IGListSectionController *sectionController = [self sectionControllerForView:cell];
    [self.displayHandler didEndDisplayingCell:cell forListAdapter:self sectionController:sectionController indexPath:indexPath];
    [self.workingRangeHandler didEndDisplayingItemAtIndexPath:indexPath forListAdapter:self];

    // break the association between the cell and the section controller
    [self removeMapForView:cell];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    id<UICollectionViewDelegate> collectionViewDelegate = self.collectionViewDelegate;
    if ([collectionViewDelegate respondsToSelector:@selector(collectionView:willDisplaySupplementaryView:forElementKind:atIndexPath:)]) {
        [collectionViewDelegate collectionView:collectionView willDisplaySupplementaryView:view forElementKind:elementKind atIndexPath:indexPath];
    }

    IGListSectionController *sectionController = [self sectionControllerForView:view];
    // if the section controller relationship was destroyed, reconnect it
    // this happens with iOS 10 UICollectionView display range changes
    if (sectionController == nil) {
        sectionController = [self.sectionMap sectionControllerForSection:indexPath.section];
        [self mapView:view toSectionController:sectionController];
    }

    id object = [self.sectionMap objectForSection:indexPath.section];
    [self.displayHandler willDisplaySupplementaryView:view forListAdapter:self sectionController:sectionController object:object indexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    id<UICollectionViewDelegate> collectionViewDelegate = self.collectionViewDelegate;
    if ([collectionViewDelegate respondsToSelector:@selector(collectionView:didEndDisplayingSupplementaryView:forElementOfKind:atIndexPath:)]) {
        [collectionViewDelegate collectionView:collectionView didEndDisplayingSupplementaryView:view forElementOfKind:elementKind atIndexPath:indexPath];
    }

    IGListSectionController *sectionController = [self sectionControllerForView:view];
    [self.displayHandler didEndDisplayingSupplementaryView:view forListAdapter:self sectionController:sectionController indexPath:indexPath];

    [self removeMapForView:view];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    IGAssert(![self.collectionViewDelegate respondsToSelector:_cmd], @"IGListAdapter is consuming method also implemented by the collectionViewDelegate: %@", NSStringFromSelector(_cmd));
    return [self sizeForItemAtIndexPath:indexPath];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    IGAssert(![self.collectionViewDelegate respondsToSelector:_cmd], @"IGListAdapter is consuming method also implemented by the collectionViewDelegate: %@", NSStringFromSelector(_cmd));
    return [[self sectionControllerForSection:section] inset];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    IGAssert(![self.collectionViewDelegate respondsToSelector:_cmd], @"IGListAdapter is consuming method also implemented by the collectionViewDelegate: %@", NSStringFromSelector(_cmd));
    return [[self sectionControllerForSection:section] minimumLineSpacing];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    IGAssert(![self.collectionViewDelegate respondsToSelector:_cmd], @"IGListAdapter is consuming method also implemented by the collectionViewDelegate: %@", NSStringFromSelector(_cmd));
    return [[self sectionControllerForSection:section] minimumInteritemSpacing];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    IGAssert(![self.collectionViewDelegate respondsToSelector:_cmd], @"IGListAdapter is consuming method also implemented by the collectionViewDelegate: %@", NSStringFromSelector(_cmd));
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    return [self sizeForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    IGAssert(![self.collectionViewDelegate respondsToSelector:_cmd], @"IGListAdapter is consuming method also implemented by the collectionViewDelegate: %@", NSStringFromSelector(_cmd));
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    return [self sizeForSupplementaryViewOfKind:UICollectionElementKindSectionFooter atIndexPath:indexPath];
}

@end
