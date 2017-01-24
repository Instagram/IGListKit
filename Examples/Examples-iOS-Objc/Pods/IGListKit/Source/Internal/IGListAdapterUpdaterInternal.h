/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#import "IGListAdapterUpdater.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN void convertReloadToDeleteInsert(NSMutableIndexSet *reloads,
                                                   NSMutableIndexSet *deletes,
                                                   NSMutableIndexSet *inserts,
                                                   IGListIndexSetResult *result,
                                                   NSArray<id<IGListDiffable>> *fromObjects);

@interface IGListAdapterUpdater ()

@property (nonatomic, strong, readonly) NSMutableArray<IGListUpdatingCompletion> *completionBlocks;

@property (nonatomic, copy, nullable) NSArray *fromObjects;
@property (nonatomic, copy, nullable) NSArray *toObjects;
@property (nonatomic, copy, nullable) NSArray *pendingTransitionToObjects;

@property (nonatomic, assign) BOOL queuedUpdateIsAnimated;

@property (nonatomic, strong, readonly) NSMutableSet<NSIndexPath *> *deleteIndexPaths;
@property (nonatomic, strong, readonly) NSMutableSet<NSIndexPath *> *insertIndexPaths;
@property (nonatomic, strong, readonly) NSMutableSet<NSIndexPath *> *reloadIndexPaths;
@property (nonatomic, strong, readonly) NSMutableIndexSet *reloadSections;

@property (nonatomic, copy, nullable) IGListObjectTransitionBlock objectTransitionBlock;
@property (nonatomic, copy, nullable) NSMutableArray<IGListItemUpdateBlock> *itemUpdateBlocks;

@property (nonatomic, copy, nullable) IGListReloadUpdateBlock reloadUpdates;
@property (nonatomic, assign, getter=hasQueuedReloadData) BOOL queuedReloadData;

@property (nonatomic, assign) BOOL batchUpdateOrReloadInProgress;

- (void)performReloadDataWithCollectionView:(UICollectionView *)collectionView;
- (void)performBatchUpdatesWithCollectionView:(UICollectionView *)collectionView;
- (void)cleanupState;
- (BOOL)hasChanges;

@end

NS_ASSUME_NONNULL_END
