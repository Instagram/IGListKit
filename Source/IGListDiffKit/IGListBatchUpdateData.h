/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

#import <IGListDiffKit/IGListMacros.h>
#import <IGListDiffKit/IGListMoveIndex.h>
#import <IGListDiffKit/IGListMoveIndexPath.h>

NS_ASSUME_NONNULL_BEGIN

/**
 An instance of `IGListBatchUpdateData` takes section indexes and item index paths 
 and performs cleanup on init in order to perform a crash-free
 update via `-[UICollectionView performBatchUpdates:completion:]`.
 */
IGLK_SUBCLASSING_RESTRICTED
NS_SWIFT_NAME(ListBatchUpdateData)
@interface IGListBatchUpdateData : NSObject

/**
 Section insert indexes.
 */
@property (nonatomic, strong, readonly) NSIndexSet *insertSections;

/**
 Section delete indexes.
 */
@property (nonatomic, strong, readonly) NSIndexSet *deleteSections;

/**
 Section moves.
 */
@property (nonatomic, strong, readonly) NSSet<IGListMoveIndex *> *moveSections;

/**
 Item insert index paths.
 */
@property (nonatomic, strong, readonly) NSArray<NSIndexPath *> *insertIndexPaths;

/**
 Item delete index paths.
 */
@property (nonatomic, strong, readonly) NSArray<NSIndexPath *> *deleteIndexPaths;

/**
 Item update index paths.
 */
@property (nonatomic, strong, readonly) NSArray<NSIndexPath *> *updateIndexPaths;

/**
 Item moves.
 */
@property (nonatomic, strong, readonly) NSArray<IGListMoveIndexPath *> *moveIndexPaths;

/**
 Creates a new batch update object with section and item operations.

 @param insertSections Section indexes to insert.
 @param deleteSections Section indexes to delete.
 @param moveSections Section moves.
 @param insertIndexPaths Item index paths to insert.
 @param deleteIndexPaths Item index paths to delete.
 @param updateIndexPaths Item index paths to update.
 @param moveIndexPaths Item index paths to move.
 @param fixIndexPathImbalance When enabled, we remove duplicate NSIndexPath inserts to avoid insert/delete imbalance and a crash.

 @return A new batch update object.
 */
- (instancetype)initWithInsertSections:(NSIndexSet *)insertSections
                        deleteSections:(NSIndexSet *)deleteSections
                          moveSections:(NSSet<IGListMoveIndex *> *)moveSections
                      insertIndexPaths:(NSArray<NSIndexPath *> *)insertIndexPaths
                      deleteIndexPaths:(NSArray<NSIndexPath *> *)deleteIndexPaths
                      updateIndexPaths:(NSArray<NSIndexPath *> *)updateIndexPaths
                        moveIndexPaths:(NSArray<IGListMoveIndexPath *> *)moveIndexPaths
                 fixIndexPathImbalance:(BOOL)fixIndexPathImbalance NS_DESIGNATED_INITIALIZER;

/**
 Convenience initializer with fixIndexPathImbalance disabled.
 */
- (instancetype)initWithInsertSections:(NSIndexSet *)insertSections
                        deleteSections:(NSIndexSet *)deleteSections
                          moveSections:(NSSet<IGListMoveIndex *> *)moveSections
                      insertIndexPaths:(NSArray<NSIndexPath *> *)insertIndexPaths
                      deleteIndexPaths:(NSArray<NSIndexPath *> *)deleteIndexPaths
                      updateIndexPaths:(NSArray<NSIndexPath *> *)updateIndexPaths
                        moveIndexPaths:(NSArray<IGListMoveIndexPath *> *)moveIndexPaths;

/**
 :nodoc:
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 :nodoc:
 */
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
