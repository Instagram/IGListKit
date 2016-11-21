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
 IGListGridCollectionViewLayout provide a grid layout for UICollectionView with section controllers that return 1 item.
 The size of the item for each section can be varying.
 
 @note This layout dose not have support for section insets and scroll direction yet. 
 */
@interface IGListGridCollectionViewLayout : UICollectionViewLayout

/**
 The scroll direction of the grid.
 */
@property (nonatomic, assign) UICollectionViewScrollDirection scrollDirection;

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
