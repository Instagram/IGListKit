/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

@class IGListAdapter;
@class IGListSectionController;



NS_ASSUME_NONNULL_BEGIN

/**
 Implement this protocol to receive display events for a section controller when it is on screen.
 */
NS_SWIFT_NAME(ListDisplayDelegate)
@protocol IGListDisplayDelegate <NSObject>

/**
 Tells the delegate that the specified section controller is about to be displayed.

 @param listAdapter The list adapter for the section controller.
 @param sectionController The section controller about to be displayed.
 */
- (void)listAdapter:(IGListAdapter *)listAdapter willDisplaySectionController:(IGListSectionController *)sectionController;

/**
 Tells the delegate that the specified section controller is no longer being displayed.

 @param listAdapter       The list adapter for the section controller.
 @param sectionController The section controller that is no longer displayed.
 */
- (void)listAdapter:(IGListAdapter *)listAdapter didEndDisplayingSectionController:(IGListSectionController *)sectionController;

/**
 Tells the delegate that a cell in the specified list is about to be displayed.

 @param listAdapter The list adapter in which the cell will display.
 @param sectionController The section controller that is displaying the cell.
 @param cell The cell about to be displayed.
 @param index The index of the cell in the section.
 */
- (void)listAdapter:(IGListAdapter *)listAdapter willDisplaySectionController:(IGListSectionController *)sectionController
               cell:(UICollectionViewCell *)cell
            atIndex:(NSInteger)index;

/**
 Tells the delegate that a cell in the specified list is no longer being displayed.

 @param listAdapter The list adapter in which the cell was displayed.
 @param sectionController The section controller that is no longer displaying the cell.
 @param cell The cell that is no longer displayed.
 @param index The index of the cell in the section.
 */
- (void)listAdapter:(IGListAdapter *)listAdapter didEndDisplayingSectionController:(IGListSectionController *)sectionController
               cell:(UICollectionViewCell *)cell
            atIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
