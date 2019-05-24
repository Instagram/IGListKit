/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 A protocol for layouts that defines interaction with an IGListCollectionView, for recieving updated section indexes.
 */
NS_SWIFT_NAME(ListCollectionViewLayoutCompatible)
@protocol IGListCollectionViewLayoutCompatible <NSObject>

/**
 Called to notify the layout that a specific section was modified before invalidation. This can be used to optimize
 layout re-calculation.
 
 @note When updating a collection view (ex: calling `-insertSections`), `-invalidateLayoutWithContext` gets called on
 the layout object. However, the invalidation context doesn't provide details on which index paths are being modified,
 which typically forces a full layout re-calculation. Layouts can use this method to keep track of which section
 actually needs to be updated on the following `-invalidateLayoutWithContext`. See `IGListCollectionView`.
 
 @param modifiedSection The section that was modified.
 */
- (void)didModifySection:(NSInteger)modifiedSection;

@end

NS_ASSUME_NONNULL_END
