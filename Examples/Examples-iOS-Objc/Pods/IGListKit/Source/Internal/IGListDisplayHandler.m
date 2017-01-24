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
#import <IGListKit/IGListSectionController.h>

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
      sectionController:(IGListSectionController<IGListSectionType> *)sectionController
                 object:(id)object
              indexPath:(NSIndexPath *)indexPath {
    IGParameterAssert(cell != nil);
    IGParameterAssert(listAdapter != nil);
    IGParameterAssert(object != nil);
    IGParameterAssert(indexPath != nil);

    id <IGListDisplayDelegate> displayDelegate = [sectionController displayDelegate];

    [displayDelegate listAdapter:listAdapter willDisplaySectionController:sectionController cell:cell atIndex:indexPath.item];

    [self.visibleCellObjectMap setObject:object forKey:cell];

    if ([self.visibleListSections countForObject:sectionController] == 0) {
        [displayDelegate listAdapter:listAdapter willDisplaySectionController:sectionController];
        [listAdapter.delegate listAdapter:listAdapter willDisplayObject:object atIndex:indexPath.section];
    }
    [self.visibleListSections addObject:sectionController];
}

- (void)didEndDisplayingCell:(UICollectionViewCell *)cell
              forListAdapter:(IGListAdapter *)listAdapter
           sectionController:(IGListSectionController<IGListSectionType> *)sectionController
                   indexPath:(NSIndexPath *)indexPath {
    IGParameterAssert(cell != nil);
    IGParameterAssert(listAdapter != nil);
    IGParameterAssert(indexPath != nil);

    const NSUInteger section = indexPath.section;

    NSMapTable *cellObjectMap = self.visibleCellObjectMap;
    id object = [cellObjectMap objectForKey:cell];
    [cellObjectMap removeObjectForKey:cell];

    if (object == nil || sectionController == nil) {
        return;
    }

    id <IGListDisplayDelegate> displayDelegate = [sectionController displayDelegate];
    [displayDelegate listAdapter:listAdapter didEndDisplayingSectionController:sectionController cell:cell atIndex:indexPath.item];

    NSCountedSet *visibleSections = self.visibleListSections;
    [visibleSections removeObject:sectionController];
    if ([visibleSections countForObject:sectionController] == 0) {
        [displayDelegate listAdapter:listAdapter didEndDisplayingSectionController:sectionController];
        [listAdapter.delegate listAdapter:listAdapter didEndDisplayingObject:object atIndex:section];
    }
}

@end
