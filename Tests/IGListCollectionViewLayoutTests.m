/**
 * Copyright (c) 2016-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <XCTest/XCTest.h>

#import <IGListKit/IGListCollectionViewLayout.h>

#import "IGListCollectionViewLayoutInternal.h"
#import "IGLayoutTestDataSource.h"
#import "IGLayoutTestItem.h"
#import "IGLayoutTestSection.h"
#import "IGListTestHelpers.h"

@interface IGListCollectionViewLayoutTests : XCTestCase

@property (nonatomic, strong) IGListCollectionViewLayout *layout;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) IGLayoutTestDataSource *dataSource;

@end

static const CGRect kTestFrame = (CGRect){{0, 0}, {100, 100}};

@implementation IGListCollectionViewLayoutTests

- (UICollectionViewCell *)cellForSection:(NSInteger)section item:(NSInteger)item {
    return [self.collectionView cellForItemAtIndexPath:genIndexPath(section, item)];
}

- (UICollectionReusableView *)headerForSection:(NSInteger)section {
    return [self.collectionView supplementaryViewForElementKind:UICollectionElementKindSectionHeader atIndexPath:genIndexPath(section, 0)];
}

- (UICollectionReusableView *)footerForSection:(NSInteger)section {
    return [self.collectionView supplementaryViewForElementKind:UICollectionElementKindSectionFooter atIndexPath:genIndexPath(section, 0)];
}

- (void)setUpWithStickyHeaders:(BOOL)sticky showHeaderWhenEmpty:(BOOL)showHeaderWhenEmpty {
    self.layout = [[IGListCollectionViewLayout alloc] initWithStickyHeaders:YES topContentInset:0 stretchToEdge:NO];
    self.layout.showHeaderWhenEmpty = showHeaderWhenEmpty;
    [self setUpCollectionViewAndDataSource:kTestFrame];
}

- (void)setUpWithStickyHeaders:(BOOL)sticky topInset:(CGFloat)inset {
    [self setUpWithStickyHeaders:sticky topInset:inset stretchToEdge:NO];
}

- (void)setUpWithStickyHeaders:(BOOL)sticky topInset:(CGFloat)inset testFrame:(CGRect)testFrame {
    [self setUpWithStickyHeaders:sticky scrollDirection:UICollectionViewScrollDirectionVertical topInset:inset stretchToEdge:NO testFrame:testFrame];
}

- (void)setUpWithStickyHeaders:(BOOL)sticky topInset:(CGFloat)inset stretchToEdge:(BOOL)stretchToEdge {
    [self setUpWithStickyHeaders:sticky scrollDirection:UICollectionViewScrollDirectionVertical topInset:inset stretchToEdge:stretchToEdge testFrame:kTestFrame];
}

- (void)setUpWithStickyHeaders:(BOOL)sticky scrollDirection:(UICollectionViewScrollDirection)scrollDirection topInset:(CGFloat)inset stretchToEdge:(BOOL)stretchToEdge testFrame:(CGRect)testFrame {
    self.layout = [[IGListCollectionViewLayout alloc] initWithStickyHeaders:sticky scrollDirection:scrollDirection topContentInset:inset stretchToEdge:stretchToEdge];
    [self setUpCollectionViewAndDataSource:testFrame];
}

- (void)setUpCollectionViewAndDataSource:(CGRect)testFrame {
    self.dataSource = [IGLayoutTestDataSource new];
    self.collectionView = [[UICollectionView alloc] initWithFrame:testFrame collectionViewLayout:self.layout];
    self.collectionView.dataSource = self.dataSource;
    self.collectionView.delegate = self.dataSource;
    [self.dataSource configCollectionView:self.collectionView];
}

- (void)tearDown {
    [super tearDown];

    self.collectionView = nil;
    self.layout = nil;
    self.dataSource = nil;
}

- (void)prepareWithData:(NSArray<IGLayoutTestSection *> *)data {
    self.dataSource.sections = data;
    [self.collectionView reloadData];
    [self.collectionView layoutIfNeeded];
}

- (void)test_whenEmptyData_thatContentSizeZero {
    [self setUpWithStickyHeaders:YES topInset:0];

    [self prepareWithData:nil];

    // check so that nil messaging doesn't default size to 0
    XCTAssertEqual(self.layout.collectionView, self.collectionView);
    XCTAssertTrue(CGSizeEqualToSize(CGSizeZero, self.collectionView.contentSize));
}

- (void)test_whenSectionDataIsEmpty_thatStickyHeaderStillShow {
    [self setUpWithStickyHeaders:YES showHeaderWhenEmpty:YES];
    
    [self prepareWithData:@[[[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                                            lineSpacing:0
                                                       interitemSpacing:0
                                                           headerHeight:10
                                                           footerHeight:0
                                                                  items:nil],
                            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                                            lineSpacing:0
                                                       interitemSpacing:0
                                                           headerHeight:20
                                                           footerHeight:0
                                                                  items:nil],
                            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                                            lineSpacing:0
                                                       interitemSpacing:0
                                                           headerHeight:30
                                                           footerHeight:0
                                                                  items:nil]]];
    
    IGAssertEqualFrame([self headerForSection:0].frame, 0, 0, 100, 10);
    IGAssertEqualFrame([self headerForSection:1].frame, 0, 10, 100, 20);
    IGAssertEqualFrame([self headerForSection:2].frame, 0, 30, 100, 30);
}

- (void)test_whenSectionDataIsEmpty_thatStickyHeaderShouldBeHidden {
    [self setUpWithStickyHeaders:YES showHeaderWhenEmpty:NO];
    
    [self prepareWithData:@[[[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                                            lineSpacing:0
                                                       interitemSpacing:0
                                                           headerHeight:10
                                                           footerHeight:0
                                                                  items:@[
                                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {85, 10}]
                                                                          ]],
                            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                                            lineSpacing:0
                                                       interitemSpacing:0
                                                           headerHeight:20
                                                           footerHeight:0
                                                                  items:nil],
                            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                                            lineSpacing:0
                                                       interitemSpacing:0
                                                           headerHeight:20
                                                           footerHeight:0
                                                                  items:@[
                                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {85, 10}],
                                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {85, 20}],
                                                                          ]]
                            ]];
    
    IGAssertEqualFrame([self headerForSection:0].frame, 0, 0, 100, 10);
    IGAssertEqualFrame([self headerForSection:1].frame, 0, 0, 0, 0);
    IGAssertEqualFrame([self headerForSection:2].frame, 0, 20, 100, 20);
}

- (void)test_whenLayingOutCellsVertically_withHeaderHeight_withLineSpacing_withInsets_thatFramesCorrect {
    [self setUpWithStickyHeaders:NO topInset:0];

    const CGFloat headerHeight = 10;
    const CGFloat lineSpacing = 10;
    const UIEdgeInsets insets = UIEdgeInsetsMake(10, 10, 5, 5);

    [self prepareWithData:@[
            [[IGLayoutTestSection alloc] initWithInsets:insets
                                            lineSpacing:lineSpacing
                                       interitemSpacing:0
                                           headerHeight:headerHeight
                                           footerHeight:0
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {85, 10}],
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {85, 20}],
                                                  ]],
            [[IGLayoutTestSection alloc] initWithInsets:insets
                                            lineSpacing:lineSpacing
                                       interitemSpacing:0
                                           headerHeight:headerHeight
                                           footerHeight:0
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {85, 30}],
                                                  ]],
    ]];

    XCTAssertEqual(self.collectionView.contentSize.height, 120);
    IGAssertEqualFrame([self headerForSection:0].frame, 10, 10, 85, 10);
    IGAssertEqualFrame([self cellForSection:0 item:0].frame, 10, 20, 85, 10);
    IGAssertEqualFrame([self cellForSection:0 item:1].frame, 10, 40, 85, 20);
    IGAssertEqualFrame([self headerForSection:1].frame, 10, 75, 85, 10);
    IGAssertEqualFrame([self cellForSection:1 item:0].frame, 10, 85, 85, 30);
}

- (void)test_whenLayingOutCellsVertically_withFooterHeight_withLineSpacing_withInsets_thatFramesCorrect {
    [self setUpWithStickyHeaders:NO topInset:0 testFrame:CGRectMake(0, 0, 100, 150)];

    const CGFloat footerHeight = 10;
    const CGFloat lineSpacing = 10;
    const UIEdgeInsets insets = UIEdgeInsetsMake(10, 10, 5, 5);

    [self prepareWithData:@[
            [[IGLayoutTestSection alloc] initWithInsets:insets
                                            lineSpacing:lineSpacing
                                       interitemSpacing:0
                                           headerHeight:0
                                           footerHeight:footerHeight
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {85, 10}],
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {85, 20}],
                                                  ]],
            [[IGLayoutTestSection alloc] initWithInsets:insets
                                            lineSpacing:lineSpacing
                                       interitemSpacing:0
                                           headerHeight:0
                                           footerHeight:footerHeight
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {85, 30}],
                                                  ]],
    ]];

    XCTAssertEqual(self.collectionView.contentSize.height, 120);
    IGAssertEqualFrame([self cellForSection:0 item:0].frame, 10, 10, 85, 10);
    IGAssertEqualFrame([self cellForSection:0 item:1].frame, 10, 30, 85, 20);
    IGAssertEqualFrame([self footerForSection:0].frame, 10, 50, 85, 10);
    IGAssertEqualFrame([self cellForSection:1 item:0].frame, 10, 75, 85, 30);
    IGAssertEqualFrame([self footerForSection:1].frame, 10, 105, 85, 10);
}

- (void)test_whenLayingOutCellsVertically_withHeaderHeight_withFooterHeight_withLineSpacing_withInsets_thatFramesCorrect {
    [self setUpWithStickyHeaders:NO topInset:0 testFrame:CGRectMake(0, 0, 100, 150)];

    const CGFloat headerHeight = 10;
    const CGFloat footerHeight = 10;
    const CGFloat lineSpacing = 10;
    const UIEdgeInsets insets = UIEdgeInsetsMake(10, 10, 5, 5);

    [self prepareWithData:@[
            [[IGLayoutTestSection alloc] initWithInsets:insets
                                            lineSpacing:lineSpacing
                                       interitemSpacing:0
                                           headerHeight:headerHeight
                                           footerHeight:footerHeight
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {85, 10}],
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {85, 20}],
                                                  ]],
            [[IGLayoutTestSection alloc] initWithInsets:insets
                                            lineSpacing:lineSpacing
                                       interitemSpacing:0
                                           headerHeight:headerHeight
                                           footerHeight:footerHeight
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {85, 30}],
                                                  ]],
    ]];

    XCTAssertEqual(self.collectionView.contentSize.height, 140);
    IGAssertEqualFrame([self headerForSection:0].frame, 10, 10, 85, 10);
    IGAssertEqualFrame([self cellForSection:0 item:0].frame, 10, 20, 85, 10);
    IGAssertEqualFrame([self cellForSection:0 item:1].frame, 10, 40, 85, 20);
    IGAssertEqualFrame([self footerForSection:0].frame, 10, 60, 85, 10);
    IGAssertEqualFrame([self headerForSection:1].frame, 10, 85, 85, 10);
    IGAssertEqualFrame([self cellForSection:1 item:0].frame, 10, 95, 85, 30);
    IGAssertEqualFrame([self footerForSection:1].frame, 10, 125, 85, 10);
}

- (void)test_whenLayingOutCellsHorizontally_withHeaderHeight_withLineSpacing_withInsets_thatFramesCorrect {
    [self setUpWithStickyHeaders:NO scrollDirection:UICollectionViewScrollDirectionHorizontal topInset:0 stretchToEdge:NO testFrame:kTestFrame];
    
    const CGFloat headerHeight = 10;
    const CGFloat lineSpacing = 10;
    const UIEdgeInsets insets = UIEdgeInsetsMake(10, 10, 5, 5);

    [self prepareWithData:@[
            [[IGLayoutTestSection alloc] initWithInsets:insets
                                            lineSpacing:lineSpacing
                                       interitemSpacing:0
                                           headerHeight:headerHeight
                                           footerHeight:0
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {45, 10}],
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {45, 20}],
                                                  ]],
            [[IGLayoutTestSection alloc] initWithInsets:insets
                                            lineSpacing:lineSpacing
                                       interitemSpacing:0
                                           headerHeight:headerHeight
                                           footerHeight:0
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {45, 30}],
                                                  ]],
    ]];

    XCTAssertEqual(self.collectionView.contentSize.width, 140);
    IGAssertEqualFrame([self headerForSection:0].frame, 10, 10, 10, 85);
    IGAssertEqualFrame([self cellForSection:0 item:0].frame, 20, 10, 45, 10);
    IGAssertEqualFrame([self cellForSection:0 item:1].frame, 20, 20, 45, 20);
    IGAssertEqualFrame([self headerForSection:1].frame, 80, 10, 10, 85);
    IGAssertEqualFrame([self cellForSection:1 item:0].frame, 90, 10, 45, 30);
}

- (void)test_whenLayingOutCellsHorizontally_withFooterHeight_withLineSpacing_withInsets_thatFramesCorrect {
    [self setUpWithStickyHeaders:NO scrollDirection:UICollectionViewScrollDirectionHorizontal topInset:0 stretchToEdge:NO testFrame:kTestFrame];

    const CGFloat footerHeight = 10;
    const CGFloat lineSpacing = 10;
    const UIEdgeInsets insets = UIEdgeInsetsMake(10, 10, 5, 5);

    [self prepareWithData:@[
            [[IGLayoutTestSection alloc] initWithInsets:insets
                                            lineSpacing:lineSpacing
                                       interitemSpacing:0
                                           headerHeight:0
                                           footerHeight:footerHeight
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {45, 10}],
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {45, 20}],
                                                  ]],
            [[IGLayoutTestSection alloc] initWithInsets:insets
                                            lineSpacing:lineSpacing
                                       interitemSpacing:0
                                           headerHeight:0
                                           footerHeight:footerHeight
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {45, 30}],
                                                  ]],
    ]];

    XCTAssertEqual(self.collectionView.contentSize.width, 75);
    IGAssertEqualFrame([self footerForSection:0].frame, 60, 10, 10, 85);
    IGAssertEqualFrame([self cellForSection:0 item:0].frame, 10, 10, 45, 10);
    IGAssertEqualFrame([self cellForSection:0 item:1].frame, 10, 20, 45, 20);
    IGAssertEqualFrame([self footerForSection:1].frame, 60, 10, 10, 85);
    IGAssertEqualFrame([self cellForSection:1 item:0].frame, 10, 55, 45, 30);
}

- (void)test_whenUsingStickyHeaders_withSimulatedScrolling_thatYPositionsAdjusted {
    [self setUpWithStickyHeaders:YES topInset:10];

    [self prepareWithData:@[
            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                            lineSpacing:0
                                       interitemSpacing:0
                                           headerHeight:10
                                           footerHeight:0
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {100, 20}],
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {100, 20}],
                                                  ]],
            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                            lineSpacing:0
                                       interitemSpacing:0
                                           headerHeight:10
                                           footerHeight:0
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {100, 30}],
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {100, 30}],
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {100, 30}],
                                                  ]],
    ]];

    // scroll header 0 halfway
    self.collectionView.contentOffset = CGPointMake(0, 5);
    [self.collectionView layoutIfNeeded];
    IGAssertEqualFrame([self headerForSection:0].frame, 0, 15, 100, 10);
    IGAssertEqualFrame([self headerForSection:1].frame, 0, 50, 100, 10);

    // scroll header 0 off and 1 up
    self.collectionView.contentOffset = CGPointMake(0, 45);
    [self.collectionView layoutIfNeeded];
    IGAssertEqualFrame([self headerForSection:0].frame, 0, 40, 100, 10);
    IGAssertEqualFrame([self headerForSection:1].frame, 0, 55, 100, 10);
}

- (void)test_whenUsingStickyHeaders_withSimulatedHorizontalScrolling_thatXPositionsAdjusted {
    [self setUpWithStickyHeaders:YES scrollDirection:UICollectionViewScrollDirectionHorizontal topInset:10 stretchToEdge:NO testFrame:kTestFrame];

    [self prepareWithData:@[
            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                            lineSpacing:0
                                       interitemSpacing:0
                                           headerHeight:10
                                           footerHeight:0
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {20, 100}],
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {20, 100}],
                                                  ]],
            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                            lineSpacing:0
                                       interitemSpacing:0
                                           headerHeight:10
                                           footerHeight:0
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {30, 100}],
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {30, 100}],
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {30, 100}],
                                                  ]],
    ]];
    
    // scroll header 0 halfway
    self.collectionView.contentOffset = CGPointMake(5, 0);
    [self.collectionView layoutIfNeeded];
    IGAssertEqualFrame([self headerForSection:0].frame, 15, 0, 10, 100);
    IGAssertEqualFrame([self headerForSection:1].frame, 50, 0, 10, 100);
    
    // scroll header 0 off and 1 left
    self.collectionView.contentOffset = CGPointMake(45, 0);
    [self.collectionView layoutIfNeeded];
    IGAssertEqualFrame([self headerForSection:0].frame, 40, 0, 10, 100);
    IGAssertEqualFrame([self headerForSection:1].frame, 55, 0, 10, 100);
}

- (void)test_whenAdjustingTopYInset_withVaryingHeaderHeights_thatYPositionsUpdated {
    [self setUpWithStickyHeaders:YES topInset:10];

    [self prepareWithData:@[
            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                            lineSpacing:0
                                       interitemSpacing:0
                                           headerHeight:10
                                           footerHeight:0
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {100, 10}],
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {100, 20}],
                                                  ]],
            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                            lineSpacing:0
                                       interitemSpacing:0
                                           headerHeight:10
                                           footerHeight:0
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {100, 30}],
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {100, 40}],
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {100, 50}],
                                                  ]],
    ]];

    // scroll header 0 off and 1 up
    self.collectionView.contentOffset = CGPointMake(0, 35);
    [self.collectionView layoutIfNeeded];
    IGAssertEqualFrame([self headerForSection:0].frame, 0, 30, 100, 10);
    IGAssertEqualFrame([self headerForSection:1].frame, 0, 45, 100, 10);

    self.layout.stickyHeaderYOffset = -10;
    [self.collectionView layoutIfNeeded];
    IGAssertEqualFrame([self headerForSection:0].frame, 0, 30, 100, 10);
    IGAssertEqualFrame([self headerForSection:1].frame, 0, 40, 100, 10);

    self.layout.stickyHeaderYOffset = 10;
    [self.collectionView layoutIfNeeded];
    IGAssertEqualFrame([self headerForSection:0].frame, 0, 30, 100, 10);
    IGAssertEqualFrame([self headerForSection:1].frame, 0, 55, 100, 10);
}

- (void)test_whenItemsSmallerThanContainerWidth_with0Insets_with0LineSpacing_with0Interitem_thatItemsFitSameRow {
    [self setUpWithStickyHeaders:NO topInset:0];

    [self prepareWithData:@[
            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                            lineSpacing:0
                                       interitemSpacing:0
                                           headerHeight:0
                                           footerHeight:0
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {33, 33}],
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {33, 33}],
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {33, 33}],
                                                  ]],
            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                            lineSpacing:0
                                       interitemSpacing:0
                                           headerHeight:0
                                           footerHeight:0
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {33, 33}],
                                                  ]],
    ]];

    XCTAssertEqual(self.collectionView.contentSize.height, 66);
    IGAssertEqualFrame([self cellForSection:0 item:0].frame, 0, 0, 33, 33);
    IGAssertEqualFrame([self cellForSection:0 item:1].frame, 33, 0, 33, 33);
    IGAssertEqualFrame([self cellForSection:0 item:2].frame, 66, 0, 33, 33);
    IGAssertEqualFrame([self cellForSection:1 item:0].frame, 0, 33, 33, 33);
}

- (void)test_whenItemsSmallerThanContainerWidth_withHalfPointItemSpacing_with0Insets_with0LineSpacing_thatItemsFitSameRow {
    [self setUpWithStickyHeaders:NO topInset:0];

    [self prepareWithData:@[
            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                            lineSpacing:0
                                       interitemSpacing:0.5
                                           headerHeight:0
                                           footerHeight:0
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {33, 33}],
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {33, 33}],
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {33, 33}],
                                                  ]],
    ]];

    XCTAssertEqual(self.collectionView.contentSize.height, 33);
    IGAssertEqualFrame([self cellForSection:0 item:0].frame, 0, 0, 33, 33);
    const CGRect rect = IGListRectIntegralScaled(CGRectMake(33.5, 0, 33, 33));
    IGAssertEqualFrame([self cellForSection:0 item:1].frame, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    IGAssertEqualFrame([self cellForSection:0 item:2].frame, 67, 0, 33, 33);
}

- (void)test_whenItemsLargerThanContainerHeight_withHorizontalScrolling_with5PointItemSpacing_with0Insets_with10PointLineSpacing_thatItemsBumpToNewColumn {
    [self setUpWithStickyHeaders:NO scrollDirection:UICollectionViewScrollDirectionHorizontal topInset:0 stretchToEdge:NO testFrame:kTestFrame];

    [self prepareWithData:@[
            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                            lineSpacing:10
                                       interitemSpacing:5
                                           headerHeight:0
                                           footerHeight:0
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {33, 33}],
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {33, 33}],
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {33, 33}],
                                                  ]],
    ]];

    XCTAssertEqual(self.collectionView.contentSize.width, 76);
    IGAssertEqualFrame([self cellForSection:0 item:0].frame, 0, 0, 33, 33);
    IGAssertEqualFrame([self cellForSection:0 item:1].frame, 0, 38, 33, 33);
    IGAssertEqualFrame([self cellForSection:0 item:2].frame, 43, 0, 33, 33);
}

- (void)test_whenSectionsSmallerThanContainerWidth_withVerticalScrolling_with0ItemSpacing_with0Insets_with0LineSpacing_thatSectionsFitSameRow {
    [self setUpWithStickyHeaders:NO topInset:0];

    [self prepareWithData:@[
            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                            lineSpacing:0
                                       interitemSpacing:0
                                           headerHeight:0
                                           footerHeight:0
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {33, 33}],
                                                  ]],
            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                            lineSpacing:0
                                       interitemSpacing:0
                                           headerHeight:0
                                           footerHeight:0
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {33, 33}],
                                                  ]],
            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                            lineSpacing:0
                                       interitemSpacing:0
                                           headerHeight:0
                                           footerHeight:0
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {33, 33}],
                                                  ]],
    ]];

    XCTAssertEqual(self.collectionView.contentSize.height, 33);
    IGAssertEqualFrame([self cellForSection:0 item:0].frame, 0, 0, 33, 33);
    IGAssertEqualFrame([self cellForSection:1 item:0].frame, 33, 0, 33, 33);
    IGAssertEqualFrame([self cellForSection:2 item:0].frame, 66, 0, 33, 33);
}

- (void)test_whenSectionsSmallerThanContainerHeight_withHorizontalScrolling_with0ItemSpacing_with0Insets_with0LineSpacing_thatSectionsFitSameColumn {
    [self setUpWithStickyHeaders:NO scrollDirection:UICollectionViewScrollDirectionHorizontal topInset:0 stretchToEdge:NO testFrame:kTestFrame];

    [self prepareWithData:@[
            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero lineSpacing:0
                                       interitemSpacing:0
                                           headerHeight:0
                                           footerHeight:0
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {33, 33}],
                                                  ]],
            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero lineSpacing:0
                                       interitemSpacing:0
                                           headerHeight:0
                                           footerHeight:0
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {33, 33}],
                                                  ]],
            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero lineSpacing:0
                                       interitemSpacing:0
                                           headerHeight:0
                                           footerHeight:0
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {33, 33}],
                                                  ]],
    ]];

    XCTAssertEqual(self.collectionView.contentSize.width, 33);
    IGAssertEqualFrame([self cellForSection:0 item:0].frame, 0, 0, 33, 33);
    IGAssertEqualFrame([self cellForSection:1 item:0].frame, 0, 33, 33, 33);
    IGAssertEqualFrame([self cellForSection:2 item:0].frame, 0, 66, 33, 33);
}

- (void)test_whenSectionsSmallerThanContainerWidth_withHalfPointSpacing_with0Insets_with0LineSpacing_thatSectionsFitSameRow {
    [self setUpWithStickyHeaders:NO topInset:0];

    [self prepareWithData:@[
            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                            lineSpacing:0
                                       interitemSpacing:0.5
                                           headerHeight:0
                                           footerHeight:0
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {33, 33}],
                                                  ]],
            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                            lineSpacing:0
                                       interitemSpacing:0.5
                                           headerHeight:0
                                           footerHeight:0
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {33, 33}],
                                                  ]],
            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                            lineSpacing:0
                                       interitemSpacing:0.5
                                           headerHeight:0
                                           footerHeight:0
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {33, 33}],
                                                  ]],
    ]];

    XCTAssertEqual(self.collectionView.contentSize.height, 33);
    IGAssertEqualFrame([self cellForSection:0 item:0].frame, 0, 0, 33, 33);
    const CGRect rect = IGListRectIntegralScaled(CGRectMake(33.5, 0, 33, 33));
    IGAssertEqualFrame([self cellForSection:1 item:0].frame, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    IGAssertEqualFrame([self cellForSection:2 item:0].frame, 67, 0, 33, 33);
}

- (void)test_whenSectionsSmallerThanContainerWidth_with0ItemSpacing_withMiddleItemHasInsets_with0LineSpacing_thatNextSectionSnapsBelow {
    [self setUpWithStickyHeaders:NO topInset:0];

    [self prepareWithData:@[
            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                            lineSpacing:0
                                       interitemSpacing:0
                                           headerHeight:0
                                           footerHeight:0
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {33, 33}],
                                                  ]],
            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsMake(10, 10, 10, 10)
                                            lineSpacing:0
                                       interitemSpacing:0
                                           headerHeight:0
                                           footerHeight:0
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {13, 50}],
                                                  ]],
            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                            lineSpacing:0
                                       interitemSpacing:0
                                           headerHeight:0
                                           footerHeight:0
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {33, 33}],
                                                  ]],
            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                            lineSpacing:0
                                       interitemSpacing:0
                                           headerHeight:0
                                           footerHeight:0
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {33, 33}],
                                                  ]],
    ]];

    XCTAssertEqual(self.collectionView.contentSize.height, 103);
    IGAssertEqualFrame([self cellForSection:0 item:0].frame, 0, 0, 33, 33);
    IGAssertEqualFrame([self cellForSection:1 item:0].frame, 43, 10, 13, 50);
    IGAssertEqualFrame([self cellForSection:2 item:0].frame, 66, 0, 33, 33);
    IGAssertEqualFrame([self cellForSection:3 item:0].frame, 0, 70, 33, 33);
}

- (void)test_whenSectionBustingRow_thatNewlineAppliesSectionInset {
    [self setUpWithStickyHeaders:NO topInset:0];

    [self prepareWithData:@[
            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                            lineSpacing:0
                                       interitemSpacing:0
                                           headerHeight:0
                                           footerHeight:0
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {33, 33}],
                                                  ]],
            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsMake(10, 10, 5, 5)
                                            lineSpacing:0
                                       interitemSpacing:0
                                           headerHeight:0
                                           footerHeight:0
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {85, 50}],
                                                  ]],
    ]];

    XCTAssertEqual(self.collectionView.contentSize.height, 98);
    IGAssertEqualFrame([self cellForSection:0 item:0].frame, 0, 0, 33, 33);
    IGAssertEqualFrame([self cellForSection:1 item:0].frame, 10, 43, 85, 50);
}

- (void)test_whenSectionsSmallerThanWidth_withSectionHeader_thatHeaderCausesNewline {
    [self setUpWithStickyHeaders:NO topInset:0];

    [self prepareWithData:@[
            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                            lineSpacing:0
                                       interitemSpacing:0
                                           headerHeight:0
                                           footerHeight:0
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {33, 33}],
                                                  ]],
            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                            lineSpacing:0
                                       interitemSpacing:0
                                           headerHeight:10
                                           footerHeight:0
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {33, 33}],
                                                  ]],
    ]];

    XCTAssertEqual(self.collectionView.contentSize.height, 76);
    IGAssertEqualFrame([self cellForSection:0 item:0].frame, 0, 0, 33, 33);
    IGAssertEqualFrame([self cellForSection:1 item:0].frame, 0, 43, 33, 33);
}

- (void)test_whenSectionsSmallerThanHeight_withHorizontalScrolling_withSectionHeader_thatHeaderCausesNewline {
    [self setUpWithStickyHeaders:NO scrollDirection:UICollectionViewScrollDirectionHorizontal topInset:0 stretchToEdge:NO testFrame:kTestFrame];

    [self prepareWithData:@[
            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                            lineSpacing:0
                                       interitemSpacing:0
                                           headerHeight:0
                                           footerHeight:0
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {33, 33}],
                                                  ]],
            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                            lineSpacing:0
                                       interitemSpacing:0
                                           headerHeight:10
                                           footerHeight:0
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {33, 33}],
                                                  ]],
    ]];

    XCTAssertEqual(self.collectionView.contentSize.width, 76);
    IGAssertEqualFrame([self cellForSection:0 item:0].frame, 0, 0, 33, 33);
    IGAssertEqualFrame([self cellForSection:1 item:0].frame, 43, 0, 33, 33);
}

- (void)test_whenBatchItemUpdates_withHeaderHeight_withLineSpacing_withInsets_thatLayoutCorrectAfterUpdates {
    [self setUpWithStickyHeaders:NO topInset:0];

    const CGFloat headerHeight = 10;
    const CGFloat lineSpacing = 10;
    const UIEdgeInsets insets = UIEdgeInsetsMake(10, 10, 5, 5);

    // making the view bigger so that we can check all cell frames
    self.collectionView.frame = CGRectMake(0, 0, 100, 400);

    [self prepareWithData:@[
            [[IGLayoutTestSection alloc] initWithInsets:insets lineSpacing:lineSpacing
                                       interitemSpacing:0
                                           headerHeight:headerHeight
                                           footerHeight:0
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {85, 10}],
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {85, 20}],
                                                  ]],
            [[IGLayoutTestSection alloc] initWithInsets:insets lineSpacing:lineSpacing
                                       interitemSpacing:0
                                           headerHeight:headerHeight
                                           footerHeight:0
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {85, 30}],
                                                  ]],
            [[IGLayoutTestSection alloc] initWithInsets:insets lineSpacing:lineSpacing
                                       interitemSpacing:0
                                           headerHeight:headerHeight
                                           footerHeight:0
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {85, 60}],
                                                  ]],
            [[IGLayoutTestSection alloc] initWithInsets:insets lineSpacing:lineSpacing
                                       interitemSpacing:0
                                           headerHeight:headerHeight
                                           footerHeight:0
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {85, 40}],
                                                  ]],
    ]];

    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];

    [self.collectionView performBatchUpdates:^{
        self.dataSource.sections = @[
                [[IGLayoutTestSection alloc] initWithInsets:insets
                                                lineSpacing:lineSpacing
                                           interitemSpacing:0
                                               headerHeight:headerHeight
                                               footerHeight:0
                                                      items:@[
                                                              [[IGLayoutTestItem alloc] initWithSize:(CGSize) {85, 30}], // reloaded
                                                              // deleted
                                                      ]],
                // moved from section 3 to 1
                [[IGLayoutTestSection alloc] initWithInsets:insets
                                                lineSpacing:lineSpacing
                                           interitemSpacing:0
                                               headerHeight:headerHeight
                                               footerHeight:0
                                                      items:@[
                                                              [[IGLayoutTestItem alloc] initWithSize:(CGSize) {85, 40}],
                                                      ]],
                // deleted section 2
                [[IGLayoutTestSection alloc] initWithInsets:insets
                                                lineSpacing:lineSpacing
                                           interitemSpacing:0
                                               headerHeight:headerHeight
                                               footerHeight:0
                                                      items:@[
                                                              [[IGLayoutTestItem alloc] initWithSize:(CGSize) {85, 30}],
                                                              [[IGLayoutTestItem alloc] initWithSize:(CGSize) {85, 10}], // inserted
                                                      ]],
                // inserted
                [[IGLayoutTestSection alloc] initWithInsets:insets
                                                lineSpacing:lineSpacing
                                           interitemSpacing:0
                                               headerHeight:headerHeight
                                               footerHeight:0
                                                      items:@[
                                                              [[IGLayoutTestItem alloc] initWithSize:(CGSize) {85, 10}],
                                                              [[IGLayoutTestItem alloc] initWithSize:(CGSize) {85, 20}],
                                                      ]],
        ];

        [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:2]];
        [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:3]];
        [self.collectionView moveSection:3 toSection:1];
        [self.collectionView reloadItemsAtIndexPaths:@[genIndexPath(0, 0)]];
        [self.collectionView deleteItemsAtIndexPaths:@[genIndexPath(0, 1)]];
        [self.collectionView insertItemsAtIndexPaths:@[genIndexPath(2, 1)]];
    } completion:^(BOOL finished) {
        [self.collectionView layoutIfNeeded];
        [expectation fulfill];

        XCTAssertEqual(self.collectionView.contentSize.height, 260);

        IGAssertEqualFrame([self headerForSection:0].frame, 10, 10, 85, 10);
        IGAssertEqualFrame([self cellForSection:0 item:0].frame, 10, 20, 85, 30);

        IGAssertEqualFrame([self headerForSection:1].frame, 10, 65, 85, 10);
        IGAssertEqualFrame([self cellForSection:1 item:0].frame, 10, 75, 85, 40);

        IGAssertEqualFrame([self headerForSection:2].frame, 10, 130, 85, 10);
        IGAssertEqualFrame([self cellForSection:2 item:0].frame, 10, 140, 85, 30);
        IGAssertEqualFrame([self cellForSection:2 item:1].frame, 10, 180, 85, 10);

        IGAssertEqualFrame([self headerForSection:3].frame, 10, 205, 85, 10);
        IGAssertEqualFrame([self cellForSection:3 item:0].frame, 10, 215, 85, 10);
        IGAssertEqualFrame([self cellForSection:3 item:1].frame, 10, 235, 85, 20);
    }];

    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
}

- (void)test_whenQueryingLayoutAttributes_withLotsOfCells_thatExactFramesFetched {
    [self setUpWithStickyHeaders:NO topInset:0];

    NSMutableArray *items = [NSMutableArray new];
    for (NSInteger i = 0; i < 1000; i++) {
        [items addObject:[[IGLayoutTestItem alloc] initWithSize:(CGSize) {100, 20}]];
    }

    [self prepareWithData:@[
            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                            lineSpacing:0
                                       interitemSpacing:0
                                           headerHeight:0
                                           footerHeight:0
                                                  items:items]
    ]];

    XCTAssertEqual([self.layout layoutAttributesForElementsInRect:CGRectMake(0, 500, 100, 100)].count, 5);
    XCTAssertEqual([self.layout layoutAttributesForElementsInRect:CGRectMake(0, 0, 100, 1000)].count, 50);
    XCTAssertEqual([self.layout layoutAttributesForElementsInRect:CGRectMake(0, 250, 100, 100)].count, 6);
    XCTAssertEqual([self.layout layoutAttributesForElementsInRect:CGRectMake(0, 250, 100, 1)].count, 1);
}

- (void)test_whenSecondItemDoesntIntersectRect_thatOtherAttributesExist {
    [self setUpWithStickyHeaders:NO topInset:0];
    NSMutableArray *data = [NSMutableArray new];
    for (NSInteger i = 0; i < 6; i++) {
        [data addObject:[[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                                        lineSpacing:0
                                                   interitemSpacing:0
                                                       headerHeight:0
                                                       footerHeight:0
                                                              items:@[
                                                                      [[IGLayoutTestItem alloc] initWithSize:(CGSize) {50, 100}],
                                                                      [[IGLayoutTestItem alloc] initWithSize:(CGSize) {50, 10}],
                                                              ]]];
    }
    [self prepareWithData:data];
    
    NSArray *attributes = [self.layout layoutAttributesForElementsInRect:CGRectMake(0, 50, 100, 100)];
    NSArray *paths = [[attributes valueForKeyPath:@"indexPath"] sortedArrayUsingSelector:@selector(compare:)];
    NSArray *expectation = @[
                             genIndexPath(0, 0),
                             genIndexPath(1, 0),
                             genIndexPath(1, 1),
                             ];
    
    // should include 2 of the 100-height items and one of the 10-height
    XCTAssertEqualObjects(paths, expectation);
}

- (void)test_whenTwoConsecutiveItemsDontIntersectRect_thatOtherAttributesExist {
    [self setUpWithStickyHeaders:NO topInset:0];
    NSMutableArray *data = [NSMutableArray new];
    for (NSInteger i = 0; i < 6; i++) {
        [data addObject:[[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                                        lineSpacing:0
                                                   interitemSpacing:0
                                                       headerHeight:0
                                                       footerHeight:0
                                                              items:@[
                                                                      [[IGLayoutTestItem alloc] initWithSize:(CGSize) {30, 100}],
                                                                      [[IGLayoutTestItem alloc] initWithSize:(CGSize) {30, 10}],
                                                                      [[IGLayoutTestItem alloc] initWithSize:(CGSize) {30, 10}],
                                                              ]]];
    }
    [self prepareWithData:data];
    
    NSArray *attributes = [self.layout layoutAttributesForElementsInRect:CGRectMake(0, 50, 100, 100)];
    NSArray *paths = [[attributes valueForKeyPath:@"indexPath"] sortedArrayUsingSelector:@selector(compare:)];

    NSArray *expectation = @[
                             genIndexPath(0, 0),
                             genIndexPath(1, 0),
                             genIndexPath(1, 1),
                             genIndexPath(1, 2),
                             ];
    
    // should include 2 of the 100-height items and two of the 10-height
    XCTAssertEqualObjects(paths, expectation);
}


- (void)test_whenChangingBoundsSize_withItemsThatNewlineAfterChange_thatLayoutShiftsItems {
    [self setUpWithStickyHeaders:NO topInset:0];

    [self prepareWithData:@[
            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                            lineSpacing:0
                                       interitemSpacing:0
                                           headerHeight:0
                                           footerHeight:0
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {33, 33}],
                                                  ]],
            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                            lineSpacing:0
                                       interitemSpacing:0
                                           headerHeight:0
                                           footerHeight:0
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {33, 33}],
                                                  ]],
            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                            lineSpacing:0
                                       interitemSpacing:0
                                           headerHeight:0
                                           footerHeight:0
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {33, 33}],
                                                  ]],
    ]];

    XCTAssertEqual(self.collectionView.contentSize.height, 33);
    IGAssertEqualFrame([self cellForSection:0 item:0].frame, 0, 0, 33, 33);
    IGAssertEqualFrame([self cellForSection:1 item:0].frame, 33, 0, 33, 33);
    IGAssertEqualFrame([self cellForSection:2 item:0].frame, 66, 0, 33, 33);

    // can no longer fit 3 items in one section
    self.collectionView.frame = CGRectMake(0, 0, 70, 100);
    [self.collectionView layoutIfNeeded];

    XCTAssertEqual(self.collectionView.contentSize.height, 66);
    IGAssertEqualFrame([self cellForSection:0 item:0].frame, 0, 0, 33, 33);
    IGAssertEqualFrame([self cellForSection:1 item:0].frame, 33, 0, 33, 33);
    IGAssertEqualFrame([self cellForSection:2 item:0].frame, 0, 33, 33, 33);
}

- (void)test_whenCollectionViewContentInset_withFullWidthItems_thatItemsPinchedIn {
    [self setUpWithStickyHeaders:NO topInset:0];
    self.collectionView.contentInset = UIEdgeInsetsMake(0, 30, 0, 30);

    [self prepareWithData:@[
            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                            lineSpacing:0
                                       interitemSpacing:0
                                           headerHeight:10
                                           footerHeight:0
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {40, 10}],
                                                          [[IGLayoutTestItem alloc] initWithSize:(CGSize) {40, 20}],
                                                  ]],
    ]];

    XCTAssertEqual(self.collectionView.contentSize.height, 40);
    IGAssertEqualFrame([self headerForSection:0].frame, 0, 0, 40, 10);
    IGAssertEqualFrame([self cellForSection:0 item:0].frame, 0, 10, 40, 10);
    IGAssertEqualFrame([self cellForSection:0 item:1].frame, 0, 20, 40, 20);
}

- (void)test_whenItemsAddedWidthSmallerThanWidth_DifferenceSmallerThanEpsilon {
    [self setUpWithStickyHeaders:NO topInset:0 stretchToEdge:YES];

    const CGSize size = CGSizeMake(33, 33);
    [self prepareWithData:@[
            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                            lineSpacing:0
                                       interitemSpacing:0
                                           headerHeight:0
                                           footerHeight:0
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:size],
                                                          [[IGLayoutTestItem alloc] initWithSize:size],
                                                          [[IGLayoutTestItem alloc] initWithSize:size],
                                                  ]],
    ]];

    IGAssertEqualFrame([self cellForSection:0 item:0].frame, 0, 0, 33, 33);
    IGAssertEqualFrame([self cellForSection:0 item:1].frame, 33, 0, 33, 33);
    IGAssertEqualFrame([self cellForSection:0 item:2].frame, 66, 0, 34, 33);
}

- (void)test_whenItemsAddedWidthSmallerThanWidth_DifferenceBiggerThanEpsilon {
    [self setUpWithStickyHeaders:NO topInset:0 stretchToEdge:YES];

    [self prepareWithData:@[
            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                            lineSpacing:0
                                       interitemSpacing:0
                                           headerHeight:0
                                           footerHeight:0
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:CGSizeMake(33, 33)],
                                                          [[IGLayoutTestItem alloc] initWithSize:CGSizeMake(65, 33)],
                                                  ]],
    ]];

    IGAssertEqualFrame([self cellForSection:0 item:0].frame, 0, 0, 33, 33);
    IGAssertEqualFrame([self cellForSection:0 item:1].frame, 33, 0, 65, 33);
}

- (void)test_whenItemsAddedWithBiggerThanWidth_DifferenceSmallerThanEpsilon {
    [self setUpWithStickyHeaders:NO topInset:0];

    [self prepareWithData:@[
            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                            lineSpacing:0
                                       interitemSpacing:0
                                           headerHeight:0
                                           footerHeight:0
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:CGSizeMake(50, 50)],
                                                          [[IGLayoutTestItem alloc] initWithSize:CGSizeMake(51, 50)],
                                                  ]],
    ]];

    IGAssertEqualFrame([self cellForSection:0 item:0].frame, 0, 0, 50, 50);
    IGAssertEqualFrame([self cellForSection:0 item:1].frame, 50, 0, 51, 50);
}

- (void)test_whenItemsAddedWithBiggerThanWidth_DifferenceBiggerThanEpsilon {
    [self setUpWithStickyHeaders:NO topInset:0];

    [self prepareWithData:@[
            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                            lineSpacing:0
                                       interitemSpacing:0
                                           headerHeight:0
                                           footerHeight:0
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:CGSizeMake(50, 50)],
                                                          [[IGLayoutTestItem alloc] initWithSize:CGSizeMake(52, 50)],
                                                  ]],
    ]];

    IGAssertEqualFrame([self cellForSection:0 item:0].frame, 0, 0, 50, 50);
    IGAssertEqualFrame([self cellForSection:0 item:1].frame, 0, 50, 52, 50);
}

- (void)test_ {
    [self setUpWithStickyHeaders:NO topInset:0];
    self.collectionView.frame = CGRectMake(0, 0, 414, 736);

    NSMutableArray *data = [NSMutableArray new];
    for (NSInteger i = 0; i < 6; i++) {
        [data addObject:[[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsMake(1, 1, 1, 1)
                                                        lineSpacing:0
                                                   interitemSpacing:0
                                                       headerHeight:0
                                                       footerHeight:0
                                                              items:@[
                                                                      [[IGLayoutTestItem alloc] initWithSize:(CGSize) {136, 136}],
                                                              ]]];
    }
    [self prepareWithData:data];

    XCTAssertEqual(self.collectionView.contentSize.height, 276);
    IGAssertEqualFrame([self cellForSection:0 item:0].frame, 1, 1, 136, 136);
    IGAssertEqualFrame([self cellForSection:1 item:0].frame, 139, 1, 136, 136);
    IGAssertEqualFrame([self cellForSection:2 item:0].frame, 277, 1, 136, 136);
    IGAssertEqualFrame([self cellForSection:3 item:0].frame, 1, 139, 136, 136);
    IGAssertEqualFrame([self cellForSection:4 item:0].frame, 139, 139, 136, 136);
    IGAssertEqualFrame([self cellForSection:5 item:0].frame, 277, 139, 136, 136);
}

- (void)test_whenQueryingAttributes_withSectionOOB_thatReturnsNil {
    [self setUpWithStickyHeaders:NO topInset:0 stretchToEdge:YES];

    [self prepareWithData:@[
            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                            lineSpacing:0
                                       interitemSpacing:0
                                           headerHeight:0
                                           footerHeight:0
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:CGSizeMake(33, 33)],
                                                          [[IGLayoutTestItem alloc] initWithSize:CGSizeMake(65, 33)],
                                                  ]],
    ]];

    XCTAssertNil([self.layout layoutAttributesForItemAtIndexPath:genIndexPath(4, 0)]);
}

- (void)test_whenQueryingAttributes_withItemOOB_thatReturnsNil {
    [self setUpWithStickyHeaders:NO topInset:0 stretchToEdge:YES];

    [self prepareWithData:@[
            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                            lineSpacing:0
                                       interitemSpacing:0
                                           headerHeight:0
                                           footerHeight:0
                                                  items:@[
                                                          [[IGLayoutTestItem alloc] initWithSize:CGSizeMake(33, 33)],
                                                          [[IGLayoutTestItem alloc] initWithSize:CGSizeMake(65, 33)],
                                                  ]],
    ]];

    XCTAssertNil([self.layout layoutAttributesForItemAtIndexPath:genIndexPath(0, 4)]);
}

- (void)test_whenUpdatingSizes_thatLayoutUpdates {
    [self setUpWithStickyHeaders:NO topInset:0];

    [self prepareWithData:@[
                            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                                            lineSpacing:0
                                                       interitemSpacing:0
                                                           headerHeight:0
                                                           footerHeight:0
                                                                  items:@[
                                                                          [[IGLayoutTestItem alloc] initWithSize:CGSizeMake(10, 10)],
                                                                          [[IGLayoutTestItem alloc] initWithSize:CGSizeMake(10, 10)],
                                                                          ]],
                            ]];

    IGAssertEqualFrame([self cellForSection:0 item:0].frame, 0, 0, 10, 10);
    IGAssertEqualFrame([self cellForSection:0 item:1].frame, 10, 0, 10, 10);

    [self prepareWithData:@[
                            [[IGLayoutTestSection alloc] initWithInsets:UIEdgeInsetsZero
                                                            lineSpacing:0
                                                       interitemSpacing:0
                                                           headerHeight:0
                                                           footerHeight:0
                                                                  items:@[
                                                                          [[IGLayoutTestItem alloc] initWithSize:CGSizeMake(20, 20)],
                                                                          [[IGLayoutTestItem alloc] initWithSize:CGSizeMake(20, 20)],
                                                                          [[IGLayoutTestItem alloc] initWithSize:CGSizeMake(20, 20)],
                                                                          ]],
                            ]];

    IGAssertEqualFrame([self cellForSection:0 item:0].frame, 0, 0, 20, 20);
    IGAssertEqualFrame([self cellForSection:0 item:1].frame, 20, 0, 20, 20);
    IGAssertEqualFrame([self cellForSection:0 item:2].frame, 40, 0, 20, 20);
}

@end
