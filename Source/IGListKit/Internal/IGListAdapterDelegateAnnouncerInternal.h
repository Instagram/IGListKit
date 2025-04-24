/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGListAdapterDelegateAnnouncer.h"

NS_ASSUME_NONNULL_BEGIN

@interface IGListAdapterDelegateAnnouncer ()

- (void)announceObjectDisplayWithAdapter:(IGListAdapter *)listAdapter object:(id)object index:(NSInteger)index;
- (void)announceObjectEndDisplayWithAdapter:(IGListAdapter *)listAdapter object:(id)object index:(NSInteger)index;

- (void)announceCellDisplayWithAdapter:(IGListAdapter *)listAdapter object:(id)object cell:(UICollectionViewCell *)cell indexPath:(NSIndexPath *)indexPath;
- (void)announceCellEndDisplayWithAdapter:(IGListAdapter *)listAdapter object:(id)object cell:(UICollectionViewCell *)cell indexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
