/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 A protocol for cells that configure themselves given a view model.
 */
NS_SWIFT_NAME(ListBindable)
@protocol IGListBindable <NSObject>

/**
 Tells the cell to configure itself with the given view model.

 @param viewModel The view model for the cell.

 @note The view model can change many times throughout the lifetime of a cell as the model values change and the cell
 is reused. Implementations should use only this method to do their configuration.
 */
- (void)bindViewModel:(id)viewModel;

@end

NS_ASSUME_NONNULL_END
