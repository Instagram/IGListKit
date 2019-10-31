/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

#import <IGListDiffKit/IGListMacros.h>

@class IGListMoveIndexPath;
@class IGListReloadIndexPath;

IGLK_SUBCLASSING_RESTRICTED
@interface IGListBatchUpdates : NSObject

@property (nonatomic, strong, readonly) NSMutableIndexSet *sectionReloads;
@property (nonatomic, strong, readonly) NSMutableArray<NSIndexPath *> *itemInserts;
@property (nonatomic, strong, readonly) NSMutableArray<NSIndexPath *> *itemDeletes;
@property (nonatomic, strong, readonly) NSMutableArray<IGListReloadIndexPath *> *itemReloads;
@property (nonatomic, strong, readonly) NSMutableArray<IGListMoveIndexPath *> *itemMoves;

@property (nonatomic, strong, readonly) NSMutableArray<void (^)(void)> *itemUpdateBlocks;
@property (nonatomic, strong, readonly) NSMutableArray<void (^)(BOOL)> *itemCompletionBlocks;

- (BOOL)hasChanges;

@end
