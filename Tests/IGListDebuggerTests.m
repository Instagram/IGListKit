/**
 * Copyright (c) 2016-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <XCTest/XCTest.h>

#import <IGListKit/IGListKit.h>
#import "IGListMoveIndexInternal.h"
#import "IGListMoveIndexPathInternal.h"

#import "IGListDebugger.h"
#import "IGListAdapterUpdaterInternal.h"
#import "IGListTestAdapterDataSource.h"

@interface IGListDebuggerTests : XCTestCase

@end

@implementation IGListDebuggerTests

- (void)test_whenSearchingAdapterInstances_thatCorrectCountReturned {
    // purge any leftover tracking
    [IGListDebugger clear];

    UIViewController *controller = [UIViewController new];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[UICollectionViewFlowLayout new]];
    IGListAdapterUpdater *updater = [IGListAdapterUpdater new];
    NSIndexPath *path = [NSIndexPath indexPathForItem:0 inSection:0];
    updater.applyingUpdateData = [[IGListBatchUpdateData alloc] initWithInsertSections:[NSIndexSet indexSetWithIndex:1]
                                                                        deleteSections:[NSIndexSet indexSetWithIndex:2]
                                                                          moveSections:[NSSet setWithObject:[[IGListMoveIndex alloc] initWithFrom:3 to:4]]
                                                                      insertIndexPaths:@[path]
                                                                      deleteIndexPaths:@[path]
                                                                        moveIndexPaths:@[[[IGListMoveIndexPath alloc] initWithFrom:path to:path]]];
    IGListTestAdapterDataSource *dataSource = [IGListTestAdapterDataSource new];
    dataSource.objects = @[@1, @2, @3];
    IGListAdapter *adapter1 = [[IGListAdapter alloc] initWithUpdater:[IGListAdapterUpdater new] viewController:nil workingRangeSize:0];
    adapter1.collectionView = collectionView;
    adapter1.dataSource = dataSource;
    IGListAdapter *adapter2 = [[IGListAdapter alloc] initWithUpdater:[IGListAdapterUpdater new] viewController:controller workingRangeSize:2];
    adapter2.collectionView = collectionView;
    IGListAdapter *adapter3 = [[IGListAdapter alloc] initWithUpdater:[IGListAdapterUpdater new] viewController:controller workingRangeSize:2];
    adapter3.collectionView = collectionView;

    NSArray *descriptions = [IGListDebugger adapterDescriptions];
    XCTAssertEqual(descriptions.count, 3);
}

@end
