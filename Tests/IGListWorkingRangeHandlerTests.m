/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
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

- (void)insertObject:(id)object withController:(IGListSectionController *)controller atIndex:(NSInteger)index;

- (void)removeObjectAtIndex:(NSInteger)index;

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

- (void)insertObject:(id)object withController:(IGListSectionController *)controller atIndex:(NSInteger)index {
    NSMutableArray *const objects = [_objects mutableCopy];
    NSMutableDictionary *const map = [_map mutableCopy];
    [objects insertObject:object atIndex:index];
    map[object] = controller;
    _objects = [objects copy];
    _map = [map copy];
}

- (void)removeObjectAtIndex:(NSInteger)index {
    NSMutableArray *const objects = [_objects mutableCopy];
    NSMutableDictionary *const map = [_map mutableCopy];
    [map removeObjectForKey:[objects objectAtIndex:index]];
    [objects removeObjectAtIndex:index];
    _objects = [objects copy];
    _map = [map copy];
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
    [adapter.workingRangeHandler willDisplayItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] forListAdapter:adapter];

    [mockWorkingRangeDelegate verifyWithDelay:5];
}

- (void)test_whenDisplayingItemAtPath_withWorkingRangeSizeZero_thatAdjacentItemsDoNotEnterWorkingRange {
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
    IGListAdapter *adapter = [[IGListAdapter alloc] initWithUpdater:updater viewController:nil];
    id collectionView = [OCMockObject niceMockForClass:[UICollectionView class]];
    adapter.collectionView = collectionView;

    id mockWorkingRangeDelegate1 = [OCMockObject mockForProtocol:@protocol(IGListWorkingRangeDelegate)];
    id mockWorkingRangeDelegate2 = [OCMockObject mockForProtocol:@protocol(IGListWorkingRangeDelegate)];
    id mockWorkingRangeDelegate3 = [OCMockObject mockForProtocol:@protocol(IGListWorkingRangeDelegate)];

    adapter.dataSource = ds;
    controller1.workingRangeDelegate = mockWorkingRangeDelegate1;
    controller2.workingRangeDelegate = mockWorkingRangeDelegate2;
    controller3.workingRangeDelegate = mockWorkingRangeDelegate3;

    // Arrange 2: Force an update so we get the objects we configured through the system.
    [adapter performUpdatesAnimated:NO completion:nil];

    // Act: Tell the working range handler that the center item will be displayed.
    [[mockWorkingRangeDelegate1 reject] listAdapter:[OCMArg any] sectionControllerWillEnterWorkingRange:[OCMArg any]];
    [[mockWorkingRangeDelegate2 expect] listAdapter:adapter sectionControllerWillEnterWorkingRange:controller2];
    [[mockWorkingRangeDelegate3 reject] listAdapter:[OCMArg any] sectionControllerWillEnterWorkingRange:[OCMArg any]];
    [adapter.workingRangeHandler willDisplayItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1] forListAdapter:adapter];

    [mockWorkingRangeDelegate1 verifyWithDelay:5];
    [mockWorkingRangeDelegate2 verifyWithDelay:5];
    [mockWorkingRangeDelegate3 verifyWithDelay:5];
}

- (void)test_whenDisplayingItemAtPath_withWorkingRangeSizeOne_thatAdjacentItemsEnterWorkingRange {
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

    id mockWorkingRangeDelegate1 = [OCMockObject mockForProtocol:@protocol(IGListWorkingRangeDelegate)];
    id mockWorkingRangeDelegate2 = [OCMockObject mockForProtocol:@protocol(IGListWorkingRangeDelegate)];
    id mockWorkingRangeDelegate3 = [OCMockObject mockForProtocol:@protocol(IGListWorkingRangeDelegate)];

    adapter.dataSource = ds;
    controller1.workingRangeDelegate = mockWorkingRangeDelegate1;
    controller2.workingRangeDelegate = mockWorkingRangeDelegate2;
    controller3.workingRangeDelegate = mockWorkingRangeDelegate3;

    // Arrange 2: Force an update so we get the objects we configured through the system.
    [adapter performUpdatesAnimated:NO completion:nil];

    // Act: Tell the working range handler that the center item will be displayed.
    [[mockWorkingRangeDelegate1 expect] listAdapter:adapter sectionControllerWillEnterWorkingRange:controller1];
    [[mockWorkingRangeDelegate2 expect] listAdapter:adapter sectionControllerWillEnterWorkingRange:controller2];
    [[mockWorkingRangeDelegate3 expect] listAdapter:adapter sectionControllerWillEnterWorkingRange:controller3];
    [adapter.workingRangeHandler willDisplayItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1] forListAdapter:adapter];

    [mockWorkingRangeDelegate1 verifyWithDelay:5];
    [mockWorkingRangeDelegate2 verifyWithDelay:5];
    [mockWorkingRangeDelegate3 verifyWithDelay:5];
}

- (void)test_whenDisplayingItemAtPath_withWorkingRangeSizeOne_thatOnlyAdjacentAndVisibleItemsEnterWorkingRange {
    // Arrange 1: Set up a simple collection view and adapter with five elements.
    IGListTestSection *controller1 = [[IGListTestSection alloc] init];
    NSString *object1 = @"obj1";
    IGListTestSection *controller2 = [[IGListTestSection alloc] init];
    NSString *object2 = @"obj2";
    IGListTestSection *controller3 = [[IGListTestSection alloc] init];
    NSString *object3 = @"obj3";
    IGListTestSection *controller4 = [[IGListTestSection alloc] init];
    NSString *object4 = @"obj4";
    IGListTestSection *controller5 = [[IGListTestSection alloc] init];
    NSString *object5 = @"obj5";
    _IGTestWorkingRangeAdapterDataSource *ds = [[_IGTestWorkingRangeAdapterDataSource alloc] initWithObjects:@[object1, object2, object3, object4, object5]
                                                                                       objectToControllerMap:@{object1: controller1,
                                                                                                               object2: controller2,
                                                                                                               object3: controller3,
                                                                                                               object4: controller4,
                                                                                                               object5: controller5}];
    IGListReloadDataUpdater *updater = [[IGListReloadDataUpdater alloc] init];
    IGListAdapter *adapter = [[IGListAdapter alloc] initWithUpdater:updater viewController:nil workingRangeSize:1];
    id collectionView = [OCMockObject niceMockForClass:[UICollectionView class]];
    adapter.collectionView = collectionView;

    id mockWorkingRangeDelegate1 = [OCMockObject mockForProtocol:@protocol(IGListWorkingRangeDelegate)];
    id mockWorkingRangeDelegate2 = [OCMockObject mockForProtocol:@protocol(IGListWorkingRangeDelegate)];
    id mockWorkingRangeDelegate3 = [OCMockObject mockForProtocol:@protocol(IGListWorkingRangeDelegate)];
    id mockWorkingRangeDelegate4 = [OCMockObject mockForProtocol:@protocol(IGListWorkingRangeDelegate)];
    id mockWorkingRangeDelegate5 = [OCMockObject mockForProtocol:@protocol(IGListWorkingRangeDelegate)];

    adapter.dataSource = ds;
    controller1.workingRangeDelegate = mockWorkingRangeDelegate1;
    controller2.workingRangeDelegate = mockWorkingRangeDelegate2;
    controller3.workingRangeDelegate = mockWorkingRangeDelegate3;
    controller4.workingRangeDelegate = mockWorkingRangeDelegate4;
    controller5.workingRangeDelegate = mockWorkingRangeDelegate5;

    // Arrange 2: Force an update so we get the objects we configured through the system.
    [adapter performUpdatesAnimated:NO completion:nil];

    // Act: Tell the working range handler that the center item will be displayed.
    [[mockWorkingRangeDelegate1 reject] listAdapter:[OCMArg any] sectionControllerWillEnterWorkingRange:[OCMArg any]];
    [[mockWorkingRangeDelegate2 expect] listAdapter:adapter sectionControllerWillEnterWorkingRange:controller2];
    [[mockWorkingRangeDelegate3 expect] listAdapter:adapter sectionControllerWillEnterWorkingRange:controller3];
    [[mockWorkingRangeDelegate4 expect] listAdapter:adapter sectionControllerWillEnterWorkingRange:controller4];
    [[mockWorkingRangeDelegate5 reject] listAdapter:[OCMArg any] sectionControllerWillEnterWorkingRange:[OCMArg any]];
    [adapter.workingRangeHandler willDisplayItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:2] forListAdapter:adapter];

    [mockWorkingRangeDelegate1 verifyWithDelay:5];
    [mockWorkingRangeDelegate2 verifyWithDelay:5];
    [mockWorkingRangeDelegate3 verifyWithDelay:5];
    [mockWorkingRangeDelegate4 verifyWithDelay:5];
    [mockWorkingRangeDelegate5 verifyWithDelay:5];
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
    [adapter.workingRangeHandler willDisplayItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] forListAdapter:adapter];

    // Arrange 4: Wait for the item to move in-range
    [mockWorkingRangeDelegate verifyWithDelay:5];

    // Act: Tell the working range handler that the first item is now hidden.
    [[mockWorkingRangeDelegate expect] listAdapter:adapter sectionControllerDidExitWorkingRange:controller];
    [adapter.workingRangeHandler didEndDisplayingItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] forListAdapter:adapter];

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
    [adapter.workingRangeHandler willDisplayItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] forListAdapter:adapter];

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
    [adapter.workingRangeHandler willDisplayItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] forListAdapter:adapter];

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
    [adapter.workingRangeHandler willDisplayItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] forListAdapter:adapter];

    // Arrange 4: Wait for the item to move in-range.
    [mockWorkingRangeDelegate verifyWithDelay:5];

    // Act: Hide the first item, and watch for the second item to leave the working range.
    [[mockWorkingRangeDelegate expect] listAdapter:adapter sectionControllerDidExitWorkingRange:controller2];
    [adapter.workingRangeHandler didEndDisplayingItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] forListAdapter:adapter];

    [mockWorkingRangeDelegate verifyWithDelay:5];
}

- (void)test_whenDisplayingItemsAtPaths_withWorkingRangeSizeOne_thatSpuriousWorkingRangeCallsAreNotMade {
    // Arrange 1: Set up a simple collection view and adapter with a single element.
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

    id mockWorkingRangeDelegate1 = [OCMockObject mockForProtocol:@protocol(IGListWorkingRangeDelegate)];
    id mockWorkingRangeDelegate2 = [OCMockObject mockForProtocol:@protocol(IGListWorkingRangeDelegate)];

    adapter.dataSource = ds;
    controller1.workingRangeDelegate = mockWorkingRangeDelegate1;
    controller2.workingRangeDelegate = mockWorkingRangeDelegate2;

    // Arrange 2: Force an update so we get the objects we configured through the system.
    [adapter performUpdatesAnimated:NO completion:nil];

    // Arrange 3: Tell the working range handler that the first item in the list will be displayed.
    [[mockWorkingRangeDelegate1 expect] listAdapter:adapter sectionControllerWillEnterWorkingRange:controller1];
    [[mockWorkingRangeDelegate2 expect] listAdapter:adapter sectionControllerWillEnterWorkingRange:controller2];
    [adapter.workingRangeHandler willDisplayItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] forListAdapter:adapter];

    [mockWorkingRangeDelegate1 verifyWithDelay:5];
    [mockWorkingRangeDelegate2 verifyWithDelay:5];

    // Act: Tell the working range handler that the second item in the list will be displayed.
    [[mockWorkingRangeDelegate1 reject] listAdapter:[OCMArg any] sectionControllerWillEnterWorkingRange:[OCMArg any]];
    [[mockWorkingRangeDelegate2 reject] listAdapter:[OCMArg any] sectionControllerWillEnterWorkingRange:[OCMArg any]];
    [adapter.workingRangeHandler willDisplayItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1] forListAdapter:adapter];

    [mockWorkingRangeDelegate1 verifyWithDelay:5];
    [mockWorkingRangeDelegate2 verifyWithDelay:5];
}

- (void)DISABLED_test_whenDisplayingItemsAtPaths_withWorkingRangeSizeZero_thenRemovingFirstItem_thenInsertingItemAtLastPosition_thatItemEntersWorkingRange {
    // Arrange 1: Set up a simple collection view and adapter with a single element.
    IGListTestSection *controller1 = [[IGListTestSection alloc] init];
    NSString *object1 = @"obj1";
    IGListTestSection *controller2 = [[IGListTestSection alloc] init];
    NSString *object2 = @"obj2";
    _IGTestWorkingRangeAdapterDataSource *ds = [[_IGTestWorkingRangeAdapterDataSource alloc] initWithObjects:@[object1, object2]
                                                                                       objectToControllerMap:@{object1: controller1,
                                                                                                               object2: controller2}];
    IGListReloadDataUpdater *updater = [[IGListReloadDataUpdater alloc] init];
    IGListAdapter *adapter = [[IGListAdapter alloc] initWithUpdater:updater viewController:nil];
    id collectionView = [OCMockObject niceMockForClass:[UICollectionView class]];
    adapter.collectionView = collectionView;

    id mockWorkingRangeDelegate1 = [OCMockObject mockForProtocol:@protocol(IGListWorkingRangeDelegate)];
    id mockWorkingRangeDelegate2 = [OCMockObject mockForProtocol:@protocol(IGListWorkingRangeDelegate)];

    adapter.dataSource = ds;
    controller1.workingRangeDelegate = mockWorkingRangeDelegate1;
    controller2.workingRangeDelegate = mockWorkingRangeDelegate2;

    // Arrange 2: Force an update so we get the objects we configured through the system.
    [adapter performUpdatesAnimated:NO completion:nil];

    // Arrange 3: Tell the working range handler that the first two items in the list will be displayed.
    [[mockWorkingRangeDelegate1 expect] listAdapter:adapter sectionControllerWillEnterWorkingRange:controller1];
    [[mockWorkingRangeDelegate2 expect] listAdapter:adapter sectionControllerWillEnterWorkingRange:controller2];
    [adapter.workingRangeHandler willDisplayItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] forListAdapter:adapter];
    [adapter.workingRangeHandler willDisplayItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1] forListAdapter:adapter];
    [mockWorkingRangeDelegate1 verifyWithDelay:5];
    [mockWorkingRangeDelegate2 verifyWithDelay:5];

    // Arrange 4: Remove the object at the first index, and update the working range handler.
    [ds removeObjectAtIndex:0];
    [[mockWorkingRangeDelegate1 expect] listAdapter:adapter sectionControllerDidExitWorkingRange:controller1];
    [adapter.workingRangeHandler didEndDisplayingItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] forListAdapter:adapter];
    [mockWorkingRangeDelegate1 verifyWithDelay:5];

    // Act: Insert a new object at index one, and update the working range handler.
    [ds insertObject:object1 withController:controller1 atIndex:1];
    [[mockWorkingRangeDelegate1 expect] listAdapter:adapter sectionControllerWillEnterWorkingRange:controller1];
    [[mockWorkingRangeDelegate2 reject] listAdapter:[OCMArg any] sectionControllerWillEnterWorkingRange:[OCMArg any]];
    [[mockWorkingRangeDelegate2 reject] listAdapter:[OCMArg any] sectionControllerDidExitWorkingRange:[OCMArg any]];
    [adapter.workingRangeHandler willDisplayItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1] forListAdapter:adapter];
    [mockWorkingRangeDelegate1 verifyWithDelay:5];
    [mockWorkingRangeDelegate2 verifyWithDelay:5];
}

- (void)DISABLED_test_whenDisplayingItemAtPath_withWorkingRangeSizeZero_thenInsertingNewItem_thatVisibleItemsRemainInWorkingRange {
    // Arrange 1: Set up a simple collection view and adapter with a single element.
    IGListTestSection *controller1 = [[IGListTestSection alloc] init];
    NSString *object1 = @"obj1";
    IGListTestSection *controller2 = [[IGListTestSection alloc] init];
    NSString *object2 = @"obj2";
    _IGTestWorkingRangeAdapterDataSource *ds = [[_IGTestWorkingRangeAdapterDataSource alloc] initWithObjects:@[object1]
                                                                                       objectToControllerMap:@{object1: controller1}];
    IGListReloadDataUpdater *updater = [[IGListReloadDataUpdater alloc] init];
    IGListAdapter *adapter = [[IGListAdapter alloc] initWithUpdater:updater viewController:nil];
    id collectionView = [OCMockObject niceMockForClass:[UICollectionView class]];
    adapter.collectionView = collectionView;

    id mockWorkingRangeDelegate1 = [OCMockObject mockForProtocol:@protocol(IGListWorkingRangeDelegate)];
    id mockWorkingRangeDelegate2 = [OCMockObject mockForProtocol:@protocol(IGListWorkingRangeDelegate)];

    adapter.dataSource = ds;
    controller1.workingRangeDelegate = mockWorkingRangeDelegate1;
    controller2.workingRangeDelegate = mockWorkingRangeDelegate2;

    // Arrange 2: Force an update so we get the objects we configured through the system.
    [adapter performUpdatesAnimated:NO completion:nil];

    // Arrange 3: Tell the working range handler that the first item in the list will be displayed.
    [[mockWorkingRangeDelegate1 expect] listAdapter:adapter sectionControllerWillEnterWorkingRange:controller1];
    [adapter.workingRangeHandler willDisplayItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] forListAdapter:adapter];
    [mockWorkingRangeDelegate1 verifyWithDelay:5];

    // Arrange 4: Insert a second object in the first index.
    [ds insertObject:object2 withController:controller2 atIndex:0];

    // Act: Tell the working range handler that the new item will become visible.
    [[mockWorkingRangeDelegate1 reject] listAdapter:[OCMArg any] sectionControllerWillEnterWorkingRange:[OCMArg any]];
    [[mockWorkingRangeDelegate1 reject] listAdapter:[OCMArg any] sectionControllerDidExitWorkingRange:[OCMArg any]];
    [[mockWorkingRangeDelegate2 expect] listAdapter:adapter sectionControllerWillEnterWorkingRange:controller2];
    [[mockWorkingRangeDelegate2 reject] listAdapter:[OCMArg any] sectionControllerDidExitWorkingRange:[OCMArg any]];
    [adapter.workingRangeHandler willDisplayItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] forListAdapter:adapter];

    [mockWorkingRangeDelegate1 verifyWithDelay:5];
    [mockWorkingRangeDelegate2 verifyWithDelay:5];
}

@end
