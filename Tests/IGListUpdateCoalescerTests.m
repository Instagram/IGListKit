/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <XCTest/XCTest.h>

#import <IGListKit/IGListKit.h>

#import "IGListUpdateCoalescer.h"

@interface IGListUpdateCoalescerTests : XCTestCase <IGListUpdateCoalescerDelegate>
@property (nonatomic, strong) IGListUpdateCoalescer *coalescer;
@property (nonatomic, strong) XCTestExpectation *updateExpectation;
@property (nonatomic, assign) NSInteger updateCount;
@end

@implementation IGListUpdateCoalescerTests

- (void)setUp {
    [super setUp];
    self.coalescer = [[IGListUpdateCoalescer alloc] init];
    self.coalescer.delegate = self;
    self.updateCount = 0;
}

- (void)tearDown {
    self.coalescer = nil;
    self.updateExpectation = nil;
    [super tearDown];
}

#pragma mark - IGListUpdateCoalescerDelegate

- (void)performUpdateWithCoalescer:(IGListUpdateCoalescer *)coalescer {
    self.updateCount++;
    [self.updateExpectation fulfill];
}

#pragma mark - Regular Dispatch

- (void)test_whenQueueingUpdate_thatDelegateIsCalled {
    self.updateExpectation = [self expectationWithDescription:@"Update performed"];
    [self.coalescer queueUpdateForView:nil];
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    XCTAssertEqual(self.updateCount, 1);
}

- (void)test_whenQueueingMultipleUpdates_thatOnlyOneUpdateIsPerformed {
    self.updateExpectation = [self expectationWithDescription:@"Update performed"];
    [self.coalescer queueUpdateForView:nil];
    [self.coalescer queueUpdateForView:nil];
    [self.coalescer queueUpdateForView:nil];
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    XCTAssertEqual(self.updateCount, 1);
}

#pragma mark - Adaptive Coalescing Config

- (void)test_whenSettingAdaptiveConfig_thatConfigIsStored {
    IGListAdaptiveCoalescingExperimentConfig config = {
        .enabled = YES,
        .minInterval = 0.1,
        .intervalIncrement = 0.05,
        .maxInterval = 0.5,
        .useMaxIntervalWhenViewNotVisible = NO
    };
    self.coalescer.adaptiveCoalescingExperimentConfig = config;
    XCTAssertTrue(self.coalescer.adaptiveCoalescingExperimentConfig.enabled);
    XCTAssertEqual(self.coalescer.adaptiveCoalescingExperimentConfig.minInterval, 0.1);
    XCTAssertEqual(self.coalescer.adaptiveCoalescingExperimentConfig.maxInterval, 0.5);
}

#pragma mark - Adaptive Dispatch

- (void)test_whenAdaptiveEnabled_withNoLastUpdate_thatUpdateIsPerformedImmediately {
    IGListAdaptiveCoalescingExperimentConfig config = {
        .enabled = YES,
        .minInterval = 0.01,
        .intervalIncrement = 0.01,
        .maxInterval = 0.1,
        .useMaxIntervalWhenViewNotVisible = NO
    };
    self.coalescer.adaptiveCoalescingExperimentConfig = config;

    self.updateExpectation = [self expectationWithDescription:@"Update performed"];
    [self.coalescer queueUpdateForView:nil];
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    XCTAssertEqual(self.updateCount, 1);
}

- (void)test_whenAdaptiveEnabled_withRecentUpdate_thatUpdateIsDelayed {
    IGListAdaptiveCoalescingExperimentConfig config = {
        .enabled = YES,
        .minInterval = 0.05,
        .intervalIncrement = 0.01,
        .maxInterval = 0.2,
        .useMaxIntervalWhenViewNotVisible = NO
    };
    self.coalescer.adaptiveCoalescingExperimentConfig = config;

    // First update - immediate
    self.updateExpectation = [self expectationWithDescription:@"First update"];
    [self.coalescer queueUpdateForView:nil];
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    XCTAssertEqual(self.updateCount, 1);

    // Second update - should be delayed since we're within minInterval
    self.updateExpectation = [self expectationWithDescription:@"Second update"];
    [self.coalescer queueUpdateForView:nil];
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    XCTAssertEqual(self.updateCount, 2);
}

- (void)test_whenAdaptiveEnabled_withViewNotVisible_thatMaxIntervalIsUsed {
    UIView *view = [[UIView alloc] init];
    // View not added to window, so it's not visible

    IGListAdaptiveCoalescingExperimentConfig config = {
        .enabled = YES,
        .minInterval = 0.01,
        .intervalIncrement = 0.01,
        .maxInterval = 0.05,
        .useMaxIntervalWhenViewNotVisible = YES
    };
    self.coalescer.adaptiveCoalescingExperimentConfig = config;

    self.updateExpectation = [self expectationWithDescription:@"Update performed"];
    [self.coalescer queueUpdateForView:view];
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    XCTAssertEqual(self.updateCount, 1);
}

- (void)test_whenAdaptiveEnabled_withVisibleView_thatUpdateIsPerformed {
    UIWindow *window = [[UIWindow alloc] init];
    window.hidden = NO;
    UIView *view = [[UIView alloc] init];
    [window addSubview:view];

    IGListAdaptiveCoalescingExperimentConfig config = {
        .enabled = YES,
        .minInterval = 0.01,
        .intervalIncrement = 0.01,
        .maxInterval = 0.1,
        .useMaxIntervalWhenViewNotVisible = YES
    };
    self.coalescer.adaptiveCoalescingExperimentConfig = config;

    self.updateExpectation = [self expectationWithDescription:@"Update performed"];
    [self.coalescer queueUpdateForView:view];
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    XCTAssertEqual(self.updateCount, 1);
}

@end
