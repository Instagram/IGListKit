/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
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

 @param sectionController The section controller the selection occured in.
 @param index The index of the selected cell.
 @param viewModel The view model that was bound to the cell.
 */
- (void)sectionController:(IGListBindingSectionController *)sectionController
     didSelectItemAtIndex:(NSInteger)index
                viewModel:(id)viewModel;

@end

NS_ASSUME_NONNULL_END
