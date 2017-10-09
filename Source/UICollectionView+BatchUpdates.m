// 
// Copyright (c) 2016-present, Facebook, Inc.
// All rights reserved.
//
// This source code is licensed under the BSD-style license found in the
// LICENSE file in the root directory of this source tree. An additional grant
// of patent rights can be found in the PATENTS file in the same directory.
//
// GitHub:
// https://github.com/Instagram/IGListKit
// 
// Documentation:
// https://instagram.github.io/IGListKit/
//

#import "UICollectionView+BatchUpdates.h"

#import <IGListKit/IGListBatchUpdateData.h>

@implementation UICollectionView (BatchUpdates)

- (void)ig_performUpdateWithIndexSetResult:(IGListIndexSetResult *)indexSetResult
                           indexPathResult:(IGListIndexPathResult *)indexPathResult
                                    update:(void (^)(void))update
                                completion:(void (^)(BOOL))completion {
    [self performBatchUpdates:^{
        if (update != nil) {
            update();
        }

        if (indexSetResult != nil) {
            IGListIndexSetResult *batchResult = [indexSetResult resultForBatchUpdates];
            [self insertSections:batchResult.inserts];
            [self deleteSections:batchResult.deletes];
            for (IGListMoveIndex *move in batchResult.moves) {
                [self moveSection:move.from toSection:move.to];
            }
        }

        if (indexPathResult != nil) {
            IGListIndexPathResult *batchResult = [indexPathResult resultForBatchUpdates];
            [self insertItemsAtIndexPaths:batchResult.inserts];
            [self deleteItemsAtIndexPaths:batchResult.deletes];
            for (IGListMoveIndex *move in batchResult.moves) {
                [self moveItemAtIndexPath:move.from toIndexPath:move.to];
            }
        }
    } completion:completion];
}

@end
