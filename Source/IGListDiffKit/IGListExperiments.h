/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

#import <IGListDiffKit/IGListDiff.h>

/**
 Bitmask-able options used for pre-release feature testing.
 */
NS_SWIFT_NAME(ListExperiment)
typedef NS_OPTIONS (NSInteger, IGListExperiment) {
    /// Specifies no experiments.
    IGListExperimentNone = 1 << 1,
    /// Test invalidating layout when cell reloads/updates in IGListBindingSectionController.
    IGListExperimentInvalidateLayoutForUpdates = 1 << 2,
    /// Test skipping performBatchUpdate if we don't have any updates.
    IGListExperimentSkipPerformUpdateIfPossible = 1 << 3,
    /// Test skipping creating {view : section controller} map, which has inconsistency issue.
    IGListExperimentSkipViewSectionControllerMap = 1 << 4
};

/**
 Check if an experiment is enabled in a bitmask.

 @param mask The bitmask of experiments.
 @param option The option to compare with.

 @return `YES` if the option is in the bitmask, otherwise `NO`.
 */
NS_SWIFT_NAME(ListExperimentEnabled(mask:option:))
static inline BOOL IGListExperimentEnabled(IGListExperiment mask, IGListExperiment option) {
    return (mask & option) != 0;
}

NS_ASSUME_NONNULL_BEGIN

NS_ASSUME_NONNULL_END
