/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

#import <IGListDiffKit/IGListExperiments.h>

@class IGListBatchUpdateData;
@class IGListBatchUpdates;
@class IGListIndexSetResult;
@protocol IGListDiffable;

NS_ASSUME_NONNULL_BEGIN

void IGListConvertReloadToDeleteInsert(NSMutableIndexSet *reloads,
                                              NSMutableIndexSet *deletes,
                                              NSMutableIndexSet *inserts,
                                              IGListIndexSetResult *result,
                                              NSArray<id<IGListDiffable>> *fromObjects);

IGListBatchUpdateData *IGListApplyUpdatesToCollectionView(UICollectionView *collectionView,
                                                                 IGListIndexSetResult *diffResult,
                                                                 IGListBatchUpdates *batchUpdates,
                                                                 NSArray<id<IGListDiffable>> *fromObjects,
                                                                 IGListExperiment experiments,
                                                                 BOOL movesAsDeletesInserts,
                                                                 BOOL preferItemReloadsForSectionReloads);

NS_ASSUME_NONNULL_END
