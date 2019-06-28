/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 An object representing a move between indexes.
 */
NS_SWIFT_NAME(ListMoveIndex)
@interface IGListMoveIndex : NSObject

/**
 An index in the old collection.
 */
@property (nonatomic, assign, readonly) NSInteger from;

/**
 An index in the new collection.
 */
@property (nonatomic, assign, readonly) NSInteger to;

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
