/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <XCTest/XCTest.h>

#import <IGListDiffKit/IGListDiff.h>
#import <IGListDiffKit/IGListBatchUpdateData.h>

#import "IGListMoveIndexInternal.h"
#import "IGListMoveIndexPathInternal.h"
#import "IGListIndexSetResultInternal.h"
#import "IGListIndexPathResultInternal.h"

@interface IGListDiffDescriptionStringTests : XCTestCase

@end

@implementation IGListDiffDescriptionStringTests

- (void)test_withBatchUpdateData_thatDescriptionStringIsValid {
    NSMutableIndexSet *insertSections = [NSMutableIndexSet indexSet];
    [insertSections addIndex:0];
    [insertSections addIndex:1];
    
    NSIndexSet *deleteSections = [NSIndexSet indexSetWithIndex:5];
    IGListMoveIndex *moveSections = [[IGListMoveIndex alloc] initWithFrom:3 to:4];
    NSIndexPath *insertIndexPaths = [NSIndexPath indexPathForItem:0 inSection:0];
    NSIndexPath *deleteIndexPaths = [NSIndexPath indexPathForItem:0 inSection:0];
    IGListMoveIndexPath *moveIndexPaths = [[IGListMoveIndexPath alloc] initWithFrom:[NSIndexPath indexPathForItem:0 inSection:6]
                                                                                 to:[NSIndexPath indexPathForItem:1 inSection:6]];
    
    IGListBatchUpdateData *result = [[IGListBatchUpdateData alloc] initWithInsertSections:insertSections
                                                                           deleteSections:deleteSections
                                                                             moveSections:[NSSet setWithObject:moveSections]
                                                                         insertIndexPaths:@[insertIndexPaths]
                                                                         deleteIndexPaths:@[deleteIndexPaths]
                                                                         updateIndexPaths:@[]
                                                                           moveIndexPaths:@[moveIndexPaths]];
    NSString *expectedDescription = [NSString stringWithFormat:@"<IGListBatchUpdateData %p; "
                                                                "deleteSections: 1; "
                                                                "insertSections: 2; "
                                                                "moveSections: 1; "
                                                                "deleteIndexPaths: 1; "
                                                                "insertIndexPaths: 1; "
                                                                "updateIndexPaths: 0>", result];
    XCTAssertTrue([result.description isEqualToString:expectedDescription]);
}

- (void)test_withIndexPathResult_thatDescriptionStringIsValid {
    NSArray *inserts = @[[NSIndexPath indexPathForItem:0 inSection:0]];
    NSArray *deletes = @[
        [NSIndexPath indexPathForItem:0 inSection:1],
        [NSIndexPath indexPathForItem:1 inSection:1]
    ];
    NSArray *updates = @[
        [NSIndexPath indexPathForItem:1 inSection:0]
    ];
    NSArray *moves = @[
        [[IGListMoveIndexPath alloc] initWithFrom:[NSIndexPath indexPathForItem:1 inSection:3]
                                               to:[NSIndexPath indexPathForItem:2 inSection:3]],
        [[IGListMoveIndexPath alloc] initWithFrom:[NSIndexPath indexPathForItem:4 inSection:3]
                                               to:[NSIndexPath indexPathForItem:3 inSection:3]]
    ];
    
    IGListIndexPathResult *result = [[IGListIndexPathResult alloc] initWithInserts:inserts
                                                                           deletes:deletes
                                                                           updates:updates
                                                                             moves:moves
                                                                   oldIndexPathMap:[NSMapTable mapTableWithKeyOptions:0 valueOptions:0]
                                                                   newIndexPathMap:[NSMapTable mapTableWithKeyOptions:0 valueOptions:0]];
    
    NSString *expectedDescription = [NSString stringWithFormat:@"<IGListIndexPathResult %p; "
                                                                "1 inserts; "
                                                                "2 deletes; "
                                                                "1 updates; "
                                                                "2 moves>", result];
    XCTAssertTrue([result.description isEqualToString:expectedDescription]);
}

- (void)test_withIndexSetResult_thatDescriptionStringIsValid {
    NSMutableIndexSet *inserts = [NSMutableIndexSet indexSet];
    [inserts addIndex:0];
    [inserts addIndex:1];
    
    NSMutableIndexSet *deletes = [NSMutableIndexSet indexSet];
    [deletes addIndex:3];
    
    NSMutableIndexSet *updates = [NSMutableIndexSet indexSet];
    [updates addIndex:4];
    [updates addIndex:5];
    [updates addIndex:6];
    
    NSArray *moves = @[
        [[IGListMoveIndex alloc] initWithFrom:9 to:10],
        [[IGListMoveIndex alloc] initWithFrom:11 to:12]
    ];
    
    IGListIndexSetResult *result = [[IGListIndexSetResult alloc] initWithInserts:inserts
                                                                         deletes:deletes
                                                                         updates:updates
                                                                           moves:moves
                                                                     oldIndexMap:[NSMapTable mapTableWithKeyOptions:0 valueOptions:0]
                                                                     newIndexMap:[NSMapTable mapTableWithKeyOptions:0 valueOptions:0]];

    NSString *expectedDescription = [NSString stringWithFormat:@"<IGListIndexSetResult %p; "
                                                                "2 inserts; "
                                                                "1 deletes; "
                                                                "3 updates; "
                                                                "2 moves>", result];
    XCTAssertTrue([result.description isEqualToString:expectedDescription]);
}

- (void)test_withMoveIndex_thatDescriptionStringIsValid {
    IGListMoveIndex *moveIndex = [[IGListMoveIndex alloc] initWithFrom:3 to:4];

    NSString *expectedDescription = [NSString stringWithFormat:@"<IGListMoveIndex %p; "
                                                                "from: 3; "
                                                                "to: 4;>", moveIndex];
    XCTAssertTrue([moveIndex.description isEqualToString:expectedDescription]);
}

- (void)test_withMoveIndexPath_thatDescriptionStringIsValid {
    NSIndexPath *from = [NSIndexPath indexPathForItem:1 inSection:1];
    NSIndexPath *to = [NSIndexPath indexPathForItem:3 inSection:1];
    IGListMoveIndexPath *moveIndexPath = [[IGListMoveIndexPath alloc] initWithFrom:from to:to];

    NSString *expectedDescription = [NSString stringWithFormat:@"<IGListMoveIndexPath %p; "
                                                                 "from: <NSIndexPath: %p> {length = 2, path = 1 - 1}; "
                                                                 "to: <NSIndexPath: %p> {length = 2, path = 1 - 3};>",
                                     moveIndexPath, from, to];
    XCTAssertTrue([moveIndexPath.description isEqualToString:expectedDescription]);
}

@end
