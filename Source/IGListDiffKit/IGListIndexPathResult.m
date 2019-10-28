/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
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
        _inserts = inserts;
        _deletes = deletes;
        _updates = updates;
        _moves = moves;
        _oldIndexPathMap = oldIndexPathMap;
        _newIndexPathMap = newIndexPathMap;
    }
    return self;
}

- (BOOL)hasChanges {
    return self.changeCount > 0;
}

- (NSInteger)changeCount {
    return self.inserts.count + self.deletes.count + self.updates.count + self.moves.count;
}

- (IGListIndexPathResult *)resultForBatchUpdates {
    NSMutableSet<NSIndexPath *> *deletes = [NSMutableSet setWithArray:self.deletes];
    NSMutableSet<NSIndexPath *> *inserts = [NSMutableSet setWithArray:self.inserts];
    NSMutableSet<NSIndexPath *> *filteredUpdates = [NSMutableSet setWithArray:self.updates];

    NSArray<IGListMoveIndexPath *> *moves = self.moves;
    NSMutableArray<IGListMoveIndexPath *> *filteredMoves = [moves mutableCopy];

    // convert move+update to delete+insert, respecting the from/to of the move
    const NSInteger moveCount = moves.count;
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
    return [NSString stringWithFormat:@"<%@ %p; %lu inserts; %lu deletes; %lu updates; %lu moves>",
            NSStringFromClass(self.class), self, (unsigned long)self.inserts.count, (unsigned long)self.deletes.count, (unsigned long)self.updates.count, (unsigned long)self.moves.count];
}

@end
