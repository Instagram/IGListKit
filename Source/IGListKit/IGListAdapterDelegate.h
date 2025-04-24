/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class IGListAdapter;

NS_ASSUME_NONNULL_BEGIN

/**
 Conform to `IGListAdapterDelegate` to receive display events for objects in a list.
 */
NS_SWIFT_UI_ACTOR
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

/**
 Notifies the delegate that a list object is about to be displayed.  This method is distinct from willDisplayObject:atIndex
 because this method gets called whenever a cell will be displayed on screen as opposed to willDisplayObject:atIndex
 which only gets called for once per section.

 @param listAdapter The list adapter sending this information.
 @param object The object that will display.
 @param cell The cell which contains the object that will display.
 @param indexPath The index path of the object in the list.
 */
- (void)listAdapter:(IGListAdapter *)listAdapter willDisplayObject:(id)object
               cell:(UICollectionViewCell *)cell
            atIndexPath:(NSIndexPath *)indexPath;

/**
 Notifies the delegate that a list object is no longer being displayed.  This method is distinct from didEndDisplayingObject:atIndex
 because this method gets called whenever a cell ends display on screen as opposed to didEndDisplayingObject:atIndex
 which only gets called once when the section fully ends display.

 @param listAdapter The list adapter sending this information.
 @param object The object that ended display.
 @param cell The cell which contains the object that ended display.
 @param indexPath The index path of the object in the list.
 */
- (void)listAdapter:(IGListAdapter *)listAdapter didEndDisplayingObject:(id)object
               cell:(UICollectionViewCell *)cell
            atIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
