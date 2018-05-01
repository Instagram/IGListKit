/**
 * Copyright (c) 2016-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <XCTest/XCTest.h>

#import <IGListKit/IGListKit.h>

#import "IGListAdapterInternal.h"
#import "IGListTestAdapterStoryboardDataSource.h"
#import "IGListStackedSectionControllerInternal.h"
#import "IGTestStoryboardViewController.h"
#import "IGTestStoryboardSupplementarySource.h"

static const CGRect kStackTestFrame = (CGRect){{0.0, 0.0}, {100.0, 100.0}};

@interface IGListAdapterStoryboardTests : XCTestCase

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) IGListAdapter *adapter;
@property (nonatomic, strong) IGListTestAdapterStoryboardDataSource *dataSource;
@property (nonatomic, strong) IGListAdapterUpdater *updater;
@property (nonatomic, strong) IGTestStoryboardViewController *viewController;

@end

@implementation IGListAdapterStoryboardTests

- (void)setUp {
    [super setUp];

    self.window = [[UIWindow alloc] initWithFrame:kStackTestFrame];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"IGTestStoryboard" bundle:[NSBundle bundleForClass:self.class]];
    self.viewController = [storyboard instantiateViewControllerWithIdentifier:@"testVC"];
    [self.window addSubview:self.viewController.view];
    [self.viewController performSelectorOnMainThread:@selector(loadView) withObject:nil waitUntilDone:YES];
    self.collectionView = self.viewController.collectionView;

    self.dataSource = [[IGListTestAdapterStoryboardDataSource alloc] init];
    self.updater = [[IGListAdapterUpdater alloc] init];
    self.adapter = [[IGListAdapter alloc] initWithUpdater:self.updater viewController:self.viewController];
}

- (void)tearDown {
    [super tearDown];

    self.adapter = nil;
    self.collectionView = nil;
    self.dataSource = nil;
}

- (void)setupWithObjects:(NSArray *)objects {
    self.dataSource.objects = objects;
    self.adapter.collectionView = self.viewController.collectionView;
    self.adapter.dataSource = self.dataSource;
    [self.adapter reloadDataWithCompletion:nil];

    IGTestStoryboardSupplementarySource *supplementarySource = [IGTestStoryboardSupplementarySource new];
    supplementarySource.collectionContext = self.adapter;
    supplementarySource.supportedElementKinds = @[UICollectionElementKindSectionHeader];

    IGListSectionController *controller = [self.adapter sectionControllerForObject:objects.firstObject];
    controller.supplementaryViewSource = supplementarySource;
    supplementarySource.sectionController = controller;

    [self.adapter performUpdatesAnimated:NO completion:nil];
    [self.collectionView layoutIfNeeded];
}

- (void)test_whenSupplementarySourceSupportsHeader {
    [self setupWithObjects:@[genTestObject(@1, @"Foo")]];

    XCTAssertNotNil([self.collectionView supplementaryViewForElementKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]]);
}

@end
