/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "IGListIndexSetResult.h"
#import "IGListIndexSetResultInternal.h"

#import <IGListKit/IGListMoveIndex.h>

@implementation IGListIndexSetResult {
    NSMapTable<id<NSObject>, NSNumber *> *_oldIndexMap;
    NSMapTable<id<NSObject>, NSNumber *> *_newIndexMap;
}

- (instancetype)initWithInserts:(NSIndexSet *)inserts
                        deletes:(NSIndexSet *)deletes
                        updates:(NSIndexSet *)updates
                          moves:(NSArray<IGListMoveIndex *> *)moves
                    oldIndexMap:(NSMapTable<id<NSObject>, NSNumber *> *)oldIndexMap
                    newIndexMap:(NSMapTable<id<NSObject>, NSNumber *> *)newIndexMap {
    if (self = [super init]) {
        _inserts = inserts;
        _deletes = deletes;
        _updates = updates;
        _moves = moves;
        _oldIndexMap = oldIndexMap;
        _newIndexMap = newIndexMap;
    }
    return self;
}

- (BOOL)hasChanges {
    return self.changeCount > 0;
}

- (NSInteger)changeCount {
    return self.inserts.count + self.deletes.count + self.updates.count + self.moves.count;
}

- (IGListIndexSetResult *)resultForBatchUpdates {
    NSMutableIndexSet *deletes = [self.deletes mutableCopy];
    NSMutableIndexSet *inserts = [self.inserts mutableCopy];
    NSMutableIndexSet *filteredUpdates = [self.updates mutableCopy];

    NSArray<IGListMoveIndex *> *moves = self.moves;
    NSMutableArray<IGListMoveIndex *> *filteredMoves = [moves mutableCopy];

    // convert all update+move to delete+insert
    const NSInteger moveCount = moves.count;
    for (NSInteger i = moveCount - 1; i >= 0; i--) {
        IGListMoveIndex *move = moves[i];
        if ([filteredUpdates containsIndex:move.from]) {
            [filteredMoves removeObjectAtIndex:i];
            [filteredUpdates removeIndex:move.from];
            [deletes addIndex:move.from];
            [inserts addIndex:move.to];
        }
    }

    // iterate all new identifiers. if its index is updated, delete from the old index and insert the new index
    for (id<NSObject> key in [_oldIndexMap keyEnumerator]) {
        const NSInteger index = [[_oldIndexMap objectForKey:key] integerValue];
        if ([filteredUpdates containsIndex:index]) {
            [deletes addIndex:index];
            [inserts addIndex:[[_newIndexMap objectForKey:key] integerValue]];
        }
    }

    return [[IGListIndexSetResult alloc] initWithInserts:inserts
                                                 deletes:deletes
                                                 updates:[NSIndexSet new]
                                                   moves:filteredMoves
                                             oldIndexMap:_oldIndexMap
                                             newIndexMap:_newIndexMap];
}

- (NSInteger)oldIndexForIdentifier:(id<NSObject>)identifier {
    NSNumber *index = [_oldIndexMap objectForKey:identifier];
    return index == nil ? NSNotFound : [index integerValue];
}

- (NSInteger)newIndexForIdentifier:(id<NSObject>)identifier {
    NSNumber *index = [_newIndexMap objectForKey:identifier];
    return index == nil ? NSNotFound : [index integerValue];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p; %zi inserts; %zi deletes; %zi updates; %zi moves>",
            NSStringFromClass(self.class), self, self.inserts.count, self.deletes.count, self.updates.count, self.moves.count];
}

@end
