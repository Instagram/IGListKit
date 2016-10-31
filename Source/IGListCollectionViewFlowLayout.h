/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

@interface IGListCollectionViewFlowLayout : UICollectionViewLayout

/**
 The scroll direction of the grid.
 */
@property (nonatomic, assign) IBInspectable UICollectionViewScrollDirection scrollDirection;

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

/**
 The estimated size of cells in the collection view.
 */
@property (nonatomic, assign) IBInspectable CGSize estimatedItemSize;

/**
 The margins used to lay out content in a section
 */
@property (nonatomic, assign) UIEdgeInsets sectionInset;

@end
