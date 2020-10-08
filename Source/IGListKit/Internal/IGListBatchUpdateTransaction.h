/*
* Copyright (c) Facebook, Inc. and its affiliates.
*
* This source code is licensed under the MIT license found in the
* LICENSE file in the root directory of this source tree.
*/

#import <Foundation/Foundation.h>

#if SWIFT_PACKAGE
#import "IGListMacros.h"
#else
#import <IGListDiffKit/IGListMacros.h>
#endif

#import "IGListUpdatingDelegate.h"
#import "IGListUpdatingDelegateExperimental.h"

#import "IGListUpdateTransactable.h"

@protocol IGListAdapterUpdaterCompatible;
@protocol IGListAdapterUpdaterDelegate;

NS_ASSUME_NONNULL_BEGIN

/// Handles a batch update transaction
IGLK_SUBCLASSING_RESTRICTED
@interface IGListBatchUpdateTransaction : NSObject <IGListUpdateTransactable>

- (instancetype)initWithCollectionViewBlock:(IGListCollectionViewBlock)collectionViewBlock
                                    updater:(id<IGListAdapterUpdaterCompatible>)updater
                                   delegate:(nullable id<IGListAdapterUpdaterDelegate>)delegate
                                     config:(IGListUpdateTransactationConfig)config
                                   animated:(BOOL)animated
                                  dataBlock:(nullable IGListTransitionDataBlock)dataBlock
                             applyDataBlock:(nullable IGListTransitionDataApplyBlock)applyDataBlock
                           itemUpdateBlocks:(NSArray<IGListItemUpdateBlock> *)itemUpdateBlocks
                           completionBlocks:(NSArray<IGListUpdatingCompletion> *)completionBlocks NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
