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
#import "IGListAsyncTask.h"

NS_ASSUME_NONNULL_BEGIN

@class IGListSectionMap;

IGLK_SUBCLASSING_RESTRICTED
@interface IGListPreprocessingTask : NSObject <IGListAsyncTask>

- (instancetype)initWithSectionMap:(IGListSectionMap *)sectionMap
                     containerSize:(CGSize)containerSize;

@end

NS_ASSUME_NONNULL_END
