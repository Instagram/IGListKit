/**
 * Copyright (c) 2016-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <XCTest/XCTest.h>

#import <IGListKit/IGListKit.h>
#import "IGListMoveIndexInternal.h"
#import "IGListMoveIndexPathInternal.h"

@interface IGListDiffResultTests : XCTestCase

@end

@implementation IGListDiffResultTests

- (void)test_whenDuplicateMoves_withIndexPaths_thatSetCountCorrect {
    IGListMoveIndexPath *move = [[IGListMoveIndexPath alloc] initWithFrom:[NSIndexPath indexPathForItem:4 inSection:2]
                                                                       to:[NSIndexPath indexPathForItem:7 inSection:5]];
    IGListMoveIndexPath *other = [[IGListMoveIndexPath alloc] initWithFrom:[NSIndexPath indexPathForItem:4 inSection:2]
                                                                        to:[NSIndexPath indexPathForItem:7 inSection:5]];
    NSSet *set = [NSSet setWithObjects:move, other, nil];
    XCTAssertEqual(set.count, 1);
}

- (void)test_whenUniqueMoves_withIndexPaths_whenFlippedIndexPaths_thatSetCountCorrect {
    IGListMoveIndexPath *move = [[IGListMoveIndexPath alloc] initWithFrom:[NSIndexPath indexPathForItem:4 inSection:2]
                                                                       to:[NSIndexPath indexPathForItem:7 inSection:5]];
    IGListMoveIndexPath *other = [[IGListMoveIndexPath alloc] initWithFrom:[NSIndexPath indexPathForItem:7 inSection:5]
                                                                        to:[NSIndexPath indexPathForItem:4 inSection:4]];
    NSSet *set = [NSSet setWithObjects:move, other, nil];
    XCTAssertEqual(set.count, 2);
}

- (void)test_whenUniqueMoves_withIndexPaths_thatSetCountCorrect {
    IGListMoveIndexPath *move = [[IGListMoveIndexPath alloc] initWithFrom:[NSIndexPath indexPathForItem:4 inSection:2]
                                                                       to:[NSIndexPath indexPathForItem:7 inSection:5]];
    IGListMoveIndexPath *other = [[IGListMoveIndexPath alloc] initWithFrom:[NSIndexPath indexPathForItem:10 inSection:2]
                                                                        to:[NSIndexPath indexPathForItem:6 inSection:11]];
    NSSet *set = [NSSet setWithObjects:move, other, nil];
    XCTAssertEqual(set.count, 2);
}

- (void)test_whenDuplicateMoves_withIndexes_thatSetCountCorrect {
    IGListMoveIndex *move = [[IGListMoveIndex alloc] initWithFrom:4 to:2];
    IGListMoveIndex *other = [[IGListMoveIndex alloc] initWithFrom:4 to:2];
    NSSet *set = [NSSet setWithObjects:move, other, nil];
    XCTAssertEqual(set.count, 1);
}

- (void)test_whenUniqueMoves_withIndexes_whenFlippedIndexes_thatSetCountCorrect {
    IGListMoveIndex *move = [[IGListMoveIndex alloc] initWithFrom:4 to:2];
    IGListMoveIndex *other = [[IGListMoveIndex alloc] initWithFrom:2 to:4];
    NSSet *set = [NSSet setWithObjects:move, other, nil];
    XCTAssertEqual(set.count, 2);
}

- (void)test_whenUniqueMoves_withIndexes_thatSetCountCorrect {
    IGListMoveIndex *move = [[IGListMoveIndex alloc] initWithFrom:4 to:2];
    IGListMoveIndex *other = [[IGListMoveIndex alloc] initWithFrom:5 to:7];
    NSSet *set = [NSSet setWithObjects:move, other, nil];
    XCTAssertEqual(set.count, 2);
}

- (void)test_whenComparingMovePointers_withIndexPaths_thatEqual {
    IGListMoveIndexPath *move = [[IGListMoveIndexPath alloc] initWithFrom:[NSIndexPath new] to:[NSIndexPath new]];
    XCTAssertTrue([move isEqual:move]);
}

- (void)test_whenComparingMovePointers_withIndexes_thatEqual {
    IGListMoveIndex *move = [[IGListMoveIndex alloc] initWithFrom:1 to:1];
    XCTAssertTrue([move isEqual:move]);
}

- (void)test_whenComparingMoves_withIndexPaths_withNonMove_thatNotEqual {
    IGListMoveIndexPath *move = [[IGListMoveIndexPath alloc] initWithFrom:[NSIndexPath new] to:[NSIndexPath new]];
    XCTAssertFalse([move isEqual:[NSObject new]]);
}

- (void)test_whenComparingMoves_withIndexes_withNonMove_thatNotEqual {
    IGListMoveIndex *move = [[IGListMoveIndex alloc] initWithFrom:1 to:1];
    XCTAssertFalse([move isEqual:[NSObject new]]);
}

- (void)test_whenSortingMoves_withIndexPaths_thatSorted {
    NSArray *moves = @[
                       [[IGListMoveIndexPath alloc] initWithFrom:[NSIndexPath indexPathForItem:2 inSection:2]
                                                              to:[NSIndexPath indexPathForItem:3 inSection:3]],
                       [[IGListMoveIndexPath alloc] initWithFrom:[NSIndexPath indexPathForItem:6 inSection:3]
                                                              to:[NSIndexPath indexPathForItem:7 inSection:4]],
                       [[IGListMoveIndexPath alloc] initWithFrom:[NSIndexPath indexPathForItem:0 inSection:1]
                                                              to:[NSIndexPath indexPathForItem:1 inSection:5]],
                       [[IGListMoveIndexPath alloc] initWithFrom:[NSIndexPath indexPathForItem:2 inSection:2]
                                                              to:[NSIndexPath indexPathForItem:3 inSection:3]],
                       ];
    NSArray *expected = @[moves[2], moves[0], moves[3], moves[1]];
    NSArray *sorted = [moves sortedArrayUsingSelector:@selector(compare:)];
    XCTAssertEqualObjects(sorted, expected);
}

- (void)test_whenSortingMoves_withIndexes_thatSorted {
    NSArray *moves = @[
                       [[IGListMoveIndex alloc] initWithFrom:2 to:2],
                       [[IGListMoveIndex alloc] initWithFrom:3 to:2],
                       [[IGListMoveIndex alloc] initWithFrom:1 to:2],
                       [[IGListMoveIndex alloc] initWithFrom:2 to:2],
                       ];
    NSArray *expected = @[moves[2], moves[0], moves[3], moves[1]];
    NSArray *sorted = [moves sortedArrayUsingSelector:@selector(compare:)];
    XCTAssertEqualObjects(sorted, expected);
}

@end
