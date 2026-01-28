/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>

#import <IGListKit/IGListKit.h>

#import "IGListAdapterInternal.h"
#import "IGListAdapterUpdater.h"
#import "IGListTestHelpers.h"
#import "IGTestDelegateDataSource.h"
#import "IGTestObject.h"
#import "IGListAdapterDelegateAnnouncer.h"
#import "IGTestCell.h"

@interface IGListAdapterDelegateAnnouncerTests : XCTestCase

// These objects are created for you in -setUp
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UIViewController *viewController;
@property (nonatomic, strong) IGListAdapterDelegateAnnouncer *announcer;

@property (nonatomic, strong) UICollectionView *collectionView1;
@property (nonatomic, strong) UICollectionView *collectionView2;

@property (nonatomic, strong) id<IGListTestCaseDataSource> dataSource1;
@property (nonatomic, strong) id<IGListTestCaseDataSource> dataSource2;
@property (nonatomic, strong) IGListAdapter *adapter1;
@property (nonatomic, strong) IGListAdapter *adapter2;

@end

@implementation IGListAdapterDelegateAnnouncerTests

- (void)setUp {
    [super setUp];

    self.window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    self.viewController = [UIViewController new];
    self.announcer = [IGListAdapterDelegateAnnouncer new];

    self.collectionView1 = [[UICollectionView alloc] initWithFrame:self.window.bounds collectionViewLayout:[UICollectionViewFlowLayout new]];
    [self.window addSubview:self.collectionView1];

    self.collectionView2 = [[UICollectionView alloc] initWithFrame:self.window.bounds collectionViewLayout:[UICollectionViewFlowLayout new]];
    [self.window addSubview:self.collectionView2];

    IGTestDelegateDataSource *const dataSource1 = [IGTestDelegateDataSource new];
    self.dataSource1 = dataSource1;

    IGTestDelegateDataSource *const dataSource2 = [IGTestDelegateDataSource new];
    self.dataSource2 = dataSource2;

    self.adapter1 = [[IGListAdapter alloc] initWithUpdater:[IGListAdapterUpdater new] viewController:self.viewController];
    self.adapter1.globalDelegateAnnouncer = self.announcer;

    self.adapter2 = [[IGListAdapter alloc] initWithUpdater:[IGListAdapterUpdater new] viewController:self.viewController];
    self.adapter2.globalDelegateAnnouncer = self.announcer;
}

- (void)setupAdapter1WithObjects:(NSArray *)objects {
    self.dataSource1.objects = objects;
    self.adapter1.collectionView = self.collectionView1;
    self.adapter1.dataSource = self.dataSource1;
    [self.collectionView1 layoutIfNeeded];
}

- (void)setupAdapter2WithObjects:(NSArray *)objects {
    self.dataSource2.objects = objects;
    self.adapter2.collectionView = self.collectionView2;
    self.adapter2.dataSource = self.dataSource2;
    [self.collectionView2 layoutIfNeeded];
}

#pragma mark - Single adapter, multiple listeners

- (void)test_whenShowingOneItem_withTwoListeners_withOneAdapter_thatBothListenersReceivesWillDisplay{
    [self setupAdapter1WithObjects:@[]];

    IGTestObject *const object = genTestObject(@1, @1);
    self.dataSource1.objects = @[
        object
    ];

    NSIndexPath *const indexPath = [NSIndexPath indexPathForItem:0 inSection:0];

    id mockDisplayHandler1 = [OCMockObject mockForProtocol:@protocol(IGListAdapterDelegate)];
    [self.announcer addListener:mockDisplayHandler1];
    [[mockDisplayHandler1 expect] listAdapter:self.adapter1 willDisplayObject:object atIndex:0];
    [[mockDisplayHandler1 expect] listAdapter:self.adapter1 willDisplayObject:object cell: [OCMArg any] atIndexPath:indexPath];

    id mockDisplayHandler2 = [OCMockObject mockForProtocol:@protocol(IGListAdapterDelegate)];
    [self.announcer addListener:mockDisplayHandler2];
    [[mockDisplayHandler2 expect] listAdapter:self.adapter1 willDisplayObject:object atIndex:0];
    [[mockDisplayHandler2 expect] listAdapter:self.adapter1 willDisplayObject:object cell: [OCMArg any] atIndexPath:indexPath];

    XCTestExpectation *expectation = genExpectation;
    [self.adapter1 performUpdatesAnimated:NO completion:^(BOOL finished2) {
        [mockDisplayHandler1 verify];
        [mockDisplayHandler2 verify];
        XCTAssertTrue(finished2);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)test_whenRemovignOneItem_withTwoListeners_withOneAdapter_thatBothListenersReceivesEndDisplay {
    IGTestObject *const object = genTestObject(@1, @1);
    NSIndexPath *const zeroIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];

    [self setupAdapter1WithObjects:@[object]];

    self.dataSource1.objects = @[];

    id mockDisplayHandler1 = [OCMockObject mockForProtocol:@protocol(IGListAdapterDelegate)];
    [self.announcer addListener:mockDisplayHandler1];
    [[mockDisplayHandler1 expect] listAdapter:self.adapter1 didEndDisplayingObject:object atIndex:0];
    [[mockDisplayHandler1 expect] listAdapter:self.adapter1 didEndDisplayingObject:object cell:[OCMArg any] atIndexPath: zeroIndexPath];

    id mockDisplayHandler2 = [OCMockObject mockForProtocol:@protocol(IGListAdapterDelegate)];
    [self.announcer addListener:mockDisplayHandler2];
    [[mockDisplayHandler2 expect] listAdapter:self.adapter1 didEndDisplayingObject:object atIndex:0];
    [[mockDisplayHandler2 expect] listAdapter:self.adapter1 didEndDisplayingObject:object cell:[OCMArg any] atIndexPath: zeroIndexPath];

    XCTestExpectation *expectation = genExpectation;
    [self.adapter1 performUpdatesAnimated:NO completion:^(BOOL finished2) {
        [mockDisplayHandler1 verify];
        [mockDisplayHandler2 verify];
        XCTAssertTrue(finished2);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:30 handler:nil];
}

#pragma mark - Remove listener

- (void)test_whenRemovingListener_thatListenerDoesNotReceiveCallbacks {
    [self setupAdapter1WithObjects:@[]];

    IGTestObject *const object = genTestObject(@1, @1);
    self.dataSource1.objects = @[object];

    id mockDisplayHandler = [OCMockObject mockForProtocol:@protocol(IGListAdapterDelegate)];
    [self.announcer addListener:mockDisplayHandler];
    [self.announcer removeListener:mockDisplayHandler];

    // Listener was removed, so it should NOT receive any callbacks
    [[mockDisplayHandler reject] listAdapter:[OCMArg any] willDisplayObject:[OCMArg any] atIndex:0];
    [[mockDisplayHandler reject] listAdapter:[OCMArg any] willDisplayObject:[OCMArg any] cell:[OCMArg any] atIndexPath:[OCMArg any]];

    XCTestExpectation *expectation = genExpectation;
    [self.adapter1 performUpdatesAnimated:NO completion:^(BOOL finished) {
        [mockDisplayHandler verify];
        XCTAssertTrue(finished);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:30 handler:nil];
}

#pragma mark - Two adapters, single listener

- (void)test_whenShowingTwoItems_withOneListeners_withTwoAdapters_thatBothItemsSendWillDisplay {
    [self setupAdapter1WithObjects:@[]];
    [self setupAdapter2WithObjects:@[]];

    IGTestObject *const object1 = genTestObject(@1, @1);
    NSIndexPath *const zeroIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];

    self.dataSource1.objects = @[
        object1
    ];

    IGTestObject *const object2 = genTestObject(@1, @1);
    self.dataSource2.objects = @[
        object2
    ];

    id mockDisplayHandler = [OCMockObject mockForProtocol:@protocol(IGListAdapterDelegate)];
    [self.announcer addListener:mockDisplayHandler];

    [[mockDisplayHandler expect] listAdapter:self.adapter1 willDisplayObject:object1 atIndex:0];
    [[mockDisplayHandler expect] listAdapter:self.adapter1 willDisplayObject:object1 cell: [OCMArg any] atIndexPath: zeroIndexPath];

    [[mockDisplayHandler expect] listAdapter:self.adapter2 willDisplayObject:object2 atIndex:0];
    [[mockDisplayHandler expect] listAdapter:self.adapter2 willDisplayObject:object2 cell: [OCMArg any] atIndexPath: zeroIndexPath];

    XCTestExpectation *expectation = genExpectation;
    [self.adapter1 performUpdatesAnimated:NO completion:^(BOOL finished1) {
        [self.adapter2 performUpdatesAnimated:NO completion:^(BOOL finished2) {
            [mockDisplayHandler verify];
            XCTAssertTrue(finished1);
            XCTAssertTrue(finished2);
            [expectation fulfill];
        }];
    }];
    [self waitForExpectationsWithTimeout:30 handler:nil];
}

@end
