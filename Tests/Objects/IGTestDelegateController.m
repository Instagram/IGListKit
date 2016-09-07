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

- (NSUInteger)numberOfItems {
    if ([self.item.value isKindOfClass:[NSNumber class]]) {
        return [self.item.value integerValue];
    }
    return 1;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    return CGSizeMake(self.collectionContext.containerSize.width, 10);
}

- (UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    IGTestCell *cell = [self.collectionContext dequeReusableCellOfClass:IGTestCell.class
                                                          forItemController:self atIndex:index];
    [[cell label] setText:[NSString stringWithFormat:@"%@", self.item.value]];
    [cell setDelegate:self];
    return cell;
}

- (void)didUpdateToItem:(id)item {
    _updateCount++;
    _item = item;
    if (self.itemUpdateBlock) {
        self.itemUpdateBlock();
    }
}

- (id<IGListDisplayDelegate>)displayDelegate {
    return self;
}

- (void)didSelectItemAtIndex:(NSInteger)index {}
- (void)didDeselectItemAtIndex:(NSInteger)index {}

#pragma mark - IGListDisplayDelegate

- (void)listAdapter:(IGListAdapter *)listAdapter willDisplayItemController:(IGListItemController <IGListItemType> *)itemController {
    self.willDisplayCount++;
}

- (void)listAdapter:(IGListAdapter *)listAdapter didEndDisplayingItemController:(IGListItemController <IGListItemType> *)itemController {
    self.didEndDisplayCount++;
}

- (void)listAdapter:(IGListAdapter *)listAdapter willDisplayItemController:(IGListItemController <IGListItemType> *)itemController
               cell:(UICollectionViewCell *)cell
            atIndex:(NSInteger)index {
    [self.willDisplayCellIndexes addObject:@(index)];
}
- (void)listAdapter:(IGListAdapter *)listAdapter didEndDisplayingItemController:(IGListItemController <IGListItemType> *)itemController
               cell:(UICollectionViewCell *)cell
            atIndex:(NSInteger)index {
    [self.didEndDisplayCellIndexes addObject:@(index)];
}

- (void)listAdapter:(IGListAdapter *)listAdapter didScrollItemController:(IGListItemController <IGListItemType> *)itemController {}

@end
