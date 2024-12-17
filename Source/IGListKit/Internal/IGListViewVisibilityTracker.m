/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGListViewVisibilityTrackerInternal.h"

#import <objc/runtime.h>

static void * kIGListViewVisibilityTrackerKey = &kIGListViewVisibilityTrackerKey;

IGListViewVisibilityTracker *IGListViewVisibilityTrackerAttachedOnView(UIView *view) {
    if (!view) {
        return nil;
    }

    IGListViewVisibilityTracker *tracker = (IGListViewVisibilityTracker *)objc_getAssociatedObject(view, kIGListViewVisibilityTrackerKey);
    if (!tracker) {
        tracker = [[IGListViewVisibilityTracker alloc] initWithView:view];
        objc_setAssociatedObject(view, kIGListViewVisibilityTrackerKey, tracker, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return tracker;
}

@implementation IGListViewVisibilityTracker {
    __weak UIView *_view;
}

- (instancetype)initWithView:(UIView *)view {
    if (self = [super init]) {
        _view = view;
        _earlyTimeInterval = 1.0;
        _dateCreated = [NSDate date];
    }
    return self;
}

static BOOL _isViewVisible(UIView *view) {
    if (!view.window) {
        return NO;
    }

    UIView *currentView = view;
    while (currentView != nil) {
        if (currentView.hidden || currentView.alpha < FLT_EPSILON) {
            return NO;
        }
        currentView = currentView.superview;
    }

    return YES;
}

- (IGListViewVisibilityState)state {
    if (_isViewVisible(_view)) {
        return IGListViewVisibilityStateMaybeVisible;
    }

    NSDate *const compareDate = _comparedDateOverride ?: [NSDate date];
    const NSTimeInterval timeSinceCreation = [compareDate timeIntervalSinceDate:_dateCreated];
    return (timeSinceCreation < _earlyTimeInterval) ? IGListViewVisibilityStateNotVisibleEarly : IGListViewVisibilityStateNotVisible;
}

@end
