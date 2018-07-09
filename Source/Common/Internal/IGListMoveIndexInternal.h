/**
 * Copyright (c) 2016-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

#import <IGListKit/IGListMoveIndex.h>

NS_ASSUME_NONNULL_BEGIN

@interface IGListMoveIndex ()

- (instancetype)initWithFrom:(NSInteger)from to:(NSInteger)to NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
