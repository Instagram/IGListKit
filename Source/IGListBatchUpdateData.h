/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

#import <IGListKit/IGListMacros.h>
#import <IGListKit/IGListMoveIndex.h>

NS_ASSUME_NONNULL_BEGIN

/**
 This object takes section indexes and item index paths and performs cleanup on init in order to perform a crash-free
 update via -[UICollectionView performBatchUpdates:completion:].
 */
IGLK_SUBCLASSING_RESTRICTED
@interface IGListBatchUpdateData : NSObject

/**
 Clean section insert indexes.
 */
@property (nonatomic, strong, readonly) NSIndexSet *insertSections;

/**
 Clean section delete indexes.
 */
@property (nonatomic, strong, readonly) NSIndexSet *deleteSections;

/**
 Clean section moves.
 */
@property (nonatomic, strong, readonly) NSSet<IGListMoveIndex *> *moveSections;

/**
 Clean item insert index paths.
 */
@property (nonatomic, strong, readonly) NSSet<NSIndexPath *> *insertIndexPaths;

/**
 Clean item delete index paths.
 */
@property (nonatomic, strong, readonly) NSSet<NSIndexPath *> *deleteIndexPaths;

/**
 Clean item reload index paths.
 */
@property (nonatomic, strong, readonly) NSSet<NSIndexPath *> *reloadIndexPaths;

/**
 Create a new batch update object with section and item operations.

 @param insertSections   Section indexes to insert.
 @param deleteSections   Section indexes to delete.
 @param moveSections     Section moves.
 @param insertIndexPaths Item index paths to insert.
 @param deleteIndexPaths Item index paths to delete.
 @param reloadIndexPaths Item index paths to reload.

 @return A new batch update object with cleaned update operations.
 */
- (instancetype)initWithInsertSections:(NSIndexSet *)insertSections
                        deleteSections:(NSIndexSet *)deleteSections
                          moveSections:(NSSet<IGListMoveIndex *> *)moveSections
                      insertIndexPaths:(NSSet<NSIndexPath *> *)insertIndexPaths
                      deleteIndexPaths:(NSSet<NSIndexPath *> *)deleteIndexPaths
                      reloadIndexPaths:(NSSet<NSIndexPath *> *)reloadIndexPaths NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
