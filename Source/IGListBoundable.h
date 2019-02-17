/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>
#import <IGListKit/IGListSectionController.h>
NS_ASSUME_NONNULL_BEGIN
@class IGListSectionController;
/**
 A protocol for cells that configure themselves given a view model.
 */
NS_SWIFT_NAME(ListBoundable)
@protocol IGListBoundable <NSObject>

/**
 Tells the cell to configure itself with the given view model.
 
 @param viewModel The view model for the cell.
 
 @note The view model can change many times throughout the lifetime of a cell as the model values change and the cell
 is reused. Implementations should use only this method to do their configuration.
 */
- (IGListSectionController *)boundedSectionController;


@end


NS_ASSUME_NONNULL_END
