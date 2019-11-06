/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

@class IGListAdapter;

NS_ASSUME_NONNULL_BEGIN

/**
 Conform to `IGListAdapterDelegate` to receive display events for objects in a list.
 */
NS_SWIFT_NAME(ListAdapterDelegate)
@protocol IGListAdapterDelegate <NSObject>

/**
 Notifies the delegate that a list object is about to be displayed.

 @param listAdapter The list adapter sending this information.
 @param object The object that will display.
 @param index The index of the object in the list.
 */
- (void)listAdapter:(IGListAdapter *)listAdapter willDisplayObject:(id)object atIndex:(NSInteger)index;

/**
 Notifies the delegate that a list object is no longer being displayed.

 @param listAdapter The list adapter sending this information.
 @param object The object that ended display.
 @param index The index of the object in the list.
 */
- (void)listAdapter:(IGListAdapter *)listAdapter didEndDisplayingObject:(id)object atIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
