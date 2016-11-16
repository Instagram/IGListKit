/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <Foundation/Foundation.h>

#import <IGListKit/IGListDiff.h>

/**
 Bitmask-able options used for pre-release feature testing.
 */
typedef NS_OPTIONS (NSInteger, IGListExperiment) {
    IGListExperimentNone = 1 << 1,
};

/**
 Check if an experiment is enabled in a bitmask.

 @param mask   The bitmask of experiments.
 @param option The option to compare with.

 @return `YES` if the option is in the bitmask, otherwise `NO`.
 */
static inline BOOL IGListExperimentEnabled(IGListExperiment mask, IGListExperiment option) {
    return (mask & option) != 0;
}

NS_ASSUME_NONNULL_BEGIN

/**
 Performs a diff with an experiment bitmask. 
 
 @see `IGListDiff()`.
 */
FOUNDATION_EXTERN IGListIndexSetResult *IGListDiffExperiment(NSArray<id<IGListDiffable>> *_Nullable oldArray,
                                                             NSArray<id<IGListDiffable>> *_Nullable newArray,
                                                             IGListDiffOption option,
                                                             IGListExperiment experiments);

/**
 Performs a diff with an experiment bitmask. 
 
 @see `IGListDiffPaths()`.
 */
FOUNDATION_EXTERN IGListIndexPathResult *IGListDiffPathsExperiment(NSInteger fromSection,
                                                                   NSInteger toSection,
                                                                   NSArray<id<IGListDiffable>> *_Nullable oldArray,
                                                                   NSArray<id<IGListDiffable>> *_Nullable newArray,
                                                                   IGListDiffOption option,
                                                                   IGListExperiment experiments);

NS_ASSUME_NONNULL_END
