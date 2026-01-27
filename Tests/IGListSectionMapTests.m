/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <XCTest/XCTest.h>

#import "IGTestDiffingObject.h"
#import "IGListSectionMap.h"
#import "IGListTestSection.h"
#import "IGTestObject.h"

@interface IGListSectionMapTests : XCTestCase

@end

@implementation IGListSectionMapTests

- (void)test_whenUpdatingItems_thatArraysAreEqual {
    NSArray *objects = @[@0, @1, @2];
    NSArray *sectionControllers = @[[IGListTestSection new], [IGListTestSection new], [IGListTestSection new]];
    IGListSectionMap *map = [[IGListSectionMap alloc] initWithMapTable:[NSMapTable strongToStrongObjectsMapTable]];
    [map updateWithObjects:objects sectionControllers:sectionControllers];
    XCTAssertEqualObjects(objects, map.objects);
}

- (void)test_whenUpdatingItems_thatSectionControllersAreMappedForSection {
    NSArray *objects = @[@0, @1, @2];
    NSArray *sectionControllers = @[[IGListTestSection new], [IGListTestSection new], [IGListTestSection new]];
    IGListSectionMap *map = [[IGListSectionMap alloc] initWithMapTable:[NSMapTable strongToStrongObjectsMapTable]];
    [map updateWithObjects:objects sectionControllers:sectionControllers];
    XCTAssertEqualObjects([map sectionControllerForSection:1], sectionControllers[1]);
}

- (void)test_whenUpdatingItems_thatSectionControllersAreMappedForItem {
    NSArray *objects = @[@0, @1, @2];
    NSArray *sectionControllers = @[[IGListTestSection new], [IGListTestSection new], [IGListTestSection new]];
    IGListSectionMap *map = [[IGListSectionMap alloc] initWithMapTable:[NSMapTable strongToStrongObjectsMapTable]];
    [map updateWithObjects:objects sectionControllers:sectionControllers];
    XCTAssertEqual([map sectionControllerForObject:objects[1]], sectionControllers[1]);
}

- (void)test_whenUpdatingItems_thatSectionsAreMappedForSectionController {
    NSArray *objects = @[@0, @1, @2];
    NSArray *sectionControllers = @[[IGListTestSection new], [IGListTestSection new], [IGListTestSection new]];
    IGListSectionMap *map = [[IGListSectionMap alloc] initWithMapTable:[NSMapTable strongToStrongObjectsMapTable]];
    [map updateWithObjects:objects sectionControllers:sectionControllers];
    XCTAssertEqual([map sectionForSectionController:sectionControllers[1]], 1);
}

- (void)test_whenUpdatingItems_withUnknownItem_thatSectionControllerIsNil {
    NSArray *objects = @[@0, @1, @2];
    NSArray *sectionControllers = @[[IGListTestSection new], [IGListTestSection new], [IGListTestSection new]];
    IGListSectionMap *map = [[IGListSectionMap alloc] initWithMapTable:[NSMapTable strongToStrongObjectsMapTable]];
    [map updateWithObjects:objects sectionControllers:sectionControllers];
    XCTAssertNil([map sectionControllerForObject:@4]);
}

- (void)test_whenUpdatingItems_withSectionController_thatSectionIsNotFound {
    NSArray *objects = @[@0, @1, @2];
    NSArray *sectionControllers = @[[IGListTestSection new], [IGListTestSection new], [IGListTestSection new]];
    IGListSectionMap *map = [[IGListSectionMap alloc] initWithMapTable:[NSMapTable strongToStrongObjectsMapTable]];
    [map updateWithObjects:objects sectionControllers:sectionControllers];
    XCTAssertEqual([map sectionForSectionController:[IGListTestSection new]], NSNotFound);
}

- (void)test_whenEnumeratingMap_withStopFlagSet_thatEnumerationEndsEarly {
    NSArray *objects = @[@0, @1, @2];
    NSArray *sectionControllers = @[[IGListTestSection new], [IGListTestSection new], [IGListTestSection new]];
    IGListSectionMap *map = [[IGListSectionMap alloc] initWithMapTable:[NSMapTable strongToStrongObjectsMapTable]];
    [map updateWithObjects:objects sectionControllers:sectionControllers];
    __block NSInteger counter = 0;
    [map enumerateUsingBlock:^(id item, IGListSectionController * sectionController, NSInteger section, BOOL *stop) {
        counter++;
        *stop = section == 1;
    }];
    XCTAssertEqual(counter, 2);
}

- (void)test_whenAccessingOOBSection_thatNilIsReturned {
    NSArray *objects = @[@0, @1, @2];
    NSArray *sectionControllers = @[[IGListTestSection new], [IGListTestSection new], [IGListTestSection new]];
    IGListSectionMap *map = [[IGListSectionMap alloc] initWithMapTable:[NSMapTable strongToStrongObjectsMapTable]];
    [map updateWithObjects:objects sectionControllers:sectionControllers];
    XCTAssertNil([map objectForSection:4]);
}

- (void)test_whenUpdatingItems_thatSectionControllerIndexesAreUpdated {
    NSArray *objects = @[@0, @1, @2];

    IGListTestSection *one = [IGListTestSection new];
    XCTAssertEqual(one.section, NSNotFound);

    NSArray *sectionControllers = @[[IGListTestSection new], one, [IGListTestSection new]];
    IGListSectionMap *map = [[IGListSectionMap alloc] initWithMapTable:[NSMapTable strongToStrongObjectsMapTable]];
    [map updateWithObjects:objects sectionControllers:sectionControllers];

    XCTAssertEqual(one.section, 1);
    XCTAssertFalse(one.isFirstSection);
}

- (void)test_whenQueryingItems_thatNilReturnsNotFound {
    IGTestDiffingObject *object = [IGTestDiffingObject new];
    object = nil;
    IGListSectionMap *map = [[IGListSectionMap alloc] initWithMapTable:[NSMapTable strongToStrongObjectsMapTable]];
    XCTAssertEqual([map sectionForObject:object], NSNotFound);
}

- (void)test_whenAccessingNegativeSection_thatNilIsReturned {
    NSArray *objects = @[@0, @1, @2];
    NSArray *sectionControllers = @[[IGListTestSection new], [IGListTestSection new], [IGListTestSection new]];
    IGListSectionMap *map = [[IGListSectionMap alloc] initWithMapTable:[NSMapTable strongToStrongObjectsMapTable]];
    [map updateWithObjects:objects sectionControllers:sectionControllers];
    XCTAssertNil([map objectForSection:-1]);
}

- (void)test_whenUpdatingWithDifferentObjectCounts_thatValidationHandlesMismatch {
    // First update with 3 objects
    NSArray *objects1 = @[@0, @1, @2];
    NSArray *sectionControllers1 = @[[IGListTestSection new], [IGListTestSection new], [IGListTestSection new]];
    IGListSectionMap *map = [[IGListSectionMap alloc] initWithMapTable:[NSMapTable strongToStrongObjectsMapTable]];
    [map updateWithObjects:objects1 sectionControllers:sectionControllers1];

    // Update with different count - this exercises the count mismatch path in validation
    NSArray *objects2 = @[@3, @4];
    NSArray *sectionControllers2 = @[[IGListTestSection new], [IGListTestSection new]];
    [map updateWithObjects:objects2 sectionControllers:sectionControllers2];

    XCTAssertEqual(map.objects.count, 2);
}

- (void)test_whenCopyingMap_thatCopyIsIndependent {
    NSArray *objects = @[@0, @1, @2];
    NSArray *sectionControllers = @[[IGListTestSection new], [IGListTestSection new], [IGListTestSection new]];
    IGListSectionMap *map = [[IGListSectionMap alloc] initWithMapTable:[NSMapTable strongToStrongObjectsMapTable]];
    [map updateWithObjects:objects sectionControllers:sectionControllers];

    IGListSectionMap *copy = [map copy];

    XCTAssertEqualObjects(map.objects, copy.objects);
    XCTAssertNotEqual(map, copy);
}

@end
