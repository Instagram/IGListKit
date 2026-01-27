/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <XCTest/XCTest.h>

#import <IGListKit/IGListKit.h>

#import "IGListPerformDiff.h"
#import "IGListTransitionData.h"
#import "IGListViewVisibilityTrackerInternal.h"

@interface IGListPerformDiffTests : XCTestCase
@end

@implementation IGListPerformDiffTests

- (void)test_whenPerformDiff_withNilCompletion_thatReturnsEarly {
    IGListTransitionData *data = [[IGListTransitionData alloc] initFromObjects:@[@1] toObjects:@[@2] toSectionControllers:@[]];
    IGListAdaptiveDiffingExperimentConfig config = {
        .enabled = YES,
        .higherQOSEnabled = NO,
        .maxItemCountToRunOnMain = 0,
        .lowerPriorityWhenViewNotVisible = NO
    };
    // Bypass nonnull check by using a variable
    IGListDiffExecutorCompletion completion = nil;
    // Should not crash when completion is nil
    IGListPerformDiffWithData(data, nil, YES, config, completion);
}

- (void)test_whenPerformDiff_withViewNotVisibleState_thatUsesLowerPriorityQueue {
    // Create a view not in any window
    UIView *view = [[UIView alloc] init];

    // Get the tracker and set it up so it returns NotVisible (not NotVisibleEarly)
    IGListViewVisibilityTracker *tracker = IGListViewVisibilityTrackerAttachedOnView(view);
    tracker.comparedDateOverride = [tracker.dateCreated dateByAddingTimeInterval:tracker.earlyTimeInterval + 1];

    // Verify the tracker returns NotVisible
    XCTAssertEqual(tracker.state, IGListViewVisibilityStateNotVisible);

    IGListTransitionData *data = [[IGListTransitionData alloc] initFromObjects:@[@1, @2, @3, @4, @5, @6] toObjects:@[@2, @3, @4, @5, @6, @7] toSectionControllers:@[]];
    IGListAdaptiveDiffingExperimentConfig config = {
        .enabled = YES,
        .higherQOSEnabled = NO,
        .maxItemCountToRunOnMain = 0,
        .lowerPriorityWhenViewNotVisible = YES
    };

    XCTestExpectation *expectation = [self expectationWithDescription:@"Diff completed"];
    IGListPerformDiffWithData(data, view, YES, config, ^(IGListIndexSetResult *result, BOOL onBackground) {
        XCTAssertNotNil(result);
        XCTAssertTrue(onBackground);
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:30 handler:nil];
}

@end
