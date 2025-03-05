/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <XCTest/XCTest.h>

#import <IGListKit/IGListKit.h>

#import "UIViewController+IGListAdapter.h"

@interface UIViewControllerIGListAdapterTests : XCTestCase
@end

@implementation UIViewControllerIGListAdapterTests

- (void)test_whenNoAdapter_thatReturnsEmpty {
    UIViewController *const viewController = [UIViewController new];
    NSArray<IGListAdapter *> *const adapters = [viewController associatedListAdapters];
    XCTAssertEqual(adapters.count, 0);
}

- (void)test_whenOneAdapter_thatReturnsOne {
    UIViewController *const viewController = [UIViewController new];
    IGListAdapter *const adapter = [[IGListAdapter alloc] initWithUpdater:[IGListAdapterUpdater new] viewController:viewController];
    NSArray<IGListAdapter *> *const adapters = [viewController associatedListAdapters];
    XCTAssertEqual(adapters.count, 1);
    XCTAssertEqual(adapters.firstObject, adapter);
}

- (void)test_whenTwoAdapters_thatReturnsTwo {
    UIViewController *const viewController = [UIViewController new];
    __unused IGListAdapter *const adapter1 = [[IGListAdapter alloc] initWithUpdater:[IGListAdapterUpdater new] viewController:viewController];
    __unused IGListAdapter *const adapter2 = [[IGListAdapter alloc] initWithUpdater:[IGListAdapterUpdater new] viewController:viewController];
    NSArray<IGListAdapter *> *const adapters = [viewController associatedListAdapters];
    XCTAssertEqual(adapters.count, 2);
}

- (void)test_whenOneAdapters_andDealloc_thatReturnsEmpty {
    UIViewController *const viewController = [UIViewController new];
    @autoreleasepool {
        __unused IGListAdapter *const adapter = [[IGListAdapter alloc] initWithUpdater:[IGListAdapterUpdater new] viewController:viewController];
        // let adapter get deallocated
    }
    NSArray<IGListAdapter *> *const adapters = [viewController associatedListAdapters];
    XCTAssertEqual(adapters.count, 0);
}

@end
