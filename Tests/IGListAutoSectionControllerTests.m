/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <XCTest/XCTest.h>

#import <IGListKit/IGListKit.h>

#import "IGTestAutoDataSource.h"
#import "IGTestAutoObject.h"
#import "IGTestStringBindableCell.h"
#import "IGTestNumberBindableCell.h"

@interface IGListAutoSectionControllerTests : XCTestCase

@property (nonatomic, strong) IGListCollectionView *collectionView;
@property (nonatomic, strong) IGListAdapter *adapter;
@property (nonatomic, strong) IGTestAutoDataSource *dataSource;
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) UIWindow *window;

@end

@implementation IGListAutoSectionControllerTests

- (void)setUp {
    [super setUp];

    self.window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 100, 1000)];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionView = [[IGListCollectionView alloc] initWithFrame:self.window.bounds collectionViewLayout:layout];

    [self.window addSubview:self.collectionView];

    self.dataSource = [IGTestAutoDataSource new];
    self.adapter = [[IGListAdapter alloc] initWithUpdater:[IGListAdapterUpdater new]
                                           viewController:nil
                                         workingRangeSize:0];
}

- (void)tearDown {
    [super tearDown];

    self.window = nil;
    self.collectionView = nil;
    self.adapter = nil;
    self.dataSource = nil;
}

- (void)setupWithObjects:(NSArray<IGTestAutoObject *> *)objects {
    self.dataSource.objects = objects;
    self.adapter.collectionView = self.collectionView;
    self.adapter.dataSource = self.dataSource;
    [self.collectionView layoutIfNeeded];
}

- (id)cellAtSection:(NSInteger)section item:(NSInteger)item {
    return [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:section]];
}

- (void)test_whenInitialLoad_withEmptyViewModels_thatCollectionViewEmpty {
    [self setupWithObjects:@[
                             [[IGTestAutoObject alloc] initWithKey:@1 objects:@[]]
                             ]];
    XCTAssertEqual([self.collectionView numberOfSections], 1);
    XCTAssertEqual([self.collectionView numberOfItemsInSection:0], 0);
}

- (void)test_whenInitialLoad_withMultipleViewModels_thatCellsMappedAndConfigured {
    [self setupWithObjects:@[
                             [[IGTestAutoObject alloc] initWithKey:@1 objects:@[@7, @"seven"]],
                             [[IGTestAutoObject alloc] initWithKey:@2 objects:@[@"foo", @"bar", @42]],
                             [[IGTestAutoObject alloc] initWithKey:@3 objects:@[]],
                             ]];

    XCTAssertEqual([self.collectionView numberOfSections], 3);
    XCTAssertEqual([self.collectionView numberOfItemsInSection:0], 2);
    XCTAssertEqual([self.collectionView numberOfItemsInSection:1], 3);
    XCTAssertEqual([self.collectionView numberOfItemsInSection:2], 0);

    IGTestNumberBindableCell *cell00 = [self cellAtSection:0 item:0];
    IGTestStringBindableCell *cell01 = [self cellAtSection:0 item:1];
    IGTestStringBindableCell *cell10 = [self cellAtSection:1 item:0];
    IGTestStringBindableCell *cell11 = [self cellAtSection:1 item:1];
    IGTestNumberBindableCell *cell12 = [self cellAtSection:1 item:2];

    XCTAssertEqualObjects(cell00.textField.text, @"7");
    XCTAssertEqualObjects(cell01.label.text, @"seven");
    XCTAssertEqualObjects(cell10.label.text, @"foo");
    XCTAssertEqualObjects(cell11.label.text, @"bar");
    XCTAssertEqualObjects(cell12.textField.text, @"42");
}

- (void)test_ {
    [self setupWithObjects:@[
                             [[IGTestAutoObject alloc] initWithKey:@1 objects:@[@7, @"seven"]],
                             ]];

    self.dataSource.objects = @[
                                [[IGTestAutoObject alloc] initWithKey:@1 objects:@[@7, @"seven", @8, @"eight"]],
                                ];

    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self.adapter performUpdatesAnimated:YES completion:^(BOOL finished) {
        XCTAssertEqual([self.collectionView numberOfSections], 1);
        XCTAssertEqual([self.collectionView numberOfItemsInSection:0], 4);

        IGTestNumberBindableCell *cell00 = [self cellAtSection:0 item:0];
        IGTestStringBindableCell *cell01 = [self cellAtSection:0 item:1];
        IGTestNumberBindableCell *cell02 = [self cellAtSection:0 item:2];
        IGTestStringBindableCell *cell03 = [self cellAtSection:0 item:3];

        XCTAssertEqualObjects(cell00.textField.text, @"7");
        XCTAssertEqualObjects(cell01.label.text, @"seven");
        XCTAssertEqualObjects(cell02.textField.text, @"8");
        XCTAssertEqualObjects(cell03.label.text, @"eight");

        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:15 handler:nil];
}

@end
