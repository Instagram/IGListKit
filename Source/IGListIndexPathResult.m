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

- (IGListIndexPathResult *)resultWithUpdatedMovesAsDeleteInserts {
    NSMutableSet<NSIndexPath *> *deletes = [self.deletes mutableCopy];
    NSMutableSet<NSIndexPath *> *inserts = [self.inserts mutableCopy];
    NSMutableSet<NSIndexPath *> *filteredUpdates = [self.updates mutableCopy];

    NSArray<IGListMoveIndexPath *> *moves = self.moves;
    NSMutableArray<IGListMoveIndexPath *> *filteredMoves = [moves mutableCopy];

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

    return [[IGListIndexPathResult alloc] initWithInserts:[inserts allObjects]
                                                  deletes:[deletes allObjects]
                                                  updates:[filteredUpdates allObjects]
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
