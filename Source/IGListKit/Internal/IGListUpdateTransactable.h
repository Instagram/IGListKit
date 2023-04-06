/*
* Copyright (c) Meta Platforms, Inc. and affiliates.
*
* This source code is licensed under the MIT license found in the
* LICENSE file in the root directory of this source tree.
*/

#import <Foundation/Foundation.h>

#if !__has_include(<IGListDiffKit/IGListDiffKit.h>)
#import "IGListExperiments.h"
#else
#import <IGListDiffKit/IGListExperiments.h>
#endif

#import "IGListBatchUpdateState.h"
#import "IGListUpdatingDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/// Config to customize how the transition works.
typedef struct {
    BOOL sectionMovesAsDeletesInserts;
    BOOL singleItemSectionUpdates;
    BOOL preferItemReloadsForSectionReloads;
    BOOL allowsReloadingOnTooManyUpdates;
    BOOL allowsBackgroundDiffing;
    IGListExperiment experiments;
} IGListUpdateTransactationConfig;

/// Conform to this protocol to handle an update transaction.
@protocol IGListUpdateTransactable <NSObject>

/// Begin the transaction. We expect all completion blocks to be called once finished.
- (void)begin;

/// Cancel any on going updates.
- (BOOL)cancel;

/// Current state of the transaction
- (IGListBatchUpdateState)state;

/// Add a completion block to complete once the transaction ends
- (void)addCompletionBlock:(IGListUpdatingCompletion)completion;

- (void)insertItemsAtIndexPaths:(NSArray <NSIndexPath *> *)indexPaths;
- (void)deleteItemsAtIndexPaths:(NSArray <NSIndexPath *> *)indexPaths;
- (void)moveItemFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;
- (void)reloadItemFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;
- (void)reloadSections:(NSIndexSet *)sections;

@end

NS_ASSUME_NONNULL_END
