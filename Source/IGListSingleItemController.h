/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant 
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

#import <IGListKit/IGListItemController.h>
#import <IGListKit/IGListItemType.h>
#import <IGListKit/IGListMacros.h>

NS_ASSUME_NONNULL_BEGIN

@class IGListSingleItemController;

/**
 A delegate that can receive selection events on an IGListSingleItemController.
 */
@protocol IGListSingleItemControllerDelegate <NSObject>

/**
 Tells the delegate that the item controller was selected.

 @param itemController The item controller that was selected.
 */
- (void)didSelectSingleItemController:(IGListSingleItemController *)itemController;

/**
 Tells the delegate that the item controller was deselected.

 @param itemController The item controller that was deselected.
 */
- (void)didDeselectSingleItemController:(IGListSingleItemController *)itemController;

@end

/**
 This item controller is meant to make building simple, single-cell feeds easier. By providing the type of cell, a block
 to configure the cell, and a block to return the size of a cell, you can use an IGListAdapter-powered feed without
 overcomplicating your architecture.
 */
IGLK_SUBCLASSING_RESTRICTED
@interface IGListSingleItemController : IGListItemController <IGListItemType>

/**
 Create a new item controller for a given cell type that will always have only one cell when present in a feed.

 @param cellClass      The UICollectionViewCell subclass for the single cell.
 @param configureBlock A block that configures the cell with the item given to the item controller.
 @param sizeBlock      A block that returns the size for the cell given the collection context.

 @return A new item controller.

 @warning Be VERY CAREFUL not to create retain cycles by holding strong references to: the object that owns the adapter
 (usually "self") or the IGListAdapter. Pass in locally scoped objects or use weak references!
 */
- (instancetype)initWithCellClass:(Class)cellClass
                   configureBlock:(void (^)(id item, __kindof UICollectionViewCell *cell))configureBlock
                        sizeBlock:(CGSize (^)(id<IGListCollectionContext> collectionContext))sizeBlock NS_DESIGNATED_INITIALIZER;

/**
 An optional delegate that handles selection and deselection.
 */
@property (nonatomic, weak, nullable) id<IGListSingleItemControllerDelegate> selectionDelegate;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
