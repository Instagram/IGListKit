/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

/**
 Conform to `IGListCollectionViewDelegateLayout` to provide customized layout information for a collection view.
 */
@protocol IGListCollectionViewDelegateLayout <UICollectionViewDelegateFlowLayout>

/**
 Asks the delegate to customize and return the starting layout information for an item being inserted into the collection view.

 @param collectionView The collection view to perform the transition on.
 @param collectionViewLayout The layout to use with the collection view.
 @param attributes The starting layout information for an item being inserted into the collection view.
 @param indexPath The index path of the item being inserted.
 */
- (UICollectionViewLayoutAttributes *)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout customizedInitialLayoutAttributes:(UICollectionViewLayoutAttributes *)attributes atIndexPath:(NSIndexPath *)indexPath;

/**
 Asks the delegate to customize and return the final layout information for an item that is about to be removed from the collection view.

 @param collectionView The collection view to perform the transition on.
 @param collectionViewLayout The layout to use with the collection view.
 @param attributes The final layout information for an item that is about to be removed from the collection view.
 @param indexPath The index path of the item being deleted.
 */
- (UICollectionViewLayoutAttributes *)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout customizedFinalLayoutAttributes:(UICollectionViewLayoutAttributes *)attributes atIndexPath:(NSIndexPath *)indexPath;

@end

