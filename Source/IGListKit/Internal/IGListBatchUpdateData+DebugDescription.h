/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

#if SWIFT_PACKAGE || USE_PACKAGE_FROM_XCODE
#import "IGListBatchUpdateData.h"
#else
#import <IGListDiffKit/IGListBatchUpdateData.h>
#endif

@interface IGListBatchUpdateData (DebugDescription)

- (NSArray<NSString *> *)debugDescriptionLines;

@end
