/*
* Copyright (c) Meta Platforms, Inc. and affiliates.
*
* This source code is licensed under the MIT license found in the
* LICENSE file in the root directory of this source tree.
*/

#import <Foundation/Foundation.h>

#if !__has_include(<IGListDiffKit/IGListDiffKit.h>)
#import "IGListMacros.h"
#else
#import <IGListDiffKit/IGListMacros.h>
#endif

#import "IGListUpdatingDelegate.h"

#import "IGListUpdateTransactable.h"

NS_ASSUME_NONNULL_BEGIN

/// Handles a `UICollectionView` `dataSource` change
IGLK_SUBCLASSING_RESTRICTED
@interface IGListDataSourceChangeTransaction : NSObject <IGListUpdateTransactable>

- (instancetype)initWithChangeBlock:(IGListDataSourceChangeBlock)block
                   itemUpdateBlocks:(NSArray<IGListItemUpdateBlock> *)itemUpdateBlocks
                   completionBlocks:(NSArray<IGListUpdatingCompletion> *)completionBlocks NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
