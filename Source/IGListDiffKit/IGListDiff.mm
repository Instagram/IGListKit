/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGListDiff.h"

#import <stack>
#import <unordered_map>
#import <vector>

#import <IGListDiffKit/IGListCompatibility.h>
#import <IGListDiffKit/IGListExperiments.h>

#import "IGListIndexPathResultInternal.h"
#import "IGListIndexSetResultInternal.h"
#import "IGListMoveIndexInternal.h"
#import "IGListMoveIndexPathInternal.h"

using namespace std;

/// Used to track data stats while diffing.
struct IGListEntry {
    /// The number of times the data occurs in the old array
    NSInteger oldCounter = 0;
    /// The number of times the data occurs in the new array
    NSInteger newCounter = 0;
    /// The indexes of the data in the old array
    stack<NSInteger> oldIndexes;
    /// Flag marking if the data has been updated between arrays by checking the isEqual: method
    BOOL updated = NO;
};

/// Track both the entry and algorithm index. Default the index to NSNotFound
struct IGListRecord {
    IGListEntry *entry;
    mutable NSInteger index;

    IGListRecord() {
        entry = NULL;
        index = NSNotFound;
    }
};

static id<NSObject> IGListTableKey(__unsafe_unretained id<IGListDiffable> object) {
    id<NSObject> key = [object diffIdentifier];
    NSCAssert(key != nil, @"Cannot use a nil key for the diffIdentifier of object %@", object);
    return key;
}

struct IGListEqualID {
    bool operator()(const id a, const id b) const {
        return (a == b) || [a isEqual: b];
    }
};

struct IGListHashID {
    size_t operator()(const id o) const {
        return (size_t)[o hash];
    }
};

static void addIndexToMap(BOOL useIndexPaths, NSInteger section, NSInteger index, __unsafe_unretained id<IGListDiffable> object, __unsafe_unretained NSMapTable *map) {
    id value;
    if (useIndexPaths) {
        value = [NSIndexPath indexPathForItem:index inSection:section];
    } else {
        value = @(index);
    }
    [map setObject:value forKey:[object diffIdentifier]];
}

static void addIndexToCollection(BOOL useIndexPaths, __unsafe_unretained id collection, NSInteger section, NSInteger index) {
    if (useIndexPaths) {
        NSIndexPath *path = [NSIndexPath indexPathForItem:index inSection:section];
        [collection addObject:path];
    } else {
        [collection addIndex:index];
    }
};

static NSArray<NSIndexPath *> *indexPathsAndPopulateMap(__unsafe_unretained NSArray<id<IGListDiffable>> *array, NSInteger section, __unsafe_unretained NSMapTable *map) {
    NSMutableArray<NSIndexPath *> *paths = [NSMutableArray new];
    [array enumerateObjectsUsingBlock:^(id<IGListDiffable> obj, NSUInteger idx, BOOL *stop) {
        NSIndexPath *path = [NSIndexPath indexPathForItem:idx inSection:section];
        [paths addObject:path];
        [map setObject:path forKey:[obj diffIdentifier]];
    }];
    return paths;
}

// Calculates indexes which require no explicit moves based on a longest increasing indexes set using O(n log n) complexity algorithm
static NSIndexSet *autoMovedIndexes(const vector<IGListRecord> &newResultsArray, NSIndexSet *untouchedIndexes)
{
    NSUInteger count = newResultsArray.size();
    vector<NSUInteger> prevIndexes(count);
    vector<NSUInteger> indexes(count + 1);

    NSUInteger length = 0;
    for (NSUInteger i = 0; i < count; i++) {
        // Binary search for the largest positive j ≤ length
        // such that X[M[j]] < X[i]
        NSUInteger lo = 1;
        NSUInteger hi = length;
        NSInteger currentIndex = newResultsArray[i].index;

        NSUInteger nextUntouched = [untouchedIndexes indexGreaterThanIndex:i];

        if (nextUntouched != NSNotFound && currentIndex > nextUntouched) {
            continue;
        }

        NSUInteger prevUntouched = [untouchedIndexes indexLessThanIndex:i];

        if (prevUntouched != NSNotFound && currentIndex < prevUntouched) {
            continue;
        }

        while (lo <= hi) {
            auto mid = lo + (hi - lo) / 2;
            NSInteger prevIndex = newResultsArray[indexes[mid]].index;
            if (prevIndex < currentIndex && (prevUntouched == NSNotFound || prevIndex > prevUntouched)) {
                lo = mid + 1;
            } else {
                hi = mid - 1;
            }
        }

        // After searching, lo is 1 greater than the
        // length of the longest prefix of X[i]
        auto newLength = lo;

        // The predecessor of X[i] is the last index of
        // the subsequence of length newLength-1
        prevIndexes[i] = indexes[newLength - 1];
        indexes[newLength] = i;

        if (newLength > length) {
            // If we found a subsequence longer than any we've
            // found yet, update L
            length = newLength;
        }
    }

    // Reconstruct the longest increasing indexes
    NSMutableIndexSet *result = [NSMutableIndexSet new];
    auto k = indexes[length];
    for (NSUInteger i = 0; i < length; i++) {
        NSUInteger index = newResultsArray[k].index;

        // Ignore inserted entries
        if (index != NSNotFound) {
            [result addIndex:index];
        }
        k = prevIndexes[k];
    }
    return result;
}

class IGListMoveChecker {
public:
    virtual bool isMove(const NSInteger oldIndex,
                        const NSInteger newIndex,
                        const NSInteger insertOffset,
                        const NSInteger deleteOffset) {

        return (oldIndex - deleteOffset + insertOffset) != newIndex;
    }

    virtual ~IGListMoveChecker() {}
};

class IGListOptimalMoveChecker : public IGListMoveChecker
{
    NSIndexSet *_autoMovedIndexes;

public:
    IGListOptimalMoveChecker(const vector<IGListRecord> &newResultsArray, NSIndexSet *untouchedIndexes)
    : _autoMovedIndexes(autoMovedIndexes(newResultsArray, untouchedIndexes))
    {}

    virtual bool isMove(const NSInteger oldIndex,
                        const NSInteger newIndex,
                        const NSInteger insertOffset,
                        const NSInteger deleteOffset) {

        return (oldIndex != newIndex) && ![_autoMovedIndexes containsIndex:oldIndex];
    }
};

static id IGListDiffing(BOOL returnIndexPaths,
                        NSInteger fromSection,
                        NSInteger toSection,
                        NSArray<id<IGListDiffable>> *oldArray,
                        NSArray<id<IGListDiffable>> *newArray,
                        IGListDiffOption option,
                        IGListExperiment experiments) {
    const NSInteger newCount = newArray.count;
    const NSInteger oldCount = oldArray.count;

    NSMapTable *oldMap = [NSMapTable strongToStrongObjectsMapTable];
    NSMapTable *newMap = [NSMapTable strongToStrongObjectsMapTable];

    // if no new objects, everything from the oldArray is deleted
    // take a shortcut and just build a delete-everything result
    if (newCount == 0) {
        if (returnIndexPaths) {
            return [[IGListIndexPathResult alloc] initWithInserts:[NSArray new]
                                                          deletes:indexPathsAndPopulateMap(oldArray, fromSection, oldMap)
                                                          updates:[NSArray new]
                                                            moves:[NSArray new]
                                                  oldIndexPathMap:oldMap
                                                  newIndexPathMap:newMap];
        } else {
            [oldArray enumerateObjectsUsingBlock:^(id<IGListDiffable> obj, NSUInteger idx, BOOL *stop) {
                addIndexToMap(returnIndexPaths, fromSection, idx, obj, oldMap);
            }];
            return [[IGListIndexSetResult alloc] initWithInserts:[NSIndexSet new]
                                                         deletes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, oldCount)]
                                                         updates:[NSIndexSet new]
                                                           moves:[NSArray new]
                                                     oldIndexMap:oldMap
                                                     newIndexMap:newMap];
        }
    }

    // if no old objects, everything from the newArray is inserted
    // take a shortcut and just build an insert-everything result
    if (oldCount == 0) {
        if (returnIndexPaths) {
            return [[IGListIndexPathResult alloc] initWithInserts:indexPathsAndPopulateMap(newArray, toSection, newMap)
                                                          deletes:[NSArray new]
                                                          updates:[NSArray new]
                                                            moves:[NSArray new]
                                                  oldIndexPathMap:oldMap
                                                  newIndexPathMap:newMap];
        } else {
            [newArray enumerateObjectsUsingBlock:^(id<IGListDiffable> obj, NSUInteger idx, BOOL *stop) {
                addIndexToMap(returnIndexPaths, toSection, idx, obj, newMap);
            }];
            return [[IGListIndexSetResult alloc] initWithInserts:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, newCount)]
                                                         deletes:[NSIndexSet new]
                                                         updates:[NSIndexSet new]
                                                           moves:[NSArray new]
                                                     oldIndexMap:oldMap
                                                     newIndexMap:newMap];
        }
    }

    // symbol table uses the old/new array diffIdentifier as the key and IGListEntry as the value
    // using id<NSObject> as the key provided by https://lists.gnu.org/archive/html/discuss-gnustep/2011-07/msg00019.html
    unordered_map<id<NSObject>, IGListEntry, IGListHashID, IGListEqualID> table;

    // pass 1
    // create an entry for every item in the new array
    // increment its new count for each occurence
    vector<IGListRecord> newResultsArray(newCount);
    for (NSInteger i = 0; i < newCount; i++) {
        id<NSObject> key = IGListTableKey(newArray[i]);
        IGListEntry &entry = table[key];
        entry.newCounter++;

        // add NSNotFound for each occurence of the item in the new array
        entry.oldIndexes.push(NSNotFound);

        // note: the entry is just a pointer to the entry which is stack-allocated in the table
        newResultsArray[i].entry = &entry;
    }

    // pass 2
    // update or create an entry for every item in the old array
    // increment its old count for each occurence
    // record the original index of the item in the old array
    // MUST be done in descending order to respect the oldIndexes stack construction
    vector<IGListRecord> oldResultsArray(oldCount);
    for (NSInteger i = oldCount - 1; i >= 0; i--) {
        id<NSObject> key = IGListTableKey(oldArray[i]);
        IGListEntry &entry = table[key];
        entry.oldCounter++;

        // push the original indices where the item occurred onto the index stack
        entry.oldIndexes.push(i);

        // note: the entry is just a pointer to the entry which is stack-allocated in the table
        oldResultsArray[i].entry = &entry;
    }

    // pass 3
    // handle data that occurs in both arrays
    for (NSInteger i = 0; i < newCount; i++) {
        IGListEntry *entry = newResultsArray[i].entry;

        // grab and pop the top original index. if the item was inserted this will be NSNotFound
        NSCAssert(!entry->oldIndexes.empty(), @"Old indexes is empty while iterating new item %li. Should have NSNotFound", (long)i);
        const NSInteger originalIndex = entry->oldIndexes.top();
        entry->oldIndexes.pop();

        if (originalIndex < oldCount) {
            const id<IGListDiffable> n = newArray[i];
            const id<IGListDiffable> o = oldArray[originalIndex];
            switch (option) {
                case IGListDiffPointerPersonality:
                    // flag the entry as updated if the pointers are not the same
                    if (n != o) {
                        entry->updated = YES;
                    }
                    break;
                case IGListDiffEquality:
                    // use -[IGListDiffable isEqualToDiffableObject:] between both version of data to see if anything has changed
                    // skip the equality check if both indexes point to the same object
                    if (n != o && ![n isEqualToDiffableObject:o]) {
                        entry->updated = YES;
                    }
                    break;
            }
        }
        if (originalIndex != NSNotFound
            && entry->newCounter > 0
            && entry->oldCounter > 0) {
            // if an item occurs in the new and old array, it is unique
            // assign the index of new and old records to the opposite index (reverse lookup)
            newResultsArray[i].index = originalIndex;
            oldResultsArray[originalIndex].index = i;
        }
    }

    // storage for final NSIndexPaths or indexes
    id mInserts, mMoves, mUpdates, mDeletes;
    if (returnIndexPaths) {
        mInserts = [NSMutableArray<NSIndexPath *> new];
        mMoves = [NSMutableArray<IGListMoveIndexPath *> new];
        mUpdates = [NSMutableArray<NSIndexPath *> new];
        mDeletes = [NSMutableArray<NSIndexPath *> new];
    } else {
        mInserts = [NSMutableIndexSet new];
        mMoves = [NSMutableArray<IGListMoveIndex *> new];
        mUpdates = [NSMutableIndexSet new];
        mDeletes = [NSMutableIndexSet new];
    }

    // track offsets from deleted items to calculate where items have moved
    vector<NSInteger> deleteOffsets(oldCount);
    NSInteger runningOffset = 0;

    auto untouchedIndexes = [NSMutableIndexSet new];

    // iterate old array records checking for deletes
    // incremement offset for each delete
    for (NSInteger i = 0; i < oldCount; i++) {
        deleteOffsets[i] = runningOffset;
        const IGListRecord record = oldResultsArray[i];
        // if the record index in the new array doesn't exist, its a delete
        if (record.index == NSNotFound) {
            addIndexToCollection(returnIndexPaths, mDeletes, fromSection, i);
            runningOffset++;
        } else if (record.index == i) {
            [untouchedIndexes addIndex:record.index];
        }

        addIndexToMap(returnIndexPaths, fromSection, i, oldArray[i], oldMap);
    }


    aligned_union<0, IGListMoveChecker, IGListOptimalMoveChecker>::type moveCheckerBuf;

    IGListMoveChecker *moveChecker = IGListExperimentEnabled(experiments, IGListExperimentOptimizedMoves)
                                         ? new (&moveCheckerBuf) IGListOptimalMoveChecker(newResultsArray, untouchedIndexes)
                                         : new (&moveCheckerBuf) IGListMoveChecker();

    // offset incremented for each insert
    NSInteger insertOffset = 0;

    for (NSInteger i = 0; i < newCount; i++) {
        const IGListRecord record = newResultsArray[i];
        const NSInteger oldIndex = record.index;
        // add to inserts if the opposing index is NSNotFound
        if (record.index == NSNotFound) {
            addIndexToCollection(returnIndexPaths, mInserts, toSection, i);
            insertOffset++;
        } else {
            // note that an entry can be updated /and/ moved
            if (record.entry->updated) {
                addIndexToCollection(returnIndexPaths, mUpdates, fromSection, oldIndex);
            }

            // calculate the offset and determine if there was a move
            const NSInteger deleteOffset = deleteOffsets[oldIndex];

            if (moveChecker->isMove(oldIndex, i, insertOffset, deleteOffset)) {

                // add move from old index to new index
                id move;
                if (returnIndexPaths) {
                    NSIndexPath *from = [NSIndexPath indexPathForItem:oldIndex inSection:fromSection];
                    NSIndexPath *to = [NSIndexPath indexPathForItem:i inSection:toSection];
                    move = [[IGListMoveIndexPath alloc] initWithFrom:from to:to];
                } else {
                    move = [[IGListMoveIndex alloc] initWithFrom:oldIndex to:i];
                }
                [mMoves addObject:move];
            }
        }

        addIndexToMap(returnIndexPaths, toSection, i, newArray[i], newMap);
    }

    moveChecker->~IGListMoveChecker();

    NSCAssert((oldCount + [mInserts count] - [mDeletes count]) == newCount,
              @"Sanity check failed applying %lu inserts and %lu deletes to old count %li equaling new count %li",
              (unsigned long)[mInserts count], (unsigned long)[mDeletes count], (long)oldCount, (long)newCount);

    if (returnIndexPaths) {
        return [[IGListIndexPathResult alloc] initWithInserts:mInserts
                                                      deletes:mDeletes
                                                      updates:mUpdates
                                                        moves:mMoves
                                              oldIndexPathMap:oldMap
                                              newIndexPathMap:newMap];
    } else {
        return [[IGListIndexSetResult alloc] initWithInserts:mInserts
                                                     deletes:mDeletes
                                                     updates:mUpdates
                                                       moves:mMoves
                                                 oldIndexMap:oldMap
                                                 newIndexMap:newMap];
    }
}

IGListIndexSetResult *IGListDiff(NSArray<id<IGListDiffable> > *oldArray,
                                 NSArray<id<IGListDiffable>> *newArray,
                                 IGListDiffOption option) {
    return IGListDiffing(NO, 0, 0, oldArray, newArray, option, 0);
}

IGListIndexPathResult *IGListDiffPaths(NSInteger fromSection,
                                       NSInteger toSection,
                                       NSArray<id<IGListDiffable>> *oldArray,
                                       NSArray<id<IGListDiffable>> *newArray,
                                       IGListDiffOption option) {
    return IGListDiffing(YES, fromSection, toSection, oldArray, newArray, option, 0);
}

IGListIndexSetResult *IGListDiffExperiment(NSArray<id<IGListDiffable>> *_Nullable oldArray,
                                           NSArray<id<IGListDiffable>> *_Nullable newArray,
                                           IGListDiffOption option,
                                           IGListExperiment experiments) {
    return IGListDiffing(NO, 0, 0, oldArray, newArray, option, experiments);
}

IGListIndexPathResult *IGListDiffPathsExperiment(NSInteger fromSection,
                                                 NSInteger toSection,
                                                 NSArray<id<IGListDiffable>> *_Nullable oldArray,
                                                 NSArray<id<IGListDiffable>> *_Nullable newArray,
                                                 IGListDiffOption option,
                                                 IGListExperiment experiments) {
    return IGListDiffing(YES, fromSection, toSection, oldArray, newArray, option, experiments);
}
