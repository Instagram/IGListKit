/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 The default invalidation context class used by IGListCollectionViewLayout.
 */
NS_SWIFT_NAME(ListCollectionViewLayoutInvalidationContext)
@interface IGListCollectionViewLayoutInvalidationContext : UICollectionViewLayoutInvalidationContext

/**
 False by default. If true, supplementary list item attributes (headers and footers) will be invalidated.
 */
@property (nonatomic, assign) BOOL invalidateSupplementaryListAttributes;

/**
 False by default. If true, all list item attributes will be invalidated.
 */
@property (nonatomic, assign) BOOL invalidateAllListAttributes;

@end

NS_ASSUME_NONNULL_END
