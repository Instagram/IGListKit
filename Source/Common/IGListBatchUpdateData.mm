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
+ (void)cleanIndexPathsWithMap:(const std::unordered_map<NSInteger, IGListMoveIndex*> &)map
                         moves:(NSMutableSet<IGListMoveIndex *> *)moves
                    indexPaths:(NSMutableArray<NSIndexPath *> *)indexPaths
                       deletes:(NSMutableIndexSet *)deletes
                       inserts:(NSMutableIndexSet *)inserts {
    for (NSInteger i = indexPaths.count - 1; i >= 0; i--) {
        NSIndexPath *path = indexPaths[i];
        const auto it = map.find(path.section);
        if (it != map.end() && it->second != nil) {
            [indexPaths removeObjectAtIndex:i];
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
                      insertIndexPaths:(NSArray<NSIndexPath *> *)insertIndexPaths
                      deleteIndexPaths:(NSArray<NSIndexPath *> *)deleteIndexPaths
                        moveIndexPaths:(NSArray<IGListMoveIndexPath *> *)moveIndexPaths {
    IGParameterAssert(insertSections != nil);
    IGParameterAssert(deleteSections != nil);
    IGParameterAssert(moveSections != nil);
    IGParameterAssert(insertIndexPaths != nil);
    IGParameterAssert(deleteIndexPaths != nil);
    IGParameterAssert(moveIndexPaths != nil);
    if (self = [super init]) {
        NSMutableSet<IGListMoveIndex *> *mMoveSections = [moveSections mutableCopy];
        NSMutableIndexSet *mDeleteSections = [deleteSections mutableCopy];
        NSMutableIndexSet *mInsertSections = [insertSections mutableCopy];
        NSMutableSet<IGListMoveIndexPath *> *mMoveIndexPaths = [moveIndexPaths mutableCopy];

        // these collections should NEVER be mutated during cleanup passes, otherwise sections that have multiple item
        // changes (e.g. a moved section that has a delete + reload on different index paths w/in the section) will only
        // convert one of the item changes into a section delete+insert. this will fail hard and be VERY difficult to
        // debug
        const NSInteger moveCount = [moveSections count];
        std::unordered_map<NSInteger, IGListMoveIndex*> fromMap(moveCount);
        std::unordered_map<NSInteger, IGListMoveIndex*> toMap(moveCount);
        for (IGListMoveIndex *move in moveSections) {
            const NSInteger from = move.from;
            const NSInteger to = move.to;

            // if the move is already deleted or inserted, discard it because count-changing operations must match
            // with data source changes
            if ([deleteSections containsIndex:from] || [insertSections containsIndex:to]) {
                [mMoveSections removeObject:move];
            } else {
                fromMap[from] = move;
                toMap[to] = move;
            }
        }

        NSMutableArray<NSIndexPath *> *mInsertIndexPaths = [insertIndexPaths mutableCopy];

        // avoid a flaky UICollectionView bug when deleting from the same index path twice
        // exposes a possible data source inconsistency issue
        NSMutableArray<NSIndexPath *> *mDeleteIndexPaths = [[[NSSet setWithArray:deleteIndexPaths] allObjects] mutableCopy];

        // avoids a bug where a cell is animated twice and one of the snapshot cells is never removed from the hierarchy
        [IGListBatchUpdateData cleanIndexPathsWithMap:fromMap moves:mMoveSections indexPaths:mDeleteIndexPaths deletes:mDeleteSections inserts:mInsertSections];

        // prevents a bug where UICollectionView corrupts the heap memory when inserting into a section that is moved
        [IGListBatchUpdateData cleanIndexPathsWithMap:toMap moves:mMoveSections indexPaths:mInsertIndexPaths deletes:mDeleteSections inserts:mInsertSections];

        for (IGListMoveIndexPath *move in moveIndexPaths) {
            // if the section w/ an index path move is deleted, just drop the move
            if ([deleteSections containsIndex:move.from.section]) {
                [mMoveIndexPaths removeObject:move];
            }

            // if a move is inside a section that is moved, convert the section move to a delete+insert
            const auto it = fromMap.find(move.from.section);
            if (it != fromMap.end() && it->second != nil) {
                IGListMoveIndex *sectionMove = it->second;
                [mMoveIndexPaths removeObject:move];
                [mMoveSections removeObject:sectionMove];
                [mDeleteSections addIndex:sectionMove.from];
                [mInsertSections addIndex:sectionMove.to];
            }
        }

        _deleteSections = [mDeleteSections copy];
        _insertSections = [mInsertSections copy];
        _moveSections = [mMoveSections copy];
        _deleteIndexPaths = [mDeleteIndexPaths copy];
        _insertIndexPaths = [mInsertIndexPaths copy];
        _moveIndexPaths = [mMoveIndexPaths copy];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p; deleteSections: %zi; insertSections: %zi; moveSections: %zi; deleteIndexPaths: %zi; insertIndexPaths: %zi;>",
            NSStringFromClass(self.class), self, self.deleteSections.count, self.insertSections.count, self.moveSections.count,
            self.deleteIndexPaths.count, self.insertIndexPaths.count];
}

@end
