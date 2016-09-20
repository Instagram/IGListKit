/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant 
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "IGListStackedItemControllerInternal.h"

#import <objc/runtime.h>

#import <IGListKit/IGListAssert.h>
#import <IGListKit/IGListSupplementaryViewSource.h>

#import "IGListItemControllerInternal.h"

@interface UICollectionViewCell (IGListStackedItemController)
@end
@implementation UICollectionViewCell (IGListStackedItemController)

static void * kStackedItemControllerKey = &kStackedItemControllerKey;

- (void)ig_setStackedItemController:(id)stackedItemController {
    objc_setAssociatedObject(self, kStackedItemControllerKey, stackedItemController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)ig_stackedItemController {
    return objc_getAssociatedObject(self, kStackedItemControllerKey);
}

static void * kStackedItemControllerIndexKey = &kStackedItemControllerIndexKey;

- (void)ig_setStackedItemControllerIndex:(NSInteger)stackedItemControllerIndex {
    objc_setAssociatedObject(self, kStackedItemControllerIndexKey, @(stackedItemControllerIndex), OBJC_ASSOCIATION_ASSIGN);
}

- (NSInteger)ig_stackedItemControllerIndex {
    return [objc_getAssociatedObject(self, kStackedItemControllerIndexKey) integerValue];
}

@end

@implementation IGListStackedItemController

- (instancetype)initWithItemControllers:(NSArray <IGListItemController<IGListItemType> *> *)itemControllers {
    if (self = [super init]) {
        for (IGListItemController<IGListItemType> *itemController in itemControllers) {
            itemController.collectionContext = self;
            itemController.viewController = self.viewController;

            if (self.supplementaryViewSource == nil) {
                self.supplementaryViewSource = itemController.supplementaryViewSource;
            }
        }

        _visibleItemControllers = [[NSCountedSet alloc] init];
        _itemControllers = [NSOrderedSet orderedSetWithArray:itemControllers];

        self.displayDelegate = self;
        self.scrollDelegate = self;

        [self reloadData];
    }
    return self;
}


#pragma mark - Private API

- (void)reloadData {
    NSMutableArray *itemControllers = [[NSMutableArray alloc] init];
    NSMutableArray *offsets = [[NSMutableArray alloc] init];

    NSUInteger numberOfItems = 0;
    for (IGListItemController<IGListItemType> *itemController in self.itemControllers) {
        [offsets addObject:@(numberOfItems)];

        const NSUInteger items = [itemController numberOfItems];
        for (NSUInteger i = 0; i < items; i++) {
            [itemControllers addObject:itemController];
        }

        numberOfItems += items;
    }

    self.itemControllerOffsets = offsets;
    self.flattenedNumberOfItems = numberOfItems;
    self.itemControllersForItems = itemControllers;

    IGAssert(self.itemControllerOffsets.count == self.itemControllers.count, @"Not enough offsets for item controllers");
    IGAssert(self.itemControllersForItems.count == self.flattenedNumberOfItems, @"Controller map does not equal total number of items");
}

- (IGListItemController <IGListItemType> *)itemControllerForItemIndex:(NSUInteger)itemIndex {
    return self.itemControllersForItems[itemIndex];
}

- (NSUInteger)offsetForItemController:(IGListItemController<IGListItemType> *)itemController {
    const NSUInteger index = [self.itemControllers indexOfObject:itemController];
    IGAssert(index != NSNotFound, @"Querying offset for an undocumented item controller");
    return [self.itemControllerOffsets[index] integerValue];
}

- (NSUInteger)localIndexForItemController:(IGListItemController<IGListItemType> *)itemController index:(NSUInteger)index {
    const NSUInteger offset = [self offsetForItemController:itemController];
    IGAssert(offset <= index, @"Item controller offset must be less than or equal to the item index");
    return index - offset;
}

- (NSIndexSet *)itemIndexesForItemController:(IGListItemController<IGListItemType> *)itemController indexes:(NSIndexSet *)indexes {
    const NSUInteger offset = [self offsetForItemController:itemController];
    NSMutableIndexSet *itemIndexes = [[NSMutableIndexSet alloc] init];
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [itemIndexes addIndex:(idx + offset)];
    }];
    return itemIndexes;
}


#pragma mark - IGListItemType

- (NSUInteger)numberOfItems {
    return self.flattenedNumberOfItems;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    IGListItemController<IGListItemType> *itemController = [self itemControllerForItemIndex:index];
    const NSUInteger localIndex = [self localIndexForItemController:itemController index:index];
    return [itemController sizeForItemAtIndex:localIndex];
}

- (UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    IGListItemController<IGListItemType> *itemController = [self itemControllerForItemIndex:index];
    const NSUInteger localIndex = [self localIndexForItemController:itemController index:index];
    return [itemController cellForItemAtIndex:localIndex];
}

- (void)didUpdateToItem:(id)item {
    for (IGListItemController<IGListItemType> *itemController in self.itemControllers) {
        [itemController didUpdateToItem:item];
    }
}

- (void)didSelectItemAtIndex:(NSInteger)index {
    IGListItemController<IGListItemType> *itemController = [self itemControllerForItemIndex:index];
    const NSUInteger localIndex = [self localIndexForItemController:itemController index:index];
    [itemController didSelectItemAtIndex:localIndex];
}

#pragma mark - IGListCollectionContext

- (CGSize)containerSize {
    return [self.collectionContext containerSize];
}

- (NSUInteger)indexForCell:(UICollectionViewCell *)cell itemController:(IGListItemController<IGListItemType> *)itemController {
    const NSUInteger index = [self.collectionContext indexForCell:cell itemController:self];
    return [self localIndexForItemController:itemController index:index];
}

- (UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index itemController:(IGListItemController<IGListItemType> *)itemController {
    const NSUInteger offset = [self offsetForItemController:itemController];
    return [self.collectionContext cellForItemAtIndex:(index + offset) itemController:self];
}

- (NSArray<UICollectionViewCell *> *)visibleCellsForItemController:(IGListItemController<IGListItemType> *)itemController {
    NSMutableArray *cells = [NSMutableArray new];
    id<IGListCollectionContext> collectionContext = self.collectionContext;
    NSArray *visibleCells = [collectionContext visibleCellsForItemController:self];
    for (UICollectionViewCell *cell in visibleCells) {
        const NSUInteger index = [collectionContext indexForCell:cell itemController:self];
        if (self.itemControllersForItems[index] == itemController) {
            [cells addObject:cell];
        }
    }
    return [cells copy];
}

- (void)deselectItemAtIndex:(NSInteger)index itemController:(IGListItemController<IGListItemType> *)itemController animated:(BOOL)animated {
    const NSUInteger localIndex = [self localIndexForItemController:itemController index:index];
    [self.collectionContext deselectItemAtIndex:localIndex itemController:self animated:animated];
}

- (NSUInteger)sectionForItemController:(IGListItemController<IGListItemType> *)itemController {
    return [self.collectionContext sectionForItemController:self];
}

- (UICollectionViewCell *)dequeReusableCellOfClass:(Class)cellClass
                             forItemController:(IGListItemController<IGListItemType> *)itemController
                                           atIndex:(NSInteger)index {
    const NSUInteger offset = [self offsetForItemController:itemController];
    return (UICollectionViewCell *_Nonnull)[self.collectionContext dequeReusableCellOfClass:cellClass
                                                                      forItemController:self
                                                                                    atIndex:(index + offset)];
}

- (UICollectionReusableView *)dequeReusableSupplementaryViewOfKind:(NSString *)elementKind
                                             forItemController:(IGListItemController<IGListItemType> *)itemController
                                                             class:(Class)viewClass
                                                           atIndex:(NSInteger)index {
    const NSUInteger offset = [self offsetForItemController:itemController];
    return (UICollectionViewCell *_Nonnull)[self.collectionContext dequeReusableSupplementaryViewOfKind:elementKind
                                                                                  forItemController:self
                                                                                                  class:viewClass
                                                                                                atIndex:(index + offset)];
}

- (void)reloadItemsInItemController:(IGListItemController<IGListItemType> *)itemController atIndexes:(NSIndexSet *)indexes {
    NSIndexSet *itemIndexes = [self itemIndexesForItemController:itemController indexes:indexes];
    [self.collectionContext reloadItemsInItemController:self atIndexes:itemIndexes];
}

- (void)insertItemsInItemController:(IGListItemController<IGListItemType> *)itemController atIndexes:(NSIndexSet *)indexes {
    [self reloadData];
    NSIndexSet *itemIndexes = [self itemIndexesForItemController:itemController indexes:indexes];
    [self.collectionContext insertItemsInItemController:self atIndexes:itemIndexes];
}

- (void)deleteItemsInItemController:(IGListItemController<IGListItemType> *)itemController atIndexes:(NSIndexSet *)indexes {
    [self reloadData];
    NSIndexSet *itemIndexes = [self itemIndexesForItemController:itemController indexes:indexes];
    [self.collectionContext deleteItemsInItemController:self atIndexes:itemIndexes];
}

- (void)reloadItemController:(IGListItemController<IGListItemType> *)itemController {
    [self reloadData];
    [self.collectionContext reloadItemController:self];
}

- (void)performBatchAnimated:(BOOL)animated updates:(void (^)())updates completion:(void (^)(BOOL))completion {
    [self.collectionContext performBatchAnimated:animated updates:^{
        updates();
    } completion:^(BOOL finished) {
        [self reloadData];
        if (completion) {
            completion(finished);
        }
    }];
}


#pragma mark - IGListDisplayDelegate

- (void)listAdapter:(IGListAdapter *)listAdapter willDisplayItemController:(IGListItemController<IGListItemType> *)itemController cell:(UICollectionViewCell *)cell atIndex:(NSInteger)index {
    IGListItemController<IGListItemType> *childItemController = [self itemControllerForItemIndex:index];
    const NSUInteger localIndex = [self localIndexForItemController:childItemController index:index];

    [cell ig_setStackedItemController:childItemController];
    [cell ig_setStackedItemControllerIndex:localIndex];

    NSCountedSet *visibleItemControllers = self.visibleItemControllers;
    id<IGListDisplayDelegate> displayDelegate = [childItemController displayDelegate];

    if ([visibleItemControllers countForObject:childItemController] == 0) {
        [displayDelegate listAdapter:listAdapter willDisplayItemController:childItemController];
    }
    [displayDelegate listAdapter:listAdapter willDisplayItemController:childItemController cell:cell atIndex:localIndex];

    [visibleItemControllers addObject:childItemController];
}

- (void)listAdapter:(IGListAdapter *)listAdapter didEndDisplayingItemController:(IGListItemController<IGListItemType> *)itemController cell:(UICollectionViewCell *)cell atIndex:(NSInteger)index {
    IGListItemController<IGListItemType> *childItemController = [self itemControllerForItemIndex:index];
    const NSUInteger localIndex = [self localIndexForItemController:childItemController index:index];
    NSCountedSet *visibleItemControllers = self.visibleItemControllers;
    id<IGListDisplayDelegate> displayDelegate = [childItemController displayDelegate];

    [displayDelegate listAdapter:listAdapter didEndDisplayingItemController:childItemController cell:cell atIndex:localIndex];

    [visibleItemControllers removeObject:childItemController];
    if ([visibleItemControllers countForObject:childItemController] == 0) {
        [displayDelegate listAdapter:listAdapter didEndDisplayingItemController:childItemController];
    }
}

- (void)listAdapter:(IGListAdapter *)listAdapter willDisplayItemController:(IGListItemController<IGListItemType> *)itemController {}
- (void)listAdapter:(IGListAdapter *)listAdapter didEndDisplayingItemController:(IGListItemController<IGListItemType> *)itemController {}

#pragma mark - IGListScrollDelegate

- (void)listAdapter:(IGListAdapter *)listAdapter didScrollItemController:(IGListItemController<IGListItemType> *)itemController {
    for (IGListItemController<IGListItemType> *childItemController in self.itemControllers) {
        [[childItemController scrollDelegate] listAdapter:listAdapter didScrollItemController:childItemController];
    }
}

- (void)listAdapter:(IGListAdapter *)listAdapter willBeginDraggingItemController:(IGListItemController<IGListItemType> *)itemController {
    for (IGListItemController<IGListItemType> *childItemController in self.itemControllers) {
        [[childItemController scrollDelegate] listAdapter:listAdapter willBeginDraggingItemController:itemController];
    }
}

- (void)listAdapter:(IGListAdapter *)listAdapter didEndDraggingItemController:(IGListItemController<IGListItemType> *)itemController willDecelerate:(BOOL)decelerate {
    for (IGListItemController<IGListItemType> *childItemController in self.itemControllers) {
        [[childItemController scrollDelegate] listAdapter:listAdapter didEndDraggingItemController:childItemController willDecelerate:decelerate];
    }
}

@end
