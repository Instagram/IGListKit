/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant 
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "IGListItemMap.h"

#import <IGListKit/IGListAssert.h>

@interface IGListItemMap ()

// both of these maps allow fast lookups of objects, list items, and indexes
@property (nonatomic, strong, readonly) NSMapTable *itemListMap;
@property (nonatomic, strong, readonly) NSMapTable *listIndexMap;

@property (nonatomic, strong, readwrite) NSArray *items;

@end

@implementation IGListItemMap

- (instancetype)initWithMapTable:(NSMapTable *)mapTable {
    IGParameterAssert(mapTable != nil);

    if (self = [super init]) {
        _itemListMap = [mapTable copy];

        // lookup list items by pointer equality
        _listIndexMap = [[NSMapTable alloc] initWithKeyOptions:NSMapTableStrongMemory | NSMapTableObjectPointerPersonality
                                                  valueOptions:NSMapTableStrongMemory
                                                      capacity:0];
        _items = [NSArray new];
    }
    return self;
}


#pragma mark - Public API

- (NSUInteger)sectionForItemController:(IGListItemController <IGListItemType> *)itemController {
    IGParameterAssert(itemController != nil);

    NSNumber *index = [self.listIndexMap objectForKey:itemController];
    return index != nil ? [index unsignedIntegerValue] : NSNotFound;
}

- (IGListItemController <IGListItemType> *)itemControllerForSection:(NSUInteger)section {
    return [self.itemListMap objectForKey:[self itemForSection:section]];
}

- (void)updateWithItems:(NSArray *)items itemControllers:(NSArray *)itemControllers {
    IGParameterAssert(items.count == itemControllers.count);

    self.items = [items copy];

    [self reset];

    [items enumerateObjectsUsingBlock:^(id item, NSUInteger idx, BOOL *stop) {
        id <NSObject> itemController = itemControllers[idx];

        // set the index of the list for easy reverse lookup
        [self.listIndexMap setObject:@(idx) forKey:itemController];
        [self.itemListMap setObject:itemController forKey:item];
    }];
}

- (nullable IGListItemController <IGListItemType> *)itemControllerForItem:(id)item {
    IGParameterAssert(item != nil);

    return [self.itemListMap objectForKey:item];
}

- (id)itemForSection:(NSUInteger)section {
    return self.items[section];
}

- (NSUInteger)sectionForItem:(id)item {
    IGParameterAssert(item != nil);

    id itemController = [self itemControllerForItem:item];
    if (itemController == nil) {
        return NSNotFound;
    } else {
        return [self sectionForItemController:itemController];
    }
}

- (void)reset {
    [self.listIndexMap removeAllObjects];
    [self.itemListMap removeAllObjects];
}

- (void)updateItem:(id)item {
    IGParameterAssert(item != nil);
    const NSUInteger section = [self sectionForItem:item];
    id itemController = [self itemControllerForItem:item];
    [self.listIndexMap setObject:@(section) forKey:itemController];
    [self.itemListMap setObject:itemController forKey:item];

    NSMutableArray *mItems = [self.items mutableCopy];
    mItems[section] = item;
    self.items = [mItems copy];
}

- (void)enumerateItemsAndItemControllersUsingBlock:(void (^)(id item, IGListItemController <IGListItemType> *itemController, NSUInteger section, BOOL *stop))block {
    IGParameterAssert(block != nil);

    BOOL stop = NO;
    NSArray *items = self.items;
    for (NSUInteger section = 0; section < items.count; section++) {
        id item = items[section];
        IGListItemController <IGListItemType> *itemController = [self itemControllerForItem:item];
        block(item, itemController, section, &stop);
        if (stop) {
            break;
        }
    }
}


#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    IGListItemMap *copy = [[IGListItemMap allocWithZone:zone] initWithMapTable:self.itemListMap];
    copy->_listIndexMap = [self.listIndexMap copy];
    copy->_items = [self.items copy];
    return copy;
}

@end
