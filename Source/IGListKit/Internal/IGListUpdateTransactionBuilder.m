/*
* Copyright (c) Facebook, Inc. and its affiliates.
*
* This source code is licensed under the MIT license found in the
* LICENSE file in the root directory of this source tree.
*/

#import "IGListUpdateTransactionBuilder.h"

#import "IGListBatchUpdateTransaction.h"
#import "IGListDataSourceChangeTransaction.h"
#import "IGListReloadTransaction.h"

/**
 Modes in ascending order of priority.
 */
typedef NS_ENUM (NSInteger, IGListUpdateTransactionBuilderMode) {
    /// The lowest priority is a batch-update, because a reload or dataSource take care of any changes.
    IGListUpdateTransactionBuilderModeBatchUpdate,
    /// The second priority is reloading all data.
    IGListUpdateTransactionBuilderModeReload,
    /// The highest priority is changing the `UICollectionView` dataSource.
    IGListUpdateTransactionBuilderModeDataSourceChange,
};

@interface IGListUpdateTransactionBuilder ()
// Batch updates
@property (nonatomic, copy, readwrite, nullable) IGListTransitionDataBlock sectionDataBlock;
@property (nonatomic, copy, readwrite, nullable) IGListTransitionDataApplyBlock applySectionDataBlock;
@property (nonatomic, strong, readonly) NSMutableArray<IGListItemUpdateBlock> *itemUpdateBlocks;
@property (nonatomic, assign, readwrite) BOOL animated;
// Reload
@property (nonatomic, copy, readwrite, nullable) IGListReloadUpdateBlock reloadBlock;
// DataSource change
@property (nonatomic, copy, readwrite, nullable) IGListDataSourceChangeBlock dataSourceChangeBlock;
// Both
@property (nonatomic, assign, readwrite) IGListUpdateTransactionBuilderMode mode;
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
                     sectionDataBlock:(IGListTransitionDataBlock)sectionDataBlock
                applySectionDataBlock:(IGListTransitionDataApplyBlock)applySectionDataBlock
                           completion:(IGListUpdatingCompletion)completion {
    self.mode = MAX(self.mode, IGListUpdateTransactionBuilderModeBatchUpdate);

    // disabled animations will always take priority
    // reset to YES in -cleanupState
    self.animated = self.animated && animated;
    self.collectionViewBlock = collectionViewBlock;

    // will call the sectionDataBlock after the dispatch
    self.sectionDataBlock = sectionDataBlock;

    // always use the last update block, even though this should always do the exact same thing
    self.applySectionDataBlock = applySectionDataBlock;

    IGListUpdatingCompletion localCompletion = completion;
    if (localCompletion) {
        [self.completionBlocks addObject:localCompletion];
    }
}

- (void)addItemBatchUpdateAnimated:(BOOL)animated
               collectionViewBlock:(IGListCollectionViewBlock)collectionViewBlock
                       itemUpdates:(IGListItemUpdateBlock)itemUpdates
                        completion:(nullable IGListUpdatingCompletion)completion {
    self.mode = MAX(self.mode, IGListUpdateTransactionBuilderModeBatchUpdate);

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
    self.mode = MAX(self.mode, IGListUpdateTransactionBuilderModeReload);

    self.collectionViewBlock = collectionViewBlock;
    self.reloadBlock = reloadBlock;

    IGListUpdatingCompletion localCompletion = completion;
    if (localCompletion) {
        [self.completionBlocks addObject:localCompletion];
    }
}

- (void)addDataSourceChange:(IGListDataSourceChangeBlock)block {
    self.mode = MAX(self.mode, IGListUpdateTransactionBuilderModeDataSourceChange);

    self.dataSourceChangeBlock = block;
}

- (void)addChangesFromBuilder:(IGListUpdateTransactionBuilder *)builder {
    if (!builder) {
        return;
    }

    self.mode = MAX(self.mode, builder.mode);

    // Section update
    self.animated = self.animated && builder.animated;
    self.sectionDataBlock = self.sectionDataBlock ?: builder.sectionDataBlock;
    self.applySectionDataBlock = self.applySectionDataBlock ?: builder.applySectionDataBlock;

    // Item updates
    [self.itemUpdateBlocks addObjectsFromArray:builder.itemUpdateBlocks];

    // Reload
    self.reloadBlock = self.reloadBlock ?: builder.reloadBlock;

    // All
    self.collectionViewBlock = self.collectionViewBlock ?: builder.collectionViewBlock;
    [self.completionBlocks addObjectsFromArray:builder.completionBlocks];
}

- (nullable id<IGListUpdateTransactable>)buildWithConfig:(IGListUpdateTransactationConfig)config
                                                delegate:(nullable id<IGListAdapterUpdaterDelegate>)delegate
                                                 updater:(IGListAdapterUpdater *)updater {
    IGListCollectionViewBlock collectionViewBlock = self.collectionViewBlock;
    if (!collectionViewBlock) {
        return nil;
    }

    switch (self.mode) {
        case IGListUpdateTransactionBuilderModeBatchUpdate: {
            return [[IGListBatchUpdateTransaction alloc] initWithCollectionViewBlock:collectionViewBlock
                                                                             updater:updater
                                                                            delegate:delegate
                                                                              config:config
                                                                            animated:self.animated
                                                                    sectionDataBlock:self.sectionDataBlock
                                                               applySectionDataBlock:self.applySectionDataBlock
                                                                    itemUpdateBlocks:self.itemUpdateBlocks
                                                                    completionBlocks:self.completionBlocks];
        }
        case IGListUpdateTransactionBuilderModeReload: {
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
        }
        case IGListUpdateTransactionBuilderModeDataSourceChange: {
            IGListDataSourceChangeBlock dataSourceChangeBlock = self.dataSourceChangeBlock;
            if (!dataSourceChangeBlock) {
                return nil;
            }
            return [[IGListDataSourceChangeTransaction alloc] initWithChangeBlock:dataSourceChangeBlock
                                                                 itemUpdateBlocks:self.itemUpdateBlocks
                                                                 completionBlocks:self.completionBlocks];
        }
    }
}

- (BOOL)hasChanges {
    return self.mode == IGListUpdateTransactionBuilderModeReload
    || self.mode == IGListUpdateTransactionBuilderModeDataSourceChange
    || self.itemUpdateBlocks.count > 0
    || self.sectionDataBlock != nil;
}

@end
