/**
 * Copyright (c) 2016-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

static inline NSIndexPath *genIndexPath(NSInteger section, NSInteger item) {
    return [NSIndexPath indexPathForItem:item inSection:section];
}

//static inline UIViewController *loadViewController(NSString *storyboard, Class testClass, UIWin)

#define genExpectation [self expectationWithDescription:NSStringFromSelector(_cmd)]
#define waitExpectation [self waitForExpectationsWithTimeout:30 handler:nil]

#define IGAssertEqualPoint(point, x, y, ...) \
do { \
CGPoint p = CGPointMake(x, y); \
XCTAssertEqual(CGPointEqualToPoint(point, p), YES); \
} while(0)

#define IGAssertEqualSize(size, w, h, ...) \
do { \
CGSize s = CGSizeMake(w, h); \
XCTAssertEqual(CGSizeEqualToSize(size, s), YES); \
} while(0)

#define IGAssertEqualFrame(frame, x, y, w, h, ...) \
do { \
CGRect expected = CGRectMake(x, y, w, h); \
XCTAssertEqual(CGRectGetMinX(expected), CGRectGetMinX(frame)); \
XCTAssertEqual(CGRectGetMinY(expected), CGRectGetMinY(frame)); \
XCTAssertEqual(CGRectGetWidth(expected), CGRectGetWidth(frame)); \
XCTAssertEqual(CGRectGetHeight(expected), CGRectGetHeight(frame)); \
} while(0)

#define IGAssertEqualInsets(insets,t,l,b,r, ...) \
do { \
XCTAssertEqual(insets.top,t); \
XCTAssertEqual(insets.left,l); \
XCTAssertEqual(insets.bottom,b); \
XCTAssertEqual(insets.right,r); \
} while(0)

#define IGAssertContains(collection, object) do {\
id haystack = collection; id needle = object; \
XCTAssertTrue([haystack containsObject:needle], @"%@ does not contain %@", haystack, needle); \
} while(0)
