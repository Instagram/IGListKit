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
 Implement this protocol to receive display events for a list.
 */
@protocol IGListDisplayDelegate <NSObject>

/**
 Tells the delegate that the specified list is about to be displayed.

 @param listAdapter        The list adapter that the list will display in.
 @param itemController The list about to be displayed.
 */
- (void)listAdapter:(IGListAdapter *)listAdapter willDisplayItemController:(IGListItemController <IGListItemType> *)itemController;

/**
 Tells the delegate that the specified list is no longer being displayed.

 @param listAdapter        The list adapter that the list was displayed in.
 @param itemController The list that is no longer displayed.
 */
- (void)listAdapter:(IGListAdapter *)listAdapter didEndDisplayingItemController:(IGListItemController <IGListItemType> *)itemController;

/**
 Tells the delegate that a row in the specified list is about to be displayed.

 @param listAdapter        The list adapter that row will display in.
 @param itemController The item controller that is displaying.
 @param cell               The cell about to be displayed.
 @param index              The index of the row.
 */
- (void)listAdapter:(IGListAdapter *)listAdapter willDisplayItemController:(IGListItemController <IGListItemType> *)itemController
               cell:(UICollectionViewCell *)cell
            atIndex:(NSInteger)index;

/**
 Tells the delegate that a row in the specified list is no longer being displayed.

 @param listAdapter        The list adapter that the list was displayed in.
 @param itemController The item controller that is no longer displaying the cell.
 @param cell               The cell that is no longer displayed.
 @param index              The index of the row.
 */
- (void)listAdapter:(IGListAdapter *)listAdapter didEndDisplayingItemController:(IGListItemController <IGListItemType> *)itemController
               cell:(UICollectionViewCell *)cell
            atIndex:(NSInteger)index;

/**
 Tells the delegate that the item controller was scrolled on screen.

 @param listAdapter        The list adapter whose collection view was scrolled.
 @param itemController The visible item controller that was scrolled.
 */
- (void)listAdapter:(IGListAdapter *)listAdapter didScrollItemController:(IGListItemController <IGListItemType> *)itemController;

@end

NS_ASSUME_NONNULL_END
