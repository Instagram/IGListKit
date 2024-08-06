/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <XCTest/XCTest.h>

#import <UIKit/UIKit.h>

#import "IGListViewVisibilityTrackerInternal.h"

@interface IGListViewVisibilityTrackerTests : XCTestCase
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *view;
@property (nonatomic, strong) IGListViewVisibilityTracker *tracker;
@end

@implementation IGListViewVisibilityTrackerTests

- (void)setUp {
    self.window = [UIWindow new];
    self.window.hidden = NO;
    
    self.containerView = [UIView new];
    [self.window addSubview:self.containerView];
    
    self.view = [UIView new];
    [self.containerView addSubview:self.view];
    
    // Advance compare date so it's not early
    self.tracker = [[IGListViewVisibilityTracker alloc] initWithView:self.view];
    self.tracker.comparedDateOverride = [self.tracker.dateCreated dateByAddingTimeInterval:self.tracker.earlyTimeInterval + 1];
}

#pragma mark - Window

- (void)test_whenOnWindow_thatVisible {
    XCTAssertEqual(self.tracker.state, IGListViewVisibilityStateMaybeVisible);
}

- (void)test_whenNoWindow_thatNotVisible {
    [self.view removeFromSuperview];
    XCTAssertEqual(self.tracker.state, IGListViewVisibilityStateNotVisible);
}

#pragma mark - Hidden

- (void)test_whenOnWindow_hidden_thatNotVisible {
    self.view.hidden = YES;
    XCTAssertEqual(self.tracker.state, IGListViewVisibilityStateNotVisible);
}

- (void)test_whenOnWindow_parentHidden_thatNotVisible {
    self.containerView.hidden = YES;
    XCTAssertEqual(self.tracker.state, IGListViewVisibilityStateNotVisible);
}

#pragma mark - Alpha

- (void)test_whenOnWindow_zeroAlpha_thatNotVisible {
    self.view.alpha = 0;
    XCTAssertEqual(self.tracker.state, IGListViewVisibilityStateNotVisible);
}

- (void)test_whenOnWindow_parentZeroAlpha_thatNotVisible {
    self.containerView.alpha = 0;
    XCTAssertEqual(self.tracker.state, IGListViewVisibilityStateNotVisible);
}

#pragma mark - Early

- (void)test_whenNoWindow_andEarly_thatNotVisibleEarly {
    [self.view removeFromSuperview];

    self.tracker.earlyTimeInterval = 1.0;
    self.tracker.comparedDateOverride = self.tracker.dateCreated;
    
    XCTAssertEqual(self.tracker.state, IGListViewVisibilityStateNotVisibleEarly);
}

@end
