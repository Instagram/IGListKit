/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGListAdapterUpdaterHelpers.h"

#import <IGListDiffKit/IGListAssert.h>
#import <IGListDiffKit/IGListBatchUpdateData.h>
#import <IGListDiffKit/IGListDiffable.h>
#import <IGListDiffKit/IGListExperiments.h>
#import <IGListDiffKit/IGListIndexSetResult.h>

#import "IGListBatchUpdates.h"
#import "IGListReloadIndexPath.h"
#import "UICollectionView+IGListBatchUpdateData.h"

void IGListConvertReloadToDeleteInsert(NSMutableIndexSet *reloads,
                                       NSMutableIndexSet *deletes,
                                       NSMutableIndexSet *inserts,
                                       IGListIndexSetResult *result,
                                       NSArray<id<IGListDiffable>> *fromObjects) {
  // reloadSections: is unsafe to use within performBatchUpdates:, so instead convert all reloads into deletes+inserts
  const BOOL hasObjects = [fromObjects count] > 0;
  [[reloads copy] enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
    // if a diff was not performed, there are no changes. instead use the same index that was originally queued
    id<NSObject> diffIdentifier = hasObjects ? [fromObjects[idx] diffIdentifier] : nil;
    const NSInteger from = hasObjects ? [result oldIndexForIdentifier:diffIdentifier] : idx;
    const NSInteger to = hasObjects ? [result newIndexForIdentifier:diffIdentifier] : idx;
    [reloads removeIndex:from];

    // if a reload is queued outside the diff and the object was inserted or deleted it cannot be
    if (from != NSNotFound && to != NSNotFound) {
            [deletes addIndex:from];
            [inserts addIndex:to];
        } else {
            IGAssert([result.deletes containsIndex:idx],
                     @"Reloaded section %lu was not found in deletes with from: %li, to: %li, deletes: %@, fromClass: %@",
                     (unsigned long)idx, (long)from, (long)to, deletes, [(id)fromObjects[idx] class]);
        }
    }];
}

static NSArray<NSIndexPath *> *convertSectionReloadToItemUpdates(NSIndexSet *sectionReloads, UICollectionView *collectionView) {
    NSMutableArray<NSIndexPath *> *updates = [NSMutableArray new];
    [sectionReloads enumerateIndexesUsingBlock:^(NSUInteger sectionIndex, BOOL * _Nonnull stop) {
        NSUInteger numberOfItems = [collectionView numberOfItemsInSection:sectionIndex];
        for (NSUInteger itemIndex = 0; itemIndex < numberOfItems; itemIndex++) {
            [updates addObject:[NSIndexPath indexPathForItem:itemIndex inSection:sectionIndex]];
        }
    }];
    return [updates copy];
}

IGListBatchUpdateData *IGListApplyUpdatesToCollectionView(UICollectionView *collectionView,
                                                          IGListIndexSetResult *diffResult,
                                                          IGListBatchUpdates *batchUpdates,
                                                          NSArray<id<IGListDiffable>> *fromObjects,
                                                          IGListExperiment experiments,
                                                          BOOL movesAsDeletesInserts,
                                                          BOOL preferItemReloadsForSectionReloads) {
    NSSet *moves = [[NSSet alloc] initWithArray:diffResult.moves];

    // combine section reloads from the diff and manual reloads via reloadItems:
    NSMutableIndexSet *reloads = [diffResult.updates mutableCopy];
    [reloads addIndexes:batchUpdates.sectionReloads];

    NSMutableIndexSet *inserts = [diffResult.inserts mutableCopy];
    NSMutableIndexSet *deletes = [diffResult.deletes mutableCopy];
    NSMutableArray<NSIndexPath *> *itemUpdates = [NSMutableArray new];
    if (movesAsDeletesInserts) {
        for (IGListMoveIndex *move in moves) {
            [deletes addIndex:move.from];
            [inserts addIndex:move.to];
        }
        // clear out all moves
        moves = [NSSet new];
    }

    // Item reloads are not safe, if any section moves happened or there are inserts/deletes.
    if (preferItemReloadsForSectionReloads
        && moves.count == 0 && inserts.count == 0 && deletes.count == 0 && reloads.count > 0) {
        [reloads enumerateIndexesUsingBlock:^(NSUInteger sectionIndex, BOOL * _Nonnull stop) {
            NSMutableIndexSet *localIndexSet = [NSMutableIndexSet indexSetWithIndex:sectionIndex];
            if (sectionIndex < [collectionView numberOfSections]
                && sectionIndex < [collectionView.dataSource numberOfSectionsInCollectionView:collectionView]
                && [collectionView numberOfItemsInSection:sectionIndex] == [collectionView.dataSource collectionView:collectionView numberOfItemsInSection:sectionIndex]) {
                // Perfer to do item reloads instead, if the number of items in section is unchanged.
                [itemUpdates addObjectsFromArray:convertSectionReloadToItemUpdates(localIndexSet, collectionView)];
            } else {
                // Otherwise, fallback to convert into delete+insert section operation.
                IGListConvertReloadToDeleteInsert(localIndexSet, deletes, inserts, diffResult, fromObjects);
            }
        }];
    } else {
        // reloadSections: is unsafe to use within performBatchUpdates:, so instead convert all reloads into deletes+inserts
        IGListConvertReloadToDeleteInsert(reloads, deletes, inserts, diffResult, fromObjects);
    }

    NSMutableArray<NSIndexPath *> *itemInserts = batchUpdates.itemInserts;
    NSMutableArray<NSIndexPath *> *itemDeletes = batchUpdates.itemDeletes;
    NSMutableArray<IGListMoveIndexPath *> *itemMoves = batchUpdates.itemMoves;

    NSSet<NSIndexPath *> *uniqueDeletes = [NSSet setWithArray:itemDeletes];
    NSMutableSet<NSIndexPath *> *reloadDeletePaths = [NSMutableSet new];
    NSMutableSet<NSIndexPath *> *reloadInsertPaths = [NSMutableSet new];
    for (IGListReloadIndexPath *reload in batchUpdates.itemReloads) {
        if (![uniqueDeletes containsObject:reload.fromIndexPath]) {
            [reloadDeletePaths addObject:reload.fromIndexPath];
            [reloadInsertPaths addObject:reload.toIndexPath];
        }
    }
    [itemDeletes addObjectsFromArray:[reloadDeletePaths allObjects]];
    [itemInserts addObjectsFromArray:[reloadInsertPaths allObjects]];

    const BOOL fixIndexPathImbalance = IGListExperimentEnabled(experiments, IGListExperimentFixIndexPathImbalance);
    IGListBatchUpdateData *updateData = [[IGListBatchUpdateData alloc] initWithInsertSections:inserts
                                                                               deleteSections:deletes
                                                                                 moveSections:moves
                                                                             insertIndexPaths:itemInserts
                                                                             deleteIndexPaths:itemDeletes
                                                                             updateIndexPaths:itemUpdates
                                                                               moveIndexPaths:itemMoves
                                                                        fixIndexPathImbalance:fixIndexPathImbalance];
    [collectionView ig_applyBatchUpdateData:updateData];
    return updateData;
}
