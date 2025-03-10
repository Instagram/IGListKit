/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

@class IGListAdapter;

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (IGListAdapter)

/// Adapters that have this VC as their `viewController`
- (NSArray<IGListAdapter *> *)associatedListAdapters;

@end

NS_ASSUME_NONNULL_END
