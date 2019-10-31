/**
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
    /// Test updater diffing performed on a background queue.
    IGListExperimentBackgroundDiffing = 1 << 2,
    /// Test fallback to reloadData when "too many" update operations.
    IGListExperimentReloadDataFallback = 1 << 3,
    /// Test removing the layout pass when calling scrollToObject to avoid creating off-screen cells.
    IGListExperimentAvoidLayoutOnScrollToObject = 1 << 4,
    /// Test fixing a crash when inserting and deleting the same NSIndexPath multiple times.
    IGListExperimentFixIndexPathImbalance = 1 << 5,
    /// Test deferring object creation until just before diffing.
    IGListExperimentDeferredToObjectCreation = 1 << 6,
    /// Test getting collection view at update time.
    IGListExperimentGetCollectionViewAtUpdate = 1 << 7,
    /// Test invalidating layout when cell reloads/updates in IGListBindingSectionController.
    IGListExperimentInvalidateLayoutForUpdates = 1 << 8,
    /// Test using the collection view when asking for layout instead of accessing the data source. Only apply to IGListCollectionViewLayout.
    IGListExperimentUseCollectionViewInsteadOfDataSourceInLayout = 1 << 9
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

/**
 Performs an index diff with an experiment bitmask.

 @param oldArray The old array of objects.
 @param newArray The new array of objects.
 @param option Option to specify the type of diff.
 @param experiments Optional experiments.

 @return An index set result object contained the changed indexes.

 @see `IGListDiff()`.
 */
NS_SWIFT_NAME(ListDiffExperiment(oldArray:newArray:option:experiments:))
FOUNDATION_EXTERN IGListIndexSetResult *IGListDiffExperiment(NSArray<id<IGListDiffable>> *_Nullable oldArray,
                                                             NSArray<id<IGListDiffable>> *_Nullable newArray,
                                                             IGListDiffOption option,
                                                             IGListExperiment experiments);

/**
 Performs a index path diff with an experiment bitmask.

 @param fromSection The old section.
 @param toSection The new section.
 @param oldArray The old array of objects.
 @param newArray The new array of objects.
 @param option Option to specify the type of diff.
 @param experiments Optional experiments.

 @return An index path result object containing the changed indexPaths.

 @see `IGListDiffPaths()`.
 */
NS_SWIFT_NAME(ListDiffPathsExperiment(fromSection:toSection:oldArray:newArray:option:experiments:))
FOUNDATION_EXTERN IGListIndexPathResult *IGListDiffPathsExperiment(NSInteger fromSection,
                                                                   NSInteger toSection,
                                                                   NSArray<id<IGListDiffable>> *_Nullable oldArray,
                                                                   NSArray<id<IGListDiffable>> *_Nullable newArray,
                                                                   IGListDiffOption option,
                                                                   IGListExperiment experiments);

NS_ASSUME_NONNULL_END
