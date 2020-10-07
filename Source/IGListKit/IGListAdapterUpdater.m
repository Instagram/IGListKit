/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGListAdapterUpdater.h"
#import "IGListAdapterUpdaterInternal.h"

#import "IGListAssert.h"

#import "IGListAdapterUpdaterHelpers.h"
#import "IGListArrayUtilsInternal.h"
#import "IGListIndexSetResultInternal.h"
#import "IGListMoveIndexPathInternal.h"
#import "IGListReloadIndexPath.h"
#import "UICollectionView+IGListBatchUpdateData.h"

typedef void (^IGListAdapterUpdaterDiffResultBlock)(IGListIndexSetResult *);
typedef void (^IGListAdapterUpdaterBlock)(void);
typedef void (^IGListAdapterUpdaterCompletionBlock)(BOOL);

@implementation IGListAdapterUpdater

@synthesize delegate = _delegate;
@synthesize sectionMovesAsDeletesInserts = _sectionMovesAsDeletesInserts;
@synthesize singleItemSectionUpdates = _singleItemSectionUpdates;
@synthesize preferItemReloadsForSectionReloads = _preferItemReloadsForSectionReloads;
@synthesize allowsBackgroundReloading = _allowsBackgroundReloading;
@synthesize allowsReloadingOnTooManyUpdates = _allowsReloadingOnTooManyUpdates;
@synthesize experiments = _experiments;

- (instancetype)init {
    IGAssertMainThread();

    if (self = [super init]) {
        // the default is to use animations unless NO is passed
        _queuedUpdateIsAnimated = YES;
        _completionBlocks = [NSMutableArray new];
        _batchUpdates = [IGListBatchUpdates new];
        _allowsBackgroundReloading = YES;
        _allowsReloadingOnTooManyUpdates = YES;
    }
    return self;
}

#pragma mark - Private API

- (BOOL)hasChanges {
    return self.hasQueuedReloadData
    || [self.batchUpdates hasChanges]
    || self.fromObjects != nil
    || self.toObjectsBlock != nil;
}

- (void)performReloadDataWithCollectionViewBlock:(IGListCollectionViewBlock)collectionViewBlock {
    IGAssertMainThread();

    id<IGListAdapterUpdaterDelegate> delegate = self.delegate;
    void (^reloadUpdates)(void) = self.reloadUpdates;
    IGListBatchUpdates *batchUpdates = self.batchUpdates;
    NSMutableArray *completionBlocks = [self.completionBlocks mutableCopy];

    [self cleanStateBeforeUpdates];

    void (^executeCompletionBlocks)(BOOL) = ^(BOOL finished) {
        for (IGListUpdatingCompletion block in completionBlocks) {
            block(finished);
        }

        self.state = IGListBatchUpdateStateIdle;
    };

    // bail early if the collection view has been deallocated in the time since the update was queued
    UICollectionView *collectionView = collectionViewBlock();
    if (collectionView == nil) {
        [self _cleanStateAfterUpdates];
        executeCompletionBlocks(NO);
        [_delegate listAdapterUpdater:self didFinishWithoutUpdatesWithCollectionView:collectionView];
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
    for (IGListItemUpdateBlock itemUpdateBlock in batchUpdates.itemUpdateBlocks) {
        itemUpdateBlock();
    }

    // add any completion blocks from item updates. added after item blocks are executed in order to capture any
    // re-entrant updates
    [completionBlocks addObjectsFromArray:batchUpdates.itemCompletionBlocks];

    self.state = IGListBatchUpdateStateExecutedBatchUpdateBlock;

    [self _cleanStateAfterUpdates];

    [delegate listAdapterUpdater:self willReloadDataWithCollectionView:collectionView isFallbackReload:NO];
    [collectionView reloadData];
    [collectionView.collectionViewLayout invalidateLayout];
    [collectionView layoutIfNeeded];
    [delegate listAdapterUpdater:self didReloadDataWithCollectionView:collectionView isFallbackReload:NO];

    executeCompletionBlocks(YES);
}

- (void)performBatchUpdatesWithCollectionViewBlock:(IGListCollectionViewBlock)collectionViewBlock {
    IGAssertMainThread();
    IGAssert(self.state == IGListBatchUpdateStateIdle, @"Should not call batch updates when state isn't idle");

    // create local variables so we can immediately clean our state but pass these items into the batch update block
    id<IGListAdapterUpdaterDelegate> delegate = self.delegate;
    NSArray *fromObjects = [self.fromObjects copy];
    IGListToObjectBlock toObjectsBlock = [self.toObjectsBlock copy];
    NSMutableArray *completionBlocks = [self.completionBlocks mutableCopy];
    void (^objectTransitionBlock)(NSArray *) = [self.objectTransitionBlock copy];
    const BOOL animated = self.queuedUpdateIsAnimated;
    const BOOL allowsReloadingOnTooManyUpdates = self.allowsReloadingOnTooManyUpdates;
    const IGListExperiment experiments = self.experiments;
    IGListBatchUpdates *batchUpdates = self.batchUpdates;

    // clean up all state so that new updates can be coalesced while the current update is in flight
    [self cleanStateBeforeUpdates];

    void (^executeCompletionBlocks)(BOOL) = ^(BOOL finished) {
        self.applyingUpdateData = nil;
        self.state = IGListBatchUpdateStateIdle;

        for (IGListUpdatingCompletion block in completionBlocks) {
            block(finished);
        }
    };

    // bail early if the collection view has been deallocated in the time since the update was queued
    UICollectionView *collectionView = collectionViewBlock();
    if (collectionView == nil) {
        [self _cleanStateAfterUpdates];
        executeCompletionBlocks(NO);
        [_delegate listAdapterUpdater:self didFinishWithoutUpdatesWithCollectionView:collectionView];
        return;
    }

    NSArray *toObjects = nil;
    if (toObjectsBlock != nil) {
        toObjects = objectsWithDuplicateIdentifiersRemoved(toObjectsBlock());
    }
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
        if (objectTransitionBlock != nil) {
            objectTransitionBlock(toObjects);
        }

        // execute each item update block which should make calls like insert, delete, and reload for index paths
        // we collect all mutations in corresponding sets on self, then filter based on UICollectionView shortcomings
        // call after the objectTransitionBlock so section level mutations happen before any items
        for (IGListItemUpdateBlock itemUpdateBlock in batchUpdates.itemUpdateBlocks) {
            itemUpdateBlock();
        }

        // add any completion blocks from item updates. added after item blocks are executed in order to capture any
        // re-entrant updates
        [completionBlocks addObjectsFromArray:batchUpdates.itemCompletionBlocks];

        self.state = IGListBatchUpdateStateExecutedBatchUpdateBlock;
    };

    void (^reloadDataFallback)(void) = ^{
        [delegate listAdapterUpdater:self willReloadDataWithCollectionView:collectionView isFallbackReload:YES];
        executeUpdateBlocks();
        [self _cleanStateAfterUpdates];
        [self _performBatchUpdatesItemBlockApplied];
        [collectionView reloadData];
        [collectionView layoutIfNeeded];
        executeCompletionBlocks(YES);
        [delegate listAdapterUpdater:self didReloadDataWithCollectionView:collectionView isFallbackReload:YES];

        // queue another update in case something changed during batch updates. this method will bail next runloop if
        // there are no changes
        [self _queueUpdateWithCollectionViewBlock:collectionViewBlock];
    };

    // disables multiple performBatchUpdates: from happening at the same time
    [self _beginPerformBatchUpdatesToObjects:toObjects];

    // if the collection view isn't in a visible window, skip diffing and batch updating. execute all transition blocks,
    // reload data, execute completion blocks, and get outta here
    if (self.allowsBackgroundReloading && collectionView.window == nil) {
        reloadDataFallback();
        return;
    }

    // block executed in the first param block of -[UICollectionView performBatchUpdates:completion:]
    void (^batchUpdatesBlock)(IGListIndexSetResult *result) = ^(IGListIndexSetResult *result){
        executeUpdateBlocks();
        if (self.singleItemSectionUpdates) {
            [collectionView deleteSections:result.deletes];
            [collectionView insertSections:result.inserts];
            for (IGListMoveIndex *move in result.moves) {
                [collectionView moveSection:move.from toSection:move.to];
            }
            // NOTE: for section updates, it's updated in the IGListSectionController's -didUpdateToObject:, since there is *only* 1 cell for the section, we can just update that cell.

            self.applyingUpdateData = [[IGListBatchUpdateData alloc]
                                       initWithInsertSections:result.inserts
                                       deleteSections:result.deletes
                                       moveSections:[NSSet setWithArray:result.moves]
                                       insertIndexPaths:@[]
                                       deleteIndexPaths:@[]
                                       updateIndexPaths:@[]
                                       moveIndexPaths:@[]];
        } else {
            self.applyingUpdateData = IGListApplyUpdatesToCollectionView(collectionView,
                                                                         result,                                                                         
                                                                         self.batchUpdates.sectionReloads,
                                                                         self.batchUpdates.itemInserts,
                                                                         self.batchUpdates.itemDeletes,
                                                                         self.batchUpdates.itemReloads,
                                                                         self.batchUpdates.itemMoves,
                                                                         fromObjects,
                                                                         self.sectionMovesAsDeletesInserts,
                                                                         self.preferItemReloadsForSectionReloads);
        }

        [self _cleanStateAfterUpdates];
        [self _performBatchUpdatesItemBlockApplied];
    };

    // block used as the second param of -[UICollectionView performBatchUpdates:completion:]
    void (^fallbackWithoutUpdates)(void) = ^(void) {
        executeCompletionBlocks(NO);

        [delegate listAdapterUpdater:self didFinishWithoutUpdatesWithCollectionView:collectionView];

        // queue another update in case something changed during batch updates. this method will bail next runloop if
        // there are no changes
        [self _queueUpdateWithCollectionViewBlock:collectionViewBlock];
    };

    // block used as the second param of -[UICollectionView performBatchUpdates:completion:]
    void (^batchUpdatesCompletionBlock)(BOOL) = ^(BOOL finished) {
        IGListBatchUpdateData *oldApplyingUpdateData = self.applyingUpdateData;
        executeCompletionBlocks(finished);

        [delegate listAdapterUpdater:self didPerformBatchUpdates:oldApplyingUpdateData collectionView:collectionView];

        // queue another update in case something changed during batch updates. this method will bail next runloop if
        // there are no changes
        [self _queueUpdateWithCollectionViewBlock:collectionViewBlock];
    };

    void (^performUpdate)(IGListIndexSetResult *) = ^(IGListIndexSetResult *result){
        [delegate listAdapterUpdater:self
willPerformBatchUpdatesWithCollectionView:collectionView
                         fromObjects:fromObjects
                           toObjects:toObjects
                  listIndexSetResult:result
                            animated:animated];

        // Wrap `[UICollectionView performBatchUpdates ...]` so that in case it crashes, the first app symbol will not be a block. A block name includes the
        // line number, which means if you change the block line number, it will be categorized as a different crash. This makes tracking crashes
        // across multiple app-versions a pain.
        IGListAdapterUpdaterPerformBatchUpdate(collectionView, animated, ^{
            batchUpdatesBlock(result);
        }, batchUpdatesCompletionBlock);
    };

    // block that executes the batch update and exception handling
    void (^tryToPerformUpdate)(IGListIndexSetResult *) = ^(IGListIndexSetResult *result){
        @try {
            if (collectionView.dataSource == nil) {
                // If the data source is nil, we should not call any collection view update.
                fallbackWithoutUpdates();
            } else if (result.changeCount > 100 && allowsReloadingOnTooManyUpdates) {
                reloadDataFallback();
            } else {
                performUpdate(result);
            }
        } @catch (NSException *exception) {
            [delegate listAdapterUpdater:self
                          collectionView:collectionView
                  willCrashWithException:exception
                             fromObjects:fromObjects
                               toObjects:toObjects
                              diffResult:result
                                 updates:(id)self.applyingUpdateData];
            @throw exception;
        }
    };

    const BOOL onBackgroundThread = IGListExperimentEnabled(experiments, IGListExperimentBackgroundDiffing);
    [delegate listAdapterUpdater:self willDiffFromObjects:fromObjects toObjects:toObjects];
    IGListAdapterUpdaterPerformDiffing(fromObjects, toObjects, IGListDiffEquality, onBackgroundThread, ^(IGListIndexSetResult *result){
        [delegate listAdapterUpdater:self didDiffWithResults:result onBackgroundThread:onBackgroundThread];
        tryToPerformUpdate(result);
    });
}

- (void)_beginPerformBatchUpdatesToObjects:(NSArray *)toObjects {
    self.pendingTransitionToObjects = toObjects;
    self.state = IGListBatchUpdateStateQueuedBatchUpdate;
}

- (void)_performBatchUpdatesItemBlockApplied {
    self.pendingTransitionToObjects = nil;
}

- (void)cleanStateBeforeUpdates {
    self.queuedUpdateIsAnimated = YES;

    // destroy to/from transition items
    self.fromObjects = nil;
    self.toObjectsBlock = nil;

    // destroy reloadData state
    self.reloadUpdates = nil;
    self.queuedReloadData = NO;

    // remove indexpath/item changes
    self.objectTransitionBlock = nil;

    // removes all object completion blocks. done before updates to start collecting completion blocks for coalesced
    // or re-entrant object updates
    [self.completionBlocks removeAllObjects];
}

- (void)_cleanStateAfterUpdates {
    self.batchUpdates = [IGListBatchUpdates new];
}

- (void)_queueUpdateWithCollectionViewBlock:(IGListCollectionViewBlock)collectionViewBlock {
    IGAssertMainThread();

    __weak __typeof__(self) weakSelf = self;

    // dispatch_async to give the main queue time to collect more batch updates so that a minimum amount of work
    // (diffing, etc) is done on main. dispatch_async does not garauntee a full runloop turn will pass though.
    // see -performUpdateWithCollectionView:fromObjects:toObjects:animated:objectTransitionBlock:completion: for more
    // details on how coalescence is done.
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf.state != IGListBatchUpdateStateIdle
            || ![weakSelf hasChanges]) {
            return;
        }

        if (weakSelf.hasQueuedReloadData) {
            [weakSelf performReloadDataWithCollectionViewBlock:collectionViewBlock];
        } else {
            [weakSelf performBatchUpdatesWithCollectionViewBlock:collectionViewBlock];
        }
    });
}

#pragma mark - IGListUpdatingDelegate

static BOOL IGListIsEqual(const void *a, const void *b, NSUInteger (*size)(const void *item)) {
    const id<IGListDiffable, NSObject> left = (__bridge id<IGListDiffable, NSObject>)a;
    const id<IGListDiffable, NSObject> right = (__bridge id<IGListDiffable, NSObject>)b;
    return [left class] == [right class]
    && [[left diffIdentifier] isEqual:[right diffIdentifier]];
}

// since the diffing algo used in this updater keys items based on their -diffIdentifier, we must use a map table that
// precisely mimics this behavior
static NSUInteger IGListIdentifierHash(const void *item, NSUInteger (*size)(const void *item)) {
    return [[(__bridge id<IGListDiffable>)item diffIdentifier] hash];
}

- (NSPointerFunctions *)objectLookupPointerFunctions {
    NSPointerFunctions *functions = [NSPointerFunctions pointerFunctionsWithOptions:NSPointerFunctionsStrongMemory];
    functions.hashFunction = IGListIdentifierHash;
    functions.isEqualFunction = IGListIsEqual;
    return functions;
}

- (void)performUpdateWithCollectionViewBlock:(IGListCollectionViewBlock)collectionViewBlock
                            fromObjects:(NSArray *)fromObjects
                         toObjectsBlock:(IGListToObjectBlock)toObjectsBlock
                               animated:(BOOL)animated
                  objectTransitionBlock:(IGListObjectTransitionBlock)objectTransitionBlock
                             completion:(IGListUpdatingCompletion)completion {
    IGAssertMainThread();
    IGParameterAssert(collectionViewBlock != nil);
    IGParameterAssert(objectTransitionBlock != nil);

    // only update the items that we are coming from if it has not been set
    // this allows multiple updates to be called while an update is already in progress, and the transition from > to
    // will be done on the first "fromObjects" received and the last "toObjects"
    // if performBatchUpdates: hasn't applied the update block, then data source hasn't transitioned its state. if an
    // update is queued in between then we must use the pending toObjects
    self.fromObjects = self.fromObjects ?: self.pendingTransitionToObjects ?: fromObjects;
    self.toObjectsBlock = toObjectsBlock;

    // disabled animations will always take priority
    // reset to YES in -cleanupState
    self.queuedUpdateIsAnimated = self.queuedUpdateIsAnimated && animated;

    // always use the last update block, even though this should always do the exact same thing
    self.objectTransitionBlock = objectTransitionBlock;

    IGListUpdatingCompletion localCompletion = completion;
    if (localCompletion) {
        [self.completionBlocks addObject:localCompletion];
    }

    [self _queueUpdateWithCollectionViewBlock:collectionViewBlock];
}

- (void)performUpdateWithCollectionViewBlock:(IGListCollectionViewBlock)collectionViewBlock
                               animated:(BOOL)animated
                            itemUpdates:(void (^)(void))itemUpdates
                             completion:(void (^)(BOOL))completion {
    IGAssertMainThread();
    IGParameterAssert(collectionViewBlock != nil);
    IGParameterAssert(itemUpdates != nil);

    IGListBatchUpdates *batchUpdates = self.batchUpdates;
    if (completion != nil) {
        [batchUpdates.itemCompletionBlocks addObject:completion];
    }

    // if already inside the execution of the update block, immediately unload the itemUpdates block.
    // the completion blocks are executed later in the lifecycle, so that still needs to be added to the batch
    if (self.state == IGListBatchUpdateStateExecutingBatchUpdateBlock) {
        itemUpdates();
    } else {
        [batchUpdates.itemUpdateBlocks addObject:itemUpdates];

        // disabled animations will always take priority
        // reset to YES in -cleanupState
        self.queuedUpdateIsAnimated = self.queuedUpdateIsAnimated && animated;

        [self _queueUpdateWithCollectionViewBlock:collectionViewBlock];
    }
}

- (void)insertItemsIntoCollectionView:(UICollectionView *)collectionView indexPaths:(NSArray <NSIndexPath *> *)indexPaths {
    IGAssertMainThread();
    IGParameterAssert(collectionView != nil);
    IGParameterAssert(indexPaths != nil);
    if (self.state == IGListBatchUpdateStateExecutingBatchUpdateBlock) {
        [self.batchUpdates.itemInserts addObjectsFromArray:indexPaths];
    } else {
        [self.delegate listAdapterUpdater:self willInsertIndexPaths:indexPaths collectionView:collectionView];
        [collectionView insertItemsAtIndexPaths:indexPaths];
    }
}

- (void)deleteItemsFromCollectionView:(UICollectionView *)collectionView indexPaths:(NSArray <NSIndexPath *> *)indexPaths {
    IGAssertMainThread();
    IGParameterAssert(collectionView != nil);
    IGParameterAssert(indexPaths != nil);
    if (self.state == IGListBatchUpdateStateExecutingBatchUpdateBlock) {
        [self.batchUpdates.itemDeletes addObjectsFromArray:indexPaths];
    } else {
        [self.delegate listAdapterUpdater:self willDeleteIndexPaths:indexPaths collectionView:collectionView];
        [collectionView deleteItemsAtIndexPaths:indexPaths];
    }
}

- (void)moveItemInCollectionView:(UICollectionView *)collectionView
                   fromIndexPath:(NSIndexPath *)fromIndexPath
                     toIndexPath:(NSIndexPath *)toIndexPath {
    if (self.state == IGListBatchUpdateStateExecutingBatchUpdateBlock) {
        IGListMoveIndexPath *move = [[IGListMoveIndexPath alloc] initWithFrom:fromIndexPath to:toIndexPath];
        [self.batchUpdates.itemMoves addObject:move];
    } else {
        [self.delegate listAdapterUpdater:self willMoveFromIndexPath:fromIndexPath toIndexPath:toIndexPath collectionView:collectionView];
        [collectionView moveItemAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
    }
}

- (void)reloadItemInCollectionView:(UICollectionView *)collectionView
                     fromIndexPath:(NSIndexPath *)fromIndexPath
                       toIndexPath:(NSIndexPath *)toIndexPath {
    if (self.state == IGListBatchUpdateStateExecutingBatchUpdateBlock) {
        IGListReloadIndexPath *reload = [[IGListReloadIndexPath alloc] initWithFromIndexPath:fromIndexPath toIndexPath:toIndexPath];
        [self.batchUpdates.itemReloads addObject:reload];
    } else {
        [self.delegate listAdapterUpdater:self willReloadIndexPaths:@[fromIndexPath] collectionView:collectionView];
        [collectionView reloadItemsAtIndexPaths:@[fromIndexPath]];
    }
}

- (void)moveSectionInCollectionView:(UICollectionView *)collectionView
                          fromIndex:(NSInteger)fromIndex
                            toIndex:(NSInteger)toIndex {
    IGAssertMainThread();
    IGParameterAssert(collectionView != nil);

    // iOS expects interactive reordering to be movement of items not sections
    // after moving a single-item section controller,
    // you end up with two items in the section for the drop location,
    // and zero items in the section originating at the drag location
    // so, we have to reload data rather than doing a section move

    [collectionView reloadData];

    // It seems that reloadData called during UICollectionView's moveItemAtIndexPath
    // delegate call does not reload all cells as intended
    // So, we further reload all visible sections to make sure none of our cells
    // are left with data that's out of sync with our dataSource

    id<IGListAdapterUpdaterDelegate> delegate = self.delegate;

    NSMutableIndexSet *visibleSections = [NSMutableIndexSet new];
    NSArray *visibleIndexPaths = [collectionView indexPathsForVisibleItems];
    for (NSIndexPath *visibleIndexPath in visibleIndexPaths) {
        [visibleSections addIndex:visibleIndexPath.section];
    }

    [delegate listAdapterUpdater:self willReloadSections:visibleSections collectionView:collectionView];

    // prevent double-animation from reloadData + reloadSections

    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [collectionView performBatchUpdates:^{
        [collectionView reloadSections:visibleSections];
    } completion:^(BOOL finished) {
        [CATransaction commit];
    }];
}

- (void)reloadDataWithCollectionViewBlock:(IGListCollectionViewBlock)collectionViewBlock
                   reloadUpdateBlock:(IGListReloadUpdateBlock)reloadUpdateBlock
                          completion:(nullable IGListUpdatingCompletion)completion {
    IGAssertMainThread();
    IGParameterAssert(collectionViewBlock != nil);
    IGParameterAssert(reloadUpdateBlock != nil);

    IGListUpdatingCompletion localCompletion = completion;
    if (localCompletion) {
        [self.completionBlocks addObject:localCompletion];
    }

    self.reloadUpdates = reloadUpdateBlock;
    self.queuedReloadData = YES;
    [self _queueUpdateWithCollectionViewBlock:collectionViewBlock];
}

- (void)reloadCollectionView:(UICollectionView *)collectionView sections:(NSIndexSet *)sections {
    IGAssertMainThread();
    IGParameterAssert(collectionView != nil);
    IGParameterAssert(sections != nil);
    if (self.state == IGListBatchUpdateStateExecutingBatchUpdateBlock) {
        [self.batchUpdates.sectionReloads addIndexes:sections];
    } else {
        [self.delegate listAdapterUpdater:self willReloadSections:sections collectionView:collectionView];
        [collectionView reloadSections:sections];
    }
}

#pragma mark - Helpers

static void IGListAdapterUpdaterPerformBatchUpdate(UICollectionView *collectionView, BOOL animated, IGListAdapterUpdaterBlock updates, IGListAdapterUpdaterCompletionBlock completion) {
    if (animated) {
        [collectionView performBatchUpdates:updates completion:completion];
    } else {
        [UIView performWithoutAnimation:^{
            [collectionView performBatchUpdates:updates completion:completion];
        }];
    }
}

static void IGListAdapterUpdaterPerformDiffing(NSArray<id<IGListDiffable>> *_Nullable oldArray,
                                               NSArray<id<IGListDiffable>> *_Nullable newArray,
                                               IGListDiffOption option,
                                               BOOL onBackgroundThread,
                                               IGListAdapterUpdaterDiffResultBlock completion) {
    if (onBackgroundThread) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
            IGListIndexSetResult *result = IGListDiff(oldArray, newArray, option);
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(result);
            });
        });
    } else {
        IGListIndexSetResult *result = IGListDiff(oldArray, newArray, option);
        completion(result);
    }
}

@end
