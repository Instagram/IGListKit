/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant 
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <Foundation/Foundation.h>

@class IGListAdapter;

@protocol IGListAdapterDelegate <NSObject>

/**
 Notifies the delegate that a list item is about to be displayed

 @param listAdapter The list adapter sending this information.
 @param item        The item vended to the list adapter for the list item from the data source's -itemsForListAdapter:.
 @param index       The index of the item/object in the list.
 */
- (void)listAdapter:(IGListAdapter *)listAdapter willDisplayItem:(id)item atIndex:(NSInteger)index;

/**
 Notifies the delegate that a list item is no longer being displayed

 @param listAdapter The list adapter sending this information.
 @param item        The item vended to the list adapter for the list item from the data source's -itemsForListAdapter:.
 @param index       The index of the item/object in the list.
 */
- (void)listAdapter:(IGListAdapter *)listAdapter didEndDisplayingItem:(id)item atIndex:(NSInteger)index;

@end
