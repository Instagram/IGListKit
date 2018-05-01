/**
 * Copyright (c) 2016-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGListTestContainerSizeSection.h"

@implementation IGListTestContainerSizeSection

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.inset = UIEdgeInsetsMake(1.0, 1.0, 1.0, 1.0);
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
    return CGSizeMake(100, 10);
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
}

@end
