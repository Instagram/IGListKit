/**
 * Copyright (c) 2016-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 An object representing a move between indexes.
 */
NS_SWIFT_NAME(ListMoveIndexPath)
@interface IGListMoveIndexPath : NSObject

/**
 An index path in the old collection.
 */
@property (nonatomic, strong, readonly) NSIndexPath *from;

/**
 An index path in the new collection.
 */
@property (nonatomic, strong, readonly) NSIndexPath *to;

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
