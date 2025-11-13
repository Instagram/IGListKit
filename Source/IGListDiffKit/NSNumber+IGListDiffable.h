/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

#if !__has_include(<IGListDiffKit/IGListDiffKit.h>)
#import "IGListDiffable.h"
#else
#import <IGListDiffKit/IGListDiffable.h>
#endif

/**
 This category provides default `IGListDiffable` conformance for `NSNumber`.
 */
@interface NSNumber (IGListDiffable) <IGListDiffable>

@end
