/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGListTestSection.h"

@interface IGListTestSection () <IGListDisplayDelegate>
@end

@implementation IGListTestSection

- (instancetype)init {
    if (self = [super init]) {
        _size = CGSizeMake(100, 10);
        self.displayDelegate = self;
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

- (UIContextMenuConfiguration * _Nullable)contextMenuConfigurationForItemAtIndex:(NSInteger)index point:(CGPoint)point {
  self.requestedContextMenu = YES;
  return nil;
}

#pragma mark - IGListDisplayDelegate

- (void)listAdapter:(IGListAdapter *)listAdapter willDisplaySectionController:(IGListSectionController *)sectionController {
    _wasDisplayed = YES;
}

- (void)listAdapter:(IGListAdapter *)listAdapter didEndDisplayingSectionController:(IGListSectionController *)sectionController {}
- (void)listAdapter:(IGListAdapter *)listAdapter willDisplaySectionController:(IGListSectionController *)sectionController
               cell:(UICollectionViewCell *)cell
            atIndex:(NSInteger)index {}
- (void)listAdapter:(IGListAdapter *)listAdapter didEndDisplayingSectionController:(IGListSectionController *)sectionController
               cell:(UICollectionViewCell *)cell
            atIndex:(NSInteger)index {}

@end
