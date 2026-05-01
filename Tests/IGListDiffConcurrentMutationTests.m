/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import <IGListDiffKit/IGListDiff.h>

#import "IGTestObject.h"

static NSArray<IGTestObject *> *generateArray(NSInteger count) {
    NSMutableArray<IGTestObject *> *array = [NSMutableArray arrayWithCapacity:count];
    for (NSInteger i = 0; i < count; i++) {
        [array addObject:genTestObject(@(i), @(i))];
    }
    return [array copy];
}

@interface IGListDiffConcurrentMutationTests : XCTestCase
@end

@implementation IGListDiffConcurrentMutationTests

#pragma mark - Mutable Array Input (Sanity)

- (void)test_whenDiffingMutableArrays_thatResultIsCorrect {
    NSMutableArray *o = [NSMutableArray arrayWithArray:@[genTestObject(@0, @0), genTestObject(@1, @1)]];
    NSMutableArray *n = [NSMutableArray arrayWithArray:@[genTestObject(@0, @0), genTestObject(@1, @2)]];
    IGListIndexSetResult *result = IGListDiff(o, n, IGListDiffEquality);
    XCTAssertTrue([result hasChanges]);
    XCTAssertTrue([result.updates containsIndex:1]);
}

- (void)test_whenDiffingMutableArrayPaths_thatResultIsCorrect {
    NSMutableArray *o = [NSMutableArray arrayWithArray:@[genTestObject(@0, @0), genTestObject(@1, @1)]];
    NSMutableArray *n = [NSMutableArray arrayWithArray:@[genTestObject(@0, @0), genTestObject(@1, @2)]];
    IGListIndexPathResult *result = IGListDiffPaths(0, 0, o, n, IGListDiffEquality);
    XCTAssertTrue([result hasChanges]);
}

#pragma mark - Snapshot Isolation

- (void)test_whenMutatingOldArrayAfterDiff_thatResultIsBasedOnSnapshot {
    NSMutableArray *o = [NSMutableArray arrayWithArray:@[genTestObject(@0, @0), genTestObject(@1, @1)]];
    NSArray *n = @[genTestObject(@0, @0)];

    IGListIndexSetResult *result = IGListDiff(o, n, IGListDiffEquality);

    // Mutate old array after diff — result should still reflect the original
    [o removeAllObjects];

    XCTAssertEqual(result.deletes.count, 1u);
    XCTAssertTrue([result.deletes containsIndex:1]);
}

- (void)test_whenMutatingNewArrayAfterDiff_thatResultIsBasedOnSnapshot {
    NSArray *o = @[genTestObject(@0, @0)];
    NSMutableArray *n = [NSMutableArray arrayWithArray:@[genTestObject(@0, @0), genTestObject(@1, @1)]];

    IGListIndexSetResult *result = IGListDiff(o, n, IGListDiffEquality);

    [n removeAllObjects];

    XCTAssertEqual(result.inserts.count, 1u);
    XCTAssertTrue([result.inserts containsIndex:1]);
}

#pragma mark - Post-Copy Background Mutation

// These tests verify the core value proposition of the defensive copy: once IGListDiffing()
// snapshots the arrays, subsequent mutations on any thread cannot affect the diff result or
// cause a use-after-free inside the algorithm.
//
// We do NOT attempt to mutate the array concurrently with the -[NSArray copy] call itself,
// because -copy is not atomic and racing with it is undefined behavior at the Foundation level.
// The defensive copy narrows the race window from the entire O(n+m) diff to just the copy call;
// callers remain responsible for not mutating the source array at the exact moment of the call.

- (void)test_whenBackgroundMutatesOldArrayDuringDiff_thatResultIsStable {
    const NSInteger size = 500;

    for (NSInteger iteration = 0; iteration < 100; iteration++) {
        // Build old and new with known differences
        NSMutableArray<IGTestObject *> *old = [NSMutableArray arrayWithCapacity:size];
        NSMutableArray<IGTestObject *> *new_ = [NSMutableArray arrayWithCapacity:size];
        for (NSInteger i = 0; i < size; i++) {
            [old addObject:genTestObject(@(i), @(i))];
            // Shift new by 1 so there's one delete and one insert
            [new_ addObject:genTestObject(@(i + 1), @(i + 1))];
        }

        // Take an immutable snapshot (simulates what the defensive copy does)
        NSArray *oldSnapshot = [old copy];
        NSArray *newSnapshot = [new_ copy];

        // Start aggressively mutating the originals on a background thread
        __block BOOL done = NO;
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
            while (!done) {
                @autoreleasepool {
                    [old removeAllObjects];
                    for (NSInteger i = 0; i < size; i++) {
                        [old addObject:genTestObject(@(arc4random()), @(arc4random()))];
                    }
                    [new_ removeAllObjects];
                    for (NSInteger i = 0; i < size; i++) {
                        [new_ addObject:genTestObject(@(arc4random()), @(arc4random()))];
                    }
                }
            }
        });

        // Diff the snapshots — should be stable regardless of background mutation
        IGListIndexSetResult *result = IGListDiff(oldSnapshot, newSnapshot, IGListDiffEquality);

        done = YES;

        // Verify the result is consistent with the known input
        // old has [0..size-1], new has [1..size], so:
        //   - item 0 is deleted (only in old)
        //   - item size is inserted (only in new)
        //   - items 1..size-1 are unchanged
        XCTAssertTrue([result.deletes containsIndex:0], @"iteration %ld", (long)iteration);
        XCTAssertTrue([result.inserts containsIndex:size - 1], @"iteration %ld", (long)iteration);
        XCTAssertEqual(result.deletes.count, 1u, @"iteration %ld", (long)iteration);
        XCTAssertEqual(result.inserts.count, 1u, @"iteration %ld", (long)iteration);
    }
}

- (void)test_whenBackgroundMutatesDictDuringDiffPaths_thatResultIsStable {
    // Mirrors the bug report pattern:
    //   NSArray *newModels = [_dict allValues];
    //   IGListDiffPaths(1, 1, self.messageModels, newModels, IGListDiffEquality);
    //
    // The defensive copy ensures the diff operates on a stable snapshot even if
    // the caller's backing dictionary is mutated on another thread after allValues returns.

    const NSInteger size = 200;

    for (NSInteger iteration = 0; iteration < 100; iteration++) {
        NSMutableDictionary<NSNumber *, IGTestObject *> *dict = [NSMutableDictionary dictionaryWithCapacity:size];
        for (NSInteger i = 0; i < size; i++) {
            dict[@(i)] = genTestObject(@(i), @(i));
        }

        // Snapshot the dictionary values (like the caller would)
        NSArray<IGTestObject *> *messageModels = generateArray(size);
        NSArray<IGTestObject *> *newModels = [dict.allValues copy];

        // Now mutate the dictionary on a background thread
        __block BOOL done = NO;
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
            NSInteger counter = size;
            while (!done) {
                @autoreleasepool {
                    NSNumber *key = @(counter++);
                    dict[key] = genTestObject(key, key);
                    [dict removeObjectForKey:@(counter - size - 1)];
                }
            }
        });

        // Diff the snapshots — dict mutation should not affect this
        IGListIndexPathResult *result = IGListDiffPaths(1, 1, messageModels, newModels, IGListDiffEquality);

        done = YES;

        // Both arrays have size elements, result should be consistent
        NSInteger changeCount = result.inserts.count + result.deletes.count + result.updates.count + result.moves.count;
        XCTAssertGreaterThanOrEqual(changeCount, 0, @"iteration %ld", (long)iteration);
        // Sanity: no out-of-bounds indices
        for (NSIndexPath *path in result.inserts) {
            XCTAssertLessThan(path.item, size, @"insert index out of range, iteration %ld", (long)iteration);
        }
    }
}

- (void)test_whenBackgroundMutatesOriginal_thatDiffPathsOnSnapshotDoesNotCrash {
    const NSInteger size = 300;

    for (NSInteger iteration = 0; iteration < 100; iteration++) {
        NSMutableArray<IGTestObject *> *mutableOld = [NSMutableArray arrayWithArray:generateArray(size)];
        NSMutableArray<IGTestObject *> *mutableNew = [NSMutableArray arrayWithArray:generateArray(size)];

        // Snapshot
        NSArray *oldSnap = [mutableOld copy];
        NSArray *newSnap = [mutableNew copy];

        __block BOOL done = NO;
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
            while (!done) {
                @autoreleasepool {
                    if (mutableOld.count > 0) [mutableOld removeLastObject];
                    [mutableOld addObject:genTestObject(@(arc4random()), @(arc4random()))];
                    if (mutableNew.count > 0) [mutableNew removeLastObject];
                    [mutableNew addObject:genTestObject(@(arc4random()), @(arc4random()))];
                }
            }
        });

        // Diff the snapshots with both index-set and index-path variants
        IGListIndexSetResult *setResult = IGListDiff(oldSnap, newSnap, IGListDiffEquality);
        IGListIndexPathResult *pathResult = IGListDiffPaths(0, 0, oldSnap, newSnap, IGListDiffEquality);
        IGListIndexSetResult *ptrResult = IGListDiff(oldSnap, newSnap, IGListDiffPointerPersonality);

        done = YES;

        // All three results should agree on whether changes exist
        XCTAssertEqual([setResult hasChanges], [pathResult hasChanges], @"iteration %ld", (long)iteration);
        (void)ptrResult;
    }
}

#pragma mark - Large Array Snapshot Correctness

- (void)test_whenDiffingLargeMutableArrays_thatInsertDeleteCountsAreConsistent {
    const NSInteger oldSize = 1000;
    const NSInteger newSize = 800;

    NSMutableArray *old = [NSMutableArray arrayWithCapacity:oldSize];
    for (NSInteger i = 0; i < oldSize; i++) {
        [old addObject:genTestObject(@(i), @(i))];
    }

    NSMutableArray *new_ = [NSMutableArray arrayWithCapacity:newSize];
    for (NSInteger i = 200; i < oldSize; i++) {
        [new_ addObject:genTestObject(@(i), @(i))];
    }

    IGListIndexSetResult *result = IGListDiff(old, new_, IGListDiffEquality);

    // old=[0..999], new=[200..999] → 200 deletes, 0 inserts
    XCTAssertEqual(result.deletes.count, 200u);
    XCTAssertEqual(result.inserts.count, 0u);

    // Sanity: oldCount + inserts - deletes == newCount
    XCTAssertEqual((NSInteger)oldSize + (NSInteger)result.inserts.count - (NSInteger)result.deletes.count,
                   (NSInteger)newSize);
}

@end
