/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <XCTest/XCTest.h>

#import <IGListKit/IGListGenericSectionController.h>

@interface IGListGenericSectionControllerTests : XCTestCase

@end

@implementation IGListGenericSectionControllerTests

- (void)test_whenUpdatingToObject_thatSameObjectIsStored {
    IGListGenericSectionController<NSString *> *controller = [IGListGenericSectionController new];
    NSString *foo = @"foo";
    [controller didUpdateToObject:foo];
    XCTAssertEqual(controller.object, foo);
}

@end
