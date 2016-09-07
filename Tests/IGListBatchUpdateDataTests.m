/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant 
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <XCTest/XCTest.h>

#import "IGListBatchUpdateData.h"

// IGListMoveIndexInternal.h
@interface IGListMoveIndex (Private)
- (instancetype)initWithFrom:(NSUInteger)from to:(NSUInteger)to;
@end

@interface IGListBatchUpdateDataTests : XCTestCase

@end

@implementation IGListBatchUpdateDataTests

static NSIndexSet *indexSet(NSArray<NSNumber *> *arr) {
    NSMutableIndexSet *set = [NSMutableIndexSet new];
    for (NSNumber *n in arr) {
        [set addIndex:[n integerValue]];
    }
    return set;
}

static NSIndexPath *newPath(NSUInteger section, NSUInteger item) {
    return [NSIndexPath indexPathForItem:item inSection:section];
}

static IGListMoveIndex *newMove(NSUInteger from, NSUInteger to) {
    return [[IGListMoveIndex alloc] initWithFrom:from to:to];
}

- (void)test_whenEmptyUpdates_thatResultExists {
    IGListBatchUpdateData *result = [[IGListBatchUpdateData alloc] initWithInsertSections:indexSet(@[])
                                                                           deleteSections:indexSet(@[])
                                                                             moveSections:[NSSet new]
                                                                         insertIndexPaths:[NSSet new]
                                                                         deleteIndexPaths:[NSSet new]
                                                                         reloadIndexPaths:[NSSet new]];
    XCTAssertNotNil(result);
}

- (void)test_whenUpdatesAreClean_thatResultMatches {
    IGListBatchUpdateData *result = [[IGListBatchUpdateData alloc] initWithInsertSections:indexSet(@[@0, @1])
                                                                           deleteSections:indexSet(@[@5])
                                                                             moveSections:[NSSet setWithArray:@[newMove(3, 4)]]
                                                                         insertIndexPaths:[NSSet setWithArray:@[newPath(0, 0)]]
                                                                         deleteIndexPaths:[NSSet setWithArray:@[newPath(1, 0)]]
                                                                         reloadIndexPaths:[NSSet setWithArray:@[newPath(2, 0)]]];
    XCTAssertEqualObjects(result.insertSections, indexSet(@[@0, @1]));
    XCTAssertEqualObjects(result.deleteSections, indexSet(@[@5]));
    XCTAssertEqualObjects(result.moveSections, [NSSet setWithArray:@[newMove(3, 4)]]);
    XCTAssertEqualObjects(result.insertIndexPaths, [NSSet setWithArray:@[newPath(0, 0)]]);
    XCTAssertEqualObjects(result.deleteIndexPaths, [NSSet setWithArray:@[newPath(1, 0)]]);
    XCTAssertEqualObjects(result.reloadIndexPaths, [NSSet setWithArray:@[newPath(2, 0)]]);
}

- (void)test_whenReloadingItems_withSectionMove_thatResultConvertsConflicts_toDeletesAndInserts {
    NSArray *reloads = @[
                         newPath(2, 0),
                         newPath(2, 1),
                         newPath(0, 0)
                         ];
    IGListBatchUpdateData *result = [[IGListBatchUpdateData alloc] initWithInsertSections:indexSet(@[])
                                                                           deleteSections:indexSet(@[])
                                                                             moveSections:[NSSet setWithArray:@[newMove(2, 4)]]
                                                                         insertIndexPaths:[NSSet new]
                                                                         deleteIndexPaths:[NSSet new]
                                                                         reloadIndexPaths:[NSSet setWithArray:reloads]];
    XCTAssertEqualObjects(result.insertSections, indexSet(@[@4]));
    XCTAssertEqualObjects(result.deleteSections, indexSet(@[@2]));
    XCTAssertEqualObjects(result.reloadIndexPaths, [NSSet setWithArray:@[newPath(0, 0)]]);
    XCTAssertEqual(result.moveSections.count, 0);
}

- (void)test_whenReloadingItem_withSectionDelete_thatDeleteWins {
    IGListBatchUpdateData *result = [[IGListBatchUpdateData alloc] initWithInsertSections:indexSet(@[])
                                                                           deleteSections:indexSet(@[@2])
                                                                             moveSections:[NSSet new]
                                                                         insertIndexPaths:[NSSet new]
                                                                         deleteIndexPaths:[NSSet new]
                                                                         reloadIndexPaths:[NSSet setWithArray:@[newPath(2, 0)]]];
    XCTAssertEqualObjects(result.deleteSections, indexSet(@[@2]));
    XCTAssertEqual(result.reloadIndexPaths.count, 0);
}

- (void)test_whenMovingSections_withItemDeletes_thatResultConvertsConflicts_toDeletesAndInserts {
    IGListBatchUpdateData *result = [[IGListBatchUpdateData alloc] initWithInsertSections:indexSet(@[])
                                                                           deleteSections:indexSet(@[])
                                                                             moveSections:[NSSet setWithArray:@[newMove(2, 4)]]
                                                                         insertIndexPaths:[NSSet new]
                                                                         deleteIndexPaths:[NSSet setWithArray:@[newPath(2, 0), newPath(3, 4)]]
                                                                         reloadIndexPaths:[NSSet new]];
    XCTAssertEqualObjects(result.insertSections, indexSet(@[@4]));
    XCTAssertEqualObjects(result.deleteSections, indexSet(@[@2]));
    XCTAssertEqualObjects(result.deleteIndexPaths, [NSSet setWithArray:@[newPath(3, 4)]]);
    XCTAssertEqual(result.moveSections.count, 0);
}

- (void)test_whenMovingSections_withItemInserts_thatResultConvertsConflicts_toDeletesAndInserts {
    IGListBatchUpdateData *result = [[IGListBatchUpdateData alloc] initWithInsertSections:indexSet(@[])
                                                                           deleteSections:indexSet(@[])
                                                                             moveSections:[NSSet setWithArray:@[newMove(2, 4)]]
                                                                         insertIndexPaths:[NSSet setWithArray:@[newPath(4, 0), newPath(3, 4)]]
                                                                         deleteIndexPaths:[NSSet new]
                                                                         reloadIndexPaths:[NSSet new]];
    XCTAssertEqualObjects(result.insertSections, indexSet(@[@4]));
    XCTAssertEqualObjects(result.deleteSections, indexSet(@[@2]));
    XCTAssertEqualObjects(result.insertIndexPaths, [NSSet setWithArray:@[newPath(3, 4)]]);
    XCTAssertEqual(result.moveSections.count, 0);
}

@end
