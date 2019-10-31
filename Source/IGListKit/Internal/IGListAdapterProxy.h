/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

#import <IGListDiffKit/IGListMacros.h>

@class IGListAdapter;

NS_ASSUME_NONNULL_BEGIN

/**
 A proxy that sends a custom set of selectors to an IGListAdapter object and the rest to a UICollectionViewDelegate
 target.
 */
IGLK_SUBCLASSING_RESTRICTED
@interface IGListAdapterProxy : NSProxy

/**
 Create a new proxy object with targets and interceptor.

 @param collectionViewTarget A UICollectionViewDelegate conforming object that receives non-intercepted messages.
 @param scrollViewTarget A UIScrollViewDelegate conforming object that receives non-intercepted messages.
 @param interceptor An IGListAdapter object that intercepts a set of messages.

 @return A new IGListAdapterProxy object.
 */
- (instancetype)initWithCollectionViewTarget:(nullable id<UICollectionViewDelegate>)collectionViewTarget
                            scrollViewTarget:(nullable id<UIScrollViewDelegate>)scrollViewTarget
                                 interceptor:(IGListAdapter *)interceptor;

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
