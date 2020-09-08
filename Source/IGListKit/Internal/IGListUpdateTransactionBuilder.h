/*
* Copyright (c) Facebook, Inc. and its affiliates.
*
* This source code is licensed under the MIT license found in the
* LICENSE file in the root directory of this source tree.
*/

#import <Foundation/Foundation.h>

#import <IGListDiffKit/IGListMacros.h>
#import <IGListKit/IGListUpdatingDelegate.h>
#import <IGListKit/IGListUpdatingDelegateExperimental.h>

@protocol IGListAdapterUpdaterDelegate;
@protocol IGListAdapterUpdating;

NS_ASSUME_NONNULL_BEGIN

/// Class to collect reload & update information before actually starting the transition.
IGLK_SUBCLASSING_RESTRICTED
@interface IGListUpdateTransactionBuilder : NSObject

/**
 Add a section-level update.

 @param animated A flag indicating if the transition should be animated.
 @param collectionViewBlock A block returning the collecion view to perform updates on.
 @param dataBlock A block which returns the transition data
 @param applyDataBlock A block that applies the data passed from the `dataBlock` block
 @param completion A completion block to execute when the update is finished.
*/
- (void)addSectionBatchUpdateAnimated:(BOOL)animated
                  collectionViewBlock:(IGListCollectionViewBlock)collectionViewBlock
                            dataBlock:(IGListTransitionDataBlock)dataBlock
                       applyDataBlock:(IGListTransitionDataApplyBlock)applyDataBlock
                           completion:(nullable IGListUpdatingCompletion)completion;

/**
 Add a item-level update.

 @param animated A flag indicating if the transition should be animated.
 @param collectionViewBlock A block returning the collecion view to perform updates on.
 @param itemUpdates A block containing all of the updates.
 @param completion A completion block to execute when the update is finished.
*/
- (void)addItemBatchUpdateAnimated:(BOOL)animated
               collectionViewBlock:(IGListCollectionViewBlock)collectionViewBlock
                       itemUpdates:(IGListItemUpdateBlock)itemUpdates
                        completion:(nullable IGListUpdatingCompletion)completion;

/**
Completely reload data in the collection.

@param collectionViewBlock A block returning the collecion view to reload.
@param reloadBlock A block that must be called when the adapter reloads the collection view.
@param completion A completion block to execute when the reload is finished.
*/
- (void)addReloadDataWithCollectionViewBlock:(IGListCollectionViewBlock)collectionViewBlock
                                 reloadBlock:(IGListReloadUpdateBlock)reloadBlock
                                  completion:(nullable IGListUpdatingCompletion)completion;

// Batch updates
- (nullable IGListTransitionDataBlock)dataBlock;
- (nullable IGListTransitionDataApplyBlock)applyDataBlock;
- (NSMutableArray<IGListItemUpdateBlock> *)itemUpdateBlocks;
- (BOOL)animated;

// Reload
- (BOOL)hasReloadData;
- (nullable IGListReloadUpdateBlock)reloadBlock;

// Both
- (nullable IGListCollectionViewBlock)collectionViewBlock;
- (NSMutableArray<IGListUpdatingCompletion> *)completionBlocks;
- (BOOL)hasChanges;

@end

NS_ASSUME_NONNULL_END
