/**
 * Copyright (c) 2016-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import <IGListKit/IGListReloadDataUpdater.h>
#import <IGListKit/IGListWorkingRangeDelegate.h>

#import "IGListAdapterInternal.h"
#import "IGListTestAdapterDataSource.h"
#import "IGListTestSection.h"
#import "IGListWorkingRangeHandler.h"

@interface _IGTestWorkingRangeAdapterDataSource : NSObject <IGListAdapterDataSource>

- (instancetype)initWithObjects:(NSArray *)objects
          objectToControllerMap:(NSDictionary<id, IGListSectionController *> *)map;

@end

@implementation _IGTestWorkingRangeAdapterDataSource {
    NSArray *_objects;
    NSDictionary *_map;
}

- (instancetype)initWithObjects:(NSArray *)objects
          objectToControllerMap:(NSDictionary<id,IGListSectionController *> *)map {
    if (self = [super init]) {
        _objects = objects;
        _map = map;
    }
    return self;
}

- (UIView *)emptyViewForListAdapter:(IGListAdapter *)listAdapter {
    return nil;
}

- (NSArray<id<IGListDiffable>> *)objectsForListAdapter:(IGListAdapter *)listAdapter {
    return _objects;
}

- (IGListSectionController *)listAdapter:(IGListAdapter *)listAdapter
                                 sectionControllerForObject:(id)object {
    return [_map objectForKey:object];
}

@end

@interface IGListWorkingRangeHandlerTests : XCTestCase

@end

@implementation IGListWorkingRangeHandlerTests

- (void)test_whenDisplayingItemAtPath_withWorkingRangeSizeZero_thatItemEntersWorkingRange {
    // Arrange 1: Set up a simple collection view and adapter with a single element.
    IGListTestSection *controller = [[IGListTestSection alloc] init];
    NSString *object = @"obj";
    _IGTestWorkingRangeAdapterDataSource *ds = [[_IGTestWorkingRangeAdapterDataSource alloc] initWithObjects:@[object]
                                                                                       objectToControllerMap:@{object: controller}];
    IGListReloadDataUpdater *updater = [[IGListReloadDataUpdater alloc] init];
    IGListAdapter *adapter = [[IGListAdapter alloc] initWithUpdater:updater viewController:nil];
    id collectionView = [OCMockObject niceMockForClass:[UICollectionView class]];
    adapter.collectionView = collectionView;
    id mockWorkingRangeDelegate = [OCMockObject mockForProtocol:@protocol(IGListWorkingRangeDelegate)];

    adapter.dataSource = ds;
    controller.workingRangeDelegate = mockWorkingRangeDelegate;

    // Arrange 2: Force an update so we get the objects we configured through the system.
    [adapter performUpdatesAnimated:NO completion:nil];

    // Act: Tell the working range handler that the first, and only item in the list will be displayed.
    [[mockWorkingRangeDelegate expect] listAdapter:adapter sectionControllerWillEnterWorkingRange:controller];
    [adapter.workingRangeHandler willDisplayItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] forListAdapter:adapter];

    [mockWorkingRangeDelegate verifyWithDelay:5];
}

- (void)test_whenDisplayingItemAtPath_withWorkingRangeSizeZero_thenHidingThatItem_thatItemLeavesWorkingRange {
    // Arrange 1: Set up a simple collection view and adapter with a single element.
    IGListTestSection *controller = [[IGListTestSection alloc] init];
    NSString *object = @"obj";
    _IGTestWorkingRangeAdapterDataSource *ds = [[_IGTestWorkingRangeAdapterDataSource alloc] initWithObjects:@[object]
                                                                                       objectToControllerMap:@{object: controller}];
    IGListReloadDataUpdater *updater = [[IGListReloadDataUpdater alloc] init];
    IGListAdapter *adapter = [[IGListAdapter alloc] initWithUpdater:updater viewController:nil];
    id collectionView = [OCMockObject niceMockForClass:[UICollectionView class]];
    adapter.collectionView = collectionView;
    id mockWorkingRangeDelegate = [OCMockObject mockForProtocol:@protocol(IGListWorkingRangeDelegate)];

    adapter.dataSource = ds;
    controller.workingRangeDelegate = mockWorkingRangeDelegate;

    // Arrange 2: Force an update so we get the objects we configured through the system.
    [adapter performUpdatesAnimated:NO completion:nil];

    // Arrange 3: Tell the working range handler that the first, and only item in the list will be displayed.
    [[mockWorkingRangeDelegate expect] listAdapter:adapter sectionControllerWillEnterWorkingRange:controller];
    [adapter.workingRangeHandler willDisplayItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] forListAdapter:adapter];

    // Arrange 4: Wait for the item to move in-range
    [mockWorkingRangeDelegate verifyWithDelay:5];

    // Act: Tell the working range handler that the first item is now hidden.
    [[mockWorkingRangeDelegate expect] listAdapter:adapter sectionControllerDidExitWorkingRange:controller];
    [adapter.workingRangeHandler didEndDisplayingItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] forListAdapter:adapter];

    [mockWorkingRangeDelegate verifyWithDelay:5];
}

- (void)test_whenDisplayingItemAtPath_withWorkingRangeSizeOne_thatNextItemEntersWorkingRange {
    // Arrange 1: Set up a simple collection view and adapter with two elements.
    IGListTestSection *controller1 = [[IGListTestSection alloc] init];
    NSString *object1 = @"obj1";
    IGListTestSection *controller2 = [[IGListTestSection alloc] init];
    NSString *object2 = @"obj2";
    _IGTestWorkingRangeAdapterDataSource *ds = [[_IGTestWorkingRangeAdapterDataSource alloc] initWithObjects:@[object1, object2]
                                                                                       objectToControllerMap:@{object1: controller1,
                                                                                                               object2: controller2}];
    IGListReloadDataUpdater *updater = [[IGListReloadDataUpdater alloc] init];
    IGListAdapter *adapter = [[IGListAdapter alloc] initWithUpdater:updater viewController:nil workingRangeSize:1];
    id collectionView = [OCMockObject niceMockForClass:[UICollectionView class]];
    adapter.collectionView = collectionView;
    id mockWorkingRangeDelegate = [OCMockObject mockForProtocol:@protocol(IGListWorkingRangeDelegate)];

    adapter.dataSource = ds;
    controller2.workingRangeDelegate = mockWorkingRangeDelegate;

    // Arrange 2: Force an update so we get the objects we configured through the system.
    [adapter performUpdatesAnimated:NO completion:nil];

    // Act: Tell the working range handler that the first, and only item in the list will be displayed.
    [[mockWorkingRangeDelegate expect] listAdapter:adapter sectionControllerWillEnterWorkingRange:controller2];
    [adapter.workingRangeHandler willDisplayItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] forListAdapter:adapter];

    [mockWorkingRangeDelegate verifyWithDelay:5];
}

- (void)test_whenDisplayingItemAtPath_withWorkingRangeSizeOne_thatThirdItemDoesNotEnterWorkingRange {
    // Arrange 1: Set up a simple collection view and adapter with three elements.
    IGListTestSection *controller1 = [[IGListTestSection alloc] init];
    NSString *object1 = @"obj1";
    IGListTestSection *controller2 = [[IGListTestSection alloc] init];
    NSString *object2 = @"obj2";
    IGListTestSection *controller3 = [[IGListTestSection alloc] init];
    NSString *object3 = @"obj3";
    _IGTestWorkingRangeAdapterDataSource *ds = [[_IGTestWorkingRangeAdapterDataSource alloc] initWithObjects:@[object1, object2, object3]
                                                                                       objectToControllerMap:@{object1: controller1,
                                                                                                               object2: controller2,
                                                                                                               object3: controller3}];
    IGListReloadDataUpdater *updater = [[IGListReloadDataUpdater alloc] init];
    IGListAdapter *adapter = [[IGListAdapter alloc] initWithUpdater:updater viewController:nil workingRangeSize:1];
    id collectionView = [OCMockObject niceMockForClass:[UICollectionView class]];
    adapter.collectionView = collectionView;
    id mockWorkingRangeDelegate2 = [OCMockObject mockForProtocol:@protocol(IGListWorkingRangeDelegate)];
    id mockWorkingRangeDelegate3 = [OCMockObject mockForProtocol:@protocol(IGListWorkingRangeDelegate)];

    adapter.dataSource = ds;
    controller2.workingRangeDelegate = mockWorkingRangeDelegate2;
    controller3.workingRangeDelegate = mockWorkingRangeDelegate3;

    // Arrange 2: Force an update so we get the objects we configured through the system.
    [adapter performUpdatesAnimated:NO completion:nil];

    // Act: Tell the working range handler that the first, and only item in the list will be displayed.
    [[mockWorkingRangeDelegate2 expect] listAdapter:adapter sectionControllerWillEnterWorkingRange:controller2];
    [[mockWorkingRangeDelegate3 reject] listAdapter:[OCMArg any] sectionControllerWillEnterWorkingRange:[OCMArg any]];
    [adapter.workingRangeHandler willDisplayItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] forListAdapter:adapter];

    [mockWorkingRangeDelegate2 verifyWithDelay:5];
    [mockWorkingRangeDelegate3 verify];
}

- (void)test_whenDisplayingItemAtPath_withWorkingRangeSizeOne_thenEndDisplayingThatItem_thatNextItemLeavesWorkingRange {
    // Arrange 1: Set up a simple collection view and adapter with two elements.
    IGListTestSection *controller1 = [[IGListTestSection alloc] init];
    NSString *object1 = @"obj1";
    IGListTestSection *controller2 = [[IGListTestSection alloc] init];
    NSString *object2 = @"obj2";
    _IGTestWorkingRangeAdapterDataSource *ds = [[_IGTestWorkingRangeAdapterDataSource alloc] initWithObjects:@[object1, object2]
                                                                                       objectToControllerMap:@{object1: controller1,
                                                                                                               object2: controller2}];
    IGListReloadDataUpdater *updater = [[IGListReloadDataUpdater alloc] init];
    IGListAdapter *adapter = [[IGListAdapter alloc] initWithUpdater:updater viewController:nil workingRangeSize:1];
    id collectionView = [OCMockObject niceMockForClass:[UICollectionView class]];
    adapter.collectionView = collectionView;
    id mockWorkingRangeDelegate = [OCMockObject mockForProtocol:@protocol(IGListWorkingRangeDelegate)];

    adapter.dataSource = ds;
    controller2.workingRangeDelegate = mockWorkingRangeDelegate;

    // Arrange 2: Force an update so we get the objects we configured through the system.
    [adapter performUpdatesAnimated:NO completion:nil];

    // Arrange 3: Tell the working range handler that the first, and only item in the list will be displayed.
    [[mockWorkingRangeDelegate expect] listAdapter:adapter sectionControllerWillEnterWorkingRange:controller2];
    [adapter.workingRangeHandler willDisplayItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] forListAdapter:adapter];

    // Arrange 4: Wait for the item to move in-range.
    [mockWorkingRangeDelegate verifyWithDelay:5];

    // Act: Hide the first item, and watch for the second item to leave the working range.
    [[mockWorkingRangeDelegate expect] listAdapter:adapter sectionControllerDidExitWorkingRange:controller2];
    [adapter.workingRangeHandler didEndDisplayingItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] forListAdapter:adapter];
    
    [mockWorkingRangeDelegate verifyWithDelay:5];
}

@end
