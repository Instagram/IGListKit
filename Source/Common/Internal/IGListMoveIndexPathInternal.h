/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IGListMoveIndexPath ()

- (instancetype)initWithFrom:(NSIndexPath *)from to:(NSIndexPath *)to NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
