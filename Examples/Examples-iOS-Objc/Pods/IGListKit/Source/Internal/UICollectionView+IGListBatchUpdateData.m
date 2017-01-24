/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "UICollectionView+IGListBatchUpdateData.h"

#import "IGListBatchUpdateData.h"

@implementation UICollectionView (IGListBatchUpdateData)

- (void)ig_applyBatchUpdateData:(IGListBatchUpdateData *)updateData {
    [self deleteItemsAtIndexPaths:[updateData.deleteIndexPaths allObjects]];
    [self insertItemsAtIndexPaths:[updateData.insertIndexPaths allObjects]];
    [self reloadItemsAtIndexPaths:[updateData.reloadIndexPaths allObjects]];

    for (IGListMoveIndex *move in updateData.moveSections) {
        [self moveSection:move.from toSection:move.to];
    }

    [self deleteSections:updateData.deleteSections];
    [self insertSections:updateData.insertSections];
}

@end
