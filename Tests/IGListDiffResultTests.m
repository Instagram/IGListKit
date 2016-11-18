/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
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

@end
