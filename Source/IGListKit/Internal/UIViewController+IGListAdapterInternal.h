/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "UIViewController+IGListAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (IGListAdapterInternal)

- (void)associateListAdapter:(IGListAdapter *)adapter;

@end

NS_ASSUME_NONNULL_END
