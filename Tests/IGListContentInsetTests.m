// 
// Copyright (c) 2016-present, Facebook, Inc.
// All rights reserved.
//
// This source code is licensed under the BSD-style license found in the
// LICENSE file in the root directory of this source tree. An additional grant
// of patent rights can be found in the PATENTS file in the same directory.
//

#import <XCTest/XCTest.h>

#import <IGListKit/IGListKit.h>
#import "UIScrollView+IGListKit.h"
#import "IGListTestHelpers.h"
#import "IGListAdapterInternal.h"

static const CGRect kStackTestFrame = (CGRect){{0.0, 0.0}, {320.0, 480.0}};

@interface IGListContentInsetTests : XCTestCase<IGListAdapterDataSource>

@property (nonatomic, strong) IGListAdapter *adapter;

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UIViewController *viewController;
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation IGListContentInsetTests

- (void)setUp {
    [super setUp];
    
    self.viewController = [UIViewController new];
    
    IGListCollectionViewLayout *layout = [[IGListCollectionViewLayout alloc] initWithStickyHeaders:NO
                                                                                   topContentInset:0
                                                                                     stretchToEdge:YES];
    self.collectionView = [[UICollectionView alloc] initWithFrame:kStackTestFrame
                                             collectionViewLayout:layout];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.viewController.view addSubview:self.collectionView];
    
    self.adapter = [[IGListAdapter alloc] initWithUpdater:[IGListAdapterUpdater new]
                                           viewController:self.viewController];
    self.adapter.dataSource = self;
    self.adapter.collectionView = self.collectionView;
    
    self.window = [[UIWindow alloc] initWithFrame:kStackTestFrame];
    self.window.rootViewController = self.viewController;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
    self.adapter = nil;
    self.viewController = nil;
    self.collectionView = nil;
}

- (void) testCollectionViewContentInset {
    const UIEdgeInsets inset = UIEdgeInsetsMake(10, 0, 10, 0);
    self.collectionView.contentInset = inset;
    IGAssertEqualInsets(self.collectionView.ig_contentInset, inset.top, inset.left, inset.bottom, inset.right);
    id<IGListCollectionContext> context = self.adapter;
    IGAssertEqualInsets(context.adjustedContainerInset, inset.top, inset.left, inset.bottom, inset.right);
}

#pragma mark - IGListAdapterDataSource

- (NSArray<id <IGListDiffable>> *)objectsForListAdapter:(IGListAdapter *)listAdapter {
    return @[];
}

- (IGListSectionController *) listAdapter:(IGListAdapter *)listAdapter sectionControllerForObject:(id)object {
    return nil;
}

- (UIView *) emptyViewForListAdapter:(IGListAdapter *)listAdapter {
    return nil;
}

@end
