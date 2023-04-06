/*
* Copyright (c) Meta Platforms, Inc. and affiliates.
*
* This source code is licensed under the MIT license found in the
* LICENSE file in the root directory of this source tree.
*/

#import "IGListDataSourceChangeTransaction.h"

@implementation IGListDataSourceChangeTransaction {
    // Given
    IGListDataSourceChangeBlock _block;
    NSArray<IGListItemUpdateBlock> *_itemUpdateBlocks;
    NSArray<IGListUpdatingCompletion> *_completionBlocks;

    // Internal
    NSMutableArray<IGListUpdatingCompletion> *_inUpdateCompletionBlocks;
    IGListBatchUpdateState _state;
}

- (instancetype)initWithChangeBlock:(IGListDataSourceChangeBlock)block
                   itemUpdateBlocks:(NSArray<IGListItemUpdateBlock> *)itemUpdateBlocks
                   completionBlocks:(NSArray<IGListUpdatingCompletion> *)completionBlocks {
    if (self = [super init]) {
        _block = block;
        _itemUpdateBlocks = itemUpdateBlocks;
        _completionBlocks = completionBlocks;
    }
    return self;
}

- (IGListBatchUpdateState)state {
    return _state;
}

#pragma mark - Update

- (void)begin {
    // Item updates must not send mutations to the collection view while we are reloading
    _state = IGListBatchUpdateStateExecutingBatchUpdateBlock;

    // Execute all stored item update blocks even if all cells will get reloaded. the actual collection view
    // mutations will be discarded, but clients are encouraged to put their actual /data/ mutations inside the
    // update block as well, so if we don't execute the block the changes will never happen
    for (IGListItemUpdateBlock itemUpdateBlock in _itemUpdateBlocks) {
        itemUpdateBlock();
    }

    _state = IGListBatchUpdateStateExecutedBatchUpdateBlock;

    // Apply dataSource change
    if (_block) {
        _block();
    }

    for (IGListUpdatingCompletion completion in _completionBlocks) {
        completion(YES);
    }

    // Execute any completion blocks from item updates. Added after item blocks are executed in order to capture any
    // re-entrant updates.
    NSArray *inUpdateCompletionBlocks = [_inUpdateCompletionBlocks copy];
    for (IGListUpdatingCompletion completion in inUpdateCompletionBlocks) {
        completion(YES);
    }

    _state = IGListBatchUpdateStateIdle;
}

#pragma mark - Cancel

- (BOOL)cancel {
    // This transaction is synchronous
    return NO;
}

#pragma mark - Item updates

- (void)insertItemsAtIndexPaths:(NSArray <NSIndexPath *> *)indexPaths {
    // no-op because changing the UICollectionView's dataSource invalidates section/item counts
}

- (void)deleteItemsAtIndexPaths:(NSArray <NSIndexPath *> *)indexPaths {
    // no-op because changing the UICollectionView's dataSource invalidates section/item counts
}

- (void)moveItemFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    // no-op because changing the UICollectionView's dataSource invalidates section/item counts
}

- (void)reloadItemFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    // no-op because changing the UICollectionView's dataSource invalidates section/item counts
}

- (void)reloadSections:(NSIndexSet *)sections {
    // no-op because changing the UICollectionView's dataSource invalidates section/item counts
}

- (void)addCompletionBlock:(IGListUpdatingCompletion)completion {
    if (!_inUpdateCompletionBlocks) {
        _inUpdateCompletionBlocks = [NSMutableArray new];
    }
    [_inUpdateCompletionBlocks addObject:completion];
}

@end
