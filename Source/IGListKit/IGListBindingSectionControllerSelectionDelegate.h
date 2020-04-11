/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

@class IGListBindingSectionController;

NS_ASSUME_NONNULL_BEGIN

/**
 A protocol that handles cell selection events in an `IGListBindingSectionController`.
 */
NS_SWIFT_NAME(ListBindingSectionControllerSelectionDelegate)
@protocol IGListBindingSectionControllerSelectionDelegate <NSObject>

/**
 Tells the delegate that a cell at a given index was selected.

 @param sectionController The section controller the selection occurred in.
 @param index The index of the selected cell.
 @param viewModel The view model that was bound to the cell.
 */
- (void)sectionController:(IGListBindingSectionController *)sectionController
     didSelectItemAtIndex:(NSInteger)index
                viewModel:(id)viewModel;

/**
 Tells the delegate that a cell at a given index was deselected.

 @param sectionController The section controller the deselection occurred in.
 @param index The index of the deselected cell.
 @param viewModel The view model that was bound to the cell.
 */
- (void)sectionController:(IGListBindingSectionController *)sectionController
   didDeselectItemAtIndex:(NSInteger)index
                viewModel:(id)viewModel;

/**
 Tells the delegate that a cell at a given index was highlighted.

 @param sectionController The section controller the highlight occurred in.
 @param index The index of the highlighted cell.
 @param viewModel The view model that was bound to the cell.
 */
- (void)sectionController:(IGListBindingSectionController *)sectionController
  didHighlightItemAtIndex:(NSInteger)index
                viewModel:(id)viewModel;

/**
 Tells the delegate that a cell at a given index was unhighlighted.

 @param sectionController The section controller the unhighlight occurred in.
 @param index The index of the unhighlighted cell.
 @param viewModel The view model that was bound to the cell.
 */
- (void)sectionController:(IGListBindingSectionController *)sectionController
didUnhighlightItemAtIndex:(NSInteger)index
                viewModel:(id)viewModel;

/**
 Tells the delegate that a cell has requested a menu configuration.

 @param sectionController The section controller the request of a menu configuration occurred in.
 @param index The index of the cell that is being longed tap.
 @param point The point of the tap on the cell.
 @param viewModel The view model that was bound to the cell.
 
 @return An object that conforms to `UIContextMenuConfiguration`.
 */
- (UIContextMenuConfiguration * _Nullable)sectionController:(IGListBindingSectionController *)sectionController
                     contextMenuConfigurationForItemAtIndex:(NSInteger)index
                                                      point:(CGPoint)point
                                                  viewModel:(id)viewModel API_AVAILABLE(ios(13.0)) API_UNAVAILABLE(tvos);

@end

NS_ASSUME_NONNULL_END
