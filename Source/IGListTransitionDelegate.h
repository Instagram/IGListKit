/**
 * Copyright (c) 2016-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

/**
 Conform to `IGListTransitionDelegate` to provide customized layout information for a collection view.
 */
@protocol IGListTransitionDelegate <NSObject>

/**
 Asks the delegate to customize and return the starting layout information for an item being inserted into the collection view.

 @param listAdapter The adapter controlling the list.
 @param attributes The starting layout information for an item being inserted into the collection view.
 @param sectionController The section controller to perform the transition on.
 @param index The index of the item being inserted.
 */
- (UICollectionViewLayoutAttributes *)listAdapter:(IGListAdapter *)listAdapter customizedInitialLayoutAttributes:(UICollectionViewLayoutAttributes *)attributes sectionController:(IGListSectionController *)sectionController atIndex:(NSInteger)index;

/**
 Asks the delegate to customize and return the final layout information for an item that is about to be removed from the collection view.

 @param listAdapter The adapter controlling the list.
 @param attributes The final layout information for an item that is about to be removed from the collection view.
 @param sectionController The section controller to perform the transition on.
 @param index The index of the item being deleted.
 */
- (UICollectionViewLayoutAttributes *)listAdapter:(IGListAdapter *)listAdapter customizedFinalLayoutAttributes:(UICollectionViewLayoutAttributes *)attributes sectionController:(IGListSectionController *)sectionController atIndex:(NSInteger)index;

@end

