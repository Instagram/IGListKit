/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#if !__has_include(<IGListDiffKit/IGListDiffKit.h>)
#import "IGListCompatibility.h"
#else
#import <IGListDiffKit/IGListCompatibility.h>
#endif

/**
 * Project version number for IGListKit.
 */
FOUNDATION_EXPORT double IGListKitVersionNumber;

/**
 * Project version string for IGListKit.
 */
FOUNDATION_EXPORT const unsigned char IGListKitVersionString[];

#if !__has_include(<IGListDiffKit/IGListDiffKit.h>)
#import "IGListAssert.h"
#import "IGListBatchUpdateData.h"
#import "IGListDiff.h"
#import "IGListDiffable.h"
#import "IGListExperiments.h"
#import "IGListIndexPathResult.h"
#import "IGListIndexSetResult.h"
#import "IGListMoveIndex.h"
#import "IGListMoveIndexPath.h"
#import "NSNumber+IGListDiffable.h"
#import "NSString+IGListDiffable.h"
#else
#import <IGListDiffKit/IGListAssert.h>
#import <IGListDiffKit/IGListBatchUpdateData.h>
#import <IGListDiffKit/IGListDiff.h>
#import <IGListDiffKit/IGListDiffable.h>
#import <IGListDiffKit/IGListExperiments.h>
#import <IGListDiffKit/IGListIndexPathResult.h>
#import <IGListDiffKit/IGListIndexSetResult.h>
#import <IGListDiffKit/IGListMoveIndex.h>
#import <IGListDiffKit/IGListMoveIndexPath.h>
#import <IGListDiffKit/NSNumber+IGListDiffable.h>
#import <IGListDiffKit/NSString+IGListDiffable.h>
