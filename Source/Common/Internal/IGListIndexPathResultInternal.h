/**
 * Copyright (c) 2016-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

#import <IGListKit/IGListIndexPathResult.h>

NS_ASSUME_NONNULL_BEGIN

@interface IGListIndexPathResult()

- (instancetype)initWithInserts:(NSArray<NSIndexPath *> *)inserts
                        deletes:(NSArray<NSIndexPath *> *)deletes
                        updates:(NSArray<NSIndexPath *> *)updates
                          moves:(NSArray<IGListMoveIndexPath *> *)moves
                oldIndexPathMap:(NSMapTable<id<NSObject>, NSIndexPath *> *)oldIndexPathMap
                newIndexPathMap:(NSMapTable<id<NSObject>, NSIndexPath *> *)newIndexPathMap;

@property (nonatomic, assign, readonly) NSInteger changeCount;

@end

NS_ASSUME_NONNULL_END
