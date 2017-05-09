/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
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
