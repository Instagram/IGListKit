/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <IGListKit/IGListReloadDataUpdater.h>

#import "IGListAsyncTask.h"

@implementation IGListReloadDataUpdater

#pragma mark - IGListUpdatingDelegate

- (NSPointerFunctions *)objectLookupPointerFunctions {
    return [NSPointerFunctions pointerFunctionsWithOptions:NSPointerFunctionsObjectPersonality];
}

- (void)performUpdateWithCollectionView:(UICollectionView *)collectionView
                            fromObjects:(NSArray *)fromObjects
                              toObjects:(NSArray *)toObjects
                               animated:(BOOL)animated
                          preUpdateTask:(id<IGListAsyncTask>)preUpdateTask
                  objectTransitionBlock:(nonnull IGListObjectTransitionBlock)objectTransitionBlock
                             completion:(nullable IGListUpdatingCompletion)completion {
    if (preUpdateTask) {
        [preUpdateTask startWithCompletion:nil];
        [preUpdateTask waitUntilCompleted];
    }
    objectTransitionBlock(toObjects);
    [self synchronousReloadDataWithCollectionView:collectionView];
    if (completion) {
        completion(YES);
    }
}

- (void)performUpdateWithCollectionView:(UICollectionView *)collectionView
                               animated:(BOOL)animated
                            itemUpdates:(IGListItemUpdateBlock)itemUpdates
                             completion:(IGListUpdatingCompletion)completion {
    itemUpdates();
    [self synchronousReloadDataWithCollectionView:collectionView];
    if (completion) {
        completion(YES);
    }
}

- (void)insertItemsIntoCollectionView:(UICollectionView *)collectionView indexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    [self synchronousReloadDataWithCollectionView:collectionView];
}

- (void)deleteItemsFromCollectionView:(UICollectionView *)collectionView indexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    [self synchronousReloadDataWithCollectionView:collectionView];
}

- (void)moveItemInCollectionView:(UICollectionView *)collectionView fromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    [self synchronousReloadDataWithCollectionView:collectionView];
}

- (void)reloadItemsInCollectionView:(UICollectionView *)collectionView indexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    [self synchronousReloadDataWithCollectionView:collectionView];
}

- (void)reloadDataWithCollectionView:(UICollectionView *)collectionView reloadUpdateBlock:(IGListReloadUpdateBlock)reloadUpdateBlock completion:(IGListUpdatingCompletion)completion {
    reloadUpdateBlock();
    [self synchronousReloadDataWithCollectionView:collectionView];
    if (completion) {
        completion(YES);
    }
}

- (void)reloadCollectionView:(UICollectionView *)collectionView sections:(NSIndexSet *)sections {
    [self synchronousReloadDataWithCollectionView:collectionView];
}

- (void)synchronousReloadDataWithCollectionView:(UICollectionView *)collectionView {
    [collectionView reloadData];
    [collectionView layoutIfNeeded];
}

@end
