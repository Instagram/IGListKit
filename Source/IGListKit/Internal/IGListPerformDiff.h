/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

#if !__has_include(<IGListDiffKit/IGListDiffKit.h>)
#import "IGListExperiments.h"
#else
#import <IGListDiffKit/IGListExperiments.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class IGListTransitionData;
@class IGListIndexSetResult;

/**
 @param result The diffing results
 @param onBackground Whether the diffing ran on a background thread
 */
NS_SWIFT_NAME(ListDiffExecutorCompletion)
typedef void (^IGListDiffExecutorCompletion)(IGListIndexSetResult *result, BOOL onBackground);

/**
 Perform diffing, which can happen sync or async depending on the params given.

 @param data Contains the objects before and after the update
 @param view  View on which we will perform the update. Used to check visibility.
 @param allowsBackgroundDiffing Allows the diffing to be performed off the main thread
 @param adaptiveConfig Details of how the adaptive diffing should work
 @param completion Returns the diffing results. Can be called async or sync, but will be called on main thread.
 */
NS_SWIFT_NAME(ListPerformDiff(data:view:allowsBackgroundDiffing:adaptiveConfig:completion:))
FOUNDATION_EXTERN void IGListPerformDiffWithData(IGListTransitionData *_Nullable data,
                                                 UIView *_Nullable view,
                                                 BOOL allowsBackgroundDiffing,
                                                 IGListAdaptiveDiffingExperimentConfig adaptiveConfig,
                                                 IGListDiffExecutorCompletion completion);

NS_ASSUME_NONNULL_END
