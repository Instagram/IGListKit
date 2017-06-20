/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

@class IGLayoutTestSection;

@interface IGLayoutTestDataSource : NSObject <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (nonatomic, strong) NSArray<IGLayoutTestSection *> *sections;

// call before using as the data source so cells and headers are configured
- (void)configCollectionView:(UICollectionView *)collectionView;

@end
