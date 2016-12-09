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
#import "IGTestStoryboardViewController.h"

static const CGRect kIGListCollectionViewTestFrame = (CGRect){{0.0, 0.0}, {100.0, 100.0}};

@interface IGListCollectionViewTests : XCTestCase

@end

@implementation IGListCollectionViewTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
    
    [[IGListCollectionView appearance] setBackgroundColor:nil];
}

-(void)test_whenUsingUIAppearance_thatIGListCollectionViewUsesAppearanceBackgroundColor {
    UIColor *appearanceColor = [UIColor redColor];
    [[IGListCollectionView appearance] setBackgroundColor:appearanceColor];
    
    IGListCollectionView *collectionView = [self setupIGListCollectionView];

    XCTAssertEqualObjects(collectionView.backgroundColor, appearanceColor);
}

-(void)test_whenNotUsingUIAppearance_thatIGListCollectionViewUsesDefaultBackgroundColor {

    IGListCollectionView *collectionView = [self setupIGListCollectionView];

    XCTAssertEqualObjects(collectionView.backgroundColor, [UIColor whiteColor]);
}

-(void)test_thatIGListCollectionViewHasCorrectDefaults {
    IGListCollectionView *collectionView = [[IGListCollectionView alloc] initWithFrame: kIGListCollectionViewTestFrame collectionViewLayout:[UICollectionViewFlowLayout new]];

    XCTAssertTrue(collectionView.alwaysBounceVertical);
}

-(void)test_whenUsingUIAppearance_thatStoryboardIGListCollectionViewUsesAppearanceBackgroundColor {
    UIColor *appearanceColor = [UIColor redColor];
    [[IGListCollectionView appearance] setBackgroundColor:appearanceColor];
    
    UIWindow *window = [[UIWindow alloc] initWithFrame:kIGListCollectionViewTestFrame];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"IGTestStoryboard" bundle:[NSBundle bundleForClass:self.class]];
    IGTestStoryboardViewController  *viewController = [storyboard instantiateViewControllerWithIdentifier:@"testVC"];
    [window addSubview:viewController.view];
    [viewController performSelectorOnMainThread:@selector(loadView) withObject:nil waitUntilDone:YES];
    
    XCTAssertEqualObjects(viewController.collectionView.backgroundColor, appearanceColor);
}

#pragma mark - Helper Methods

-(IGListCollectionView *)setupIGListCollectionView {
    UIWindow *window = [[UIWindow alloc] initWithFrame:kIGListCollectionViewTestFrame];
    IGListCollectionView *collectionView = [[IGListCollectionView alloc] initWithFrame: kIGListCollectionViewTestFrame collectionViewLayout:[UICollectionViewFlowLayout new]];
    UIViewController *viewController = [UIViewController new];
    [viewController.view addSubview:collectionView];
    [window addSubview:viewController.view];
    [viewController performSelectorOnMainThread:@selector(loadView) withObject:nil waitUntilDone:YES];
    
    return collectionView;
}

@end
