/*
* Copyright (c) Facebook, Inc. and its affiliates.
*
* This source code is licensed under the MIT license found in the
* LICENSE file in the root directory of this source tree.
*/

#import "IGListUpdateTransactionBuilder.h"

#import "IGListBatchUpdateTransaction.h"
#import "IGListReloadTransaction.h"

@interface IGListUpdateTransactionBuilder ()
// Batch updates
@property (nonatomic, copy, readwrite, nullable) IGListTransitionDataBlock dataBlock;
@property (nonatomic, copy, readwrite, nullable) IGListTransitionDataApplyBlock applyDataBlock;
@property (nonatomic, strong, readonly) NSMutableArray<IGListItemUpdateBlock> *itemUpdateBlocks;
@property (nonatomic, assign, readwrite) BOOL animated;
// Reload
@property (nonatomic, assign, readwrite) BOOL hasReloadData;
@property (nonatomic, copy, readwrite, nullable) IGListReloadUpdateBlock reloadBlock;
// Both
@property (nonatomic, copy, readwrite, nullable) IGListCollectionViewBlock collectionViewBlock;
@property (nonatomic, strong, readonly) NSMutableArray<IGListUpdatingCompletion> *completionBlocks;
@end

@implementation IGListUpdateTransactionBuilder

- (instancetype)init {
    if (self = [super init]) {
        _animated = YES;
        _itemUpdateBlocks = [NSMutableArray new];
        _completionBlocks = [NSMutableArray new];
    }
    return self;
}

#pragma mark - Add changes

- (void)addSectionBatchUpdateAnimated:(BOOL)animated
                  collectionViewBlock:(IGListCollectionViewBlock)collectionViewBlock
                            dataBlock:(IGListTransitionDataBlock)dataBlock
                       applyDataBlock:(IGListTransitionDataApplyBlock)applyDataBlock
                           completion:(IGListUpdatingCompletion)completion {
    // disabled animations will always take priority
    // reset to YES in -cleanupState
    self.animated = self.animated && animated;
    self.collectionViewBlock = collectionViewBlock;

    // will call the dataBlock after the dispatch
    self.dataBlock = dataBlock;

    // always use the last update block, even though this should always do the exact same thing
    self.applyDataBlock = applyDataBlock;

    IGListUpdatingCompletion localCompletion = completion;
    if (localCompletion) {
        [self.completionBlocks addObject:localCompletion];
    }
}

- (void)addItemBatchUpdateAnimated:(BOOL)animated
               collectionViewBlock:(IGListCollectionViewBlock)collectionViewBlock
                       itemUpdates:(IGListItemUpdateBlock)itemUpdates
                        completion:(nullable IGListUpdatingCompletion)completion {
    // disabled animations will always take priority
    // reset to YES in -cleanupState
    self.animated = self.animated && animated;
    self.collectionViewBlock = collectionViewBlock;

    [self.itemUpdateBlocks addObject:itemUpdates];

    IGListUpdatingCompletion localCompletion = completion;
    if (localCompletion) {
        [self.completionBlocks addObject:localCompletion];
    }
}

- (void)addReloadDataWithCollectionViewBlock:(IGListCollectionViewBlock)collectionViewBlock
                                 reloadBlock:(IGListReloadUpdateBlock)reloadBlock
                                  completion:(nullable IGListUpdatingCompletion)completion {
    self.hasReloadData = YES;
    self.collectionViewBlock = collectionViewBlock;
    self.reloadBlock = reloadBlock;

    IGListUpdatingCompletion localCompletion = completion;
    if (localCompletion) {
        [self.completionBlocks addObject:localCompletion];
    }
}

- (BOOL)hasChanges {
    return self.hasReloadData
    || self.itemUpdateBlocks.count > 0
    || self.dataBlock != nil;
}

- (nullable id<IGListUpdateTransactable>)buildWithConfig:(IGListUpdateTransactationConfig)config
                                                delegate:(nullable id<IGListAdapterUpdaterDelegate>)delegate
                                                 updater:(id<IGListAdapterUpdaterCompatible>)updater {
    IGListCollectionViewBlock collectionViewBlock = _collectionViewBlock;
    if (!collectionViewBlock) {
        return nil;
    }

    if (_hasReloadData) {
        IGListReloadUpdateBlock reloadBlock = self.reloadBlock;
        if (!reloadBlock) {
            return nil;
        }
        return [[IGListReloadTransaction alloc] initWithCollectionViewBlock:collectionViewBlock
                                                                    updater:updater
                                                                   delegate:delegate
                                                                reloadBlock:reloadBlock
                                                           itemUpdateBlocks:self.itemUpdateBlocks
                                                           completionBlocks:self.completionBlocks];
    } else {
        return [[IGListBatchUpdateTransaction alloc] initWithCollectionViewBlock:collectionViewBlock
                                                                         updater:updater
                                                                        delegate:delegate
                                                                          config:config
                                                                        animated:self.animated
                                                                       dataBlock:self.dataBlock
                                                                  applyDataBlock:self.applyDataBlock
                                                                itemUpdateBlocks:self.itemUpdateBlocks
                                                                completionBlocks:self.completionBlocks];
    }
}

@end
