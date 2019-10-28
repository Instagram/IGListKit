/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <IGListKit/IGListReloadDataUpdater.h>

@implementation IGListReloadDataUpdater

#pragma mark - IGListUpdatingDelegate

- (NSPointerFunctions *)objectLookupPointerFunctions {
    return [NSPointerFunctions pointerFunctionsWithOptions:NSPointerFunctionsObjectPersonality];
}

- (void)performUpdateWithCollectionViewBlock:(IGListCollectionViewBlock)collectionViewBlock
                            fromObjects:(NSArray *)fromObjects
                         toObjectsBlock:(IGListToObjectBlock)toObjectsBlock
                               animated:(BOOL)animated
                  objectTransitionBlock:(IGListObjectTransitionBlock)objectTransitionBlock
                             completion:(IGListUpdatingCompletion)completion {
    if (toObjectsBlock != nil) {
        NSArray *toObjects = toObjectsBlock() ?: @[];
        objectTransitionBlock(toObjects);
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

- (void)reloadDataWithCollectionViewBlock:(IGListCollectionViewBlock)collectionViewBlock reloadUpdateBlock:(IGListReloadUpdateBlock)reloadUpdateBlock completion:(IGListUpdatingCompletion)completion {
    reloadUpdateBlock();
    [self _synchronousReloadDataWithCollectionView:collectionViewBlock()];
    if (completion) {
        completion(YES);
    }
}

- (void)reloadCollectionView:(UICollectionView *)collectionView sections:(NSIndexSet *)sections {
    [self _synchronousReloadDataWithCollectionView:collectionView];
}

- (void)_synchronousReloadDataWithCollectionView:(UICollectionView *)collectionView {
    [collectionView reloadData];
    [collectionView layoutIfNeeded];
}

@end
