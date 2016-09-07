/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant 
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

#import <IGListKit/IGListDiffable.h>

@class IGListAdapter;
@class IGListItemController;

@protocol IGListItemType;

NS_ASSUME_NONNULL_BEGIN

/**
 Implement this protocol to provide data to power an IGListAdapter feed.
 */
@protocol IGListAdapterDataSource <NSObject>

/**
 Asks the data source for an array of items for each list in your feed.

 @param listAdapter The list adapter requesting this information.

 @return An array of items for each item in the feed.
 */
- (NSArray<id <IGListDiffable>> *)itemsForListAdapter:(IGListAdapter *)listAdapter;

/**
 Asks the data source for an item controller for the specified data item.

 @param listAdapter The list adapter requesting this information.
 @param item        An item in the feed, provided in -itemsForListAdapter:. You can also pass this to your list.

 @return An IGListItemType conforming item that can be displayed in the feed.

 @discussion New list items should be initialized here for items when asked. You are free to inject the item into the
 list, as there are no other ways for a list to query its item beyond this point. You may also pass any other
 information to the list at this time.

 List items are initialized for all items whenever the IGListAdapter is created or asked to reload. If the order of an
 item has changed, the list will be reused.
 */
- (IGListItemController <IGListItemType> *)listAdapter:(IGListAdapter *)listAdapter itemControllerForItem:(id)item;

/**
 Asks the data source for a view to use as the collection view background when there are no items.

 @param listAdapter The list adapter requesting this information.

 @return A view to use as the collection view background, or nil if you don't want a background view.

 @discussion This method is called every time the list adapter is updated. You are free to return new views every time,
 but for performance reasons you may want to retain your own view and return it here. The infra is only responsible for
 adding the background view and maintaining its visibility.
 */
- (nullable UIView *)emptyViewForListAdapter:(IGListAdapter *)listAdapter;

@end

NS_ASSUME_NONNULL_END
