/**
 * Copyright (c) 2016-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

#import <IGListKit/IGListAdapter.h>

NS_ASSUME_NONNULL_BEGIN

@interface UICollectionViewLayout (InteractiveReordering)

- (void)ig_hijackLayoutInteractiveReorderingMethodForAdapter:(IGListAdapter *)adapter;

- (nullable NSIndexPath *)updatedTargetForInteractivelyMovingItem:(NSIndexPath *)previousIndexPath
                                                      toIndexPath:(NSIndexPath *)originalTarget
                                                          adapter:(IGListAdapter *)adapter;

@end

NS_ASSUME_NONNULL_END
