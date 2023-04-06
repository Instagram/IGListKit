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

#if !__has_include(<IGListKit/IGListUpdatingDelegate.h>)
#import "IGListUpdatingDelegate.h"
#else
#import <IGListKit/IGListUpdatingDelegate.h>
#endif

#import "IGListUpdateTransactable.h"

@class IGListAdapterUpdater;
@protocol IGListAdapterUpdaterDelegate;

NS_ASSUME_NONNULL_BEGIN

/// Handles a batch update transaction
IGLK_SUBCLASSING_RESTRICTED
@interface IGListBatchUpdateTransaction : NSObject <IGListUpdateTransactable>

- (instancetype)initWithCollectionViewBlock:(IGListCollectionViewBlock)collectionViewBlock
                                    updater:(IGListAdapterUpdater *)updater
                                   delegate:(nullable id<IGListAdapterUpdaterDelegate>)delegate
                                     config:(IGListUpdateTransactationConfig)config
                                   animated:(BOOL)animated
                           sectionDataBlock:(nullable IGListTransitionDataBlock)sectionDataBlock
                      applySectionDataBlock:(nullable IGListTransitionDataApplyBlock)applySectionDataBlock
                           itemUpdateBlocks:(NSArray<IGListItemUpdateBlock> *)itemUpdateBlocks
                           completionBlocks:(NSArray<IGListUpdatingCompletion> *)completionBlocks NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
