/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <XCTest/XCTest.h>

#import <IGListKit/IGListKit.h>

#import <OCMock/OCMock.h>

#import "IGListAdapter+DebugDescription.h"
#import "IGListAdapterUpdater+DebugDescription.h"
#import "IGListAdapterUpdaterInternal.h"
#import "IGListAdapterInternal.h"
#import "IGListBatchUpdateData+DebugDescription.h"
#import "IGListMoveIndexInternal.h"
#import "IGListMoveIndexPathINternal.h"
#import "IGListTestAdapterDataSource.h"
#import "IGListTestCase.h"
#import "IGListUpdateTransactable.h"
#import "IGTestDelegateDataSource.h"
#import "IGTestObject.h"

@interface IGListAdapterUpdater (DebugDescriptionTests)
- (void)setTransaction:(id<IGListUpdateTransactable>)transaction;
@end

@interface IGListBindingSectionController (DebugDescriptionTests)
- (void)setViewModels:(NSArray<id<IGListDiffable>> *)viewModels;
@end


@interface IGListDebugDescriptionTests : IGListTestCase

@end

@implementation IGListDebugDescriptionTests

- (void)setUp {
    self.dataSource = [IGListTestAdapterDataSource new];
    [super setUp];
}

- (void)test_withListAdapter_thatDebugDescriptionIsValid {
    self.dataSource.objects = @[@1, @2, @3];

    IGListAdapter *adapter = [[IGListAdapter alloc] initWithUpdater:[IGListAdapterUpdater new] viewController:nil];
    adapter.collectionView = self.collectionView;
    adapter.dataSource = self.dataSource;

    [adapter.registeredCellIdentifiers addObject:@"IGCellIdentifier"];
    [adapter.registeredNibNames addObject:@"IGCellNibName"];
    [adapter.registeredSupplementaryViewIdentifiers addObject:@"IGSupplementaryViewIdentifier"];
    [adapter.registeredSupplementaryViewNibNames addObject:@"IGSupplementaryNibName"];

    IGListBindingSectionController *bindingSectionController = [[IGListBindingSectionController alloc] init];
    bindingSectionController.viewModels = @[[[IGTestObject alloc] initWithKey:@"Key" value:@(1)]];

    adapter.previousSectionMap = [[IGListSectionMap alloc] initWithMapTable:[NSMapTable strongToStrongObjectsMapTable]];
    [adapter.previousSectionMap updateWithObjects:@[@1] sectionControllers:@[bindingSectionController]];

    XCTAssertTrue(adapter.debugDescriptionLines.count > 0);
    XCTAssertTrue(adapter.debugDescription.length > 0);
}

- (void)test_withListAdapterUpdater_thatDebugDescriptionIsValid {
    id transactionMock = [OCMockObject mockForProtocol:@protocol(IGListUpdateTransactable)];

    IGListAdapterUpdater *updater = [IGListAdapterUpdater new];
    [updater setTransaction:transactionMock];

    [[[transactionMock expect] andReturnValue:@(IGListBatchUpdateStateIdle)] state];
    XCTAssertTrue(updater.debugDescriptionLines.count > 0);

    [[[transactionMock expect] andReturnValue:@(IGListBatchUpdateStateQueuedBatchUpdate)] state];
    XCTAssertTrue(updater.debugDescriptionLines.count > 0);

    [[[transactionMock expect] andReturnValue:@(IGListBatchUpdateStateExecutingBatchUpdateBlock)] state];
    XCTAssertTrue(updater.debugDescriptionLines.count > 0);

    [[[transactionMock expect] andReturnValue:@(IGListBatchUpdateStateExecutedBatchUpdateBlock)] state];
    XCTAssertTrue(updater.debugDescriptionLines.count > 0);
}

- (void)test_withBatchUpdateData_thatDebugDescriptionIsValid {
    NSMutableIndexSet *insertSections = [NSMutableIndexSet indexSet];
    [insertSections addIndex:0];
    [insertSections addIndex:1];

    NSIndexSet *deleteSections = [NSIndexSet indexSetWithIndex:5];
    IGListMoveIndex *moveSections = [[IGListMoveIndex alloc] initWithFrom:3 to:4];
    NSIndexPath *insertIndexPaths = [NSIndexPath indexPathForItem:0 inSection:0];
    NSIndexPath *deleteIndexPaths = [NSIndexPath indexPathForItem:0 inSection:0];
    IGListMoveIndexPath *moveIndexPaths = [[IGListMoveIndexPath alloc] initWithFrom:[NSIndexPath indexPathForItem:0 inSection:6]
                                                                                 to:[NSIndexPath indexPathForItem:1 inSection:6]];

    IGListBatchUpdateData *data = [[IGListBatchUpdateData alloc] initWithInsertSections:insertSections
                                                                         deleteSections:deleteSections
                                                                           moveSections:[NSSet setWithObject:moveSections]
                                                                       insertIndexPaths:@[insertIndexPaths]
                                                                       deleteIndexPaths:@[deleteIndexPaths]
                                                                       updateIndexPaths:@[]
                                                                         moveIndexPaths:@[moveIndexPaths]];

    XCTAssertTrue(data.debugDescriptionLines.count > 0);
}

@end

