//
//  IGListCollectionViewStoryboardTests.m
//  IGListKit
//
//  Created by Jeff Bailey on 12/8/16.
//  Copyright © 2016 Instagram. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <IGListKit/IGListKit.h>
#import "IGTestStoryboardViewController.h"

static const CGRect kIGListCollectionViewTestFrame = (CGRect){{0.0, 0.0}, {100.0, 100.0}};

@interface IGListCollectionViewStoryboardTests : XCTestCase

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) IGTestStoryboardViewController *viewController;
@end

@implementation IGListCollectionViewStoryboardTests

- (void)setUp {
    [super setUp];
    
    self.window = [[UIWindow alloc] initWithFrame:kIGListCollectionViewTestFrame];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
    [self.viewController.view removeFromSuperview];
}

-(void)test_whenUsingUIAppearance_thatStoryboardIGListCollectionViewUsesAppearanceBackgroundColor {
    UIColor *appearanceColor = [UIColor redColor];
    [[IGListCollectionView appearance] setBackgroundColor:appearanceColor];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"IGTestStoryboard" bundle:[NSBundle bundleForClass:self.class]];
    self.viewController = [storyboard instantiateViewControllerWithIdentifier:@"testVC"];
    [self.window addSubview:self.viewController.view];
    [self.viewController performSelectorOnMainThread:@selector(loadView) withObject:nil waitUntilDone:YES];
    
    XCTAssertEqualObjects(self.viewController.collectionView.backgroundColor, appearanceColor);
}

@end
