/**
 * Copyright (c) 2016-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <IGListKit/IGListDisplayDelegate.h>

#import "IGListStackedSectionController.h"

@interface IGListStackedSectionController ()
<
IGListBatchContext,
IGListCollectionContext,
IGListDisplayDelegate,
IGListScrollDelegate,
IGListWorkingRangeDelegate
>

@property (nonatomic, strong, readonly) NSOrderedSet<__kindof IGListSectionController *> *sectionControllers;

/// An array the length of the total number of items in the stack, pointing to a section controller for the item index.
@property (nonatomic, copy) NSArray<IGListSectionController *> *sectionControllersForItems;

/// An array of index offsets for each item in the flattened stack.
@property (nonatomic, copy) NSArray<NSNumber *> *sectionControllerOffsets;

/// A cached collection of the number of items summed from each section controller in the stack.
@property (nonatomic, assign) NSInteger flattenedNumberOfItems;

/// A counted set of the visible section controllers, used to forward granular display events to child section controllers
@property (nonatomic, strong, readonly) NSCountedSet *visibleSectionControllers;

/// Temporary batch context so the stack controller can transform child indices within the stack before updating.
@property (nonatomic, strong) id<IGListBatchContext> forwardingBatchContext;

- (IGListSectionController *)sectionControllerForObjectIndex:(NSInteger)itemIndex;
- (NSInteger)offsetForSectionController:(IGListSectionController *)sectionController;
- (void)reloadData;

@end
