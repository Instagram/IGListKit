/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>
#import <GameplayKit/GKRandomSource.h>
#import <XCTest/XCTest.h>

#import <IGListDiffKit/IGListDiff.h>
#import <IGListDiffKit/IGListExperiments.h>

#import "IGListIndexSetResultInternal.h"
#import "IGListMoveIndexInternal.h"
#import "IGListMoveIndexPathInternal.h"

@interface IGListDiffExperimentOptimizedMovesTests : XCTestCase

@end

static NSArray *updatedArray(NSArray *oldArray, NSArray *newArray, IGListIndexSetResult *diff) {
    NSMutableArray *result = [oldArray mutableCopy];

    NSMutableIndexSet *deletes = [diff.deletes mutableCopy];
    NSMutableIndexSet *inserts = [diff.inserts mutableCopy];

    NSMutableIndexSet *fromIndexes = [NSMutableIndexSet new];
    NSMutableIndexSet *toIndexes = [NSMutableIndexSet new];

    for (IGListMoveIndex *move in diff.moves) {
        [fromIndexes addIndex:move.from];
        [toIndexes addIndex:move.to];
    }

    [deletes addIndexes:fromIndexes];
    [inserts addIndexes:toIndexes];

    [result removeObjectsAtIndexes:deletes];

    NSArray *insertedObjects = [newArray objectsAtIndexes:inserts];
    [result insertObjects:insertedObjects atIndexes:inserts];

    for (IGListMoveIndex *move in diff.moves) {
        [result replaceObjectAtIndex:move.to withObject:oldArray[move.from]];
    }

    return result;
}

@implementation IGListDiffExperimentOptimizedMovesTests

- (void)test_whenMovingBackward_thatIndexesMatch {
    NSArray *o = @[ @0, @1, @2, @3, @4, @5 ];
    NSArray *n = @[ @5, @4, @0, @1, @2, @3 ];
    IGListIndexSetResult *result = IGListDiffExperiment(o, n, IGListDiffEquality, IGListExperimentOptimizedMoves);
    XCTAssertEqual(result.updates.count, 0);
    NSArray *expectedMoves = @[ [[IGListMoveIndex alloc] initWithFrom:5 to:0],
                                [[IGListMoveIndex alloc] initWithFrom:4 to:1] ];
    XCTAssertEqualObjects(result.moves, expectedMoves);
    NSMutableIndexSet *expectedDeletes = [NSMutableIndexSet new];
    XCTAssertEqualObjects(result.deletes, expectedDeletes);
    NSMutableIndexSet *expectedInserts = [NSMutableIndexSet new];
    XCTAssertEqualObjects(result.inserts, expectedInserts);
}

- (void)test_whenMovingBackwardWithInsertionBefore_thatIndexesMatch {
    NSArray *o = @[ @0, @1, @2, @3, @4, @5 ];
    NSArray *n = @[ @100, @5, @0, @1, @2, @3, @4 ];
    IGListIndexSetResult *result = IGListDiffExperiment(o, n, IGListDiffEquality, IGListExperimentOptimizedMoves);
    XCTAssertEqual(result.updates.count, 0);
    NSArray *expectedMoves = @[ [[IGListMoveIndex alloc] initWithFrom:5 to:1] ];
    XCTAssertEqualObjects(result.moves, expectedMoves);
    NSMutableIndexSet *expectedDeletes = [NSMutableIndexSet new];
    XCTAssertEqualObjects(result.deletes, expectedDeletes);
    NSIndexSet *expectedInserts = [NSIndexSet indexSetWithIndex:0];
    XCTAssertEqualObjects(result.inserts, expectedInserts);
}

- (void)test_whenMovingBackwardWithInsertionInBetween_thatIndexesMatch {
    NSArray *o = @[ @0, @1, @2, @3, @4, @5 ];
    NSArray *n = @[ @5, @100, @0, @1, @2, @3, @4 ];
    IGListIndexSetResult *result = IGListDiffExperiment(o, n, IGListDiffEquality, IGListExperimentOptimizedMoves);
    XCTAssertEqual(result.updates.count, 0);
    NSArray *expectedMoves = @[ [[IGListMoveIndex alloc] initWithFrom:5 to:0] ];
    XCTAssertEqualObjects(result.moves, expectedMoves);
    NSMutableIndexSet *expectedDeletes = [NSMutableIndexSet new];
    XCTAssertEqualObjects(result.deletes, expectedDeletes);
    NSIndexSet *expectedInserts = [NSIndexSet indexSetWithIndex:1];
    XCTAssertEqualObjects(result.inserts, expectedInserts);
}

- (void)test_whenMovingBackwardWithDeletionBefore_thatIndexesMatch {
    NSArray *o = @[ @0, @1, @2, @3, @4, @5 ];
    NSArray *n = @[ @1, @4, @5, @2, @3 ];
    IGListIndexSetResult *result = IGListDiffExperiment(o, n, IGListDiffEquality, IGListExperimentOptimizedMoves);
    XCTAssertEqual(result.updates.count, 0);
    NSArray *expectedMoves = @[ [[IGListMoveIndex alloc] initWithFrom:4 to:1],
                                [[IGListMoveIndex alloc] initWithFrom:5 to:2] ];
    XCTAssertEqualObjects(result.moves, expectedMoves);
    NSIndexSet *expectedDeletes = [NSIndexSet indexSetWithIndex:0];
    XCTAssertEqualObjects(result.deletes, expectedDeletes);
    NSIndexSet *expectedInserts = [NSIndexSet new];
    XCTAssertEqualObjects(result.inserts, expectedInserts);
}

- (void)test_whenMovingBackwardWithDeletionInBetween_thatIndexesMatch {
    NSArray *o = @[ @0, @1, @2, @3, @4, @5 ];
    NSArray *n = @[ @5, @0, @2, @3, @4 ];
    IGListIndexSetResult *result = IGListDiffExperiment(o, n, IGListDiffEquality, IGListExperimentOptimizedMoves);
    XCTAssertEqual(result.updates.count, 0);
    NSArray *expectedMoves = @[ [[IGListMoveIndex alloc] initWithFrom:5 to:0] ];
    XCTAssertEqualObjects(result.moves, expectedMoves);
    NSIndexSet *expectedDeletes = [NSIndexSet indexSetWithIndex:1];
    XCTAssertEqualObjects(result.deletes, expectedDeletes);
    NSIndexSet *expectedInserts = [NSIndexSet new];
    XCTAssertEqualObjects(result.inserts, expectedInserts);
}

- (void)test_whenMovingForward_thatIndexesMatch {
    NSArray *o = @[ @0, @1, @2, @3, @4, @5 ];
    NSArray *n = @[ @2, @3, @4, @5, @1, @0 ];
    IGListIndexSetResult *result = IGListDiffExperiment(o, n, IGListDiffEquality, IGListExperimentOptimizedMoves);
    XCTAssertEqual(result.updates.count, 0);
    NSArray *expectedMoves = @[ [[IGListMoveIndex alloc] initWithFrom:1 to:4],
                                [[IGListMoveIndex alloc] initWithFrom:0 to:5] ];
    XCTAssertEqualObjects(result.moves, expectedMoves);
    NSMutableIndexSet *expectedDeletes = [NSMutableIndexSet new];
    XCTAssertEqualObjects(result.deletes, expectedDeletes);
    NSMutableIndexSet *expectedInserts = [NSMutableIndexSet new];
    XCTAssertEqualObjects(result.inserts, expectedInserts);
}

- (void)test_whenMovingBothWays_thatIndexesMatch {
    NSArray *o = @[ @0, @1, @2, @3, @4, @5 ];
    NSArray *n = @[ @1, @2, @0, @5, @3, @4 ];
    IGListIndexSetResult *result = IGListDiffExperiment(o, n, IGListDiffEquality, IGListExperimentOptimizedMoves);
    XCTAssertEqual(result.updates.count, 0);
    NSArray *expectedMoves = @[ [[IGListMoveIndex alloc] initWithFrom:0 to:2],
                                [[IGListMoveIndex alloc] initWithFrom:5 to:3] ];
    XCTAssertEqualObjects(result.moves, expectedMoves);
    NSMutableIndexSet *expectedDeletes = [NSMutableIndexSet new];
    XCTAssertEqualObjects(result.deletes, expectedDeletes);
    NSMutableIndexSet *expectedInserts = [NSMutableIndexSet new];
    XCTAssertEqualObjects(result.inserts, expectedInserts);
}

- (void)test_whenSwappingNeighbors_thatResultHasSingleMove {
    NSArray *o = @[@1, @2];
    NSArray *n = @[@2, @1];
    IGListIndexSetResult *result = IGListDiffExperiment(o, n, IGListDiffEquality, IGListExperimentOptimizedMoves);
    NSArray *expected = @[
                          [[IGListMoveIndex alloc] initWithFrom:1 to:0]
                          ];
    XCTAssertEqualObjects(result.moves, expected);
    XCTAssertEqual([result changeCount], 1);
}

- (void)test_whenRandomlyUpdating_thatApplyingDiffProducesSameArray {
    NSArray *o = @[ @0, @1, @2, @3, @4, @5, @6, @7, @8, @9 ];

    for (int testIdx = 0; testIdx < 1000; testIdx ++) {

        NSMutableArray *n = [o mutableCopy];

        for (int i = 0; i < 2; i++) {
            [n removeObjectAtIndex:arc4random_uniform((uint32_t) n.count)];
        }

        NSMutableIndexSet *fromIndexes = [NSMutableIndexSet new];
        NSMutableIndexSet *toIndexes = [NSMutableIndexSet new];

        for (int i = 0; i < 2; i++) {
            NSUInteger fromIdx;
            do {
                fromIdx = arc4random_uniform((uint32_t) n.count);
            } while ([fromIndexes containsIndex:fromIdx] || [toIndexes containsIndex:fromIdx]);
            [fromIndexes addIndex:fromIdx];

            NSUInteger toIdx;
            do {
                toIdx = arc4random_uniform((uint32_t) n.count);
            } while ([toIndexes containsIndex:fromIdx] || [toIndexes containsIndex:toIdx]);
            [toIndexes addIndex:toIdx];
        }

        NSArray *movedObjects = [n objectsAtIndexes:fromIndexes];
        [n removeObjectsAtIndexes:fromIndexes];
        [n insertObjects:movedObjects atIndexes:toIndexes];

        NSMutableIndexSet *inserts = [NSMutableIndexSet new];
        NSMutableArray *insertedObjects = [NSMutableArray new];

        for (int i = 0; i < 3; i++) {
            NSUInteger idx;
            do {
                idx = arc4random_uniform((uint32_t) n.count);
            } while ([inserts containsIndex:idx]);
            [inserts addIndex:idx];
            [insertedObjects addObject:@(n.count + i + 10)];
        }

        [n insertObjects:insertedObjects atIndexes:inserts];

        IGListIndexSetResult *result = IGListDiffExperiment(o, n, IGListDiffEquality, IGListExperimentOptimizedMoves);
        XCTAssertEqualObjects(updatedArray(o, n, result), n);
    }
}

- (void)test_whenReversing_thatApplyingDiffProducesSameArray {

    NSArray *o = @[ @0, @1, @2, @3, @4, @5, @6, @7, @8, @9 ];

    NSArray *n = o.reverseObjectEnumerator.allObjects;

    IGListIndexSetResult *result = IGListDiffExperiment(o, n, IGListDiffEquality, IGListExperimentOptimizedMoves);
    XCTAssertEqualObjects(updatedArray(o, n, result), n);
}


- (void)test_whenShuffling_thatApplyingDiffProducesSameArray {

    for (int testIdx = 0; testIdx < 1000; testIdx ++) {
        NSArray *o = @[ @0, @1, @2, @3, @4, @5, @6, @7, @8, @9 ];
        NSArray *n = [o shuffledArray];

        IGListIndexSetResult *result = IGListDiffExperiment(o, n, IGListDiffEquality, IGListExperimentOptimizedMoves);
        XCTAssertEqualObjects(updatedArray(o, n, result), n);
    }
}

@end
