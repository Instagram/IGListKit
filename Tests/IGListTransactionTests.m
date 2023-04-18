/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <XCTest/XCTest.h>

#import "IGListAdapterUpdater.h"
#import "IGListBatchUpdateTransaction.h"
#import "IGListDataSourceChangeTransaction.h"
#import "IGListReloadTransaction.h"
#import "IGListTestUICollectionViewDataSource.h"
#import "IGListTransitionData.h"

@interface IGListBatchUpdateTransaction (Tests)

- (NSInteger)mode;
- (void)setSectionData:(IGListTransitionData *)sectionData;

@end

@interface IGListTransactionTests : XCTestCase {
    IGListUpdateTransactationConfig _config;
}

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) IGListTestUICollectionViewDataSource *dataSource;
@property (nonatomic, strong) IGListTransitionDataApplyBlock applySectionDataBlock;

@end

@implementation IGListTransactionTests

- (IGListCollectionViewBlock)collectionViewBlock {
    return ^UICollectionView *{ return self.collectionView; };
}

- (IGListTransitionDataBlock)dataBlockFromObjects:(NSArray *)fromObjects toObjects:(NSArray *)toObjects {
    return ^IGListTransitionData *{
        return [[IGListTransitionData alloc] initFromObjects:fromObjects toObjects:toObjects toSectionControllers:@[]];
    };
}

- (IGListBatchUpdateTransaction *)makeBatchUpdateTransaction {
    return [[IGListBatchUpdateTransaction alloc] initWithCollectionViewBlock:[self collectionViewBlock]
                                                                     updater:[IGListAdapterUpdater new]
                                                                    delegate:nil
                                                                      config:_config
                                                                    animated:NO
                                                            sectionDataBlock:[self dataBlockFromObjects:@[] toObjects:@[@0]]
                                                       applySectionDataBlock:self.applySectionDataBlock
                                                            itemUpdateBlocks:@[]
                                                            completionBlocks:@[]];
}

- (IGListDataSourceChangeTransaction *)makeDataSourceChangeTransaction {
    return [[IGListDataSourceChangeTransaction alloc] initWithChangeBlock:^{}
                                                         itemUpdateBlocks:@[]
                                                         completionBlocks:@[]];
}

- (IGListReloadTransaction *)makeReloadTransaction {
    return [[IGListReloadTransaction alloc] initWithCollectionViewBlock:[self collectionViewBlock]
                                                                updater:[IGListAdapterUpdater new]
                                                               delegate:nil
                                                            reloadBlock:^{}
                                                       itemUpdateBlocks:@[]
                                                       completionBlocks:@[]];
}

- (void)setUp {
    [super setUp];

    self.window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.window.frame collectionViewLayout:layout];
    [self.window addSubview:self.collectionView];

    self.dataSource = [[IGListTestUICollectionViewDataSource alloc] initWithCollectionView:self.collectionView];
    __weak __typeof__(self) weakSelf = self;
    self.applySectionDataBlock = ^(IGListTransitionData *data) {
        weakSelf.dataSource.sections = data.toObjects;
    };

    memset(&_config, 0, sizeof(IGListUpdateTransactationConfig));
}

- (void)tearDown {
    [super tearDown];
    self.collectionView = nil;
    self.dataSource = nil;
    self.window = nil;
    memset(&_config, 0, sizeof(IGListUpdateTransactationConfig));
}

- (void)test_withBatchUpdateTransaction_thatNilCollectionViewBailsCorrectly {
    self.collectionView = nil;
    IGListBatchUpdateTransaction *batchUpdateTransaction = [self makeBatchUpdateTransaction];
    [batchUpdateTransaction begin];
    XCTAssertEqual(batchUpdateTransaction.state, IGListBatchUpdateStateIdle);
}

- (void)test_withBatchUpdateTransaction_thatCancellingTransactionMultipleTimesPerformsCorrectly {
    _config.allowsBackgroundDiffing = YES;
    IGListBatchUpdateTransaction *batchUpdateTransaction = [self makeBatchUpdateTransaction];
    [batchUpdateTransaction begin];
    [batchUpdateTransaction cancel];
    [batchUpdateTransaction cancel];
    XCTAssertEqual(batchUpdateTransaction.mode, 2);
}

- (void)test_withBatchUpdateTransaction_thatMismatchedCollectionViewStateIsCaught {
    self.dataSource.sections = @[[IGSectionObject sectionWithObjects:@[]]];
    IGListBatchUpdateTransaction *batchUpdateTransaction = [self makeBatchUpdateTransaction];

    @try {
        [batchUpdateTransaction begin];
    } @catch (NSException *exception) {}
}

- (void)test_withBatchUpdateTransaction_thatCancellingTransactionBetweenRunLoopsIsCaptured {
    _config.allowsBackgroundDiffing = YES;
    IGListBatchUpdateTransaction *batchUpdateTransaction = [self makeBatchUpdateTransaction];
    [batchUpdateTransaction begin];
    [batchUpdateTransaction cancel];

    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    dispatch_async(dispatch_get_main_queue(), ^{
        XCTAssertEqual(batchUpdateTransaction.mode, 2); // Check mode is cancelled
        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)test_withDataSourceChangeTransaction_thatAllStubbedMethodsNoOpCorrectly {
    IGListDataSourceChangeTransaction *transaction = [self makeDataSourceChangeTransaction];

    XCTAssertFalse([transaction cancel]);

    NSIndexPath *from = [NSIndexPath indexPathForItem:0 inSection:0];
    NSIndexPath *to = [NSIndexPath indexPathForItem:0 inSection:1];

    [transaction insertItemsAtIndexPaths:@[]];
    [transaction deleteItemsAtIndexPaths:@[]];
    [transaction moveItemFromIndexPath:from toIndexPath:to];
    [transaction reloadItemFromIndexPath:from toIndexPath:to];
    [transaction reloadSections:[NSIndexSet indexSet]];
}

- (void)test_withReloadTransaction_thatAllStubbedMethodsNoOpCorrectly {
    IGListReloadTransaction *transaction = [self makeReloadTransaction];

    XCTAssertFalse([transaction cancel]);

    NSIndexPath *from = [NSIndexPath indexPathForItem:0 inSection:0];
    NSIndexPath *to = [NSIndexPath indexPathForItem:0 inSection:1];

    [transaction insertItemsAtIndexPaths:@[]];
    [transaction deleteItemsAtIndexPaths:@[]];
    [transaction moveItemFromIndexPath:from toIndexPath:to];
    [transaction reloadItemFromIndexPath:from toIndexPath:to];
    [transaction reloadSections:[NSIndexSet indexSet]];
}

@end
