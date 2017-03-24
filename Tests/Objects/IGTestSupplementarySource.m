/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant 
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "IGTestSupplementarySource.h"

#import "IGTestNibSupplementaryView.h"

@implementation IGTestSupplementarySource

- (instancetype)init {
    if (self = [super init]) {
        _size = CGSizeMake(100, 10);
    }
    return self;
}

#pragma mark - IGListSupplementaryViewSource

- (UICollectionReusableView *)viewForSupplementaryElementOfKind:(NSString *)elementKind
                                                        atIndex:(NSInteger)index {
    if (self.dequeueFromNib) {
        IGTestNibSupplementaryView *view = [self.collectionContext dequeueReusableSupplementaryViewOfKind:elementKind
                                                                                     forSectionController:self.sectionController
                                                                                                  nibName:@"IGTestNibSupplementaryView"
                                                                                                   bundle:[NSBundle bundleForClass:self.class]
                                                                                                  atIndex:index];
        view.label.text = @"Foo bar baz";
        return view;
    } else {
        return [self.collectionContext dequeueReusableSupplementaryViewOfKind:elementKind
                                                         forSectionController:self.sectionController
                                                                        class:[UICollectionReusableView class]
                                                                      atIndex:index];
    }
}

- (CGSize)sizeForSupplementaryViewOfKind:(NSString *)elementKind atIndex:(NSInteger)index {
    return self.size;
}

@end
