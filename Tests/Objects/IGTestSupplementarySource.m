/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant 
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "IGTestSupplementarySource.h"

@implementation IGTestSupplementarySource

#pragma mark - IGListSupplementaryViewSource

- (UICollectionReusableView *)viewForSupplementaryElementOfKind:(NSString *)elementKind
                                                        atIndex:(NSInteger)index {
    return [self.collectionContext dequeReusableSupplementaryViewOfKind:elementKind
                                                  forItemController:self.itemController
                                                                  class:[UICollectionReusableView class]
                                                                atIndex:index];
}

- (CGSize)sizeForSupplementaryViewOfKind:(NSString *)elementKind atIndex:(NSInteger)index {
    return CGSizeMake([self.collectionContext containerSize].width, 10);
}

- (CGSize)estimatedSizeForSupplementaryViewOfKind:(NSString *)elementKind
                                          atIndex:(NSInteger)index {
    return CGSizeZero;
}

@end
