/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
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
