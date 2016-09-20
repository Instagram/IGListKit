/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant 
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <IGListKit/IGListDisplayDelegate.h>

#import "IGListStackedItemController.h"

@interface IGListStackedItemController ()
<
IGListCollectionContext,
IGListDisplayDelegate,
IGListScrollDelegate
>

@property (nonatomic, strong, readonly) NSOrderedSet<__kindof IGListItemController<IGListItemType> *> *itemControllers;

/// An array the length of the total number of items in the stack, pointing to an item controller for the item index.
@property (nonatomic, copy) NSArray<IGListItemController<IGListItemType> *> *itemControllersForItems;

/// An array of index offsets for each item in the flattened stack.
@property (nonatomic, copy) NSArray<NSNumber *> *itemControllerOffsets;

/// A cached collection of the number of items summed from each item controller in the stack.
@property (nonatomic, assign) NSUInteger flattenedNumberOfItems;

/// A counted set of the visible item controllers, used to forward granular display events to child item controllers
@property (nonatomic, strong, readonly) NSCountedSet *visibleItemControllers;

- (IGListItemController <IGListItemType> *)itemControllerForItemIndex:(NSUInteger)itemIndex;
- (NSUInteger)offsetForItemController:(IGListItemController<IGListItemType> *)itemController;

@end
