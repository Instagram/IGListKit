/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <XCTest/XCTest.h>

#import <IGListKit/IGListSectionController.h>

@interface IGListSectionControllerTests : XCTestCase

@end

@implementation IGListSectionControllerTests

- (void)test_withBaseSectionContoller_thatDefaultValuesAreCorrect {
    NSObject *object = [NSObject new];
    IGListSectionController *sectionController = [[IGListSectionController alloc] init];
    XCTAssertNotNil(sectionController);

    XCTAssertEqual([sectionController numberOfItems], 1);
    XCTAssertTrue(CGSizeEqualToSize([sectionController sizeForItemAtIndex:0], CGSizeZero));
    XCTAssertTrue([sectionController shouldSelectItemAtIndex:0]);
    XCTAssertTrue([sectionController shouldDeselectItemAtIndex:0]);
    XCTAssertFalse([sectionController canMoveItemAtIndex:0]);

    [sectionController didUpdateToObject:object];

    [sectionController didSelectItemAtIndex:0];
    [sectionController didDeselectItemAtIndex:0];
    [sectionController didHighlightItemAtIndex:0];
    [sectionController didUnhighlightItemAtIndex:0];

    @try {
        [sectionController cellForItemAtIndex:0];
    } @catch (NSException *exception) {}

    @try {
        [sectionController moveObjectFromIndex:0 toIndex:1];
    } @catch (NSException *exception) {}
}

- (void)test_whenCreatedOutsideDataSource_thatCollectionContextIsNil {
    // Creating a section controller directly (not through the data source) should result in
    // a nil collectionContext since the thread context stack is empty. This covers line 61.

    // Clear the thread context stack to ensure we're testing the "outside data source" path
    // This is needed because other tests may have left context on the stack
    NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary];
    [threadDictionary removeObjectForKey:@"kIGListSectionControllerThreadKey"];

    IGListSectionController *sectionController = [[IGListSectionController alloc] init];
    XCTAssertNil(sectionController.collectionContext);
    XCTAssertNil(sectionController.viewController);
}

- (void)test_whenCallingContextMenuConfiguration_thatDefaultReturnsNil {
    // The default implementation of contextMenuConfigurationForItemAtIndex:point: returns nil
    IGListSectionController *sectionController = [[IGListSectionController alloc] init];
    if (@available(iOS 13.0, *)) {
        UIContextMenuConfiguration *config = [sectionController contextMenuConfigurationForItemAtIndex:0 point:CGPointZero];
        XCTAssertNil(config);
    }
}

@end
