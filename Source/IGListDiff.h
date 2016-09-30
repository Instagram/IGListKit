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
 An option on how to do comparisons between similar objects.
 */
typedef NS_ENUM(NSUInteger, IGListDiffOption) {
    /**
     Compare objects using pointer personality.
     */
    IGListDiffPointerPersonality,
    /**
     Compare objects using -[NSObject isEqual:].
     */
    IGListDiffEquality
};

/**
 Create a diff using indexes between two collections.

 @param oldArray The old objects to diff against.
 @param newArray The new objects to diff with.
 @param option   An option on how to compare objects.

 @return Result object with effected indexes.
 */
FOUNDATION_EXTERN IGListIndexSetResult *IGListDiff(NSArray<id<IGListDiffable> > *_Nullable oldArray,
                                                   NSArray<id<IGListDiffable>> *_Nullable newArray,
                                                   IGListDiffOption option);

/**
 Create a diff using index paths between two collections.

 @param fromSection The old section used to seed returned index paths.
 @param toSection   The new section used to seed returned index paths.
 @param oldArray    The old objects to diff against.
 @param newArray    The new objects to diff with.
 @param option      An option on how to compare objects.

 @return Result object with effected index paths.
 */
FOUNDATION_EXTERN IGListIndexPathResult *IGListDiffPaths(NSInteger fromSection,
                                                         NSInteger toSection,
                                                         NSArray<id<IGListDiffable>> *_Nullable oldArray,
                                                         NSArray<id<IGListDiffable>> *_Nullable newArray,
                                                         IGListDiffOption option);

NS_ASSUME_NONNULL_END
