/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>

#import <IGListKit/IGListKit.h>

@interface IGListCollectionScrollingTraitsTests : XCTestCase

@property (nonatomic, strong) id<IGListCollectionContext> collectionContext;
@property (nonatomic, strong) id mockCollectionView;

@end

@implementation IGListCollectionScrollingTraitsTests

- (void)setUp {
    [super setUp];

    self.mockCollectionView = [OCMockObject niceMockForClass:[UICollectionView class]];

    IGListAdapter *adapter = [[IGListAdapter alloc] initWithUpdater:[IGListAdapterUpdater new] viewController:nil];
    adapter.collectionView = self.mockCollectionView;
    self.collectionContext = (id<IGListCollectionContext>)adapter;
}

- (void)test_whenTracking_thatIsTrackingReturnsTrue {
    [[[self.mockCollectionView stub] andReturnValue:@YES] isTracking];
    XCTAssertTrue(self.collectionContext.scrollingTraits.isTracking);
}

- (void)test_whenNotTracking_thatIsTrackingReturnsFalse {
    [[[self.mockCollectionView stub] andReturnValue:@NO] isTracking];
    XCTAssertFalse(self.collectionContext.scrollingTraits.isTracking);
}

- (void)test_whenDragging_thatIsDraggingReturnsTrue {
    [[[self.mockCollectionView stub] andReturnValue:@YES] isDragging];
    XCTAssertTrue(self.collectionContext.scrollingTraits.isDragging);
}

- (void)test_whenDragging_thatIsDraggingReturnsFalse {
    [[[self.mockCollectionView stub] andReturnValue:@NO] isDragging];
    XCTAssertFalse(self.collectionContext.scrollingTraits.isDragging);
}

- (void)test_whenDecelerating_thatIsDeceleratingReturnsTrue {
    [[[self.mockCollectionView stub] andReturnValue:@YES] isDecelerating];
    XCTAssertTrue(self.collectionContext.scrollingTraits.isDecelerating);
}

- (void)test_whenDecelerating_thatIsDeceleratingReturnsFalse {
    [[[self.mockCollectionView stub] andReturnValue:@NO] isDecelerating];
    XCTAssertFalse(self.collectionContext.scrollingTraits.isDecelerating);
}


@end
