/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant 
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <XCTest/XCTest.h>

#import <OCMock/OCMockObject.h>

#import <IGListKit/IGListKit.h>

#import "IGListAdapterInternal.h"
#import "IGListDisplayHandler.h"
#import "IGListTestAdapterDataSource.h"
#import "IGListTestSection.h"

@interface IGListDisplayHandlerTests : XCTestCase

@property (nonatomic, strong) IGListDisplayHandler *displayHandler;
@property (nonatomic, strong) IGListAdapter *adapter;
@property (nonatomic, strong) id mockDisplayDelegate;
@property (nonatomic, strong) id mockAdapterDelegate;
@property (nonatomic, strong) id mockAdapterDataSource;
@property (nonatomic, strong) IGListTestSection *list;
@property (nonatomic, strong) id object;

@end

@implementation IGListDisplayHandlerTests

- (void)setUp {
    [super setUp];

    self.list = [[IGListTestSection alloc] init];
    self.object = [[NSObject alloc] init];
    self.displayHandler = [[IGListDisplayHandler alloc] init];
    IGListCollectionView *collectionView = [OCMockObject niceMockForClass:[IGListCollectionView class]];
    self.mockAdapterDataSource = [OCMockObject niceMockForProtocol:@protocol(IGListAdapterDataSource)];
    IGListAdapterUpdater *updater = [IGListAdapterUpdater new];
    self.adapter = [[IGListAdapter alloc] initWithUpdatingDelegate:updater viewController:nil workingRangeSize:0];
    self.adapter.collectionView = collectionView;
    self.adapter.dataSource = self.mockAdapterDataSource;
    self.mockDisplayDelegate = [OCMockObject mockForProtocol:@protocol(IGListDisplayDelegate)];
    self.mockAdapterDelegate = [OCMockObject mockForProtocol:@protocol(IGListAdapterDelegate)];
}

- (void)tearDown {
    [super tearDown];
    self.list.displayDelegate = nil;
    self.adapter.delegate = nil;
}

- (void)test_whenDisplayingFirstCell_thatDisplayHandlerReceivesEvent {
    NSIndexPath *path = [NSIndexPath new];
    UICollectionViewCell *cell = [UICollectionViewCell new];

    [[self.mockDisplayDelegate expect] listAdapter:self.adapter willDisplayItemController:self.list];
    [[self.mockDisplayDelegate expect] listAdapter:self.adapter willDisplayItemController:self.list cell:cell atIndex:path.item];

    [[self.mockAdapterDelegate expect] listAdapter:self.adapter willDisplayItem:self.object atIndex:path.section];

    self.list.displayDelegate = self.mockDisplayDelegate;
    self.adapter.delegate = self.mockAdapterDelegate;
    [self.displayHandler willDisplayCell:cell forListAdapter:self.adapter itemController:self.list object:self.object indexPath:path];

    [self.mockDisplayDelegate verify];
    [self.mockAdapterDelegate verify];
}

- (void)test_whenDisplayingSecondCell_thatDisplayHandlerReceivesEvent {
    // simulate first cell appearing in the collection view
    NSIndexPath *firstPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.displayHandler willDisplayCell:[UICollectionViewCell new] forListAdapter:self.adapter itemController:self.list object:self.object indexPath:firstPath];

    NSIndexPath *nextPath = [NSIndexPath indexPathForItem:1 inSection:0];
    UICollectionViewCell *cell = [UICollectionViewCell new];
    [[self.mockDisplayDelegate expect] listAdapter:self.adapter willDisplayItemController:self.list cell:cell atIndex:nextPath.item];
    [[self.mockDisplayDelegate reject] listAdapter:self.adapter willDisplayItemController:self.list];

    [[self.mockAdapterDelegate reject] listAdapter:self.adapter willDisplayItem:self.object atIndex:firstPath.section];

    self.list.displayDelegate = self.mockDisplayDelegate;
    self.adapter.delegate = self.mockAdapterDelegate;
    [self.displayHandler willDisplayCell:cell forListAdapter:self.adapter itemController:self.list object:self.object indexPath:nextPath];

    [self.mockDisplayDelegate verify];
    [self.mockAdapterDelegate verify];
}

- (void)test_whenEndDisplayingSecondToLastCell_thatDisplayHandlerReceivesEvent {
    // simulate first cell appearing in the collection view
    NSIndexPath *firstPath = [NSIndexPath indexPathForItem:0 inSection:0];
    UICollectionViewCell *cellOne = [UICollectionViewCell new];
    UICollectionViewCell *cellTwo = [UICollectionViewCell new];

    [self.displayHandler willDisplayCell:cellOne forListAdapter:self.adapter itemController:self.list object:self.object indexPath:firstPath];

    NSIndexPath *nextPath = [NSIndexPath indexPathForItem:1 inSection:0];

    [self.displayHandler willDisplayCell:cellTwo forListAdapter:self.adapter itemController:self.list object:self.object indexPath:nextPath];

    [[self.mockDisplayDelegate reject] listAdapter:self.adapter didEndDisplayingItemController:self.list];
    [[self.mockDisplayDelegate expect] listAdapter:self.adapter didEndDisplayingItemController:self.list cell:cellOne atIndex:firstPath.item];

    [[self.mockAdapterDelegate reject] listAdapter:self.adapter didEndDisplayingItem:self.object atIndex:firstPath.section];

    self.list.displayDelegate = self.mockDisplayDelegate;
    self.adapter.delegate = self.mockAdapterDelegate;
    [self.displayHandler didEndDisplayingCell:cellOne forListAdapter:self.adapter itemController:self.list indexPath:firstPath];

    [self.mockDisplayDelegate verify];
    [self.mockAdapterDelegate verify];
}

- (void)test_whenEndDisplayingLastCell_thatDisplayHandlerReceivesEvent {
    // simulate first cell appearing then disappearing in the collection view
    NSIndexPath *firstPath = [NSIndexPath indexPathForItem:0 inSection:0];
    UICollectionViewCell *cell = [UICollectionViewCell new];

    [self.displayHandler willDisplayCell:cell forListAdapter:self.adapter itemController:self.list object:self.object indexPath:firstPath];

    [[self.mockDisplayDelegate expect] listAdapter:self.adapter didEndDisplayingItemController:self.list];
    [[self.mockDisplayDelegate expect] listAdapter:self.adapter didEndDisplayingItemController:self.list cell:cell atIndex:firstPath.item];

    [[self.mockAdapterDelegate expect] listAdapter:self.adapter didEndDisplayingItem:self.object atIndex:firstPath.section];

    self.list.displayDelegate = self.mockDisplayDelegate;
    self.adapter.delegate = self.mockAdapterDelegate;
    [self.displayHandler didEndDisplayingCell:cell forListAdapter:self.adapter itemController:self.list indexPath:firstPath];

    [self.mockDisplayDelegate verify];
    [self.mockAdapterDelegate verify];
}

- (void)test_whenEndDisplayingCell_withCellNeverDisplayed_thatDisplayHandlerReceivesNoEvent {
    //simulate a cell received didEndDisplay when it didn't receive willDisplay. OS 7 issue only
    NSIndexPath *firstPath = [NSIndexPath indexPathForItem:0 inSection:0];
    UICollectionViewCell *cell = [UICollectionViewCell new];

    // all following methods shouldn't be called.
    [[self.mockDisplayDelegate reject] listAdapter:self.adapter didEndDisplayingItemController:self.list];
    [[self.mockDisplayDelegate reject] listAdapter:self.adapter didEndDisplayingItemController:self.list cell:cell atIndex:firstPath.item];
    [[self.mockAdapterDelegate reject] listAdapter:self.adapter didEndDisplayingItem:self.object atIndex:firstPath.section];

    self.list.displayDelegate = self.mockDisplayDelegate;
    self.adapter.delegate = self.mockAdapterDelegate;
    [self.displayHandler didEndDisplayingCell:cell forListAdapter:self.adapter itemController:self.list indexPath:firstPath];
}

- (void)test_whenEndDisplayingCell_withEndDisplayTwice_thatDisplayHandlerReceivesOneEvent {
    //simulate a cell received didEndDisplay twice but willDisplay once. OS 7 issue only
    NSIndexPath *firstPath = [NSIndexPath indexPathForItem:0 inSection:0];
    UICollectionViewCell *cell = [UICollectionViewCell new];

    [self.displayHandler willDisplayCell:cell forListAdapter:self.adapter itemController:self.list object:self.object indexPath:firstPath];

    [[self.mockDisplayDelegate expect] listAdapter:self.adapter didEndDisplayingItemController:self.list];
    [[self.mockDisplayDelegate expect] listAdapter:self.adapter didEndDisplayingItemController:self.list cell:cell atIndex:firstPath.item];
    [[self.mockAdapterDelegate expect] listAdapter:self.adapter didEndDisplayingItem:self.object atIndex:firstPath.section];

    [[self.mockDisplayDelegate reject] listAdapter:self.adapter didEndDisplayingItemController:self.list];
    [[self.mockDisplayDelegate reject] listAdapter:self.adapter didEndDisplayingItemController:self.list cell:cell atIndex:firstPath.item];
    [[self.mockAdapterDelegate reject] listAdapter:self.adapter didEndDisplayingItem:self.object atIndex:firstPath.section];

    self.list.displayDelegate = self.mockDisplayDelegate;
    self.adapter.delegate = self.mockAdapterDelegate;
    //first call
    [self.displayHandler didEndDisplayingCell:cell forListAdapter:self.adapter itemController:self.list indexPath:firstPath];
    //second call
    [self.displayHandler didEndDisplayingCell:cell forListAdapter:self.adapter itemController:self.list indexPath:firstPath];

    [self.mockDisplayDelegate verify];
    [self.mockAdapterDelegate verify];
}


- (void)test_whenCellInserted_withDisplayedCellExistingAtPath_thatDisplayHandlerReceivesCorrectParams {
    // simulate first cell appearing in the collection view
    NSIndexPath *path = [NSIndexPath indexPathForItem:0 inSection:0];
    UICollectionViewCell *cellOne = [UICollectionViewCell new];

    // display the "old" cell/object
    [self.displayHandler willDisplayCell:cellOne forListAdapter:self.adapter itemController:self.list object:self.object indexPath:path];

    // simulate a new object being inserted into the index path of the old section
    IGListTestSection *anotherList = [IGListTestSection new];
    id anotherObject = [NSObject new];
    UICollectionViewCell *anotherCell = [UICollectionViewCell new];

    [[self.mockDisplayDelegate expect] listAdapter:self.adapter willDisplayItemController:anotherList];
    [[self.mockDisplayDelegate expect] listAdapter:self.adapter willDisplayItemController:anotherList cell:anotherCell atIndex:path.item];

    anotherList.displayDelegate = self.mockDisplayDelegate;
    [self.displayHandler willDisplayCell:anotherCell forListAdapter:self.adapter itemController:anotherList object:anotherObject indexPath:path];

    [self.mockDisplayDelegate verify];
}

@end
