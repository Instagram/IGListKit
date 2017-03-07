/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <Foundation/Foundation.h>

#import <IGListKit/IGListMacros.h>

@class IGListMoveIndexPath;

IGLK_SUBCLASSING_RESTRICTED
@interface IGListBatchUpdates : NSObject

@property (nonatomic, strong, readonly) NSMutableIndexSet *sectionReloads;
@property (nonatomic, strong, readonly) NSMutableSet<NSIndexPath *> *itemInserts;
@property (nonatomic, strong, readonly) NSMutableSet<NSIndexPath *> *itemDeletes;
@property (nonatomic, strong, readonly) NSMutableSet<NSIndexPath *> *itemReloads;
@property (nonatomic, strong, readonly) NSMutableSet<IGListMoveIndexPath *> *itemMoves;

@end
