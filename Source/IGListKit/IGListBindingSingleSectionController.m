/**
* Copyright (c) Meta Platforms, Inc. and affiliates.
*
* This source code is licensed under the MIT license found in the
* LICENSE file in the root directory of this source tree.
*/

#import "IGListBindingSingleSectionController.h"

#if !__has_include(<IGListDiffKit/IGListDiffKit.h>)
#import "IGListAssert.h"
#else
#import <IGListDiffKit/IGListAssert.h>
#endif

#import "IGListSectionControllerInternal.h"

@interface IGListBindingSingleSectionController ()

@end

@implementation IGListBindingSingleSectionController {
    id<IGListDiffable> _item;
    __weak UICollectionViewCell *_displayingCell;
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

- (void)didUpdateToObject:(id<IGListDiffable>)object {
    if ([_item isEqualToDiffableObject:object]) {
        return;
    }
    _item = object;

    if (_displayingCell) {
        [self configureCell:_displayingCell withViewModel:_item];
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

- (void)willDisplayCell:(UICollectionViewCell *)cell atIndex:(NSInteger)index listAdapter:(IGListAdapter *)listAdapter {
    IGParameterAssert(index == 0);
    _displayingCell = cell;
    [super willDisplayCell:cell atIndex:index listAdapter:listAdapter];
}

- (void)didEndDisplayingCell:(UICollectionViewCell *)cell atIndex:(NSInteger)index listAdapter:(IGListAdapter *)listAdapter {
    IGParameterAssert(index == 0);
    if (cell == _displayingCell) {
        _displayingCell = nil;
    }
    [super didEndDisplayingCell:cell atIndex:index listAdapter:listAdapter];
}

- (BOOL)isDisplayingCell {
    return _displayingCell != nil;
}

@end
