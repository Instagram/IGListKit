/**
 * Copyright (c) 2016-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#import <IGListKit/IGListMoveIndexPath.h>

#import "IGListAdapterUpdater.h"
#import "IGListBatchUpdateState.h"
#import "IGListBatchUpdates.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN void convertReloadToDeleteInsert(NSMutableIndexSet *reloads,
                                                   NSMutableIndexSet *deletes,
                                                   NSMutableIndexSet *inserts,
                                                   IGListIndexSetResult *result,
                                                   NSArray<id<IGListDiffable>> *fromObjects);

@interface IGListAdapterUpdater ()

@property (nonatomic, copy, nullable) NSArray *fromObjects;
@property (nonatomic, copy, nullable) IGListToObjectBlock toObjectsBlock;
@property (nonatomic, copy, nullable) NSArray *pendingTransitionToObjects;
@property (nonatomic, strong) NSMutableArray<IGListUpdatingCompletion> *completionBlocks;

@property (nonatomic, assign) BOOL queuedUpdateIsAnimated;

@property (nonatomic, strong) IGListBatchUpdates *batchUpdates;

@property (nonatomic, copy, nullable) IGListObjectTransitionBlock objectTransitionBlock;

@property (nonatomic, copy, nullable) IGListReloadUpdateBlock reloadUpdates;
@property (nonatomic, assign, getter=hasQueuedReloadData) BOOL queuedReloadData;

@property (nonatomic, assign) IGListBatchUpdateState state;
@property (nonatomic, strong, nullable) IGListBatchUpdateData *applyingUpdateData;

- (void)performReloadDataWithCollectionView:(UICollectionView *)collectionView;
- (void)performBatchUpdatesWithCollectionView:(UICollectionView *)collectionView;
- (void)cleanStateBeforeUpdates;
- (BOOL)hasChanges;

@end

NS_ASSUME_NONNULL_END
