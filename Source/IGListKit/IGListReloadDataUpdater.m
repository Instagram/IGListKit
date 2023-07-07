/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGListReloadDataUpdater.h"

@implementation IGListReloadDataUpdater {
    BOOL _isInDataUpdateBlock;
}

#pragma mark - IGListUpdatingDelegate

- (NSPointerFunctions *)objectLookupPointerFunctions {
    return [NSPointerFunctions pointerFunctionsWithOptions:NSPointerFunctionsObjectPersonality];
}

- (void)performUpdateWithCollectionViewBlock:(IGListCollectionViewBlock)collectionViewBlock
                                    animated:(BOOL)animated
                            sectionDataBlock:(IGListTransitionDataBlock)sectionDataBlock
                       applySectionDataBlock:(IGListTransitionDataApplyBlock)applySectionDataBlock
                                  completion:(nullable IGListUpdatingCompletion)completion {
    IGListTransitionData *sectionData = sectionDataBlock ? sectionDataBlock() : nil;
    if (sectionData != nil && applySectionDataBlock != nil) {
        _isInDataUpdateBlock = YES;
        applySectionDataBlock(sectionData);
        _isInDataUpdateBlock = NO;
    }
    [self _synchronousReloadDataWithCollectionView:collectionViewBlock()];
    if (completion) {
        completion(YES);
    }
}

- (void)performUpdateWithCollectionViewBlock:(IGListCollectionViewBlock)collectionViewBlock
                               animated:(BOOL)animated
                            itemUpdates:(IGListItemUpdateBlock)itemUpdates
                             completion:(IGListUpdatingCompletion)completion {
    itemUpdates();
    [self _synchronousReloadDataWithCollectionView:collectionViewBlock()];
    if (completion) {
        completion(YES);
    }
}

- (void)performDataSourceChange:(IGListDataSourceChangeBlock)block {
    // A `UICollectionView` dataSource change will automatically invalidate
    // its data, so no need to do anything else.
    block();
}

- (void)reloadDataWithCollectionViewBlock:(IGListCollectionViewBlock)collectionViewBlock reloadUpdateBlock:(IGListReloadUpdateBlock)reloadUpdateBlock completion:(IGListUpdatingCompletion)completion {
    reloadUpdateBlock();
    [self _synchronousReloadDataWithCollectionView:collectionViewBlock()];
    if (completion) {
        completion(YES);
    }
}

- (void)insertItemsIntoCollectionView:(UICollectionView *)collectionView indexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    [self _synchronousReloadDataWithCollectionView:collectionView];
}

- (void)deleteItemsFromCollectionView:(UICollectionView *)collectionView indexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    [self _synchronousReloadDataWithCollectionView:collectionView];
}

- (void)moveItemInCollectionView:(UICollectionView *)collectionView fromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    [self _synchronousReloadDataWithCollectionView:collectionView];
}

- (void)reloadItemInCollectionView:(UICollectionView *)collectionView fromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    [self _synchronousReloadDataWithCollectionView:collectionView];
}

- (void)moveSectionInCollectionView:(UICollectionView *)collectionView fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    [self _synchronousReloadDataWithCollectionView:collectionView];
}

- (void)reloadCollectionView:(UICollectionView *)collectionView sections:(NSIndexSet *)sections {
    [self _synchronousReloadDataWithCollectionView:collectionView];
}

- (void)_synchronousReloadDataWithCollectionView:(UICollectionView *)collectionView {
    [collectionView reloadData];
    [collectionView layoutIfNeeded];
}

- (BOOL)isInDataUpdateBlock {
    return _isInDataUpdateBlock;
}

@end
