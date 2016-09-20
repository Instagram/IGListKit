/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

@class IGListAdapter;
@class IGListItemController;

@protocol IGListItemType;

/**
 Implement this protocol to receive display events for an item controller when it is on screen.
 */
@protocol IGListScrollDelegate <NSObject>

/**
 Tells the delegate that the item controller was scrolled on screen.

 @param listAdapter    The list adapter whose collection view was scrolled.
 @param itemController The visible item controller that was scrolled.
 */
- (void)listAdapter:(IGListAdapter *)listAdapter didScrollItemController:(IGListItemController <IGListItemType> *)itemController;

/**
 Tells the delegate that the item controller will be dragged on screen.

 @param listAdapter    The list adapter whose collection view will drag.
 @param itemController The visible item controller that will drag.
 */
- (void)listAdapter:(IGListAdapter *)listAdapter willBeginDraggingItemController:(IGListItemController <IGListItemType> *)itemController;

/**
 Tells the delegate that the item controller did end dragging on screen.

 @param listAdapter    The list adapter whose collection view ended dragging.
 @param itemController The visible item controller that ended dragging.
 */
- (void)listAdapter:(IGListAdapter *)listAdapter didEndDraggingItemController:(IGListItemController <IGListItemType> *)itemController willDecelerate:(BOOL)decelerate;

@end
