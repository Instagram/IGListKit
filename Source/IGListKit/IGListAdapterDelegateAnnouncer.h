/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

#import "IGListAdapterDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface IGListAdapterDelegateAnnouncer : NSObject

/// Default announcer for all `IGListAdapter`
+ (instancetype)sharedInstance;

/// Add a delegate that will receive callbacks for all `IGListAdapter`.
/// This is a weak reference, so you don't need to remove it on dealloc.
- (void)addListener:(id<IGListAdapterDelegate>)listener;

/// Remove delegate
- (void)removeListener:(id<IGListAdapterDelegate>)listener;

@end

NS_ASSUME_NONNULL_END
