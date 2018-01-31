/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant 
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "IGListDiffTests.h"

#import <XCTest/XCTest.h>
#import <Foundation/Foundation.h>

#import <IGListKit/IGListDiff.h>
#import <IGListKit/IGListExperiments.h>
#import "IGListIndexSetResultInternal.h"
#import "IGListMoveIndexInternal.h"
#import "IGListMoveIndexPathInternal.h"

#import "IGTestObject.h"

#define genIndexPath(i, s) [NSIndexPath indexPathForItem:i inSection:s]

#define IGAssertContains(collection, object) do {\
    id haystack = collection; id needle = object; \
    XCTAssertTrue([haystack containsObject:needle], @"%@ does not contain %@", haystack, needle); \
    } while(0)


static NSIndexSet *indexSetWithIndexes(NSArray *indexes) {
    NSMutableIndexSet *indexset = [NSMutableIndexSet new];
    for (NSNumber *i in indexes) {
        [indexset addIndex:i.integerValue];
    }
    return indexset;
}

static NSArray *sorted(NSArray *arr) {
    return [arr sortedArrayUsingSelector:@selector(compare:)];
}

@implementation IGListDiffTests

- (void)test_whenDiffingEmptyArrays_thatResultHasNoChanges {
    NSArray *o = @[];
    NSArray *n = @[];
    IGListIndexSetResult *result = IGListDiff(o, n, IGListDiffEquality);
    XCTAssertFalse([result hasChanges]);
}

- (void)test_whenDiffingFromEmptyArray_thatResultHasChanges {
    NSArray *o = @[];
    NSArray *n = @[@1];
    IGListIndexSetResult *result = IGListDiff(o, n, IGListDiffEquality);
    XCTAssertEqualObjects(result.inserts, [NSIndexSet indexSetWithIndex:0]);
    XCTAssertEqual([result changeCount], 1);
}

- (void)test_whenDiffingToEmptyArray_thatResultHasChanges {
    NSArray *o = @[@1];
    NSArray *n = @[];
    IGListIndexSetResult *result = IGListDiff(o, n, IGListDiffEquality);
    XCTAssertEqualObjects(result.deletes, [NSIndexSet indexSetWithIndex:0]);
    XCTAssertEqual([result changeCount], 1);
}

- (void)test_whenSwappingObjects_thatResultHasMoves {
    NSArray *o = @[@1, @2];
    NSArray *n = @[@2, @1];
    IGListIndexSetResult *result = IGListDiff(o, n, IGListDiffEquality);
    NSArray *expected = @[
                          [[IGListMoveIndex alloc] initWithFrom:0 to:1],
                          [[IGListMoveIndex alloc] initWithFrom:1 to:0],
                          ];
    NSArray<IGListMoveIndexPath *> *sortedMoves = sorted(result.moves);
    XCTAssertEqualObjects(sortedMoves, expected);
    XCTAssertEqual([result changeCount], 2);
}

- (void)test_whenMovingObjectsTogether_thatResultHasMoves {
    // "trick" is having multiple @3s
    NSArray *o = @[@1, @2, @3, @3, @4];
    NSArray *n = @[@2, @3, @1, @3, @4];
    IGListIndexSetResult *result = IGListDiff(o, n, IGListDiffEquality);
    IGAssertContains(result.moves, [[IGListMoveIndex alloc] initWithFrom:1 to:0]);
    IGAssertContains(result.moves, [[IGListMoveIndex alloc] initWithFrom:0 to:2]);
}

- (void)test_whenDiffingWordsFromPaper_withIndexPaths_thatDeletesMatchPaper {
    // http://dl.acm.org/citation.cfm?id=359467&dl=ACM&coll=DL&CFID=529464736&CFTOKEN=43088172
    NSString *oString = @"much writing is like snow , a mass of long words and phrases falls upon the relevant facts covering up the details .";
    NSString *nString = @"a mass of latin words falls upon the relevant facts like soft snow , covering up the details .";
    NSArray *o = [oString componentsSeparatedByString:@" "];
    NSArray *n = [nString componentsSeparatedByString:@" "];
    IGListIndexPathResult *result = IGListDiffPaths(0, 0, o, n, IGListDiffEquality);
    NSArray *expected = @[genIndexPath(0, 0), genIndexPath(1, 0), genIndexPath(2, 0), genIndexPath(9, 0), genIndexPath(11, 0), genIndexPath(12, 0)];
    XCTAssertEqualObjects(result.deletes, expected);
}

- (void)test_whenDiffingWordsFromPaper_withIndexPaths_thatInsertsMatchPaper {
    // http://dl.acm.org/citation.cfm?id=359467&dl=ACM&coll=DL&CFID=529464736&CFTOKEN=43088172
    NSString *oString = @"much writing is like snow , a mass of long words and phrases falls upon the relevant facts covering up the details .";
    NSString *nString = @"a mass of latin words falls upon the relevant facts like soft snow , covering up the details .";
    NSArray *o = [oString componentsSeparatedByString:@" "];
    NSArray *n = [nString componentsSeparatedByString:@" "];
    IGListIndexPathResult *result = IGListDiffPaths(0, 0, o, n, IGListDiffEquality);
    NSArray *expected = @[genIndexPath(3, 0), genIndexPath(11, 0)];
    XCTAssertEqualObjects(result.inserts, expected);
}

- (void)test_whenSwappingObjects_withIndexPaths_thatResultHasMoves {
    NSArray *o = @[@1, @2, @3, @4];
    NSArray *n = @[@2, @4, @5, @3];
    IGListIndexPathResult *result = IGListDiffPaths(0, 0, o, n, IGListDiffEquality);
    NSArray *expected = @[
                          [[IGListMoveIndexPath alloc] initWithFrom:genIndexPath(2, 0) to:genIndexPath(3, 0)],
                          [[IGListMoveIndexPath alloc] initWithFrom:genIndexPath(3, 0) to:genIndexPath(1, 0)],
                          ];
    NSArray<IGListMoveIndexPath *> *sortedMoves = sorted(result.moves);
    XCTAssertEqualObjects(sortedMoves, expected);
}

- (void)test_whenObjectEqualityChanges_thatResultHasUpdates {
    NSArray *o = @[
                   genTestObject(@"0", @0),
                   genTestObject(@"1", @1),
                   genTestObject(@"2", @2),
                   ];
    NSArray *n = @[
                   genTestObject(@"0", @0),
                   genTestObject(@"1", @3), // value updated from @1 to @3
                   genTestObject(@"2", @2),
                   ];
    IGListIndexPathResult *result = IGListDiffPaths(0, 0, o, n, IGListDiffEquality);
    NSArray *expected = @[genIndexPath(1, 0)];
    XCTAssertEqualObjects(result.updates, expected);
}

- (void)test_whenDiffingWordsFromPaper_thatInsertsMatchPaper {
    // http://dl.acm.org/citation.cfm?id=359467&dl=ACM&coll=DL&CFID=529464736&CFTOKEN=43088172
    NSString *oString = @"much writing is like snow , a mass of long words and phrases falls upon the relevant facts covering up the details .";
    NSString *nString = @"a mass of latin words falls upon the relevant facts like soft snow , covering up the details .";
    NSArray *o = [oString componentsSeparatedByString:@" "];
    NSArray *n = [nString componentsSeparatedByString:@" "];
    IGListIndexSetResult *result = IGListDiff(o, n, IGListDiffEquality);
    NSIndexSet *expectedInserts = indexSetWithIndexes(@[@3, @11]);
    XCTAssertEqualObjects(result.inserts, expectedInserts);
}

- (void)test_whenDiffingWordsFromPaper_thatDeletesMatchPaper {
    // http://dl.acm.org/citation.cfm?id=359467&dl=ACM&coll=DL&CFID=529464736&CFTOKEN=43088172
    NSString *oString = @"much writing is like snow , a mass of long words and phrases falls upon the relevant facts covering up the details .";
    NSString *nString = @"a mass of latin words falls upon the relevant facts like soft snow , covering up the details .";
    NSArray *o = [oString componentsSeparatedByString:@" "];
    NSArray *n = [nString componentsSeparatedByString:@" "];
    IGListIndexSetResult *result = IGListDiff(o, n, IGListDiffEquality);
    NSIndexSet *expectedDeletes = indexSetWithIndexes(@[@0, @1, @2, @9, @11, @12]);
    XCTAssertEqualObjects(result.deletes, expectedDeletes);
}

- (void)test_whenDeletingItems_withInserts_withMoves_thatResultHasInsertsMovesAndDeletes {
    NSArray *o = @[@0, @1, @2, @3, @4, @5, @6, @7, @8];
    NSArray *n = @[@0, @2, @3, @4, @7, @6, @9, @5, @10];
    IGListIndexSetResult *result = IGListDiff(o, n, IGListDiffEquality);
    NSIndexSet *expectedDeletes = indexSetWithIndexes(@[@1, @8]);
    NSIndexSet *expectedInserts = indexSetWithIndexes(@[@6, @8]);
    NSArray *expectedMoves = @[
                               [[IGListMoveIndex alloc] initWithFrom:5 to:7],
                               [[IGListMoveIndex alloc] initWithFrom:7 to:4],
                               ];
    NSArray<IGListMoveIndexPath *> *sortedMoves = sorted(result.moves);
    XCTAssertEqualObjects(result.deletes, expectedDeletes);
    XCTAssertEqualObjects(result.inserts, expectedInserts);
    XCTAssertEqualObjects(sortedMoves, expectedMoves);
}

- (void)test_whenMovingItems_withEqualityChanges_thatResultsHasMovesAndUpdates {
    NSArray *o = @[
                   genTestObject(@"0", @0),
                   genTestObject(@"1", @1),
                   genTestObject(@"2", @2),
                   ];

    // objects 0 and 2 are swapped and object at original index 2 has its data changed to @3
    NSArray *n = @[
                   genTestObject(@"2", @3),
                   genTestObject(@"1", @1),
                   genTestObject(@"0", @0),
                   ];

    IGListIndexSetResult *result = IGListDiff(o, n, IGListDiffEquality);
    NSArray *expectedMoves = @[
                               [[IGListMoveIndex alloc] initWithFrom:0 to:2],
                               [[IGListMoveIndex alloc] initWithFrom:2 to:0],
                               ];
    NSIndexSet *expectedUpdates = [NSIndexSet indexSetWithIndex:2];
    NSArray<IGListMoveIndexPath *> *sortedMoves = sorted(result.moves);
    XCTAssertEqualObjects(result.updates, expectedUpdates);
    XCTAssertEqualObjects(sortedMoves, expectedMoves);
}

- (void)test_whenDiffingPointers_withObjectCopy_thatResultHasUpdate {
    NSArray *o = @[
                   genTestObject(@"0", @0),
                   genTestObject(@"1", @1),
                   genTestObject(@"2", @2),
                   ];
    NSArray *n = @[
                   o[0],
                   [o[1] copy], // new pointer
                   o[2],
                   ];
    IGListIndexPathResult *result = IGListDiffPaths(0, 0, o, n, IGListDiffPointerPersonality);
    NSArray *expected = @[genIndexPath(1, 0)];
    XCTAssertEqualObjects(result.updates, expected);
}

- (void)test_whenDiffingPointers_withSameObjects_thatResultHasNoChanges {
    NSArray *o = @[
                   genTestObject(@"0", @0),
                   genTestObject(@"1", @1),
                   genTestObject(@"2", @2),
                   ];
    NSArray *n = [o copy];
    IGListIndexPathResult *result = IGListDiffPaths(0, 0, o, n, IGListDiffPointerPersonality);
    XCTAssertFalse([result hasChanges]);
}

- (void)test_whenDeletingObjects_withArrayOfEqualObjects_thatChangeCountMatches {
    NSArray *o = @[@"dog", @"dog", @"dog", @"dog"];
    NSArray *n = @[@"dog", @"dog"];
    IGListIndexSetResult *result = IGListDiff(o, n, IGListDiffEquality);
    // there is a "flaw" in the algorithm that cannot detect bulk ops when they are all the same object
    // confirm that the results are at least correct
    XCTAssertEqual(o.count + result.inserts.count - result.deletes.count, 2);
}

- (void)test_whenInsertingObjects_withArrayOfEqualObjects_thatChangeCountMatches {
    NSArray *o = @[@"dog", @"dog"];
    NSArray *n = @[@"dog", @"dog", @"dog", @"dog"];
    IGListIndexSetResult *result = IGListDiff(o, n, IGListDiffEquality);
    // there is a "flaw" in the algorithm that cannot detect bulk ops when they are all the same object
    // confirm that the results are at least correct
    XCTAssertEqual(o.count + result.inserts.count - result.deletes.count, 4);
}

- (void)test_whenInsertingObject_withOldArrayHavingMultiples_thatChangeCountMatches {
    NSArray *o = @[@(NSNotFound), @(NSNotFound), @(NSNotFound), @49, @33, @"cat", @"cat", @0, @14];
    NSMutableArray *n = [o mutableCopy];
    [n insertObject:@"cat" atIndex:5]; // 3 cats in a row
    IGListIndexSetResult *result = IGListDiff(o, n, IGListDiffEquality);
    XCTAssertEqual(o.count + result.inserts.count - result.deletes.count, 10);
}

- (void)test_whenMovingDuplicateObjects_thatChangeCountMatches {
    NSArray *o = @[@1, @20, @14, @(NSNotFound), @"cat", @(NSNotFound), @4, @"dog", @"cat", @"cat", @"fish", @(NSNotFound), @"fish", @(NSNotFound)];
    NSArray *n = @[@1, @28, @14, @"cat", @"cat", @4, @"dog", o[3], @"cat", @"fish", o[11], @"fish", o[13]];
    IGListIndexSetResult *result = IGListDiff(o, n, IGListDiffEquality);
    XCTAssertEqual(o.count + result.inserts.count - result.deletes.count, n.count);
}

- (void)test_whenDiffingDuplicatesAtTail_withDuplicateAtHead_thatResultHasNoChanges {
    NSArray *o = @[@"cat", @1, @2, @3, @"cat"];
    NSArray *n = @[@"cat", @1, @2, @3, @"cat"];
    IGListIndexSetResult *result = IGListDiff(o, n, IGListDiffEquality);
    XCTAssertFalse([result hasChanges]);
}

- (void)test_whenDuplicateObjects_thatMovesAreUnique {
    NSArray *o = @[@"cat", @(NSNotFound), @"dog", @"dog", @(NSNotFound), @(NSNotFound), @"cat", @65];
    NSArray *n = @[@"cat", o[1], @"dog", o[4], @"dog", o[5], @"cat", @"cat", @"fish", @65];
    IGListIndexSetResult *result = IGListDiff(o, n, IGListDiffEquality);
    XCTAssertEqual([[NSSet setWithArray:[[result moves] valueForKeyPath:@"from"]] count], [result.moves count]);
}

- (void)test_whenMovingObjectShiftsOthers_thatMovesContainRequiredMoves {
    NSArray *o = @[@1, @2, @3, @4, @5, @6, @7];
    NSArray *n = @[@1, @4, @5, @2, @3, @6, @7];
    IGListIndexSetResult *result = IGListDiff(o, n, IGListDiffEquality);
    IGAssertContains(result.moves, [[IGListMoveIndex alloc] initWithFrom:3 to:1]);
    IGAssertContains(result.moves, [[IGListMoveIndex alloc] initWithFrom:1 to:3]);
}

- (void)test_whenDiffing_thatOldIndexesMatch {
    NSArray *o = @[@1, @2, @3, @4, @5, @6, @7];
    NSArray *n = @[@2, @9, @3, @1, @5, @6, @8];
    IGListIndexSetResult *result = IGListDiff(o, n, IGListDiffEquality);
    XCTAssertEqual([result oldIndexForIdentifier:@1], 0);
    XCTAssertEqual([result oldIndexForIdentifier:@2], 1);
    XCTAssertEqual([result oldIndexForIdentifier:@3], 2);
    XCTAssertEqual([result oldIndexForIdentifier:@4], 3);
    XCTAssertEqual([result oldIndexForIdentifier:@5], 4);
    XCTAssertEqual([result oldIndexForIdentifier:@6], 5);
    XCTAssertEqual([result oldIndexForIdentifier:@7], 6);
    XCTAssertEqual([result oldIndexForIdentifier:@8], NSNotFound);
    XCTAssertEqual([result oldIndexForIdentifier:@9], NSNotFound);
}

- (void)test_whenDiffing_thatNewIndexesMatch {
    NSArray *o = @[@1, @2, @3, @4, @5, @6, @7];
    NSArray *n = @[@2, @9, @3, @1, @5, @6, @8];
    IGListIndexSetResult *result = IGListDiff(o, n, IGListDiffEquality);
    XCTAssertEqual([result newIndexForIdentifier:@1], 3);
    XCTAssertEqual([result newIndexForIdentifier:@2], 0);
    XCTAssertEqual([result newIndexForIdentifier:@3], 2);
    XCTAssertEqual([result newIndexForIdentifier:@4], NSNotFound);
    XCTAssertEqual([result newIndexForIdentifier:@5], 4);
    XCTAssertEqual([result newIndexForIdentifier:@6], 5);
    XCTAssertEqual([result newIndexForIdentifier:@7], NSNotFound);
    XCTAssertEqual([result newIndexForIdentifier:@8], 6);
    XCTAssertEqual([result newIndexForIdentifier:@9], 1);
}

- (void)test_whenDiffing_thatOldIndexPathsMatch {
    NSArray *o = @[@1, @2, @3, @4, @5, @6, @7];
    NSArray *n = @[@2, @9, @3, @1, @5, @6, @8];
    IGListIndexPathResult *result = IGListDiffPaths(0, 1, o, n, IGListDiffEquality);
    XCTAssertEqualObjects([result oldIndexPathForIdentifier:@1], [NSIndexPath indexPathForItem:0 inSection:0]);
    XCTAssertEqualObjects([result oldIndexPathForIdentifier:@2], [NSIndexPath indexPathForItem:1 inSection:0]);
    XCTAssertEqualObjects([result oldIndexPathForIdentifier:@3], [NSIndexPath indexPathForItem:2 inSection:0]);
    XCTAssertEqualObjects([result oldIndexPathForIdentifier:@4], [NSIndexPath indexPathForItem:3 inSection:0]);
    XCTAssertEqualObjects([result oldIndexPathForIdentifier:@5], [NSIndexPath indexPathForItem:4 inSection:0]);
    XCTAssertEqualObjects([result oldIndexPathForIdentifier:@6], [NSIndexPath indexPathForItem:5 inSection:0]);
    XCTAssertEqualObjects([result oldIndexPathForIdentifier:@7], [NSIndexPath indexPathForItem:6 inSection:0]);
    XCTAssertNil([result oldIndexPathForIdentifier:@8]);
    XCTAssertNil([result oldIndexPathForIdentifier:@9]);
}

- (void)test_whenDiffing_thatNewIndexPathsMatch {
    NSArray *o = @[@1, @2, @3, @4, @5, @6, @7];
    NSArray *n = @[@2, @9, @3, @1, @5, @6, @8];
    IGListIndexPathResult *result = IGListDiffPaths(0, 1, o, n, IGListDiffEquality);
    XCTAssertEqualObjects([result newIndexPathForIdentifier:@1], [NSIndexPath indexPathForItem:3 inSection:1]);
    XCTAssertEqualObjects([result newIndexPathForIdentifier:@2], [NSIndexPath indexPathForItem:0 inSection:1]);
    XCTAssertEqualObjects([result newIndexPathForIdentifier:@3], [NSIndexPath indexPathForItem:2 inSection:1]);
    XCTAssertNil([result newIndexPathForIdentifier:@4]);
    XCTAssertEqualObjects([result newIndexPathForIdentifier:@5], [NSIndexPath indexPathForItem:4 inSection:1]);
    XCTAssertEqualObjects([result newIndexPathForIdentifier:@6], [NSIndexPath indexPathForItem:5 inSection:1]);
    XCTAssertNil([result newIndexPathForIdentifier:@7]);
    XCTAssertEqualObjects([result newIndexPathForIdentifier:@8], [NSIndexPath indexPathForItem:6 inSection:1]);
    XCTAssertEqualObjects([result newIndexPathForIdentifier:@9], [NSIndexPath indexPathForItem:1 inSection:1]);
}

- (void)test_whenDiffing_withBatchUpdateResult_thatIndexesMatch {
    NSArray *o = @[
                   genTestObject(@1, @1),
                   genTestObject(@2, @1),
                   genTestObject(@3, @1),
                   genTestObject(@4, @1),
                   genTestObject(@5, @1),
                   genTestObject(@6, @1),
                   ];
    NSArray *n = @[
                   // deleted
                   genTestObject(@2, @2), // updated
                   genTestObject(@5, @1), // moved
                   genTestObject(@4, @1),
                   genTestObject(@7, @1), // inserted
                   genTestObject(@6, @2), // updated
                   genTestObject(@3, @2), // moved+updated
                   ];
    IGListIndexSetResult *result = [IGListDiff(o, n, IGListDiffEquality) resultForBatchUpdates];
    XCTAssertEqual(result.updates.count, 0);
    NSArray *expectedMoves = @[ [[IGListMoveIndex alloc] initWithFrom:4 to:1] ];
    XCTAssertEqualObjects(result.moves, expectedMoves);
    NSMutableIndexSet *expectedDeletes = [NSMutableIndexSet indexSetWithIndex:0];
    [expectedDeletes addIndex:1];
    [expectedDeletes addIndex:2];
    [expectedDeletes addIndex:5];
    XCTAssertEqualObjects(result.deletes, expectedDeletes);
    NSMutableIndexSet *expectedInserts = [NSMutableIndexSet indexSetWithIndex:0];
    [expectedInserts addIndex:3];
    [expectedInserts addIndex:4];
    [expectedInserts addIndex:5];
    XCTAssertEqualObjects(result.inserts, expectedInserts);
}

- (void)test_whenDiffing_withBatchUpdateResult_thatIndexPathsMatch {
    NSArray *o = @[
                   genTestObject(@1, @1),
                   genTestObject(@2, @1),
                   genTestObject(@3, @1),
                   genTestObject(@4, @1),
                   genTestObject(@5, @1),
                   genTestObject(@6, @1),
                   ];
    NSArray *n = @[
                   // deleted
                   genTestObject(@2, @2), // updated
                   genTestObject(@5, @1), // moved
                   genTestObject(@4, @1),
                   genTestObject(@7, @1), // inserted
                   genTestObject(@6, @2), // updated
                   genTestObject(@3, @2), // moved+updated
                   ];
    IGListIndexPathResult *result = [IGListDiffPaths(0, 1, o, n, IGListDiffEquality) resultForBatchUpdates];
    XCTAssertEqual(result.updates.count, 0);
    NSArray *expectedMoves = @[ [[IGListMoveIndexPath alloc] initWithFrom:genIndexPath(4, 0) to:genIndexPath(1, 1)] ];
    XCTAssertEqualObjects(result.moves, expectedMoves);
    NSArray *expectedDeletes = @[genIndexPath(0, 0), genIndexPath(1, 0), genIndexPath(2, 0), genIndexPath(5, 0)];
    XCTAssertEqualObjects(sorted(result.deletes), expectedDeletes);
    NSArray *expectedInserts = @[genIndexPath(0, 1), genIndexPath(3, 1), genIndexPath(4, 1), genIndexPath(5, 1)];
    XCTAssertEqualObjects(sorted(result.inserts), expectedInserts);
}

@end
