/*
* Copyright (c) Facebook, Inc. and its affiliates.
*
* This source code is licensed under the MIT license found in the
* LICENSE file in the root directory of this source tree.
*/

#import <Foundation/Foundation.h>

#import <IGListDiffKit/IGListMacros.h>
#import <IGListKit/IGListUpdatingDelegate.h>

#import "IGListUpdateTransactable.h"

@class IGListAdapterUpdater;
@protocol IGListAdapterUpdaterDelegate;

NS_ASSUME_NONNULL_BEGIN

/// Handles a full reload transaction
IGLK_SUBCLASSING_RESTRICTED
@interface IGListReloadTransaction : NSObject <IGListUpdateTransactable>

- (instancetype)initWithCollectionViewBlock:(IGListCollectionViewBlock)collectionViewBlock
                                    updater:(IGListAdapterUpdater *)updater
                                   delegate:(nullable id<IGListAdapterUpdaterDelegate>)delegate
                                reloadBlock:(IGListReloadUpdateBlock)reloadBlock
                           itemUpdateBlocks:(NSArray<IGListItemUpdateBlock> *)itemUpdateBlocks
                           completionBlocks:(NSArray<IGListUpdatingCompletion> *)completionBlocks NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
