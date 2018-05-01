/**
 * Copyright (c) 2016-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGListTestStoryboardSection.h"
#import "IGTestStoryboardCell.h"

@implementation IGListTestStoryboardSection

- (NSInteger)numberOfItems {
    return self.items;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    return CGSizeMake(100, 45);
}

- (UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    return [self.collectionContext dequeueReusableCellFromStoryboardWithIdentifier:@"IGTestStoryboardCell"
                                                              forSectionController:self
                                                                           atIndex:index];
}

- (void)didUpdateToObject:(id)object {
    if ([object isKindOfClass:[NSNumber class]]) {
        self.items = [object integerValue];
    }
}

- (void)didSelectItemAtIndex:(NSInteger)index {}

@end
