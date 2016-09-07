/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant 
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <Foundation/Foundation.h>

#import <IGListKit/IGListMacros.h>

@class IGListItemController;
@protocol IGListItemType;

NS_ASSUME_NONNULL_BEGIN

/**
 The IGListItemMap provides a way to map a collection of items to a collection of list items, achieve O(1) lookup time,
 and track the type of list items contained in the collection.

 IGListItemMap is a mutable object and does not garauntee thread safety.
 */
IGLK_SUBCLASSING_RESTRICTED
@interface IGListItemMap : NSObject <NSCopying>

- (instancetype)initWithMapTable:(NSMapTable *)mapTable NS_DESIGNATED_INITIALIZER;

/**
 The items stored in the map.
 */
@property (nonatomic, strong, readonly) NSArray *items;

/**
 Update the map with items and the list counterparts.

 @param items               The items in the collection.
 @param itemControllers The list items that map to each item.
 */
- (void)updateWithItems:(NSArray <id <NSObject>> *)items itemControllers:(NSArray <id <NSObject>> *)itemControllers;

/**
 Fetch a list item given a section.

 @param section The section index of the list.

 @return An item controller.
 */
- (nullable IGListItemController <IGListItemType> *)itemControllerForSection:(NSUInteger)section;

/**
 Fetch the item for a section

 @param section The section index of the list.

 @return The item corresponding to the section.
 */
- (id)itemForSection:(NSUInteger)section;

/**
 Fetch a list given an item. Can return nil.

 @param item The item that maps to a list.

 @return An item controller.
 */
- (nullable id)itemControllerForItem:(id)item;

/**
 Look up the section index for a list.

 @param itemController The list to look up.

 @return The section index of the given list if it exists, NSNotFound otherwise.
 */
- (NSUInteger)sectionForItemController:(id)itemController;

/**
 Look up the section index for an item.

 @param item The item to look up.

 @return The section index of the given item if it exists, NSNotFound otherwise.
 */
- (NSUInteger)sectionForItem:(id)item;

/**
 Remove all saved objects and item controllers.
 */
- (void)reset;

/**
 Update an item with a new instance.
 */
- (void)updateItem:(id)item;

/**
 Applies a given block object to the entries of the item controller map.

 @param block A block object to operate on entries in the item controller map.
 */
- (void)enumerateItemsAndItemControllersUsingBlock:(void (^)(id item, IGListItemController <IGListItemType> *itemController, NSUInteger section, BOOL *stop))block;

- (id)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
