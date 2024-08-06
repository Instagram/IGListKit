/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGListViewVisibilityTracker.h"

NS_ASSUME_NONNULL_BEGIN

@interface IGListViewVisibilityTracker()

/// Date the tracker is created
@property (nonatomic, strong, readwrite) NSDate *dateCreated;

/// When evaluating the state, compare the `dateCreated` to this one. If nil, we use `now`
@property (nonatomic, strong, readwrite, nullable) NSDate *comparedDateOverride;

/// What we consider as early. Default is 1 second.
@property (nonatomic, assign, readwrite) NSTimeInterval earlyTimeInterval;

@end

NS_ASSUME_NONNULL_END
