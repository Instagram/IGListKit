/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

#if __has_include(<IGListDiffKit/IGListDiffKit.h>)
#import <IGListDiffKit/IGListExperiments.h>
#else
#import "IGListExperiments.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@class IGListUpdateCoalescer;

@protocol IGListUpdateCoalescerDelegate <NSObject>

/// Indicates that coalescing is done and the update should be performed.
- (void)performUpdateWithCoalescer:(IGListUpdateCoalescer *)coalescer;

@end

/**
 Class responsible for batching updates together
 */
NS_SWIFT_NAME(ListUpdateCoalescer)
@interface IGListUpdateCoalescer : NSObject

@property (nonatomic, assign) IGListAdaptiveCoalescingExperimentConfig adaptiveCoalescingExperimentConfig;

@property (nonatomic, weak) id<IGListUpdateCoalescerDelegate> delegate;

/**
 Start coalescing updates, which will eventually call `-performUpdateWithCoalescer`
 
 @params view View used to track visibility (if enabled in config)
 */
- (void)queueUpdateForView:(nullable UIView *)view;

@end

NS_ASSUME_NONNULL_END
