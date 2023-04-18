/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

@class IGListBatchUpdateData;
@class IGListIndexSetResult;
@class IGListReloadIndexPath;
@class IGListMoveIndexPath;
@protocol IGListDiffable;

NS_ASSUME_NONNULL_BEGIN

void IGListConvertReloadToDeleteInsert(NSMutableIndexSet *reloads,
                                       NSMutableIndexSet *deletes,
                                       NSMutableIndexSet *inserts,
                                       IGListIndexSetResult *result,
                                       NSArray<id<IGListDiffable>> *fromObjects);

IGListBatchUpdateData *IGListApplyUpdatesToCollectionView(UICollectionView *collectionView,
                                                          IGListIndexSetResult *diffResult,
                                                          NSMutableIndexSet *sectionReloads,
                                                          NSMutableArray<NSIndexPath *> *itemInserts,
                                                          NSMutableArray<NSIndexPath *> *itemDeletes,
                                                          NSMutableArray<IGListReloadIndexPath *> *itemReloads,
                                                          NSMutableArray<IGListMoveIndexPath *> *itemMoves,
                                                          NSArray<id<IGListDiffable>> *fromObjects,
                                                          BOOL sectionMovesAsDeletesInserts,
                                                          BOOL preferItemReloadsForSectionReloads);

NSIndexSet *IGListSectionIndexFromIndexPaths(NSArray<NSIndexPath *> *indexPaths);

NS_ASSUME_NONNULL_END
