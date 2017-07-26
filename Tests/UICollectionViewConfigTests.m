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

@interface UICollectionViewConfigTests : XCTestCase

@end

@implementation UICollectionViewConfigTests

- (void)testCollectionViewConfiguration {
    UICollectionViewLayout *layout = [[IGListCollectionViewLayout alloc] initWithStickyHeaders:NO topContentInset:0.0 stretchToEdge:YES];
    UICollectionView *collectionView =
                                      [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 100, 100) collectionViewLayout:layout];
    
    [collectionView ig_ConfigForIGListKit];
    
    XCTAssertFalse(collectionView.prefetchingEnabled);
    XCTAssertEqual(collectionView.backgroundColor, [UIColor whiteColor]);
}

@end
