/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGListBatchUpdateTransaction.h"

#if !__has_include(<IGListDiffKit/IGListDiffKit.h>)
#import "IGListAssert.h"
#import "IGListDiffable.h"
#import "IGListDiff.h"
#else
#import <IGListDiffKit/IGListAssert.h>
#import <IGListDiffKit/IGListDiffable.h>
#import <IGListDiffKit/IGListDiff.h>
#endif

#import "IGListAdapterUpdaterDelegate.h"

#import "IGListAdapterUpdaterHelpers.h"
#import "IGListIndexSetResultInternal.h"
#import "IGListItemUpdatesCollector.h"
#import "IGListMoveIndexPathInternal.h"
#import "IGListReloadIndexPath.h"
#import "IGListTransitionData.h"
#import "UICollectionView+IGListBatchUpdateData.h"
#import "IGListPerformDiff.h"

typedef NS_ENUM (NSInteger, IGListBatchUpdateTransactionMode) {
    IGListBatchUpdateTransactionModeCancellable,
    IGListBatchUpdateTransactionModeNotCancellable,
    IGListBatchUpdateTransactionModeCancelled,
};

@interface IGListBatchUpdateTransaction ()
// Given
@property (nonatomic, copy, readonly) UICollectionView *collectionView;
@property (nonatomic, weak, readonly) IGListAdapterUpdater *updater;
@property (nonatomic, weak, readonly, nullable) id<IGListAdapterUpdaterDelegate> delegate;
@property (nonatomic, assign, readonly) IGListUpdateTransactationConfig config;
@property (nonatomic, assign, readonly) BOOL animated;
@property (nonatomic, copy, readonly, nullable) IGListTransitionData *sectionData;
@property (nonatomic, copy, readonly, nullable) IGListTransitionDataApplyBlock applySectionDataBlock;
@property (nonatomic, copy, readonly) NSArray<IGListItemUpdateBlock> *itemUpdateBlocks;
@property (nonatomic, copy, readonly) NSArray<IGListUpdatingCompletion> *completionBlocks;
// Internal
@property (nonatomic, strong, readonly) IGListItemUpdatesCollector *inUpdateItemCollector;
@property (nonatomic, copy, readonly) NSMutableArray<IGListUpdatingCompletion> *inUpdateCompletionBlocks;
@property (nonatomic, assign, readwrite) IGListBatchUpdateState state;
@property (nonatomic, assign, readwrite) IGListBatchUpdateTransactionMode mode;
@property (nonatomic, strong, readwrite, nullable) IGListBatchUpdateData *actualCollectionViewUpdates;
/// Item counts the collection view reports before the update, captured when item updates can be validated.
@property (nonatomic, copy, readwrite, nullable) NSArray<NSNumber *> *itemCountsBeforeUpdate;
@end

@implementation IGListBatchUpdateTransaction

- (instancetype)initWithCollectionViewBlock:(IGListCollectionViewBlock)collectionViewBlock
                                    updater:(IGListAdapterUpdater *)updater
                                   delegate:(id<IGListAdapterUpdaterDelegate>)delegate
                                     config:(IGListUpdateTransactationConfig)config
                                   animated:(BOOL)animated
                           sectionDataBlock:(IGListTransitionDataBlock)sectionDataBlock
                      applySectionDataBlock:(IGListTransitionDataApplyBlock)applySectionDataBlock
                           itemUpdateBlocks:(NSArray<IGListItemUpdateBlock> *)itemUpdateBlocks
                           completionBlocks:(NSArray<IGListUpdatingCompletion> *)completionBlocks {
    if (self = [super init]) {
        _collectionView = collectionViewBlock ? collectionViewBlock() : nil;
        _updater = updater;
        _delegate = delegate;
        _config = config;
        _animated = animated;
        _sectionData = sectionDataBlock ? sectionDataBlock() : nil;
        _applySectionDataBlock = [applySectionDataBlock copy];
        _itemUpdateBlocks = [itemUpdateBlocks copy];
        _completionBlocks = [completionBlocks copy];

        _inUpdateItemCollector = [IGListItemUpdatesCollector new];
        _state = IGListBatchUpdateStateIdle;
        _mode = IGListBatchUpdateTransactionModeCancellable;
    }
    return self;
}

#pragma mark - Update

- (void)begin {
    // bail early if the collection view has been deallocated in the time since the update was queued
    if (self.collectionView == nil) {
        [self _bail];
        return;
    }

#ifdef DEBUG
    for (id obj in self.sectionData.toObjects) {
        IGAssert([obj conformsToProtocol:@protocol(IGListDiffable)],
                 @"In order to use IGListAdapterUpdater, object %@ must conform to IGListDiffable", obj);
        IGAssert([obj diffIdentifier] != nil,
                 @"Cannot have a nil diffIdentifier for object %@", obj);
    }
#endif

    // disables multiple performBatchUpdates: from happening at the same time
    self.state = IGListBatchUpdateStateQueuedBatchUpdate;

    [self _diff];
}

- (void)_diff {
    IGListTransitionData *data = self.sectionData;
    [self.delegate listAdapterUpdater:self.updater willDiffFromObjects:data.fromObjects toObjects:data.toObjects];

    __weak __typeof__(self) weakSelf = self;
    IGListPerformDiffWithData(data,
                              self.collectionView,
                              self.config.allowsBackgroundDiffing,
                              self.config.adaptiveDiffingExperimentConfig,
                              ^(IGListIndexSetResult * _Nonnull result, BOOL onBackground) {
        [weakSelf _didDiff:result onBackground:onBackground];
    });
}

- (void)_didDiff:(IGListIndexSetResult *)diffResult onBackground:(BOOL)onBackground {
    if (self.mode == IGListBatchUpdateTransactionModeCancelled) {
        // Cancelling should have already taken care of the completion blocks
        return;
    }

    // After this point, we can assume that the update has began and there's no turning back.
    self.mode = IGListBatchUpdateTransactionModeNotCancellable;

    [self.delegate listAdapterUpdater:self.updater didDiffWithResults:diffResult onBackgroundThread:onBackground];

    @try {
        // Keeping a pointer to self.collectionView.dataSource, because it can get deallocated before the UICollectionView and crash
        id<UICollectionViewDataSource> const collectionViewDataSource = self.collectionView.dataSource;

        if (collectionViewDataSource == nil) {
            // If the data source is nil, we should not call any collection view update.
            [self _bail];
        } else if (diffResult.changeCount > 100 && self.config.allowsReloadingOnTooManyUpdates) {
            [self _reload];
        } else if (self.sectionData && [self.collectionView numberOfSections] != (NSInteger)self.sectionData.fromObjects.count) {
            // If data is nil, there are no section updates.
            IGWarnAssert(@"The UICollectionView's section count (%li) didn't match the IGListAdapter's count (%li), so we can't performBatchUpdates. Falling back to reloadData.",
                         (long)[self.collectionView numberOfSections],
                         (long)self.sectionData.fromObjects.count);
            [self _reload];
        } else {
            [self _applyDiff:diffResult];
        }
    } @catch (NSException *exception) {
        [self.delegate listAdapterUpdater:self.updater
                           collectionView:self.collectionView
                   willCrashWithException:exception
                              fromObjects:self.sectionData.fromObjects
                                toObjects:self.sectionData.toObjects
                               diffResult:diffResult
                                  updates:(id)_actualCollectionViewUpdates];
        @throw exception;
    }
}

- (void)_applyDiff:(IGListIndexSetResult *)diffResult {
    [self.delegate listAdapterUpdater:self.updater
willPerformBatchUpdatesWithCollectionView:self.collectionView
                          fromObjects:self.sectionData.fromObjects
                            toObjects:self.sectionData.toObjects
                   listIndexSetResult:diffResult
                             animated:self.animated];
    void (^updates)(void) = ^ {
        [self _applyDataUpdates];
        [self _applyCollectioViewUpdates:diffResult];
    };

    void (^completion)(BOOL) = ^(BOOL finished) {
        [self _didPerformBatchUpdate:finished];
    };

    // Section indexes only stay the same before and after the update when no sections are inserted, deleted or moved.
    if (IGListExperimentEnabled(self.config.experiments, IGListExperimentReloadSectionsWithInconsistentItemUpdates)
        && !self.config.singleItemSectionUpdates
        && diffResult.inserts.count == 0
        && diffResult.deletes.count == 0
        && diffResult.moves.count == 0) {
        const NSInteger sectionCount = [self.collectionView numberOfSections];
        NSMutableArray<NSNumber *> *itemCounts = [NSMutableArray arrayWithCapacity:(NSUInteger)sectionCount];
        for (NSInteger section = 0; section < sectionCount; section++) {
            [itemCounts addObject:@([self.collectionView numberOfItemsInSection:section])];
        }
        self.itemCountsBeforeUpdate = itemCounts;
    }

    @try {
        if (self.animated) {
            [self.collectionView performBatchUpdates:updates completion:completion];
        } else {
            [UIView performWithoutAnimation:^{
                [self.collectionView performBatchUpdates:updates completion:completion];
            }];
        }
    }
    @catch (NSException *exception) {
        /// Currently, we don't throw on `NSInternalInconsistencyException`, like the comment below explains. This was a temporary workaround for the large
        /// volume of exceptions that started with Xcode 14.3. Now, lets use this experiment flag to slowly reintroduce it, and eventually remove the workaround.
        const BOOL ignoreException = !IGListExperimentEnabled(self.config.experiments, IGListExperimentThrowOnInconsistencyException);
        if (ignoreException && [[exception name] isEqualToString:NSInternalInconsistencyException]) {
            /// As part of S342566 we have to recover from crashing the app since Xcode 14.3 has shipped
            /// with a different build SDK that changes the runtime behavior of -performBatchUpdates: issues.
            /// When we are performing batch updates, it's on us to advance the data source to the new state
            /// inside the updates closure.
            /// The data source must return the old counts up until the updates closure executes, and must return
            /// the new counts after the updates closure finishes executing.
            /// In prior iOS releases, UICollectionView would log an error message to the console for certain cases
            /// of invalid updates, and instead fall back to reloadData. Using reloadData is destructive to UI state
            /// and can negatively impact performance, but this was kept the app running so far without us noticing!
            /// Now that UIKit has changed this runtime behavior we are going to apply the same workaround for the crash while we work
            /// with our product team to properly fix their data source changes outside of the -performBatchUpdatesBlock:
            /// IGLisKit processed a new being as an assert that requires investigation,
            /// since it will be processed as invalid data source state that needs a reload.
            IGFailure(@"IGListKit caught exception (%@): %@", exception.name, exception.reason);
            [self begin];
            return;
        } else {
            [self.delegate listAdapterUpdater:self.updater
                               collectionView:self.collectionView
                       willCrashWithException:exception
                                  fromObjects:self.sectionData.fromObjects
                                    toObjects:self.sectionData.toObjects
                                   diffResult:diffResult
                                      updates:(id)_actualCollectionViewUpdates];
            @throw exception;
        }
    }
}

- (void)_applyDataUpdates {
    self.state = IGListBatchUpdateStateExecutingBatchUpdateBlock;

    // run the update block so that the adapter can set its items. this makes sure that just before the update is
    // committed that the data source is updated to the /latest/ "toObjects". this makes the data source in sync
    // with the items that the updater is transitioning to
    if (self.applySectionDataBlock != nil && self.sectionData != nil) {
        self.applySectionDataBlock((IGListTransitionData *)self.sectionData);
    }

    // execute each item update block which should make calls like insert, delete, and reload for index paths
    // we collect all mutations in corresponding sets on self, then filter based on UICollectionView shortcomings
    // call after the objectTransitionBlock so section level mutations happen before any items
    for (IGListItemUpdateBlock block in self.itemUpdateBlocks) {
        block();
    }

    self.state = IGListBatchUpdateStateExecutedBatchUpdateBlock;
}

- (void)_applyCollectioViewUpdates:(IGListIndexSetResult *)diffResult {
    if (self.config.singleItemSectionUpdates) {
        [self.collectionView deleteSections:diffResult.deletes];
        [self.collectionView insertSections:diffResult.inserts];
        for (IGListMoveIndex *move in diffResult.moves) {
            [self.collectionView moveSection:move.from toSection:move.to];
        }
        // NOTE: for section updates, it's updated in the IGListSectionController's -didUpdateToObject:, since there is *only* 1 cell for the section, we can just update that cell.

        self.actualCollectionViewUpdates = [[IGListBatchUpdateData alloc]
                                            initWithInsertSections:diffResult.inserts
                                            deleteSections:diffResult.deletes
                                            moveSections:[NSSet setWithArray:diffResult.moves]
                                            insertIndexPaths:@[]
                                            deleteIndexPaths:@[]
                                            updateIndexPaths:@[]
                                            moveIndexPaths:@[]];
    } else {
        [self _reloadSectionsWithInconsistentItemUpdates:diffResult];
        self.actualCollectionViewUpdates = IGListApplyUpdatesToCollectionView(self.collectionView,
                                                                              diffResult,
                                                                              self.inUpdateItemCollector.sectionReloads,
                                                                              self.inUpdateItemCollector.itemInserts,
                                                                              self.inUpdateItemCollector.itemDeletes,
                                                                              self.inUpdateItemCollector.itemReloads,
                                                                              self.inUpdateItemCollector.itemMoves,
                                                                              self.sectionData.fromObjects ?: @[],
                                                                              self.config.sectionMovesAsDeletesInserts,
                                                                              self.config.preferItemReloadsForSectionReloads);
    }
}

/// Moves the item updates of every section whose updates don't add up to its item counts into a section reload,
/// which is valid for any item count. Item updates in sections that don't exist are dropped.
- (void)_reloadSectionsWithInconsistentItemUpdates:(IGListIndexSetResult *)diffResult {
    NSArray<NSNumber *> *itemCountsBefore = self.itemCountsBeforeUpdate;
    if (itemCountsBefore == nil) {
        return;
    }
    IGListItemUpdatesCollector *collector = self.inUpdateItemCollector;
    const NSUInteger itemUpdateCount = collector.itemInserts.count + collector.itemDeletes.count
        + collector.itemReloads.count + collector.itemMoves.count;
    if (itemUpdateCount == 0) {
        return;
    }

    id<UICollectionViewDataSource> dataSource = self.collectionView.dataSource;
    NSInteger sectionCount = MIN((NSInteger)itemCountsBefore.count, [dataSource numberOfSectionsInCollectionView:self.collectionView]);
    // IGListConvertReloadToDeleteInsert looks reloaded sections up in fromObjects when it isn't empty.
    const NSUInteger fromObjectCount = self.sectionData.fromObjects.count;
    if (fromObjectCount > 0) {
        sectionCount = MIN(sectionCount, (NSInteger)fromObjectCount);
    }
    BOOL (^isSectionInRange)(NSIndexPath *) = ^BOOL(NSIndexPath *indexPath) {
        return indexPath.section >= 0 && indexPath.section < sectionCount;
    };

    NSMutableIndexSet *inconsistentSections = [NSMutableIndexSet new];
    // Count reloads and moves the way UICollectionView does: as a delete of the old index and an insert of the new one.
    // A reload whose index is also deleted is dropped by IGListApplyUpdatesToCollectionView.
    NSMutableDictionary<NSNumber *, NSMutableIndexSet *> *deletesBySection = [NSMutableDictionary new];
    NSMutableDictionary<NSNumber *, NSMutableIndexSet *> *insertsBySection = [NSMutableDictionary new];
    void (^add)(NSMutableDictionary<NSNumber *, NSMutableIndexSet *> *, NSIndexPath *) = ^(NSMutableDictionary<NSNumber *, NSMutableIndexSet *> *bySection, NSIndexPath *indexPath) {
        if (!isSectionInRange(indexPath)) {
            return;
        }
        if (indexPath.item < 0 || indexPath.item == NSNotFound) {
            [inconsistentSections addIndex:(NSUInteger)indexPath.section];
            return;
        }
        NSNumber *section = @(indexPath.section);
        NSMutableIndexSet *items = bySection[section];
        if (items == nil) {
            items = [NSMutableIndexSet new];
            bySection[section] = items;
        }
        [items addIndex:(NSUInteger)indexPath.item];
    };
    NSSet<NSIndexPath *> *uniqueDeletes = [NSSet setWithArray:collector.itemDeletes];
    for (NSIndexPath *indexPath in uniqueDeletes) {
        add(deletesBySection, indexPath);
    }
    for (NSIndexPath *indexPath in collector.itemInserts) {
        add(insertsBySection, indexPath);
    }
    for (IGListReloadIndexPath *reload in collector.itemReloads) {
        if (![uniqueDeletes containsObject:reload.fromIndexPath]) {
            add(deletesBySection, reload.fromIndexPath);
            add(insertsBySection, reload.toIndexPath);
        }
    }
    for (IGListMoveIndexPath *move in collector.itemMoves) {
        add(deletesBySection, move.from);
        add(insertsBySection, move.to);
    }

    NSMutableSet<NSNumber *> *sections = [NSMutableSet setWithArray:deletesBySection.allKeys];
    [sections addObjectsFromArray:insertsBySection.allKeys];
    for (NSNumber *sectionNumber in sections) {
        const NSInteger section = sectionNumber.integerValue;
        if ([collector.sectionReloads containsIndex:(NSUInteger)section] || [diffResult.updates containsIndex:(NSUInteger)section]) {
            continue;
        }
        const NSInteger itemCountBefore = itemCountsBefore[(NSUInteger)section].integerValue;
        const NSInteger itemCountAfter = [dataSource collectionView:self.collectionView numberOfItemsInSection:section];
        NSIndexSet *deletes = deletesBySection[sectionNumber] ?: [NSIndexSet indexSet];
        NSIndexSet *inserts = insertsBySection[sectionNumber] ?: [NSIndexSet indexSet];
        const BOOL deletesInRange = deletes.count == 0 || (NSInteger)deletes.lastIndex < itemCountBefore;
        const BOOL insertsInRange = inserts.count == 0 || (NSInteger)inserts.lastIndex < itemCountAfter;
        const BOOL countsMatch = itemCountBefore - (NSInteger)deletes.count + (NSInteger)inserts.count == itemCountAfter;
        if (!deletesInRange || !insertsInRange || !countsMatch) {
            [inconsistentSections addIndex:(NSUInteger)section];
        }
    }

    BOOL (^isDropped)(NSIndexPath *) = ^BOOL(NSIndexPath *indexPath) {
        return !isSectionInRange(indexPath) || [inconsistentSections containsIndex:(NSUInteger)indexPath.section];
    };
    // Dropping a move between sections changes the counts of both, so both have to reload, which can drop more moves.
    NSUInteger previousInconsistentSectionCount;
    do {
        previousInconsistentSectionCount = inconsistentSections.count;
        for (IGListMoveIndexPath *move in collector.itemMoves) {
            if (isDropped(move.from) || isDropped(move.to)) {
                if (isSectionInRange(move.from)) {
                    [inconsistentSections addIndex:(NSUInteger)move.from.section];
                }
                if (isSectionInRange(move.to)) {
                    [inconsistentSections addIndex:(NSUInteger)move.to.section];
                }
            }
        }
    } while (inconsistentSections.count != previousInconsistentSectionCount);

    [collector.itemInserts filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSIndexPath *indexPath, NSDictionary *bindings) {
        return !isDropped(indexPath);
    }]];
    [collector.itemDeletes filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSIndexPath *indexPath, NSDictionary *bindings) {
        return !isDropped(indexPath);
    }]];
    [collector.itemReloads filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(IGListReloadIndexPath *reload, NSDictionary *bindings) {
        return !isDropped(reload.fromIndexPath) && !isDropped(reload.toIndexPath);
    }]];
    [collector.itemMoves filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(IGListMoveIndexPath *move, NSDictionary *bindings) {
        return !isDropped(move.from) && !isDropped(move.to);
    }]];
    const NSUInteger droppedItemUpdateCount = itemUpdateCount - (collector.itemInserts.count + collector.itemDeletes.count
        + collector.itemReloads.count + collector.itemMoves.count);
    if (droppedItemUpdateCount == 0) {
        return;
    }
    IGFailure(@"IGListKit dropped %lu item updates and reloaded sections %@ because the updates don't match the item counts of %ld sections",
              (unsigned long)droppedItemUpdateCount, inconsistentSections, (long)sectionCount);
    [collector.sectionReloads addIndexes:inconsistentSections];
}

- (void)_didPerformBatchUpdate:(BOOL)finished {
    if (self.actualCollectionViewUpdates) {
        [self.delegate listAdapterUpdater:self.updater didPerformBatchUpdates:(IGListBatchUpdateData *)self.actualCollectionViewUpdates collectionView:self.collectionView];
    }
    [self _executeCompletionAsFinished:finished];
}

- (void)_executeCompletionAsFinished:(BOOL)finished {
    for (IGListUpdatingCompletion block in self.completionBlocks) {
        block(finished);
    }

    // Execute any completion blocks from item updates. Added after item blocks are executed in order to capture any
    // re-entrant updates.
    NSArray *inUpdateCompletionBlocks = [_inUpdateCompletionBlocks copy];
    for (IGListUpdatingCompletion block in inUpdateCompletionBlocks) {
        block(finished);
    }

    self.state = IGListBatchUpdateStateIdle;
}

#pragma mark - Fallbacks

- (void)_reload {
    [self.delegate listAdapterUpdater:self.updater willReloadDataWithCollectionView:self.collectionView isFallbackReload:YES];
    [self _applyDataUpdates];
    [self.collectionView reloadData];
    [self.collectionView layoutIfNeeded];
    [self.delegate listAdapterUpdater:self.updater didReloadDataWithCollectionView:self.collectionView isFallbackReload:YES];
    [self _executeCompletionAsFinished:YES];
}

- (void)_bail {
    [self.delegate listAdapterUpdater:self.updater didFinishWithoutUpdatesWithCollectionView:self.collectionView];
    [self _executeCompletionAsFinished:NO];
}

#pragma mark - Cancel

- (BOOL)cancel {
    if (_mode != IGListBatchUpdateTransactionModeCancellable) {
        return NO;
    }
    _mode = IGListBatchUpdateTransactionModeCancelled;
    return YES;
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

- (void)addCompletionBlock:(IGListUpdatingCompletion)completion {
    if (!_inUpdateCompletionBlocks) {
        _inUpdateCompletionBlocks = [NSMutableArray new];
    }
    [_inUpdateCompletionBlocks addObject:completion];
}

@end
