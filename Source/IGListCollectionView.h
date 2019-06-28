/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

@protocol IGListCollectionViewLayoutCompatible;

NS_ASSUME_NONNULL_BEGIN

/**
 This `UICollectionView` subclass allows for partial layout invalidation using `IGListCollectionViewLayout`,
 or custom layout classes that conform to IGListCollectionViewLayoutCompatible.

 @note When updating a collection view (ex: calling `-insertSections`), `-invalidateLayoutWithContext` gets called on
 the layout object. However, the invalidation context doesn't provide details on which index paths are being modified,
 which typically forces a full layout re-calculation. `IGListCollectionView` gives `IGListCollectionViewLayout` the
 missing information to re-calculate only the modified layout attributes.
 */
NS_SWIFT_NAME(ListCollectionView)
@interface IGListCollectionView : UICollectionView

/**
 Create a new view with an `IGListcollectionViewLayout` class or subclass.

 @param frame The frame to initialize with.
 @param collectionViewLayout The layout to use with the collection view. You can use IGListCollectionViewLayout
 here, or a custom layout class that conforms to IGListCollectionViewLayoutCompatible.

 @note You can initialize a new view with a base layout by simply calling `-[IGListCollectionView initWithFrame:]`.
 */
- (instancetype)initWithFrame:(CGRect)frame listCollectionViewLayout:(UICollectionViewLayout<IGListCollectionViewLayoutCompatible> *)collectionViewLayout NS_DESIGNATED_INITIALIZER;

/**
 :nodoc:
 */
- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)collectionViewLayout NS_UNAVAILABLE;

/**
 :nodoc:
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
