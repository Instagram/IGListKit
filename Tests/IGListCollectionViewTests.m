//
//  IGListCollectionViewTests.m
//  IGListKit
//
//  Created by Jeff Bailey on 12/7/16.
//  Copyright © 2016 Instagram. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <IGListKit/IGListKit.h>

static const CGRect kIGListCollectionViewTestFrame = (CGRect){{0.0, 0.0}, {100.0, 100.0}};

@interface IGListCollectionViewTests : XCTestCase

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) IGListCollectionView *collectionView;
@property (nonatomic, strong) UIViewController *viewController;

@end

@implementation IGListCollectionViewTests

- (void)setUp {
    [super setUp];
    self.window = [[UIWindow alloc] initWithFrame:kIGListCollectionViewTestFrame];
    self.collectionView = [[IGListCollectionView alloc] initWithFrame: kIGListCollectionViewTestFrame collectionViewLayout:[UICollectionViewFlowLayout new]];
    self.viewController = [UIViewController new];
}

- (void)tearDown {
    [super tearDown];
    [self.viewController.view removeFromSuperview];
    
    [[IGListCollectionView appearance] setBackgroundColor:nil];
}

-(void)test_whenUsingUIAppearance_thatIGListCollectionViewUsesAppearanceBackgroundColor {
    UIColor *appearanceColor = [UIColor redColor];
    [[IGListCollectionView appearance] setBackgroundColor:appearanceColor];
    
    [self.viewController.view addSubview:self.collectionView];
    [self.window addSubview:self.viewController.view];

    [self.viewController performSelectorOnMainThread:@selector(loadView) withObject:nil waitUntilDone:YES];

    XCTAssertEqualObjects(self.collectionView.backgroundColor, appearanceColor);
}

-(void)test_whenNotUsingUIAppearance_thatIGListCollectionViewUsesDefaultBackgroundColor {
    [self.viewController.view addSubview:self.collectionView];
    [self.window addSubview:self.viewController.view];
    
    [self.viewController performSelectorOnMainThread:@selector(loadView) withObject:nil waitUntilDone:YES];
    
    XCTAssertEqualObjects(self.collectionView.backgroundColor, [UIColor whiteColor]);
}

-(void)test_thatCollectionViewHasCorrectDefaults {
    XCTAssertTrue(self.collectionView.alwaysBounceVertical);
}


@end
