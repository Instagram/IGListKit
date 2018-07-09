/**
 * Copyright (c) 2016-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <XCTest/XCTest.h>

#import "IGTestStoryboardCell.h"
#import "IGTestSingleStoryboardItemDataSource.h"
#import "IGTestStoryboardViewController.h"
#import "IGListTestCase.h"

#define genExpectation [self expectationWithDescription:NSStringFromSelector(_cmd)]

@interface IGListSingleStoryboardSectionControllerTests : XCTestCase

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) IGListAdapter *adapter;
@property (nonatomic, strong) IGListAdapterUpdater *updater;
@property (nonatomic, strong) IGTestSingleStoryboardItemDataSource *dataSource;
@property (nonatomic, strong) IGTestStoryboardViewController *viewController;
@property (nonatomic, strong) UIWindow *window;

@end

@implementation IGListSingleStoryboardSectionControllerTests

- (void)setUp {
    [super setUp];
    self.window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"IGTestStoryboard" bundle:[NSBundle bundleForClass:self.class]];
    self.viewController = [storyboard instantiateViewControllerWithIdentifier:@"testVC"];
    [self.window addSubview:self.viewController.view];
    [self.viewController performSelectorOnMainThread:@selector(loadView) withObject:nil waitUntilDone:YES];
    self.collectionView = self.viewController.collectionView;
    self.dataSource = [[IGTestSingleStoryboardItemDataSource alloc] init];
    self.updater = [[IGListAdapterUpdater alloc] init];
    self.adapter = [[IGListAdapter alloc] initWithUpdater:self.updater viewController:self.viewController workingRangeSize:2];
}

- (void)tearDown {
    [super tearDown];
    self.window = nil;
    self.viewController = nil;
    self.collectionView = nil;
    self.adapter = nil;
}

- (void)setupWithObjects:(NSArray *)objects {
    self.dataSource.objects = objects;
    self.adapter.collectionView = self.viewController.collectionView;
    self.adapter.dataSource = self.dataSource;
    [self.collectionView layoutIfNeeded];
}

- (void)test_whenDisplayingCollectionView_thatSectionsHaveOneItem {
    [self setupWithObjects:@[
                             genTestObject(@1, @"Foo"),
                             genTestObject(@2, @"Bar"),
                             genTestObject(@3, @"Baz"),
                             ]];
    XCTAssertEqual([self.collectionView numberOfSections], 3);
    XCTAssertEqual([self.collectionView numberOfItemsInSection:0], 1);
    XCTAssertEqual([self.collectionView numberOfItemsInSection:1], 1);
    XCTAssertEqual([self.collectionView numberOfItemsInSection:2], 1);
}

- (void)test_whenDisplayingCollectionView_thatCellsAreConfigured {
    [self setupWithObjects:@[
                             genTestObject(@1, @"Foo"),
                             genTestObject(@2, @"Bar"),
                             genTestObject(@3, @"Baz"),
                             ]];
    IGTestStoryboardCell *cell1 = (IGTestStoryboardCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    IGTestStoryboardCell *cell2 = (IGTestStoryboardCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1]];
    IGTestStoryboardCell *cell3 = (IGTestStoryboardCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:2]];
    XCTAssertEqualObjects(cell1.label.text, @"Foo");
    XCTAssertEqualObjects(cell2.label.text, @"Bar");
    XCTAssertEqualObjects(cell3.label.text, @"Baz");
}

- (void)test_whenDisplayingCollectionView_thatCellsAreSized {
    [self setupWithObjects:@[
                             genTestObject(@1, @"Foo"),
                             genTestObject(@2, @"Bar"),
                             genTestObject(@3, @"Baz"),
                             ]];
    IGTestStoryboardCell *cell1 = (IGTestStoryboardCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    IGTestStoryboardCell *cell2 = (IGTestStoryboardCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1]];
    IGTestStoryboardCell *cell3 = (IGTestStoryboardCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:2]];
    XCTAssertEqual(cell1.frame.size.height, 44);
    XCTAssertEqual(cell2.frame.size.height, 44);
    XCTAssertEqual(cell3.frame.size.height, 44);
}

- (void)test_whenItemUpdated_thatCellIsConfigured {
    [self setupWithObjects:@[
                             genTestObject(@1, @"Foo"),
                             genTestObject(@2, @"Bar"),
                             genTestObject(@3, @"Baz"),
                             ]];
    self.dataSource.objects = @[
                                genTestObject(@1, @"Foo"),
                                genTestObject(@2, @"Qux"), // new value
                                genTestObject(@3, @"Baz"),
                                ];
    XCTestExpectation *expectation = genExpectation;
    [self.adapter performUpdatesAnimated:YES completion:^(BOOL finished) {
        IGTestStoryboardCell *cell2 = (IGTestStoryboardCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1]];
        XCTAssertEqualObjects(cell2.label.text, @"Qux");
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:30 handler:nil];
}

@end
