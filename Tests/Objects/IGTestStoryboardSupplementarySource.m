/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "IGTestStoryboardSupplementarySource.h"
#import "IGTestStoryboardSupplementaryView.h"

@implementation IGTestStoryboardSupplementarySource

- (UICollectionReusableView *)viewForSupplementaryElementOfKind:(NSString *)elementKind
                                                        atIndex:(NSInteger)index {
    IGTestStoryboardSupplementaryView *view = [self.collectionContext dequeueReusableSupplementaryViewFromStoryboardOfKind:elementKind
                                                                                                            withIdentifier:@"IGTestStoryboardSupplementaryView"
                                                                                                      forSectionController:self.sectionController
                                                                                                                   atIndex:index];
    view.label.text = @"Header";
    return view;
}

- (CGSize)sizeForSupplementaryViewOfKind:(NSString *)elementKind atIndex:(NSInteger)index {
    return CGSizeMake([self.collectionContext containerSize].width, 45);
}

@end
