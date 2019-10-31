/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGListCollectionView.h"

#import "IGListCollectionViewLayout.h"
#import "IGListCollectionViewLayoutCompatible.h"

@implementation IGListCollectionView

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame {
    IGListCollectionViewLayout *layout = [[IGListCollectionViewLayout alloc] initWithStickyHeaders:NO topContentInset:0 stretchToEdge:YES];
    return [self initWithFrame:frame listCollectionViewLayout:layout];
}

- (instancetype)initWithFrame:(CGRect)frame listCollectionViewLayout:(UICollectionViewLayout<IGListCollectionViewLayoutCompatible> *)collectionViewLayout {
    return [super initWithFrame:frame collectionViewLayout:collectionViewLayout];
}

#pragma mark - IGListCollectionViewLayout

- (UICollectionViewLayout<IGListCollectionViewLayoutCompatible> *)_listLayout {
    if ([self.collectionViewLayout conformsToProtocol:@protocol(IGListCollectionViewLayoutCompatible)]) {
        return (UICollectionViewLayout<IGListCollectionViewLayoutCompatible> *)self.collectionViewLayout;
    }

    return nil;
}

#pragma mark - Overides reloads

- (void)reloadItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    [self _didModifyIndexPaths:indexPaths];
    [super reloadItemsAtIndexPaths:indexPaths];
}

- (void)reloadSections:(NSIndexSet *)sections {
    [self _didModifySections:sections];
    [super reloadSections:sections];
}

#pragma mark - Override deletes

- (void)deleteItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    [self _didModifyIndexPaths:indexPaths];
    [super deleteItemsAtIndexPaths:indexPaths];
}

- (void)deleteSections:(NSIndexSet *)sections {
    [self _didModifySections:sections];
    [super deleteSections:sections];
}

#pragma mark - Override inserts

- (void)insertItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    [self _didModifyIndexPaths:indexPaths];
    [super insertItemsAtIndexPaths:indexPaths];
}

- (void)insertSections:(NSIndexSet *)sections {
    [self _didModifySections:sections];
    [super insertSections:sections];
}

#pragma mark - Override moves

- (void)moveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath {
    [self _didModifyIndexPaths:@[indexPath, newIndexPath]];
    [super moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
}

- (void)moveSection:(NSInteger)section toSection:(NSInteger)newSection {
    [self _didModifySection:MIN(section, newSection)];
    [super moveSection:section toSection:newSection];
}

#pragma mark - Modify section

- (void)_didModifySections:(NSIndexSet *)sections {
    if (sections.count == 0) {
        return;
    }
    [self _didModifySection:sections.firstIndex];
}

- (void)_didModifySection:(NSUInteger)section {
    [self._listLayout didModifySection:section];
}

#pragma mark - Modified index path

- (void)_didModifyIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    for (NSIndexPath *indexPath in indexPaths) {
        [self _didModifySection:indexPath.section];
    }
}

@end
