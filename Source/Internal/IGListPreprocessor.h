/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>
#import <IGListKit/IGListMacros.h>
#import <IGListKit/IGListPreprocessingContext.h>

NS_ASSUME_NONNULL_BEGIN

@class IGListSectionController, IGListSectionMap;

IGLK_SUBCLASSING_RESTRICTED
@interface IGListPreprocessor : NSObject

- (instancetype)initWithSectionMap:(IGListSectionMap *)sectionMap;

/**
 * Must be called from the main thread.
 */
- (void)schedulePreprocessingWithContainerSize:(CGSize)containerSize completion:(dispatch_block_t)completionBlock;

/**
 * Must be called from the main thread.
 */
- (void)waitForPreprocessingToFinish;

@end

NS_ASSUME_NONNULL_END
