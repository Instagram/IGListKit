// (c) Meta Platforms, Inc. and affiliates. Confidential and proprietary.

#import <UIKit/UIKit.h>

#import <FBDefines/FBDefines.h>

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
