/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 `IGListGridCollectionViewLayout` provides a vertically-scrolling, section-based grid layout for `UICollectionView`.
 Items in the layout are displayed consecutively in a grid with exactly 1 item per section.
 If items are square, the appearance would be similar to the iOS Photos app.
 However, the size of the items for each section can vary.
 */
IGLK_SUBCLASSING_RESTRICTED
@interface IGListGridCollectionViewLayout : UICollectionViewLayout

/**
 The minimum spacing to use between lines of items in the grid.
 */
@property (nonatomic, assign) IBInspectable CGFloat minimumLineSpacing;

/**
 The minimum spacing to use between items in the same row.
 */
@property (nonatomic, assign) IBInspectable CGFloat minimumInteritemSpacing;

/**
 The default size to use for cells.
 */
@property (nonatomic, assign) IBInspectable CGSize itemSize;

@end

NS_ASSUME_NONNULL_END
