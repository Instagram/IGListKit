/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant 
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <XCTest/XCTest.h>

#import "IGListItemMap.h"
#import "IGListTestSection.h"
#import "IGTestObject.h"

#define genTestObject(k, v) [[IGTestObject alloc] initWithKey:k value:v]

@interface IGListItemMapTests : XCTestCase

@end

@implementation IGListItemMapTests

- (void)test_whenUpdatingItems_thatArraysAreEqual {
    NSArray *objects = @[@0, @1, @2];
    NSArray *listItems = @[@"a", @"b", @"c"];
    IGListItemMap *map = [[IGListItemMap alloc] initWithMapTable:[NSMapTable strongToStrongObjectsMapTable]];
    [map updateWithItems:objects itemControllers:listItems];
    XCTAssertEqualObjects(objects, map.items);
}

- (void)test_whenUpdatingItems_thatItemControllersAreMappedForSection {
    NSArray *objects = @[@0, @1, @2];
    NSArray *listItems = @[@"a", @"b", @"c"];
    IGListItemMap *map = [[IGListItemMap alloc] initWithMapTable:[NSMapTable strongToStrongObjectsMapTable]];
    [map updateWithItems:objects itemControllers:listItems];
    XCTAssertEqualObjects([map itemControllerForSection:1], listItems[1]);
}

- (void)test_whenUpdatingItems_thatItemControllersAreMappedForItem {
    NSArray *objects = @[@0, @1, @2];
    NSArray *listItems = @[@"a", @"b", @"c"];
    IGListItemMap *map = [[IGListItemMap alloc] initWithMapTable:[NSMapTable strongToStrongObjectsMapTable]];
    [map updateWithItems:objects itemControllers:listItems];
    XCTAssertEqual([map itemControllerForItem:objects[1]], listItems[1]);
}

- (void)test_whenUpdatingItems_thatSectionsAreMappedForItemController {
    NSArray *objects = @[@0, @1, @2];
    NSArray *listItems = @[@"a", @"b", @"c"];
    IGListItemMap *map = [[IGListItemMap alloc] initWithMapTable:[NSMapTable strongToStrongObjectsMapTable]];
    [map updateWithItems:objects itemControllers:listItems];
    XCTAssertEqual([map sectionForItemController:listItems[1]], 1);
}

- (void)test_whenUpdatingItems_withUnknownItem_thatItemControllerIsNil {
    NSArray *objects = @[@0, @1, @2];
    NSArray *listItems = @[@"a", @"b", @"c"];
    IGListItemMap *map = [[IGListItemMap alloc] initWithMapTable:[NSMapTable strongToStrongObjectsMapTable]];
    [map updateWithItems:objects itemControllers:listItems];
    XCTAssertNil([map itemControllerForItem:@4]);
}

- (void)test_whenUpdatingItems_withItemController_thatSectionIsNotFound {
    NSArray *objects = @[@0, @1, @2];
    NSArray *listItems = @[[IGListTestSection new], [IGListTestSection new], [IGListTestSection new]];
    IGListItemMap *map = [[IGListItemMap alloc] initWithMapTable:[NSMapTable strongToStrongObjectsMapTable]];
    [map updateWithItems:objects itemControllers:listItems];
    XCTAssertEqual([map sectionForItemController:[IGListTestSection new]], NSNotFound);
}

- (void)test_whenEnumeratingMap_withStopFlagSet_thatEnumerationEndsEarly {
    NSArray *objects = @[@0, @1, @2];
    NSArray *listItems = @[@"a", @"b", @"c"];
    IGListItemMap *map = [[IGListItemMap alloc] initWithMapTable:[NSMapTable strongToStrongObjectsMapTable]];
    [map updateWithItems:objects itemControllers:listItems];
    __block NSInteger counter = 0;
    [map enumerateItemsAndItemControllersUsingBlock:^(id item, IGListItemController<IGListItemType> * itemController, NSUInteger section, BOOL *stop) {
        counter++;
        *stop = section == 1;
    }];
    XCTAssertEqual(counter, 2);
}

@end
