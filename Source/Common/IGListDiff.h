/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <Foundation/Foundation.h>

#import <IGListKit/IGListDiffable.h>
#import <IGListKit/IGListIndexPathResult.h>
#import <IGListKit/IGListIndexSetResult.h>

NS_ASSUME_NONNULL_BEGIN

/**
 An option for how to do comparisons between similar objects.
 */
typedef NS_ENUM(NSInteger, IGListDiffOption) {
    /**
     Compare objects using pointer personality.
     */
    IGListDiffPointerPersonality,
    /**
     Compare objects using `-[IGListDiffable isEqualToDiffableObject:]`.
     */
    IGListDiffEquality
};

/**
 Comparison behavior options.
 */
typedef NS_OPTIONS(NSInteger, IGListDiffBehavior) {
    IGListDiffBehaviorDefault = 0,
    /**
     When used, moves are reported incrementally. Can be used to reorder a collection. O(n^2) complexity.
     
     By default, moves are reported with old and new positions. O(n) complexity.
     */
    IGListDiffBehaviorIncrementalMoves = 1 << 0
};

/**
 Creates a diff using indexes between two collections.

 @param oldArray The old objects to diff against.
 @param newArray The new objects.
 @param option   An option on how to compare objects.

 @return A result object containing affected indexes.
 */
FOUNDATION_EXTERN IGListIndexSetResult *IGListDiff(NSArray<id<IGListDiffable>> *_Nullable oldArray,
                                                   NSArray<id<IGListDiffable>> *_Nullable newArray,
                                                   IGListDiffOption option);

/**
 Creates a diff using index paths between two collections.

 @param fromSection The old section.
 @param toSection   The new section.
 @param oldArray    The old objects to diff against.
 @param newArray    The new objects.
 @param option      An option on how to compare objects.

 @return A result object containing affected indexes.
 */
FOUNDATION_EXTERN IGListIndexPathResult *IGListDiffPaths(NSInteger fromSection,
                                                         NSInteger toSection,
                                                         NSArray<id<IGListDiffable>> *_Nullable oldArray,
                                                         NSArray<id<IGListDiffable>> *_Nullable newArray,
                                                         IGListDiffOption option);

/**
 Creates a diff using indexes between two collections.

 @param oldArray The old objects to diff against.
 @param newArray The new objects.
 @param option   An option on how to compare objects.
 @param behavior Comparison behaviors.

 @return A result object containing affected indexes.
 */
FOUNDATION_EXTERN IGListIndexSetResult *IGListDiffWithBehavior(NSArray<id<IGListDiffable>> *_Nullable oldArray,
                                                               NSArray<id<IGListDiffable>> *_Nullable newArray,
                                                               IGListDiffOption option,
                                                               IGListDiffBehavior behavior);

/**
 Creates a diff using index paths between two collections.

 @param fromSection The old section.
 @param toSection   The new section.
 @param oldArray    The old objects to diff against.
 @param newArray    The new objects.
 @param option      An option on how to compare objects.
 @param behavior    Comparison behaviors.

 @return A result object containing affected indexes.
 */
FOUNDATION_EXTERN IGListIndexPathResult *IGListDiffPathsWithBehavior(NSInteger fromSection,
                                                                     NSInteger toSection,
                                                                     NSArray<id<IGListDiffable>> *_Nullable oldArray,
                                                                     NSArray<id<IGListDiffable>> *_Nullable newArray,
                                                                     IGListDiffOption option,
                                                                     IGListDiffBehavior behavior);

NS_ASSUME_NONNULL_END
