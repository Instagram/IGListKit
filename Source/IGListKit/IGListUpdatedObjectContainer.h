/*
* Copyright (c) Facebook, Inc. and its affiliates.
*
* This source code is licensed under the MIT license found in the
* LICENSE file in the root directory of this source tree.
*/

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Temporary protocol to make IGListExperimentArrayAndSetOptimization easier
@protocol IGListUpdatedObjectContainer <NSObject, NSFastEnumeration>
- (void)addObject:(id)object;
@end

@interface NSMutableArray (IGListUpdatedObjectContainer) <IGListUpdatedObjectContainer>
@end

@interface NSMutableSet (IGListUpdatedObjectContainer) <IGListUpdatedObjectContainer>
@end

NS_ASSUME_NONNULL_END
