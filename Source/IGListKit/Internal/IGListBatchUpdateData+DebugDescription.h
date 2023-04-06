/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

#if !__has_include(<IGListDiffKit/IGListDiffKit.h>)
#import "IGListBatchUpdateData.h"
#else
#import <IGListDiffKit/IGListBatchUpdateData.h>
#endif

@interface IGListBatchUpdateData (DebugDescription)

- (NSArray<NSString *> *)debugDescriptionLines;

@end
