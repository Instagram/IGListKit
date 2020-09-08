/*
* Copyright (c) Facebook, Inc. and its affiliates.
*
* This source code is licensed under the MIT license found in the
* LICENSE file in the root directory of this source tree.
*/

#import "IGListBatchUpdateTransaction.h"

#import <IGListDiffKit/IGListAssert.h>
#import <IGListDiffKit/IGListDiffable.h>
#import <IGListDiffKit/IGListDiff.h>
#import <IGListKit/IGListAdapterUpdaterDelegate.h>

#import "IGListAdapterUpdaterHelpers.h"
#import "IGListIndexSetResultInternal.h"
#import "IGListItemUpdatesCollector.h"
#import "IGListMoveIndexPathInternal.h"
#import "IGListReloadIndexPath.h"
#import "IGListTransitionData.h"
#import "UICollectionView+IGListBatchUpdateData.h"

@interface IGListBatchUpdateTransaction ()
// Given
@property (nonatomic, copy, readonly) IGListCollectionViewBlock collectionViewBlock;
@property (nonatomic, weak, readonly, nullable) id<IGListAdapterUpdaterCompatible> updater;
@property (nonatomic, weak, readonly, nullable) id<IGListAdapterUpdaterDelegate> delegate;
@property (nonatomic, assign, readonly) IGListUpdateTransactationConfig config;
@property (nonatomic, assign, readonly) BOOL animated;
@property (nonatomic, copy, readonly, nullable) IGListTransitionDataBlock dataBlock;
@property (nonatomic, copy, readonly, nullable) IGListTransitionDataApplyBlock applyDataBlock;
@property (nonatomic, copy, readonly) NSArray<IGListItemUpdateBlock> *itemUpdateBlocks;
@property (nonatomic, copy, readonly) NSArray<IGListUpdatingCompletion> *completionBlocks;
// Internal
@property (nonatomic, strong, readonly) IGListItemUpdatesCollector *inUpdateItemCollector;
@property (nonatomic, copy, readonly) NSMutableArray<IGListUpdatingCompletion> *inUpdateCompletionBlocks;
@property (nonatomic, assign, readwrite) IGListBatchUpdateState state;
@property (nonatomic, strong, readwrite, nullable) IGListBatchUpdateData *actualCollectionViewUpdates;
@end

@implementation IGListBatchUpdateTransaction

- (instancetype)initWithCollectionViewBlock:(IGListCollectionViewBlock)collectionViewBlock
                                    updater:(id<IGListAdapterUpdaterCompatible>)updater
                                   delegate:(nullable id<IGListAdapterUpdaterDelegate>)delegate
                                     config:(IGListUpdateTransactationConfig)config
                                   animated:(BOOL)animated
                                  dataBlock:(nullable IGListTransitionDataBlock)dataBlock
                             applyDataBlock:(nullable IGListTransitionDataApplyBlock)applyDataBlock
                           itemUpdateBlocks:(NSArray<IGListItemUpdateBlock> *)itemUpdateBlocks
                           completionBlocks:(NSArray<IGListUpdatingCompletion> *)completionBlocks {
    if (self = [super init]) {
        _collectionViewBlock = [collectionViewBlock copy];
        _updater = updater;
        _delegate = delegate;
        _config = config;
        _animated = animated;
        _dataBlock = [dataBlock copy];
        _applyDataBlock = [applyDataBlock copy];
        _itemUpdateBlocks = [itemUpdateBlocks copy];
        _completionBlocks = [completionBlocks copy];

        _inUpdateItemCollector = [IGListItemUpdatesCollector new];
        _state = IGListBatchUpdateStateIdle;
    }
    return self;
}

#pragma mark - IGListUpdateTransactable

- (void)begin {
    IGListCollectionViewBlock collectionViewBlock = self.collectionViewBlock;
    id<IGListAdapterUpdaterCompatible> updater = self.updater;
    id<IGListAdapterUpdaterDelegate> delegate = self.delegate;
    IGListTransitionDataBlock dataBlock = self.dataBlock;
    IGListTransitionDataApplyBlock applyDataBlock = self.applyDataBlock;
    NSArray<IGListItemUpdateBlock> *itemUpdateBlocks = self.itemUpdateBlocks;
    NSArray<IGListUpdatingCompletion> *completionBlocks = self.completionBlocks;
    const BOOL animated = self.animated;
    const IGListUpdateTransactationConfig config = self.config;

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

        self.actualCollectionViewUpdates = nil;
        self.state = IGListBatchUpdateStateIdle;
    };

    // bail early if the collection view has been deallocated in the time since the update was queued
    UICollectionView *collectionView = collectionViewBlock();
    if (collectionView == nil) {
        [delegate listAdapterUpdater:updater didFinishWithoutUpdatesWithCollectionView:collectionView];
        executeCompletionBlocks(NO);
        return;
    }


    IGListTransitionData *data = nil;
    if (dataBlock != nil) {
        data = dataBlock();
    }

    NSArray *toObjects = data.toObjects;
    NSArray *fromObjects = data.fromObjects;

#ifdef DEBUG
    for (id obj in toObjects) {
        IGAssert([obj conformsToProtocol:@protocol(IGListDiffable)],
                 @"In order to use IGListAdapterUpdater, object %@ must conform to IGListDiffable", obj);
        IGAssert([obj diffIdentifier] != nil,
                 @"Cannot have a nil diffIdentifier for object %@", obj);
    }
#endif

    void (^executeUpdateBlocks)(void) = ^{
        self.state = IGListBatchUpdateStateExecutingBatchUpdateBlock;

        // run the update block so that the adapter can set its items. this makes sure that just before the update is
        // committed that the data source is updated to the /latest/ "toObjects". this makes the data source in sync
        // with the items that the updater is transitioning to
        if (applyDataBlock != nil && data != nil) {
            applyDataBlock(data);
        }

        // execute each item update block which should make calls like insert, delete, and reload for index paths
        // we collect all mutations in corresponding sets on self, then filter based on UICollectionView shortcomings
        // call after the objectTransitionBlock so section level mutations happen before any items
        for (IGListItemUpdateBlock itemUpdateBlock in itemUpdateBlocks) {
            itemUpdateBlock();
        }

        self.state = IGListBatchUpdateStateExecutedBatchUpdateBlock;
    };

    void (^reloadDataFallback)(void) = ^{
        [delegate listAdapterUpdater:updater willReloadDataWithCollectionView:collectionView isFallbackReload:YES];
        executeUpdateBlocks();
        [collectionView reloadData];
        [collectionView layoutIfNeeded];
        [delegate listAdapterUpdater:updater didReloadDataWithCollectionView:collectionView isFallbackReload:YES];
        executeCompletionBlocks(YES);
    };

    // disables multiple performBatchUpdates: from happening at the same time
    self.state = IGListBatchUpdateStateQueuedBatchUpdate;

    // if the collection view isn't in a visible window, skip diffing and batch updating. execute all transition blocks,
    // reload data, execute completion blocks, and get outta here
    if (config.allowsBackgroundReloading && collectionView.window == nil) {
        reloadDataFallback();
        return;
    }

    // block executed in the first param block of -[UICollectionView performBatchUpdates:completion:]
    void (^batchUpdatesBlock)(IGListIndexSetResult *result) = ^(IGListIndexSetResult *result){
        executeUpdateBlocks();
        if (config.singleItemSectionUpdates) {
            [collectionView deleteSections:result.deletes];
            [collectionView insertSections:result.inserts];
            for (IGListMoveIndex *move in result.moves) {
                [collectionView moveSection:move.from toSection:move.to];
            }
            // NOTE: for section updates, it's updated in the IGListSectionController's -didUpdateToObject:, since there is *only* 1 cell for the section, we can just update that cell.

            self.actualCollectionViewUpdates = [[IGListBatchUpdateData alloc]
                                                initWithInsertSections:result.inserts
                                                deleteSections:result.deletes
                                                moveSections:[NSSet setWithArray:result.moves]
                                                insertIndexPaths:@[]
                                                deleteIndexPaths:@[]
                                                updateIndexPaths:@[]
                                                moveIndexPaths:@[]];
        } else {
            self.actualCollectionViewUpdates = IGListApplyUpdatesToCollectionView(collectionView,
                                                                                  result,
                                                                                  self.inUpdateItemCollector.sectionReloads,
                                                                                  self.inUpdateItemCollector.itemInserts,
                                                                                  self.inUpdateItemCollector.itemDeletes,
                                                                                  self.inUpdateItemCollector.itemReloads,
                                                                                  self.inUpdateItemCollector.itemMoves,
                                                                                  fromObjects,
                                                                                  config.sectionMovesAsDeletesInserts,
                                                                                  config.preferItemReloadsForSectionReloads);
        }
    };

    // block used as the second param of -[UICollectionView performBatchUpdates:completion:]
    void (^fallbackWithoutUpdates)(void) = ^(void) {
        [delegate listAdapterUpdater:updater didFinishWithoutUpdatesWithCollectionView:collectionView];
        executeCompletionBlocks(NO);
    };

    // block used as the second param of -[UICollectionView performBatchUpdates:completion:]
    void (^batchUpdatesCompletionBlock)(BOOL) = ^(BOOL finished) {
        IGListBatchUpdateData *oldApplyingUpdateData = self.actualCollectionViewUpdates;
        [delegate listAdapterUpdater:updater didPerformBatchUpdates:oldApplyingUpdateData collectionView:collectionView];
        executeCompletionBlocks(finished);
    };

    void (^performUpdate)(IGListIndexSetResult *) = ^(IGListIndexSetResult *result){
        [delegate listAdapterUpdater:updater
willPerformBatchUpdatesWithCollectionView:collectionView
                         fromObjects:fromObjects
                           toObjects:toObjects
                  listIndexSetResult:result
                            animated:animated];

        if (animated) {
            [collectionView performBatchUpdates:^{
                batchUpdatesBlock(result);
            } completion:batchUpdatesCompletionBlock];
        } else {
            [UIView performWithoutAnimation:^{
                [collectionView performBatchUpdates:^{
                    batchUpdatesBlock(result);
                } completion:batchUpdatesCompletionBlock];
            }];
        }
    };

    // block that executes the batch update and exception handling
    void (^tryToPerformUpdate)(IGListIndexSetResult *) = ^(IGListIndexSetResult *result){
        [delegate listAdapterUpdater:updater didDiffWithResults:result onBackgroundThread:config.allowBackgroundDiffing];

        @try {
            if (collectionView.dataSource == nil) {
                // If the data source is nil, we should not call any collection view update.
                fallbackWithoutUpdates();
            } else if (result.changeCount > 100 && config.allowsReloadingOnTooManyUpdates) {
                reloadDataFallback();
            } else {
                performUpdate(result);
            }
        } @catch (NSException *exception) {
            [delegate listAdapterUpdater:updater
                          collectionView:collectionView
                  willCrashWithException:exception
                             fromObjects:fromObjects
                               toObjects:toObjects
                              diffResult:result
                                 updates:(id)self.actualCollectionViewUpdates];
            @throw exception;
        }
    };

    [delegate listAdapterUpdater:updater willDiffFromObjects:fromObjects toObjects:toObjects];
    if (config.allowBackgroundDiffing) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
            IGListIndexSetResult *result = IGListDiff(fromObjects, toObjects, IGListDiffEquality);
            dispatch_async(dispatch_get_main_queue(), ^{
                tryToPerformUpdate(result);
            });
        });
    } else {
        IGListIndexSetResult *result = IGListDiff(fromObjects, toObjects, IGListDiffEquality);
        tryToPerformUpdate(result);
    }
}

- (void)addCompletionBlock:(IGListUpdatingCompletion)completion {
    if (!self.inUpdateCompletionBlocks) {
        _inUpdateCompletionBlocks = [NSMutableArray new];
    }
    [self.inUpdateCompletionBlocks addObject:completion];
}

#pragma mark - Item updates

- (void)insertItemsAtIndexPaths:(NSArray <NSIndexPath *> *)indexPaths {
    [self.inUpdateItemCollector.itemInserts addObjectsFromArray:indexPaths];
}

- (void)deleteItemsAtIndexPaths:(NSArray <NSIndexPath *> *)indexPaths {
    [self.inUpdateItemCollector.itemDeletes addObjectsFromArray:indexPaths];
}

- (void)moveItemFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    IGListMoveIndexPath *move = [[IGListMoveIndexPath alloc] initWithFrom:fromIndexPath to:toIndexPath];
    [self.inUpdateItemCollector.itemMoves addObject:move];
}

- (void)reloadItemFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    IGListReloadIndexPath *reload = [[IGListReloadIndexPath alloc] initWithFromIndexPath:fromIndexPath toIndexPath:toIndexPath];
    [self.inUpdateItemCollector.itemReloads addObject:reload];
}

- (void)reloadSections:(NSIndexSet *)sections {
    [self.inUpdateItemCollector.sectionReloads addIndexes:sections];
}

@end
