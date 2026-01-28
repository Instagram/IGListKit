/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <XCTest/XCTest.h>

#import <IGListKit/IGListKit.h>

#import "IGListItemUpdatesCollector.h"
#import "IGListMoveIndexPathInternal.h"
#import "IGListReloadIndexPath.h"

@interface IGListItemUpdatesCollectorTests : XCTestCase
@end

@implementation IGListItemUpdatesCollectorTests

#pragma mark - Initialization

- (void)test_whenInitialized_thatCollectionsAreEmpty {
    IGListItemUpdatesCollector *collector = [[IGListItemUpdatesCollector alloc] init];
    XCTAssertEqual(collector.sectionReloads.count, 0);
    XCTAssertEqual(collector.itemInserts.count, 0);
    XCTAssertEqual(collector.itemDeletes.count, 0);
    XCTAssertEqual(collector.itemMoves.count, 0);
    XCTAssertEqual(collector.itemReloads.count, 0);
}

#pragma mark - hasChanges

- (void)test_whenEmpty_thatHasChangesIsFalse {
    IGListItemUpdatesCollector *collector = [[IGListItemUpdatesCollector alloc] init];
    XCTAssertFalse([collector hasChanges]);
}

- (void)test_whenHasSectionReloads_thatHasChangesIsTrue {
    IGListItemUpdatesCollector *collector = [[IGListItemUpdatesCollector alloc] init];
    [collector.sectionReloads addIndex:0];
    XCTAssertTrue([collector hasChanges]);
}

- (void)test_whenHasItemInserts_thatHasChangesIsTrue {
    IGListItemUpdatesCollector *collector = [[IGListItemUpdatesCollector alloc] init];
    [collector.itemInserts addObject:[NSIndexPath indexPathForItem:0 inSection:0]];
    XCTAssertTrue([collector hasChanges]);
}

- (void)test_whenHasItemDeletes_thatHasChangesIsTrue {
    IGListItemUpdatesCollector *collector = [[IGListItemUpdatesCollector alloc] init];
    [collector.itemDeletes addObject:[NSIndexPath indexPathForItem:0 inSection:0]];
    XCTAssertTrue([collector hasChanges]);
}

- (void)test_whenHasItemMoves_thatHasChangesIsTrue {
    IGListItemUpdatesCollector *collector = [[IGListItemUpdatesCollector alloc] init];
    NSIndexPath *from = [NSIndexPath indexPathForItem:0 inSection:0];
    NSIndexPath *to = [NSIndexPath indexPathForItem:1 inSection:0];
    IGListMoveIndexPath *move = [[IGListMoveIndexPath alloc] initWithFrom:from to:to];
    [collector.itemMoves addObject:move];
    XCTAssertTrue([collector hasChanges]);
}

- (void)test_whenHasItemReloads_thatHasChangesIsTrue {
    IGListItemUpdatesCollector *collector = [[IGListItemUpdatesCollector alloc] init];
    NSIndexPath *from = [NSIndexPath indexPathForItem:0 inSection:0];
    NSIndexPath *to = [NSIndexPath indexPathForItem:0 inSection:0];
    IGListReloadIndexPath *reload = [[IGListReloadIndexPath alloc] initWithFromIndexPath:from toIndexPath:to];
    [collector.itemReloads addObject:reload];
    XCTAssertTrue([collector hasChanges]);
}

@end
