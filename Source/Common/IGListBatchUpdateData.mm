/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "IGListBatchUpdateData.h"
#import <IGListKit/IGListCompatibility.h>

#import <unordered_map>

#import <IGListKit/IGListAssert.h>

// Filters indexPaths removing all paths that have a section in sections.
static NSMutableSet *indexPathsMinusSections(NSSet<NSIndexPath *> *indexPaths, NSIndexSet *sections) {
    NSMutableSet *filteredIndexPaths = [indexPaths mutableCopy];
    for (NSIndexPath *indexPath in indexPaths) {
        const NSUInteger section = indexPath.section;
        if ([sections containsIndex:section]) {
            [filteredIndexPaths removeObject:indexPath];
        }
    }
    return filteredIndexPaths;
}

// Plucks the given move from available moves and turns it into a delete + insert
static void convertMoveToDeleteAndInsert(NSMutableSet<IGListMoveIndex *> *moves,
                                         IGListMoveIndex *move,
                                         NSMutableIndexSet *deletes,
                                         NSMutableIndexSet *inserts) {
    [moves removeObject:move];

    // add a delete and insert respecting the move's from and to sections
    // delete + insert will result in reloading the entire section
    [deletes addIndex:move.from];
    [inserts addIndex:move.to];
}

@implementation IGListBatchUpdateData

// Converts all section moves that have index path operations into a section delete + insert.
+ (void)cleanIndexPathsWithMap:(const std::unordered_map<NSUInteger, IGListMoveIndex*> &)map
                         moves:(NSMutableSet<IGListMoveIndex *> *)moves
                    indexPaths:(NSMutableSet<NSIndexPath *> *)indexPaths
                       deletes:(NSMutableIndexSet *)deletes
                       inserts:(NSMutableIndexSet *)inserts {
    for (NSIndexPath *path in [indexPaths copy]) {
        const auto it = map.find(path.section);
        if (it != map.end() && it->second != nil) {
            [indexPaths removeObject:path];
            convertMoveToDeleteAndInsert(moves, it->second, deletes, inserts);
        }
    }
}

/**
 Converts all section moves that are also reloaded, or have index path inserts, deletes, or reloads into a section
 delete + insert in order to avoid UICollectionView heap corruptions, exceptions, and animation/snapshot bugs.
 */
- (instancetype)initWithInsertSections:(NSIndexSet *)insertSections
                        deleteSections:(NSIndexSet *)deleteSections
                          moveSections:(NSSet<IGListMoveIndex *> *)moveSections
                      insertIndexPaths:(NSSet<NSIndexPath *> *)insertIndexPaths
                      deleteIndexPaths:(NSSet<NSIndexPath *> *)deleteIndexPaths
                      reloadIndexPaths:(NSSet<NSIndexPath *> *)reloadIndexPaths {
    IGParameterAssert(insertSections != nil);
    IGParameterAssert(deleteSections != nil);
    IGParameterAssert(moveSections != nil);
    IGParameterAssert(insertIndexPaths != nil);
    IGParameterAssert(deleteIndexPaths != nil);
    IGParameterAssert(reloadIndexPaths != nil);
    if (self = [super init]) {
        NSMutableSet<IGListMoveIndex *> *mMoveSections = [moveSections mutableCopy];
        NSMutableIndexSet *mDeleteSections = [deleteSections mutableCopy];
        NSMutableIndexSet *mInsertSections = [insertSections mutableCopy];

        // these collections should NEVER be mutated during cleanup passes, otherwise sections that have multiple item
        // changes (e.g. a moved section that has a delete + reload on different index paths w/in the section) will only
        // convert one of the item changes into a section delete+insert. this will fail hard and be VERY difficult to
        // debug
        const NSUInteger moveCount = [moveSections count];
        std::unordered_map<NSUInteger, IGListMoveIndex*> fromMap(moveCount);
        std::unordered_map<NSUInteger, IGListMoveIndex*> toMap(moveCount);
        for (IGListMoveIndex *move in moveSections) {
            const NSUInteger from = move.from;
            const NSUInteger to = move.to;

            // if the move is already deleted or inserted, discard it and use delete+insert instead
            if ([deleteSections containsIndex:from] || [insertSections containsIndex:to]) {
                convertMoveToDeleteAndInsert(mMoveSections, move, mDeleteSections, mInsertSections);
            } else {
                fromMap[from] = move;
                toMap[to] = move;
            }
        }

        NSMutableSet<NSIndexPath *> *mInsertIndexPaths = [insertIndexPaths mutableCopy];
        NSMutableSet<NSIndexPath *> *mDeleteIndexPaths = [deleteIndexPaths mutableCopy];

        // UICollectionView will throw if reloading an index path in a section that is also deleted
        NSMutableSet<NSIndexPath *> *mReloadIndexPaths = indexPathsMinusSections(reloadIndexPaths, deleteSections);

        // UICollectionView will throw about simultaneous animations when reloading and moving cells at the same time
        [IGListBatchUpdateData cleanIndexPathsWithMap:fromMap moves:mMoveSections indexPaths:mReloadIndexPaths deletes:mDeleteSections inserts:mInsertSections];

        // avoids a bug where a cell is animated twice and one of the snapshot cells is never removed from the hierarchy
        [IGListBatchUpdateData cleanIndexPathsWithMap:fromMap moves:mMoveSections indexPaths:mDeleteIndexPaths deletes:mDeleteSections inserts:mInsertSections];

        // prevents a bug where UICollectionView corrupts the heap memory when inserting into a section that is moved
        [IGListBatchUpdateData cleanIndexPathsWithMap:toMap moves:mMoveSections indexPaths:mInsertIndexPaths deletes:mDeleteSections inserts:mInsertSections];

        _deleteSections = [mDeleteSections copy];
        _insertSections = [mInsertSections copy];
        _moveSections = [mMoveSections copy];
        _deleteIndexPaths = [mDeleteIndexPaths copy];
        _insertIndexPaths = [mInsertIndexPaths copy];
        _reloadIndexPaths = [mReloadIndexPaths copy];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p; deleteSections: %zi; insertSections: %zi; moveSections: %zi; deleteIndexPaths: %zi; insertIndexPaths: %zi; reloadIndexPaths: %zi;>",
            NSStringFromClass(self.class), self, self.deleteSections.count, self.insertSections.count, self.moveSections.count,
            self.deleteIndexPaths.count, self.insertIndexPaths.count, self.reloadIndexPaths.count];
}

@end
