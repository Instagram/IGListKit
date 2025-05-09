/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

#import "IGListDiff.h"

/**
 Bitmask-able options used for pre-release feature testing.
 */
NS_SWIFT_NAME(ListExperiment)
typedef NS_OPTIONS (NSInteger, IGListExperiment) {
    /// Specifies no experiments.
    IGListExperimentNone = 1 << 1,
    /// Test invalidating layout when cell reloads/updates in IGListBindingSectionController.
    IGListExperimentInvalidateLayoutForUpdates = 1 << 2,
    /// Throw NSInternalInconsistencyException during an update
    IGListExperimentThrowOnInconsistencyException = 1 << 3,
    /// Remove the early exit so multiple updates can't happen at once
    IGListExperimentRemoveDataSourceChangeEarlyExit = 1 << 4,
    /// Avoids creating off-screen cells
    IGListExperimentFixPreferredFocusedView = 1 << 5,
};

/**
 Customize how diffing is performed
 */
NS_SWIFT_NAME(ListAdaptiveDiffingExperimentConfig)
typedef struct IGListAdaptiveDiffingExperimentConfig {
    /// Enabled experimental code path. This needs to be enabled for the other properties to take effect.
    BOOL enabled;
    /// Enable higher background thread priority
    BOOL higherQOSEnabled;
    /// If both item counts are under this number, we'll run the diffing on the main thread.
    NSInteger maxItemCountToRunOnMain;
    /// Lower QOS if view is not visible according to `IGListViewVisibilityTracker`
    BOOL lowerPriorityWhenViewNotVisible;
} IGListAdaptiveDiffingExperimentConfig;

/**
 Customize how coalescing works to speed up some updates
 */
NS_SWIFT_NAME(ListAdaptiveCoalescingExperimentConfig)
typedef struct IGListAdaptiveCoalescingExperimentConfig {
    /// Enable adaptive coalescing, where we try to mininimize the update delay
    BOOL enabled;
    /// Start coalescing if the last update was within this interval
    NSTimeInterval minInterval;
    /// If we need to coalesce, increase the interval by this much for next time.
    NSTimeInterval intervalIncrement;
    /// This is the maximum coalesce interval, so the slowest and update can wait.
    NSTimeInterval maxInterval;
    /// Coalece using `maxInterval` if view is not visible according to `IGListViewVisibilityTracker`
    BOOL useMaxIntervalWhenViewNotVisible;
} IGListAdaptiveCoalescingExperimentConfig;

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
