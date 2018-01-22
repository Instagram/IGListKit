/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "IGListCollectionView.h"

#import "IGListCollectionViewLayout.h"

@implementation IGListCollectionView

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame {
    IGListCollectionViewLayout *layout = [[IGListCollectionViewLayout alloc] initWithStickyHeaders:NO topContentInset:0 stretchToEdge:YES];
    return [self initWithFrame:frame listCollectionViewLayout:layout];
}

- (instancetype)initWithFrame:(CGRect)frame listCollectionViewLayout:(IGListCollectionViewLayout *)collectionViewLayout {
    return [super initWithFrame:frame collectionViewLayout:collectionViewLayout];
}

#pragma mark - IGListCollectionViewLayout

- (IGListCollectionViewLayout *)listLayout {
    if ([self.collectionViewLayout isKindOfClass:[IGListCollectionViewLayout class]]) {
        return (IGListCollectionViewLayout *)self.collectionViewLayout;
    }

    return nil;
}

#pragma mark - Overides reloads

- (void)reloadItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    [self didModifyIndexPaths:indexPaths];
    [super reloadItemsAtIndexPaths:indexPaths];
}

- (void)reloadSections:(NSIndexSet *)sections {
    [self didModifySections:sections];
    [super reloadSections:sections];
}

#pragma mark - Override deletes

- (void)deleteItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    [self didModifyIndexPaths:indexPaths];
    [super deleteItemsAtIndexPaths:indexPaths];
}

- (void)deleteSections:(NSIndexSet *)sections {
    [self didModifySections:sections];
    [super deleteSections:sections];
}

#pragma mark - Override inserts

- (void)insertItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    [self didModifyIndexPaths:indexPaths];
    [super insertItemsAtIndexPaths:indexPaths];
}

- (void)insertSections:(NSIndexSet *)sections {
    [self didModifySections:sections];
    [super insertSections:sections];
}

#pragma mark - Override moves

- (void)moveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath {
    [self didModifyIndexPaths:@[indexPath, newIndexPath]];
    [super moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
}

- (void)moveSection:(NSInteger)section toSection:(NSInteger)newSection {
    [self didModifySection:MIN(section, newSection)];
    [super moveSection:section toSection:newSection];
}

#pragma mark - Modify section

- (void)didModifySections:(NSIndexSet *)sections {
    if (sections.count == 0) {
        return;
    }
    [self didModifySection:sections.firstIndex];
}

- (void)didModifySection:(NSUInteger)section {
    [self.listLayout didModifySection:section];
}

#pragma mark - Modified index path

- (void)didModifyIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    for (NSIndexPath *indexPath in indexPaths) {
        [self didModifySection:indexPath.section];
    }
}

@end
