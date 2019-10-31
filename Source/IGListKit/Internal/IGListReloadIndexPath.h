/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

#import <IGListDiffKit/IGListMacros.h>

NS_ASSUME_NONNULL_BEGIN

/**
 An object with index path information for reloading an item during a batch update.
 */
IGLK_SUBCLASSING_RESTRICTED
@interface IGListReloadIndexPath : NSObject

/**
 The index path of the item before batch updates are applied.
 */
@property (nonatomic, strong, readonly) NSIndexPath *fromIndexPath;

/**
 The index path of the item after batch updates are applied.
 */
@property (nonatomic, strong, readonly) NSIndexPath *toIndexPath;

/**
 Creates a new reload object.

 @param fromIndexPath The index path of the item before batch updates.
 @param toIndexPath The index path of the item after batch updates.
 @return A new reload object.
 */
- (instancetype)initWithFromIndexPath:(NSIndexPath *)fromIndexPath
                          toIndexPath:(NSIndexPath *)toIndexPath NS_DESIGNATED_INITIALIZER;

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
