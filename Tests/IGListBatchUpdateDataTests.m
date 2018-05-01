/**
 * Copyright (c) 2016-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <XCTest/XCTest.h>

#import <IGListKit/IGListBatchUpdateData.h>
#import "IGListMoveIndexPathInternal.h"

// IGListMoveIndexInternal.h
@interface IGListMoveIndex (Private)
- (instancetype)initWithFrom:(NSInteger)from to:(NSInteger)to;
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

static NSIndexPath *newPath(NSInteger section, NSInteger item) {
    return [NSIndexPath indexPathForItem:item inSection:section];
}

static IGListMoveIndexPath *newMovePath(NSInteger fromSection, NSInteger fromItem, NSInteger toSection, NSInteger toItem) {
    return [[IGListMoveIndexPath alloc] initWithFrom:newPath(fromSection, fromItem) to:newPath(toSection, toItem)];
}

static IGListMoveIndex *newMove(NSInteger from, NSInteger to) {
    return [[IGListMoveIndex alloc] initWithFrom:from to:to];
}

- (void)test_whenEmptyUpdates_thatResultExists {
    IGListBatchUpdateData *result = [[IGListBatchUpdateData alloc] initWithInsertSections:indexSet(@[])
                                                                           deleteSections:indexSet(@[])
                                                                             moveSections:[NSSet new]
                                                                         insertIndexPaths:@[]
                                                                         deleteIndexPaths:@[]
                                                                           moveIndexPaths:@[]];
    XCTAssertNotNil(result);
}

- (void)test_whenUpdatesAreClean_thatResultMatches {
    IGListBatchUpdateData *result = [[IGListBatchUpdateData alloc] initWithInsertSections:indexSet(@[@0, @1])
                                                                           deleteSections:indexSet(@[@5])
                                                                             moveSections:[NSSet setWithArray:@[newMove(3, 4)]]
                                                                         insertIndexPaths:@[newPath(0, 0)]
                                                                         deleteIndexPaths:@[newPath(1, 0)]
                                                                           moveIndexPaths:@[newMovePath(6, 0, 6, 1)]];
    XCTAssertEqualObjects(result.insertSections, indexSet(@[@0, @1]));
    XCTAssertEqualObjects(result.deleteSections, indexSet(@[@5]));
    XCTAssertEqualObjects(result.moveSections, [NSSet setWithArray:@[newMove(3, 4)]]);
    XCTAssertEqualObjects(result.insertIndexPaths, @[newPath(0, 0)]);
    XCTAssertEqualObjects(result.deleteIndexPaths, @[newPath(1, 0)]);
    XCTAssertEqual(result.moveIndexPaths.count, 1);
    XCTAssertEqualObjects(result.moveIndexPaths.firstObject, [[IGListMoveIndexPath alloc] initWithFrom:newPath(6, 0) to:newPath(6, 1)]);
}

- (void)test_whenMovingSections_withItemDeletes_thatResultConvertsConflicts_toDeletesAndInserts {
    IGListBatchUpdateData *result = [[IGListBatchUpdateData alloc] initWithInsertSections:indexSet(@[])
                                                                           deleteSections:indexSet(@[])
                                                                             moveSections:[NSSet setWithArray:@[newMove(2, 4)]]
                                                                         insertIndexPaths:@[]
                                                                         deleteIndexPaths:@[newPath(2, 0), newPath(3, 4)]
                                                                           moveIndexPaths:@[]];
    XCTAssertEqualObjects(result.insertSections, indexSet(@[@4]));
    XCTAssertEqualObjects(result.deleteSections, indexSet(@[@2]));
    XCTAssertEqualObjects(result.deleteIndexPaths, @[newPath(3, 4)]);
    XCTAssertEqual(result.moveSections.count, 0);
}

- (void)test_whenMovingSections_withItemInserts_thatResultConvertsConflicts_toDeletesAndInserts {
    IGListBatchUpdateData *result = [[IGListBatchUpdateData alloc] initWithInsertSections:indexSet(@[])
                                                                           deleteSections:indexSet(@[])
                                                                             moveSections:[NSSet setWithArray:@[newMove(2, 4)]]
                                                                         insertIndexPaths:@[newPath(4, 0), newPath(3, 4)]
                                                                         deleteIndexPaths:@[]
                                                                           moveIndexPaths:@[]];
    XCTAssertEqualObjects(result.insertSections, indexSet(@[@4]));
    XCTAssertEqualObjects(result.deleteSections, indexSet(@[@2]));
    XCTAssertEqualObjects(result.insertIndexPaths, @[newPath(3, 4)]);
    XCTAssertEqual(result.moveSections.count, 0);
}

- (void)test_whenMovingIndexPaths_withSectionDeleted_thatResultDropsTheMove {
    IGListBatchUpdateData *result = [[IGListBatchUpdateData alloc] initWithInsertSections:indexSet(@[])
                                                                           deleteSections:indexSet(@[@0])
                                                                             moveSections:[NSSet new]
                                                                         insertIndexPaths:@[]
                                                                         deleteIndexPaths:@[]
                                                                           moveIndexPaths:@[newMovePath(0, 0, 0, 1)]];
    XCTAssertEqual(result.moveIndexPaths.count, 0);
    XCTAssertEqualObjects(result.deleteSections, indexSet(@[@0]));
}

- (void)test_whenMovingIndexPaths_withSectionMoved_thatResultConvertsToDeletesAndInserts {
    IGListBatchUpdateData *result = [[IGListBatchUpdateData alloc] initWithInsertSections:indexSet(@[])
                                                                           deleteSections:indexSet(@[])
                                                                             moveSections:[NSSet setWithArray:@[newMove(0, 1)]]
                                                                         insertIndexPaths:@[]
                                                                         deleteIndexPaths:@[]
                                                                           moveIndexPaths:@[newMovePath(0, 0, 0, 1)]];
    XCTAssertEqual(result.moveIndexPaths.count, 0);
    XCTAssertEqual(result.moveSections.count, 0);
    XCTAssertEqualObjects(result.deleteSections, indexSet(@[@0]));
    XCTAssertEqualObjects(result.insertSections, indexSet(@[@1]));
}

- (void)test_whenMovingSections_withMoveFromConflictWithDelete_thatResultDropsTheMove {
    IGListBatchUpdateData *result = [[IGListBatchUpdateData alloc] initWithInsertSections:indexSet(@[])
                                                                           deleteSections:indexSet(@[@2])
                                                                             moveSections:[NSSet setWithArray:@[newMove(2, 6), newMove(0, 2)]]
                                                                         insertIndexPaths:@[]
                                                                         deleteIndexPaths:@[]
                                                                           moveIndexPaths:@[]];
    XCTAssertEqual(result.deleteSections.count, 1);
    XCTAssertEqual(result.moveSections.count, 1);
    XCTAssertEqual(result.insertSections.count, 0);
    XCTAssertEqualObjects(result.deleteSections, indexSet(@[@2]));
    XCTAssertEqualObjects(result.moveSections.anyObject, newMove(0, 2));
}

@end
