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
@property (nonatomic, copy, readonly) UICollectionView *collectionView;
@property (nonatomic, weak, readonly) IGListAdapterUpdater *updater;
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
                                    updater:(IGListAdapterUpdater *)updater
                                   delegate:(id<IGListAdapterUpdaterDelegate>)delegate
                                reloadBlock:(IGListReloadUpdateBlock)reloadBlock
                           itemUpdateBlocks:(NSArray<IGListItemUpdateBlock> *)itemUpdateBlocks
                           completionBlocks:(NSArray<IGListUpdatingCompletion> *)completionBlocks {
    if (self = [super init]) {
        _collectionView = collectionViewBlock ? collectionViewBlock() : nil;
        _updater = updater;
        _delegate = delegate;
        _reloadBlock = [reloadBlock copy];
        _itemUpdateBlocks = [itemUpdateBlocks copy];
        _completionBlocks = [completionBlocks copy];

        _state = IGListBatchUpdateStateIdle;
    }
    return self;
}

#pragma mark - Update

- (void)begin {
    // bail early if the collection view has been deallocated in the time since the update was queued
    if (self.collectionView == nil) {
        [self.delegate listAdapterUpdater:self.updater didFinishWithoutUpdatesWithCollectionView:self.collectionView];
        [self _executeCompletionBlocks:YES];
        return;
    }

    // item updates must not send mutations to the collection view while we are reloading
    self.state = IGListBatchUpdateStateExecutingBatchUpdateBlock;

    if (self.reloadBlock) {
        self.reloadBlock();
    }

    // execute all stored item update blocks even if we are just calling reloadData. the actual collection view
    // mutations will be discarded, but clients are encouraged to put their actual /data/ mutations inside the
    // update block as well, so if we don't execute the block the changes will never happen
    for (IGListItemUpdateBlock itemUpdateBlock in self.itemUpdateBlocks) {
        itemUpdateBlock();
    }

    self.state = IGListBatchUpdateStateExecutedBatchUpdateBlock;

    [self.delegate listAdapterUpdater:self.updater willReloadDataWithCollectionView:self.collectionView isFallbackReload:NO];
    [self.collectionView reloadData];
    [self.collectionView.collectionViewLayout invalidateLayout];
    [self.collectionView layoutIfNeeded];
    [self.delegate listAdapterUpdater:self.updater didReloadDataWithCollectionView:self.collectionView isFallbackReload:NO];

    [self _executeCompletionBlocks:YES];
}

- (void)_executeCompletionBlocks:(BOOL)finished {
    for (IGListUpdatingCompletion block in self.completionBlocks) {
        block(finished);
    }

    // Execute any completion blocks from item updates. Added after item blocks are executed in order to capture any
    // re-entrant updates.
    NSArray *inUpdateCompletionBlocks = [self.inUpdateCompletionBlocks copy];
    for (IGListUpdatingCompletion block in inUpdateCompletionBlocks) {
        block(finished);
    }

    self.state = IGListBatchUpdateStateIdle;
}

#pragma mark - Cancel

- (BOOL)cancel {
    // This transaction is syncronous
    return NO;
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

- (void)addCompletionBlock:(IGListUpdatingCompletion)completion {
    if (!self.inUpdateCompletionBlocks) {
        _inUpdateCompletionBlocks = [NSMutableArray new];
    }
    [self.inUpdateCompletionBlocks addObject:completion];
}

@end
