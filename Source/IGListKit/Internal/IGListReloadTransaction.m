/*
* Copyright (c) Facebook, Inc. and its affiliates.
*
* This source code is licensed under the MIT license found in the
* LICENSE file in the root directory of this source tree.
*/

#import "IGListReloadTransaction.h"

#import <IGListKit/IGListAdapterUpdaterDelegate.h>

@interface IGListReloadTransaction ()
// Given
@property (nonatomic, copy, readonly) IGListCollectionViewBlock collectionViewBlock;
@property (nonatomic, weak, readonly, nullable) id<IGListAdapterUpdaterCompatible> updater;
@property (nonatomic, weak, readonly, nullable) id<IGListAdapterUpdaterDelegate> delegate;
@property (nonatomic, copy, readonly) IGListReloadUpdateBlock reloadBlock;
@property (nonatomic, copy, readonly) NSArray<IGListItemUpdateBlock> *itemUpdateBlocks;
@property (nonatomic, copy, readonly) NSArray<IGListUpdatingCompletion> *completionBlocks;
// Internal
@property (nonatomic, assign, readwrite) IGListBatchUpdateState state;
@property (nonatomic, copy, readonly) NSMutableArray<IGListUpdatingCompletion> *inUpdateCompletionBlocks;
@end

@implementation IGListReloadTransaction

- (instancetype)initWithCollectionViewBlock:(IGListCollectionViewBlock)collectionViewBlock
                                    updater:(id<IGListAdapterUpdaterCompatible>)updater
                                   delegate:(nullable id<IGListAdapterUpdaterDelegate>)delegate
                                reloadBlock:(IGListReloadUpdateBlock)reloadBlock
                           itemUpdateBlocks:(NSArray<IGListItemUpdateBlock> *)itemUpdateBlocks
                           completionBlocks:(NSArray<IGListUpdatingCompletion> *)completionBlocks {
    if (self = [super init]) {
        _collectionViewBlock = [collectionViewBlock copy];
        _updater = updater;
        _delegate = delegate;
        _reloadBlock = [reloadBlock copy];
        _itemUpdateBlocks = [itemUpdateBlocks copy];
        _completionBlocks = [completionBlocks copy];

        _state = IGListBatchUpdateStateIdle;
    }
    return self;
}

#pragma mark - IGListUpdateTransactable

- (void)begin {
    IGListCollectionViewBlock collectionViewBlock = self.collectionViewBlock;
    id<IGListAdapterUpdaterCompatible> updater = self.updater;
    id<IGListAdapterUpdaterDelegate> delegate = self.delegate;
    void (^reloadUpdates)(void) = self.reloadBlock;
    NSArray *itemUpdateBlocks = self.itemUpdateBlocks;
    NSArray *completionBlocks = self.completionBlocks;

    void (^executeCompletionBlocks)(BOOL) = ^(BOOL finished) {
        for (IGListUpdatingCompletion block in completionBlocks) {
            block(finished);
        }

        // Execute any completion blocks from item updates. Added after item blocks are executed in order to capture any
        // re-entrant updates.
        NSArray *inUpdateCompletionBlocks = [self.inUpdateCompletionBlocks copy];
        for (IGListUpdatingCompletion block in inUpdateCompletionBlocks) {
            block(finished);
        }

        self.state = IGListBatchUpdateStateIdle;
    };

    // bail early if the collection view has been deallocated in the time since the update was queued
    UICollectionView *collectionView = collectionViewBlock();
    if (collectionView == nil) {
        executeCompletionBlocks(NO);
        [delegate listAdapterUpdater:updater didFinishWithoutUpdatesWithCollectionView:collectionView];
        return;
    }

    // item updates must not send mutations to the collection view while we are reloading
    self.state = IGListBatchUpdateStateExecutingBatchUpdateBlock;

    if (reloadUpdates) {
        reloadUpdates();
    }

    // execute all stored item update blocks even if we are just calling reloadData. the actual collection view
    // mutations will be discarded, but clients are encouraged to put their actual /data/ mutations inside the
    // update block as well, so if we don't execute the block the changes will never happen
    for (IGListItemUpdateBlock itemUpdateBlock in itemUpdateBlocks) {
        itemUpdateBlock();
    }

    self.state = IGListBatchUpdateStateExecutedBatchUpdateBlock;

    [delegate listAdapterUpdater:updater willReloadDataWithCollectionView:collectionView isFallbackReload:NO];
    [collectionView reloadData];
    [collectionView.collectionViewLayout invalidateLayout];
    [collectionView layoutIfNeeded];
    [delegate listAdapterUpdater:updater didReloadDataWithCollectionView:collectionView isFallbackReload:NO];

    executeCompletionBlocks(YES);
}

- (void)addCompletionBlock:(IGListUpdatingCompletion)completion {
    if (!self.inUpdateCompletionBlocks) {
        _inUpdateCompletionBlocks = [NSMutableArray new];
    }
    [self.inUpdateCompletionBlocks addObject:completion];
}

#pragma mark - Item updates

- (void)insertItemsAtIndexPaths:(NSArray <NSIndexPath *> *)indexPaths {
    // no-op. Reloading all cells.
}

- (void)deleteItemsAtIndexPaths:(NSArray <NSIndexPath *> *)indexPaths {
    // no-op. Reloading all cells.
}

- (void)moveItemFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    // no-op. Reloading all cells.
}

- (void)reloadItemFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    // no-op. Reloading all cells.
}

- (void)reloadSections:(NSIndexSet *)sections {
    // no-op. Reloading all cells.
}

@end
