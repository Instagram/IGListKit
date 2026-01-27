/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>

#import <IGListKit/IGListKit.h>

#import "IGListTestAdapterDataSource.h"
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

- (void)test_whenCalledMultipleTimes_thatReturnsSameAdapters {
    UIViewController *const viewController = [UIViewController new];
    IGListAdapter *const adapter = [[IGListAdapter alloc] initWithUpdater:[IGListAdapterUpdater new] viewController:viewController];

    NSArray<IGListAdapter *> *const adapters1 = [viewController associatedListAdapters];
    NSArray<IGListAdapter *> *const adapters2 = [viewController associatedListAdapters];

    XCTAssertEqual(adapters1.count, 1);
    XCTAssertEqual(adapters2.count, 1);
    XCTAssertEqual(adapters1.firstObject, adapter);
    XCTAssertEqual(adapters2.firstObject, adapter);
}

#pragma mark - Preferred Focus

- (void)test_whenCollectionViewDelegateImplementsPreferredFocus_thatDelegatesToIt {
    UIViewController *const viewController = [UIViewController new];
    UICollectionView *const collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 100, 100) collectionViewLayout:[UICollectionViewFlowLayout new]];

    IGListTestAdapterDataSource *const dataSource = [IGListTestAdapterDataSource new];
    dataSource.objects = @[@0, @1, @2];

    IGListAdapter *const adapter = [[IGListAdapter alloc] initWithUpdater:[IGListAdapterUpdater new] viewController:viewController];
    adapter.collectionView = collectionView;
    adapter.dataSource = dataSource;
    [collectionView reloadData];

    NSIndexPath *const expectedIndexPath = [NSIndexPath indexPathForItem:1 inSection:2];

    id mockDelegate = [OCMockObject mockForProtocol:@protocol(UICollectionViewDelegate)];
    [[[mockDelegate stub] andReturnValue:OCMOCK_VALUE(expectedIndexPath)] indexPathForPreferredFocusedViewInCollectionView:collectionView];
    [[[mockDelegate stub] andReturnValue:@YES] respondsToSelector:@selector(indexPathForPreferredFocusedViewInCollectionView:)];

    adapter.collectionViewDelegate = mockDelegate;

    NSIndexPath *const result = [adapter indexPathForPreferredFocusedViewInCollectionView:collectionView];
    XCTAssertEqualObjects(result, expectedIndexPath);
}

- (void)test_whenExperimentEnabled_thatReturnsFirstVisibleIndexPath {
    UIWindow *const window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    UIViewController *const viewController = [UIViewController new];
    UICollectionView *const collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 100, 100) collectionViewLayout:[UICollectionViewFlowLayout new]];
    [window addSubview:collectionView];

    IGListTestAdapterDataSource *const dataSource = [IGListTestAdapterDataSource new];
    dataSource.objects = @[@0, @1, @2];

    IGListAdapter *const adapter = [[IGListAdapter alloc] initWithUpdater:[IGListAdapterUpdater new] viewController:viewController];
    adapter.collectionView = collectionView;
    adapter.dataSource = dataSource;
    adapter.experiments = IGListExperimentFixPreferredFocusedView;

    [collectionView reloadData];
    [collectionView layoutIfNeeded];

    NSIndexPath *const result = [adapter indexPathForPreferredFocusedViewInCollectionView:collectionView];
    XCTAssertNotNil(result);
}

- (void)test_whenNoDelegate_andNoExperiment_thatReturnsNil {
    UIViewController *const viewController = [UIViewController new];
    UICollectionView *const collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 100, 100) collectionViewLayout:[UICollectionViewFlowLayout new]];

    IGListTestAdapterDataSource *const dataSource = [IGListTestAdapterDataSource new];
    dataSource.objects = @[@0, @1, @2];

    IGListAdapter *const adapter = [[IGListAdapter alloc] initWithUpdater:[IGListAdapterUpdater new] viewController:viewController];
    adapter.collectionView = collectionView;
    adapter.dataSource = dataSource;
    adapter.collectionViewDelegate = nil;
    adapter.experiments = IGListExperimentNone;

    [collectionView reloadData];

    NSIndexPath *const result = [adapter indexPathForPreferredFocusedViewInCollectionView:collectionView];
    XCTAssertNil(result);
}

@end
