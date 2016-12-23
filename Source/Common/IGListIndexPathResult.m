/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "IGListIndexPathResult.h"
#import "IGListIndexPathResultInternal.h"

@implementation IGListIndexPathResult {
    NSMapTable<id<NSObject>, NSIndexPath *> *_oldIndexPathMap;
    NSMapTable<id<NSObject>, NSIndexPath *> *_newIndexPathMap;
}

- (instancetype)initWithInserts:(NSArray<NSIndexPath *> *)inserts
                        deletes:(NSArray<NSIndexPath *> *)deletes
                        updates:(NSArray<NSIndexPath *> *)updates
                          moves:(NSArray<IGListMoveIndexPath *> *)moves
                oldIndexPathMap:(NSMapTable<id<NSObject>, NSIndexPath *> *)oldIndexPathMap
                newIndexPathMap:(NSMapTable<id<NSObject>, NSIndexPath *> *)newIndexPathMap {
    if (self = [super init]) {
        _inserts = [inserts copy];
        _deletes = [deletes copy];
        _updates = [updates copy];
        _moves = [moves copy];
        _oldIndexPathMap = [oldIndexPathMap copy];
        _newIndexPathMap = [newIndexPathMap copy];
    }
    return self;
}

- (BOOL)hasChanges {
    return self.inserts.count || self.deletes.count || self.updates.count || self.moves.count;
}

- (IGListIndexPathResult *)resultForBatchUpdates {
    NSMutableSet<NSIndexPath *> *deletes = [NSMutableSet setWithArray:self.deletes];
    NSMutableSet<NSIndexPath *> *inserts = [NSMutableSet setWithArray:self.inserts];
    NSMutableSet<NSIndexPath *> *filteredUpdates = [NSMutableSet setWithArray:self.updates];

    NSArray<IGListMoveIndexPath *> *moves = self.moves;
    NSMutableArray<IGListMoveIndexPath *> *filteredMoves = [moves mutableCopy];

    // convert move+update to delete+insert, respecting the from/to of the move
    const NSUInteger moveCount = moves.count;
    for (NSInteger i = moveCount - 1; i >= 0; i--) {
        IGListMoveIndexPath *move = moves[i];
        if ([filteredUpdates containsObject:move.from]) {
            [filteredMoves removeObjectAtIndex:i];
            [filteredUpdates removeObject:move.from];
            [deletes addObject:move.from];
            [inserts addObject:move.to];
        }
    }

    // iterate all new identifiers. if its index is updated, delete from the old index and insert the new index
    for (id<NSObject> key in [_oldIndexPathMap keyEnumerator]) {
        NSIndexPath *indexPath = [_oldIndexPathMap objectForKey:key];
        if ([filteredUpdates containsObject:indexPath]) {
            [deletes addObject:indexPath];
            [inserts addObject:(id)[_newIndexPathMap objectForKey:key]];
        }
    }

    return [[IGListIndexPathResult alloc] initWithInserts:[inserts allObjects]
                                                  deletes:[deletes allObjects]
                                                  updates:[NSArray new]
                                                    moves:filteredMoves
                                          oldIndexPathMap:_oldIndexPathMap
                                          newIndexPathMap:_newIndexPathMap];
}

- (NSIndexPath *)oldIndexPathForIdentifier:(id<NSObject>)identifier {
    return [_oldIndexPathMap objectForKey:identifier];
}

- (NSIndexPath *)newIndexPathForIdentifier:(id<NSObject>)identifier {
    return [_newIndexPathMap objectForKey:identifier];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p; %zi inserts; %zi deletes; %zi updates; %zi moves>",
            NSStringFromClass(self.class), self, self.inserts.count, self.deletes.count, self.updates.count, self.moves.count];
}

@end
