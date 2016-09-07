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

NS_ASSUME_NONNULL_BEGIN

/**
 Implement this protocol to receive working range events for a list.

 The working range is a range *near* the viewport in which you can begin preparing content for display. For example,
 you could begin decoding images, or warming text caches.
 */
@protocol IGListWorkingRangeDelegate <NSObject>

/**
 Notifies the delegate that an item controller will enter the working range.

 @param listAdapter    The adapter controlling the feed.
 @param itemController The item controller entering the range.
 */
- (void)listAdapter:(IGListAdapter *)listAdapter itemControllerWillEnterWorkingRange:(IGListItemController <IGListItemType> *)itemController;

/**
 Notifies the delegate that an item controller exited the working range.

 @param listAdapter    The adapter controlling the feed.
 @param itemController The item controller that exited the range.
 */
- (void)listAdapter:(IGListAdapter *)listAdapter itemControllerDidExitWorkingRange:(IGListItemController <IGListItemType> *)itemController;

@end

NS_ASSUME_NONNULL_END
