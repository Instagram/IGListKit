/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

#if !__has_include(<IGListDiffKit/IGListDiffKit.h>)
#import "IGListIndexSetResult.h"
#else
#import <IGListDiffKit/IGListIndexSetResult.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface IGListIndexSetResult()

- (instancetype)initWithInserts:(NSIndexSet *)inserts
                        deletes:(NSIndexSet *)deletes
                        updates:(NSIndexSet *)updates
                          moves:(NSArray<IGListMoveIndex *> *)moves
                    oldIndexMap:(NSMapTable<id<NSObject>, NSNumber *> *)oldIndexMap
                    newIndexMap:(NSMapTable<id<NSObject>, NSNumber *> *)newIndexMap;

@property (nonatomic, assign, readonly) NSInteger changeCount;

@end

NS_ASSUME_NONNULL_END
