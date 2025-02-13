/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGListAdapterUpdater.h"

#if !__has_include(<IGListDiffKit/IGListDiffKit.h>)
#import "IGListAssert.h"
#else
#import <IGListDiffKit/IGListAssert.h>
#endif

#import "IGListAdapterUpdaterHelpers.h"
#import "IGListDefaultExperiments.h"
#import "IGListIndexSetResultInternal.h"
#import "IGListMoveIndexPathInternal.h"
#import "IGListReloadIndexPath.h"
#import "IGListTransitionData.h"
#import "IGListUpdateTransactable.h"
#import "IGListUpdateTransactionBuilder.h"
#import "UICollectionView+IGListBatchUpdateData.h"
#import "IGListUpdateCoalescer.h"

@interface IGListAdapterUpdater () <IGListUpdateCoalescerDelegate>
@property (nonatomic, strong) IGListUpdateTransactionBuilder *transactionBuilder;
@property (nonatomic, strong) IGListUpdateCoalescer *coalescer;
@property (nonatomic, strong, nullable) IGListUpdateTransactionBuilder *lastTransactionBuilder;
@property (nonatomic, strong, nullable) id<IGListUpdateTransactable> transaction;
@end

@implementation IGListAdapterUpdater

- (instancetype)init {
    IGAssertMainThread();

    if (self = [super init]) {
        _transactionBuilder = [IGListUpdateTransactionBuilder new];
        _coalescer = [IGListUpdateCoalescer new];
        _coalescer.delegate = self;
        _allowsReloadingOnTooManyUpdates = YES;
        _experiments = IGListDefaultExperiments();
    }
    return self;
}

#pragma mark - Update

- (BOOL)hasChanges {
    return [self.transactionBuilder hasChanges];
}

- (void)_queueUpdateIfNeeded {
    IGAssertMainThread();

    if (!self.transactionBuilder.hasChanges) {
        return;
    }

    // Will call `-performUpdateWithCoalescer`
    [self.coalescer queueUpdateForView:self.transactionBuilder.collectionView];
}

- (void)performUpdateWithCoalescer:(IGListUpdateCoalescer *)coalescer {
    [self update];
}

- (void)update {
    IGAssertMainThread();

    if (![self.transactionBuilder hasChanges]) {
        return;
    }

    if (self.transaction && self.transaction.state != IGListBatchUpdateStateIdle) {
        return;
    }

    IGListUpdateTransactationConfig config = (IGListUpdateTransactationConfig) {
        .sectionMovesAsDeletesInserts = _sectionMovesAsDeletesInserts,
        .singleItemSectionUpdates = _singleItemSectionUpdates,
        .preferItemReloadsForSectionReloads = _preferItemReloadsForSectionReloads,
        .allowsReloadingOnTooManyUpdates = _allowsReloadingOnTooManyUpdates,
        .allowsBackgroundDiffing = _allowsBackgroundDiffing,
        .experiments = _experiments,
        .adaptiveDiffingExperimentConfig = _adaptiveDiffingExperimentConfig,
    };

    id<IGListUpdateTransactable> transaction = [self.transactionBuilder buildWithConfig:config delegate:_delegate updater:self];
    self.transaction = transaction;
    self.lastTransactionBuilder = self.transactionBuilder;
    self.transactionBuilder = [IGListUpdateTransactionBuilder new];

    if (!transaction) {
        // If we don't have enough information, we might not be able to create a transaction.
        self.lastTransactionBuilder = nil;
        return;
    }

    __weak __typeof__(self) weakSelf = self;
    __weak __typeof__(transaction) weakTransaction = transaction;
    [transaction addCompletionBlock:^(BOOL finished) {
        __typeof__(self) strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }
        if (strongSelf.transaction == weakTransaction) {
            strongSelf.transaction = nil;
            strongSelf.lastTransactionBuilder = nil;

            // queue another update in case something changed during batch updates. this method will bail next runloop if
            // there are no changes
            [strongSelf _queueUpdateIfNeeded];
        }
    }];
    [transaction begin];
}

- (BOOL)isInDataUpdateBlock {
    return self.transaction.state == IGListBatchUpdateStateExecutingBatchUpdateBlock;
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
                                    animated:(BOOL)animated
                            sectionDataBlock:(IGListTransitionDataBlock)sectionDataBlock
                       applySectionDataBlock:(IGListTransitionDataApplyBlock)applySectionDataBlock
                                  completion:(nullable IGListUpdatingCompletion)completion {
    IGAssertMainThread();
    IGParameterAssert(collectionViewBlock != nil);
    IGParameterAssert(sectionDataBlock != nil);
    IGParameterAssert(applySectionDataBlock != nil);

    [self.transactionBuilder addSectionBatchUpdateAnimated:animated
                                       collectionViewBlock:collectionViewBlock
                                          sectionDataBlock:sectionDataBlock
                                     applySectionDataBlock:applySectionDataBlock
                                                completion:completion];

    [self _queueUpdateIfNeeded];
}


- (void)performUpdateWithCollectionViewBlock:(IGListCollectionViewBlock)collectionViewBlock
                                    animated:(BOOL)animated
                                 itemUpdates:(void (^)(void))itemUpdates
                                  completion:(void (^)(BOOL))completion {
    IGAssertMainThread();
    IGParameterAssert(collectionViewBlock != nil);
    IGParameterAssert(itemUpdates != nil);

    // if already inside the execution of the update block, immediately unload the itemUpdates block.
    // the completion blocks are executed later in the lifecycle, so that still needs to be added to the batch
    if ([self isInDataUpdateBlock]) {
        if (completion != nil) {
            [self.transaction addCompletionBlock:completion];
        }
        itemUpdates();
    } else {
        [self.transactionBuilder addItemBatchUpdateAnimated:animated
                                       collectionViewBlock:collectionViewBlock
                                               itemUpdates:itemUpdates
                                                completion:completion];

        [self _queueUpdateIfNeeded];
    }
}

- (void)reloadDataWithCollectionViewBlock:(IGListCollectionViewBlock)collectionViewBlock
                        reloadUpdateBlock:(IGListReloadUpdateBlock)reloadUpdateBlock
                               completion:(nullable IGListUpdatingCompletion)completion {
    IGAssertMainThread();
    IGParameterAssert(collectionViewBlock != nil);
    IGParameterAssert(reloadUpdateBlock != nil);

    [self.transactionBuilder addReloadDataWithCollectionViewBlock:collectionViewBlock
                                                     reloadBlock:reloadUpdateBlock
                                                      completion:completion];

    [self _queueUpdateIfNeeded];
}

- (void)performDataSourceChange:(IGListDataSourceChangeBlock)block {
    // Unlike the other "performs", we need the dataSource change to be synchronous.
    // Which means we need to cancel the current transaction, flatten the changes from
    // both the current transtion and builder, and execute that new transaction.

    if (!self.transaction
        && ![self.transactionBuilder hasChanges]
        && !IGListExperimentEnabled(self.experiments, IGListExperimentRemoveDataSourceChangeEarlyExit)) {
        // If nothing is going on, lets take a shortcut.
        block();
        return;
    }

    IGListUpdateTransactionBuilder *builder = [IGListUpdateTransactionBuilder new];
    [builder addDataSourceChange:block];

    // Lets try to cancel any current transactions.
    if ([self.transaction cancel] && self.lastTransactionBuilder) {
        // We still need to apply the item-updates and completion-blocks, so lets merge the builders.
        [builder addChangesFromBuilder:(IGListUpdateTransactionBuilder *)self.lastTransactionBuilder];
    }

    // Lets merge pending changes
    [builder addChangesFromBuilder:self.transactionBuilder];

    // Clear the current state
    self.transaction = nil;
    self.lastTransactionBuilder = nil;
    self.transactionBuilder = builder;

    // Update synchronously
    [self update];
}

- (void)insertItemsIntoCollectionView:(UICollectionView *)collectionView indexPaths:(NSArray <NSIndexPath *> *)indexPaths {
    IGAssertMainThread();
    IGParameterAssert(collectionView != nil);
    IGParameterAssert(indexPaths != nil);
    if ([self isInDataUpdateBlock]) {
        [self.transaction insertItemsAtIndexPaths:indexPaths];
    } else {
        [self.delegate listAdapterUpdater:self willInsertIndexPaths:indexPaths collectionView:collectionView];
        [collectionView insertItemsAtIndexPaths:indexPaths];
    }
}

- (void)deleteItemsFromCollectionView:(UICollectionView *)collectionView indexPaths:(NSArray <NSIndexPath *> *)indexPaths {
    IGAssertMainThread();
    IGParameterAssert(collectionView != nil);
    IGParameterAssert(indexPaths != nil);
    if ([self isInDataUpdateBlock]) {
        [self.transaction deleteItemsAtIndexPaths:indexPaths];
    } else {
        [self.delegate listAdapterUpdater:self willDeleteIndexPaths:indexPaths collectionView:collectionView];
        [collectionView deleteItemsAtIndexPaths:indexPaths];
    }
}

- (void)moveItemInCollectionView:(UICollectionView *)collectionView
                   fromIndexPath:(NSIndexPath *)fromIndexPath
                     toIndexPath:(NSIndexPath *)toIndexPath {
    if ([self isInDataUpdateBlock]) {
        [self.transaction moveItemFromIndexPath:fromIndexPath toIndexPath:toIndexPath];
    } else {
        [self.delegate listAdapterUpdater:self willMoveFromIndexPath:fromIndexPath toIndexPath:toIndexPath collectionView:collectionView];
        [collectionView moveItemAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
    }
}

- (void)reloadItemInCollectionView:(UICollectionView *)collectionView
                     fromIndexPath:(NSIndexPath *)fromIndexPath
                       toIndexPath:(NSIndexPath *)toIndexPath {
    if ([self isInDataUpdateBlock]) {
        [self.transaction reloadItemFromIndexPath:fromIndexPath toIndexPath:toIndexPath];
    } else {
        [self.delegate listAdapterUpdater:self willReloadIndexPaths:@[fromIndexPath] collectionView:collectionView];
        [collectionView reloadItemsAtIndexPaths:@[fromIndexPath]];
    }
}

- (void)reloadCollectionView:(UICollectionView *)collectionView sections:(NSIndexSet *)sections {
    IGAssertMainThread();
    IGParameterAssert(collectionView != nil);
    IGParameterAssert(sections != nil);
    if ([self isInDataUpdateBlock]) {
        [self.transaction reloadSections:sections];
    } else {
        [self.delegate listAdapterUpdater:self willReloadSections:sections collectionView:collectionView];
        [collectionView reloadSections:sections];
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

    NSArray *visibleIndexPaths = [collectionView indexPathsForVisibleItems];
    NSIndexSet *visibleSections = IGListSectionIndexFromIndexPaths(visibleIndexPaths);

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

- (void)willCrashWithCollectionView:(UICollectionView *)collectionView
    sectionControllerClass:(Class)sectionControllerClass {
    [self.delegate listAdapterUpdater:self
    willCrashWithCollectionView:collectionView
    sectionControllerClass:sectionControllerClass];
}

#pragma mark - Properties

- (IGListAdaptiveCoalescingExperimentConfig)adaptiveCoalescingExperimentConfig {
    return _coalescer.adaptiveCoalescingExperimentConfig;
}

- (void)setAdaptiveCoalescingExperimentConfig:(IGListAdaptiveCoalescingExperimentConfig)adaptiveCoalescingExperimentConfig {
    _coalescer.adaptiveCoalescingExperimentConfig = adaptiveCoalescingExperimentConfig;
}

@end
