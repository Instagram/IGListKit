/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <IGListKit/IGListDisplayDelegate.h>

#import "IGListStackedSectionController.h"

@interface IGListStackedSectionController ()
<
IGListCollectionContext,
IGListDisplayDelegate,
IGListScrollDelegate
>

@property (nonatomic, strong, readonly) NSOrderedSet<__kindof IGListSectionController<IGListSectionType> *> *sectionControllers;

/// An array the length of the total number of items in the stack, pointing to an section controller for the item index.
@property (nonatomic, copy) NSArray<IGListSectionController<IGListSectionType> *> *sectionControllersForItems;

/// An array of index offsets for each item in the flattened stack.
@property (nonatomic, copy) NSArray<NSNumber *> *sectionControllerOffsets;

/// A cached collection of the number of items summed from each section controller in the stack.
@property (nonatomic, assign) NSUInteger flattenedNumberOfItems;

/// A counted set of the visible section controllers, used to forward granular display events to child section controllers
@property (nonatomic, strong, readonly) NSCountedSet *visibleSectionControllers;

- (IGListSectionController <IGListSectionType> *)sectionControllerForObjectIndex:(NSUInteger)itemIndex;
- (NSUInteger)offsetForSectionController:(IGListSectionController<IGListSectionType> *)sectionController;

@end
