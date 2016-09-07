/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant 
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <XCTest/XCTest.h>

#import "IGListIndexPathResultInternal.h"
#import "IGListIndexSetResultInternal.h"
#import "IGListMoveIndexInternal.h"
#import "IGListMoveIndexPathInternal.h"

@interface IGListResultTests : XCTestCase

@end

@implementation IGListResultTests

static NSIndexSet *indexSetWithIndexes(NSArray *indexes) {
    NSMutableIndexSet *indexset = [NSMutableIndexSet new];
    for (NSNumber *i in indexes) {
        [indexset addIndex:i.integerValue];
    }
    return indexset;
}

static NSIndexPath *indexPath(NSUInteger item, NSUInteger section) {
    return [NSIndexPath indexPathForItem:item inSection:section];
}

- (void)testIndexSetResultConvertingUpdatesAndMoves {
    IGListIndexSetResult *initResult = [[IGListIndexSetResult alloc] initWithInserts:indexSetWithIndexes(@[@2, @3])
                                                                         deletes:indexSetWithIndexes(@[@0])
                                                                         updates:indexSetWithIndexes(@[@1, @4])
                                                                           moves:@[
                                                                                   [[IGListMoveIndex alloc] initWithFrom:1 to:5],
                                                                                   [[IGListMoveIndex alloc] initWithFrom:6 to:7]
                                                                                   ]
                                                                         oldIndexMap:[NSMapTable new]
                                                                         newIndexMap:[NSMapTable new]
                                        ];
    IGListIndexSetResult *converted = [initResult resultWithUpdatedMovesAsDeleteInserts];
    NSIndexSet *expectedDeletes = indexSetWithIndexes(@[@0, @1]);
    NSIndexSet *expectedInserts = indexSetWithIndexes(@[@2, @3, @5]);
    NSIndexSet *expectedUpdates = indexSetWithIndexes(@[@4]);
    NSArray *expectedMoves = @[
                               [[IGListMoveIndex alloc] initWithFrom:6 to:7]
                               ];
    XCTAssertEqualObjects(converted.deletes, expectedDeletes);
    XCTAssertEqualObjects(converted.inserts, expectedInserts);
    XCTAssertEqualObjects(converted.updates, expectedUpdates);
    XCTAssertEqualObjects(converted.moves, expectedMoves);
}

- (void)testIndexPathResultConvertingUpdatesAndMoves {
    IGListIndexPathResult *initResult = [[IGListIndexPathResult alloc] initWithInserts:@[
                                                                                     indexPath(0, 1),
                                                                                     indexPath(1, 2),
                                                                                     ]
                                                                           deletes:@[
                                                                                     indexPath(0, 0),
                                                                                     ]
                                                                           updates:@[
                                                                                     indexPath(1, 1),
                                                                                     indexPath(2, 4),
                                                                                     ]
                                                                                 moves:@[
                                                                                         [[IGListMoveIndexPath alloc] initWithFrom:indexPath(1, 1) to:indexPath(5, 1)],
                                                                                         [[IGListMoveIndexPath alloc] initWithFrom:indexPath(6, 0) to:indexPath(7, 0)],
                                                                                         ]
                                                                       oldIndexPathMap:[NSMapTable new]
                                                                       newIndexPathMap:[NSMapTable new]
                                         ];
    IGListIndexPathResult *converted = [initResult resultWithUpdatedMovesAsDeleteInserts];
    NSArray *expectedDeletes = @[
                                 indexPath(0, 0),
                                 indexPath(1, 1),
                                 ];
    NSArray *expectedInserts = @[
                                 indexPath(0, 1),
                                 indexPath(1, 2),
                                 indexPath(5, 1),
                                 ];
    NSArray *expectedUpdates = @[
                                 indexPath(2, 4),
                                 ];
    NSArray *expectedMoves = @[
                               [[IGListMoveIndexPath alloc] initWithFrom:indexPath(6, 0) to:indexPath(7, 0)],
                               ];
    XCTAssertEqualObjects([converted.deletes sortedArrayUsingSelector:@selector(compare:)], [expectedDeletes sortedArrayUsingSelector:@selector(compare:)]);
    XCTAssertEqualObjects([converted.inserts sortedArrayUsingSelector:@selector(compare:)], [expectedInserts sortedArrayUsingSelector:@selector(compare:)]);
    XCTAssertEqualObjects([converted.updates sortedArrayUsingSelector:@selector(compare:)], [expectedUpdates sortedArrayUsingSelector:@selector(compare:)]);
    XCTAssertEqualObjects([converted.moves sortedArrayUsingSelector:@selector(compare:)], [expectedMoves sortedArrayUsingSelector:@selector(compare:)]);
}

@end
