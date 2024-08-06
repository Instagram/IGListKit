/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

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
 @param allowsBackgroundDiffing Allows the diffing to be performed off the main thread
 @param completion Returns the diffing results. Can be called async or sync, but will be called on main thread.
 */
NS_SWIFT_NAME(ListPerformDiff(data:allowsBackgroundDiffing:completion:))
FOUNDATION_EXTERN void IGListPerformDiffWithData(IGListTransitionData *_Nullable data,
                                                 BOOL allowsBackgroundDiffing,
                                                 IGListDiffExecutorCompletion completion);

NS_ASSUME_NONNULL_END
