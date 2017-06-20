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
@property (nonatomic, strong) NSMapTable *visibleViewObjectMap;

@end

@implementation IGListDisplayHandler

- (instancetype)init {
    if (self = [super init]) {
        _visibleListSections = [[NSCountedSet alloc] init];
        _visibleViewObjectMap = [[NSMapTable alloc] initWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableStrongMemory capacity:0];
    }
    return self;
}

- (id)pluckObjectForView:(UICollectionReusableView *)view {
    NSMapTable *viewObjectMap = self.visibleViewObjectMap;
    id object = [viewObjectMap objectForKey:view];
    [viewObjectMap removeObjectForKey:view];
    return object;
}

- (void)willDisplayReusableView:(UICollectionReusableView *)view
                 forListAdapter:(IGListAdapter *)listAdapter
              sectionController:(IGListSectionController *)sectionController
                         object:(id)object
                      indexPath:(NSIndexPath *)indexPath {
    IGParameterAssert(view != nil);
    IGParameterAssert(listAdapter != nil);
    IGParameterAssert(object != nil);
    IGParameterAssert(indexPath != nil);

    [self.visibleViewObjectMap setObject:object forKey:view];
    NSCountedSet *visibleListSections = self.visibleListSections;
    if ([visibleListSections countForObject:sectionController] == 0) {
        [sectionController.displayDelegate listAdapter:listAdapter willDisplaySectionController:sectionController];
        [listAdapter.delegate listAdapter:listAdapter willDisplayObject:object atIndex:indexPath.section];
    }
    [visibleListSections addObject:sectionController];
}

- (void)didEndDisplayingReusableView:(UICollectionReusableView *)view
                      forListAdapter:(IGListAdapter *)listAdapter
                   sectionController:(IGListSectionController *)sectionController
                              object:(id)object
                           indexPath:(NSIndexPath *)indexPath {
    IGParameterAssert(view != nil);
    IGParameterAssert(listAdapter != nil);
    IGParameterAssert(indexPath != nil);

    if (object == nil || sectionController == nil) {
        return;
    }

    const NSInteger section = indexPath.section;

    NSCountedSet *visibleSections = self.visibleListSections;
    [visibleSections removeObject:sectionController];

    if ([visibleSections countForObject:sectionController] == 0) {
        [sectionController.displayDelegate listAdapter:listAdapter didEndDisplayingSectionController:sectionController];
        [listAdapter.delegate listAdapter:listAdapter didEndDisplayingObject:object atIndex:section];
    }
}

- (void)willDisplaySupplementaryView:(UICollectionReusableView *)view
                      forListAdapter:(IGListAdapter *)listAdapter
                   sectionController:(IGListSectionController *)sectionController
                              object:(id)object
                           indexPath:(NSIndexPath *)indexPath {
    [self willDisplayReusableView:view forListAdapter:listAdapter sectionController:sectionController object:object indexPath:indexPath];
}

- (void)didEndDisplayingSupplementaryView:(UICollectionReusableView *)view
                           forListAdapter:(IGListAdapter *)listAdapter
                        sectionController:(IGListSectionController *)sectionController
                                indexPath:(NSIndexPath *)indexPath {
    // if cell display events break, don't send display events when the object has disappeared
    id object = [self pluckObjectForView:view];
    [self didEndDisplayingReusableView:view forListAdapter:listAdapter sectionController:sectionController object:object indexPath:indexPath];
}

- (void)willDisplayCell:(UICollectionViewCell *)cell
         forListAdapter:(IGListAdapter *)listAdapter
      sectionController:(IGListSectionController *)sectionController
                 object:(id)object
              indexPath:(NSIndexPath *)indexPath {
    id <IGListDisplayDelegate> displayDelegate = [sectionController displayDelegate];
    [displayDelegate listAdapter:listAdapter willDisplaySectionController:sectionController cell:cell atIndex:indexPath.item];
    [self willDisplayReusableView:cell forListAdapter:listAdapter sectionController:sectionController object:object indexPath:indexPath];
}

- (void)didEndDisplayingCell:(UICollectionViewCell *)cell
              forListAdapter:(IGListAdapter *)listAdapter
           sectionController:(IGListSectionController *)sectionController
                   indexPath:(NSIndexPath *)indexPath {
    // if cell display events break, don't send cell events to the displayDelegate when the object has disappeared
    id object = [self pluckObjectForView:cell];
    if (object == nil) {
        return;
    }

    [sectionController.displayDelegate listAdapter:listAdapter didEndDisplayingSectionController:sectionController cell:cell atIndex:indexPath.item];
    [self didEndDisplayingReusableView:cell forListAdapter:listAdapter sectionController:sectionController object:object indexPath:indexPath];
}

@end
