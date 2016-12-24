/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <TargetConditionals.h>

#if TARGET_OS_EMBEDDED || TARGET_OS_SIMULATOR
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif

/**
 * Project version number for IGListKit.
 */
FOUNDATION_EXPORT double IGListKitVersionNumber;

/**
 * Project version string for IGListKit.
 */
FOUNDATION_EXPORT const unsigned char IGListKitVersionString[];

// Common (iOS, tvOS, macOS compatible):

#import <IGListKit/IGListAssert.h>
#import <IGListKit/IGListBatchUpdateData.h>
#import <IGListKit/IGListDiff.h>
#import <IGListKit/IGListDiffable.h>
#import <IGListKit/IGListExperiments.h>
#import <IGListKit/IGListIndexPathResult.h>
#import <IGListKit/IGListIndexSetResult.h>
#import <IGListKit/IGListMoveIndex.h>
#import <IGListKit/IGListMoveIndexPath.h>
#import <IGListKit/NSNumber+IGListDiffable.h>
#import <IGListKit/NSString+IGListDiffable.h>