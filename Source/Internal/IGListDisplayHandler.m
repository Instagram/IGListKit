/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant 
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "IGListDisplayHandler.h"

#import <IGListKit/IGListAssert.h>
#import <IGListKit/IGListAdapter.h>
#import <IGListKit/IGListDisplayDelegate.h>
#import <IGListKit/IGListItemController.h>

@interface IGListDisplayHandler ()

@property (nonatomic, strong) NSCountedSet *visibleListSections;
@property (nonatomic, strong) NSMapTable *visibleCellObjectMap;

@end

@implementation IGListDisplayHandler

- (instancetype)init {
    if (self = [super init]) {
        _visibleListSections = [[NSCountedSet alloc] init];
        _visibleCellObjectMap = [[NSMapTable alloc] initWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableStrongMemory capacity:0];
    }
    return self;
}

- (void)willDisplayCell:(UICollectionViewCell *)cell
         forListAdapter:(IGListAdapter *)listAdapter
     itemController:(IGListItemController<IGListItemType> *)itemController
                 object:(id)object
              indexPath:(NSIndexPath *)indexPath {
    IGParameterAssert(cell != nil);
    IGParameterAssert(listAdapter != nil);
    IGParameterAssert(object != nil);
    IGParameterAssert(indexPath != nil);

    id <IGListDisplayDelegate> displayDelegate = [itemController displayDelegate];

    [displayDelegate listAdapter:listAdapter willDisplayItemController:itemController cell:cell atIndex:indexPath.item];

    [self.visibleCellObjectMap setObject:object forKey:cell];

    if ([self.visibleListSections countForObject:itemController] == 0) {
        [displayDelegate listAdapter:listAdapter willDisplayItemController:itemController];
        [listAdapter.delegate listAdapter:listAdapter willDisplayItem:object atIndex:indexPath.section];
    }
    [self.visibleListSections addObject:itemController];
}

- (void)didEndDisplayingCell:(UICollectionViewCell *)cell
              forListAdapter:(IGListAdapter *)listAdapter
          itemController:(IGListItemController<IGListItemType> *)itemController
                   indexPath:(NSIndexPath *)indexPath {
    IGParameterAssert(cell != nil);
    IGParameterAssert(listAdapter != nil);
    IGParameterAssert(indexPath != nil);

    const NSUInteger section = indexPath.section;

    NSMapTable *cellObjectMap = self.visibleCellObjectMap;
    id object = [cellObjectMap objectForKey:cell];
    [cellObjectMap removeObjectForKey:cell];

    if (object == nil || itemController == nil) {
        return;
    }

    id <IGListDisplayDelegate> displayDelegate = [itemController displayDelegate];
    [displayDelegate listAdapter:listAdapter didEndDisplayingItemController:itemController cell:cell atIndex:indexPath.item];

    NSCountedSet *visibleSections = self.visibleListSections;
    [visibleSections removeObject:itemController];
    if ([visibleSections countForObject:itemController] == 0) {
        [displayDelegate listAdapter:listAdapter didEndDisplayingItemController:itemController];
        [listAdapter.delegate listAdapter:listAdapter didEndDisplayingItem:object atIndex:section];
    }
}

@end
