/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

#import <IGListKit/IGListMacros.h>

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

 @param collectionViewTarget A UICollectionViewDelegate conforming object that receives unintercepted messages.
 @param scrollViewTarget     A UIScrollViewDelegate conforming object that receives unintercepted messages.
 @param interceptor          An IGListAdapter object that intercepts a set of messages.

 @return A new IGListAdapterProxy object.
 */
- (instancetype)initWithCollectionViewTarget:(nullable id<UICollectionViewDelegate>)collectionViewTarget
                            scrollViewTarget:(nullable id<UIScrollViewDelegate>)scrollViewTarget
                                 interceptor:(IGListAdapter *)interceptor;

@end

NS_ASSUME_NONNULL_END
