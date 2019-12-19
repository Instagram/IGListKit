/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#ifdef __OBJC__
#import <Cocoa/Cocoa.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "IGListAssert.h"
#import "IGListBatchUpdateData.h"
#import "IGListCompatibility.h"
#import "IGListDiff.h"
#import "IGListDiffable.h"
#import "IGListDiffKit.h"
#import "IGListExperiments.h"
#import "IGListIndexPathResult.h"
#import "IGListIndexSetResult.h"
#import "IGListMacros.h"
#import "IGListMoveIndex.h"
#import "IGListMoveIndexPath.h"
#import "NSNumber+IGListDiffable.h"
#import "NSString+IGListDiffable.h"

FOUNDATION_EXPORT double IGListDiffKitVersionNumber;
FOUNDATION_EXPORT const unsigned char IGListDiffKitVersionString[];
