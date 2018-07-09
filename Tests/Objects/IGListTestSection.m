/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant 
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "IGListTestSection.h"

@implementation IGListTestSection

- (instancetype)init {
    if (self = [super init]) {
        _size = CGSizeMake(100, 10);
    }
    return self;
}

- (NSArray <Class> *)cellClasses {
    return @[UICollectionViewCell.class];
}

- (NSInteger)numberOfItems {
    return self.items;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    return self.size;
}

- (UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    return [self.collectionContext dequeueReusableCellOfClass:UICollectionViewCell.class
                                      forSectionController:self
                                                    atIndex:index];
}

- (void)didUpdateToObject:(id)object {
    if ([object isKindOfClass:[NSNumber class]]) {
        self.items = [object integerValue];
    }
}

- (void)didSelectItemAtIndex:(NSInteger)index {
    self.wasSelected = YES;
}

- (void)didDeselectItemAtIndex:(NSInteger)index {
    self.wasDeselected = YES;
}

- (void)didHighlightItemAtIndex:(NSInteger)index {
    self.wasHighlighted = YES;
}

- (void)didUnhighlightItemAtIndex:(NSInteger)index {
    self.wasUnhighlighted = YES;
}

@end
