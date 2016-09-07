/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant 
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "IGTestDelegateController.h"

#import "IGTestCell.h"
#import "IGTestObject.h"

@implementation IGTestDelegateController

- (instancetype)init {
    if (self = [super init]) {
        _willDisplayCellIndexes = [NSCountedSet new];
        _didEndDisplayCellIndexes = [NSCountedSet new];
    }
    return self;
}

- (NSInteger)numberOfItems {
    if ([self.item.value isKindOfClass:[NSNumber class]]) {
        return [self.item.value integerValue];
    }
    return 1;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    return CGSizeMake(self.collectionContext.containerSize.width, 10);
}

- (UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    IGTestCell *cell = [self.collectionContext dequeueReusableCellOfClass:IGTestCell.class
                                                          forSectionController:self atIndex:index];
    [[cell label] setText:[NSString stringWithFormat:@"%@", self.item.value]];
    [cell setDelegate:self];
    if (self.cellConfigureBlock) {
        self.cellConfigureBlock(self);
    }
    return cell;
}

- (void)didUpdateToObject:(id)object {
    _updateCount++;
    _item = object;
    if (self.itemUpdateBlock) {
        self.itemUpdateBlock();
    }
}

- (id<IGListDisplayDelegate>)displayDelegate {
    return self;
}

- (void)didSelectItemAtIndex:(NSInteger)index {}

#pragma mark - IGListDisplayDelegate

- (void)listAdapter:(IGListAdapter *)listAdapter willDisplaySectionController:(IGListSectionController <IGListSectionType> *)sectionController {
    self.willDisplayCount++;
}

- (void)listAdapter:(IGListAdapter *)listAdapter didEndDisplayingSectionController:(IGListSectionController <IGListSectionType> *)sectionController {
    self.didEndDisplayCount++;
}

- (void)listAdapter:(IGListAdapter *)listAdapter willDisplaySectionController:(IGListSectionController <IGListSectionType> *)sectionController
               cell:(UICollectionViewCell *)cell
            atIndex:(NSInteger)index {
    [self.willDisplayCellIndexes addObject:@(index)];
}
- (void)listAdapter:(IGListAdapter *)listAdapter didEndDisplayingSectionController:(IGListSectionController <IGListSectionType> *)sectionController
               cell:(UICollectionViewCell *)cell
            atIndex:(NSInteger)index {
    [self.didEndDisplayCellIndexes addObject:@(index)];
}

- (void)listAdapter:(IGListAdapter *)listAdapter didScrollSectionController:(IGListSectionController <IGListSectionType> *)sectionController {}

@end
