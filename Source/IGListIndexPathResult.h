/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <Foundation/Foundation.h>

#import <IGListKit/IGListMoveIndexPath.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Result object returned when diffing with sections.
 */
@interface IGListIndexPathResult : NSObject

/**
 Index paths inserted into the new collection.
 */
@property (nonatomic, copy, readonly) NSArray<NSIndexPath *> *inserts;

/**
 Index paths deleted from the old collection.
 */
@property (nonatomic, copy, readonly) NSArray<NSIndexPath *> *deletes;

/**
 Index paths in the new collection that need updated.
 */
@property (nonatomic, copy, readonly) NSArray<NSIndexPath *> *updates;

/**
 Moves from an index path in the old collection to an index path in the new collection.
 */
@property (nonatomic, copy, readonly) NSArray<IGListMoveIndexPath *> *moves;

/**
 Convenience to query if the result has any changes.

 @return YES if the result has changes, NO otherwise.
 */
- (BOOL)hasChanges;

/**
 Fetch the index path of the object with identifier before the diff.

 @param identifier The diff identifier of the object. See -[IGListDiffable diffIdentifier].

 @return The index path of the object before the diff, or nil.
 */
- (nullable NSIndexPath *)oldIndexPathForIdentifier:(id<NSObject>)identifier;

/**
 Fetch the index path of the object with identifier after the diff.

 @param identifier The diff identifier of the object. See -[IGListDiffable diffIdentifier].

 @return The index path of the object after the diff, or nil.
 */
- (nullable NSIndexPath *)newIndexPathForIdentifier:(id<NSObject>)identifier;

/**
 Create a new result object transforming index paths that are both moved and updated into delete and inserts.

 @discussion This is a convenience method for using a result object to perform UICollectionView and UITableView updates.
 */
- (IGListIndexPathResult *)resultWithUpdatedMovesAsDeleteInserts;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
