/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

@class IGListViewVisibilityTracker;

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(ListViewVisibilityState)
typedef NS_ENUM(NSInteger, IGListViewVisibilityState) {
    /// View is not in the window, hidden, or has alpha 0
    IGListViewVisibilityStateNotVisible,
    /// View is not visible, but tracking started recently, so it could change soon.
    IGListViewVisibilityStateNotVisibleEarly,
    /// View is in the window and not hidden, but there is no guarantee that its bounds are visible or not obstructed
    IGListViewVisibilityStateMaybeVisible,
};

/**
 Get the tracker associated with a view. If non exists, it will create one and attach it.

 @param view View's who's visibility is being tracked

 @return The tracker
 */
NS_SWIFT_NAME(IGListViewVisibilityTracker(attachedOnView:))
FOUNDATION_EXTERN IGListViewVisibilityTracker *_Nullable IGListViewVisibilityTrackerAttachedOnView(UIView *view);

/// Track a view visibility status
NS_SWIFT_NAME(ListViewVisibilityTracker)
@interface IGListViewVisibilityTracker : NSObject

- (instancetype)initWithView:(UIView *)view NS_DESIGNATED_INITIALIZER;

/**
 :nodoc:
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 :nodoc:
 */
+ (instancetype)new NS_UNAVAILABLE;

/// Calculates the state
- (IGListViewVisibilityState)state;

@end

NS_ASSUME_NONNULL_END
