/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

#import <IGListKit/IGListSectionController.h>
#import <IGListKit/IGListSectionType.h>
#import <IGListKit/IGListMacros.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^IGListSingleSectionCellConfigureBlock)(id item, __kindof UICollectionViewCell *cell);
typedef CGSize (^IGListSingleSectionCellSizeBlock)(id item, id<IGListCollectionContext> _Nullable collectionContext);

@class IGListSingleSectionController;

/**
 A delegate that can receive selection events on an IGListSingleSectionController.
 */
@protocol IGListSingleSectionControllerDelegate <NSObject>

/**
 Tells the delegate that the section controller was selected.

 @param sectionController The section controller that was selected.
 */
- (void)didSelectSingleSectionController:(IGListSingleSectionController *)sectionController;

@end

/**
 This section controller is meant to make building simple, single-cell feeds easier. By providing the type of cell, a block
 to configure the cell, and a block to return the size of a cell, you can use an IGListAdapter-powered feed without
 overcomplicating your architecture.
 */
IGLK_SUBCLASSING_RESTRICTED
@interface IGListSingleSectionController : IGListSectionController <IGListSectionType>

/**
 Create a new section controller for a given cell type that will always have only one cell when present in a feed.
 
 @param cellClass      The UICollectionViewCell subclass for the single cell.
 @param configureBlock A block that configures the cell with the item given to the section controller.
 @param sizeBlock      A block that returns the size for the cell given the collection context.
 
 @return A new section controller.
 
 @warning Be VERY CAREFUL not to create retain cycles by holding strong references to: the object that owns the adapter
 (usually "self") or the IGListAdapter. Pass in locally scoped objects or use weak references!
 */
- (instancetype)initWithCellClass:(Class)cellClass
                   configureBlock:(IGListSingleSectionCellConfigureBlock)configureBlock
                        sizeBlock:(IGListSingleSectionCellSizeBlock)sizeBlock;

/**
 Create a new section controller for a given nib name and bundle that will always have only one cell when present in a feed.
 
 @param nibName        The name of the nib file for the single cell.
 @param bundle         The bundle in which to search for the nib file. If nil, this method looks for the file in the main bundle.
 @param configureBlock A block that configures the cell with the item given to the section controller.
 @param sizeBlock      A block that returns the size for the cell given the collection context.
 
 @return A new section controller.
 
 @warning Be VERY CAREFUL not to create retain cycles by holding strong references to: the object that owns the adapter
 (usually "self") or the IGListAdapter. Pass in locally scoped objects or use weak references!
 */
- (instancetype)initWithNibName:(NSString *)nibName
                         bundle:(nullable NSBundle *)bundle
                 configureBlock:(IGListSingleSectionCellConfigureBlock)configureBlock
                      sizeBlock:(IGListSingleSectionCellSizeBlock)sizeBlock;

/**
 Create a new section controller for a given storyboard cell identifier that will always have only one cell when present in a feed.
 
 @param identifier     The identifier of the cell prototype in storyboard.
 @param configureBlock A block that configures the cell with the item given to the section controller.
 @param sizeBlock      A block that returns the size for the cell given the collection context.
 
 @return A new section controller.
 
 @warning Be VERY CAREFUL not to create retain cycles by holding strong references to: the object that owns the adapter
 (usually "self") or the IGListAdapter. Pass in locally scoped objects or use weak references!
 */
- (instancetype)initWithStoryboardCellIdentifier:(NSString *)identifier
                                  configureBlock:(IGListSingleSectionCellConfigureBlock)configureBlock
                                       sizeBlock:(IGListSingleSectionCellSizeBlock)sizeBlock;

/**
 An optional delegate that handles selection and deselection.
 */
@property (nonatomic, weak, nullable) id<IGListSingleSectionControllerDelegate> selectionDelegate;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
