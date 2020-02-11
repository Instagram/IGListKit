/**
* Copyright (c) Facebook, Inc. and its affiliates.
*
* This source code is licensed under the MIT license found in the
* LICENSE file in the root directory of this source tree.
*/

#import "IGListBindingSingleSectionController.h"

#import <IGListDiffKit/IGListAssert.h>

@interface IGListBindingSingleSectionController () <IGListDisplayDelegate>

@end

@implementation IGListBindingSingleSectionController {
    id _item;
    __weak UICollectionViewCell *_displayingCell;
}

- (instancetype)init {
    if (self = [super init]) {
        self.displayDelegate = self;
    }
    return self;
}

- (void)didSelectItemWithCell:(UICollectionViewCell *)cell {
    // no-op
}

- (void)didDeselectItemWithCell:(UICollectionViewCell *)cell {
    // no-op
}

- (void)didHighlightItemWithCell:(UICollectionViewCell *)cell {
    // no-op
}

- (void)didUnhighlightItemWithCell:(UICollectionViewCell *)cell {
    // no-op
}

- (Class)cellClass {
    IGFailAssert(@"Implemented by subclass");
    return nil;
}

- (void)configureCell:(UICollectionViewCell *)cell withViewModel:(id)viewModel {
    IGFailAssert(@"Implemented by subclass");
}

- (CGSize)sizeForViewModel:(id)viewModel {
    IGFailAssert(@"Implemented by subclass");
    return CGSizeZero;
}

#pragma mark - IGListDisplayDelegate

- (void)listAdapter:(nonnull IGListAdapter *)listAdapter willDisplaySectionController:(nonnull IGListSectionController *)sectionController {
    // no-op
}

- (void)listAdapter:(nonnull IGListAdapter *)listAdapter didEndDisplayingSectionController:(nonnull IGListSectionController *)sectionController {
    // no-op
}

- (void)listAdapter:(nonnull IGListAdapter *)listAdapter willDisplaySectionController:(nonnull IGListSectionController *)sectionController cell:(nonnull UICollectionViewCell *)cell atIndex:(NSInteger)index {
    IGParameterAssert(index == 0);
    _displayingCell = cell;
}

- (void)listAdapter:(nonnull IGListAdapter *)listAdapter didEndDisplayingSectionController:(nonnull IGListSectionController *)sectionController cell:(nonnull UICollectionViewCell *)cell atIndex:(NSInteger)index {
    IGParameterAssert(index == 0);
    _displayingCell = nil;
}

#pragma mark - IGListSectionController Overrides

- (NSInteger)numberOfItems {
    return 1;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    IGParameterAssert(index == 0);
    return [self sizeForViewModel:_item];
}

- (UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    IGParameterAssert(index == 0);
    UICollectionViewCell *cell = [self.collectionContext dequeueReusableCellOfClass:[self cellClass] forSectionController:self atIndex:index];
    IGAssert(cell != nil, @"could not find a cell of class %@", NSStringFromClass([self cellClass]));
    [self configureCell:cell withViewModel:_item];
    return cell;
}

- (void)didUpdateToObject:(id)object {
    _item = object;

    if (_enabledCellConfigurationDuringUpdate) {
        if (_displayingCell) {
            [self configureCell:_displayingCell withViewModel:_item];
        }
    }
}

- (void)didSelectItemAtIndex:(NSInteger)index {
    IGParameterAssert(index == 0);
    UICollectionViewCell *cell = [self.collectionContext cellForItemAtIndex:0 sectionController:self];
    [self didSelectItemWithCell:cell];
}

- (void)didDeselectItemAtIndex:(NSInteger)index {
    IGParameterAssert(index == 0);
    UICollectionViewCell *cell = [self.collectionContext cellForItemAtIndex:0 sectionController:self];
    [self didDeselectItemWithCell:cell];
}

- (void)didHighlightItemAtIndex:(NSInteger)index {
    IGParameterAssert(index == 0);
    UICollectionViewCell *cell = [self.collectionContext cellForItemAtIndex:0 sectionController:self];
    [self didHighlightItemWithCell:cell];
}

- (void)didUnhighlightItemAtIndex:(NSInteger)index {
    IGParameterAssert(index == 0);
    UICollectionViewCell *cell = [self.collectionContext cellForItemAtIndex:0 sectionController:self];
    [self didUnhighlightItemWithCell:cell];
}

@end
