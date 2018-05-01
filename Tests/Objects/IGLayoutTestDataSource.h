/**
 * Copyright (c) 2016-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

@class IGLayoutTestSection;

@interface IGLayoutTestDataSource : NSObject <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (nonatomic, strong) NSArray<IGLayoutTestSection *> *sections;

// call before using as the data source so cells and headers are configured
- (void)configCollectionView:(UICollectionView *)collectionView;

@end
