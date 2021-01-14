/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

#import "IGListUpdatingDelegate.h"

@class IGListTransitionData;

NS_ASSUME_NONNULL_BEGIN

/// A block that returns the `IGListTransitionData` needed before an update.
NS_SWIFT_NAME(ListTransitionDataBlock)
typedef IGListTransitionData * _Nullable (^IGListTransitionDataBlock)(void);

/**
 A block to be called when the adapter applies changes to the collection view.

 @param data The new data that contains the from/to objects.
 */
NS_SWIFT_NAME(ListTransitionDataApplyBlock)
typedef void (^IGListTransitionDataApplyBlock)(IGListTransitionData *data);

/**
 Temporary experimental version of `IGListUpdatingDelegate`
 */
NS_SWIFT_NAME(ListUpdatingDelegateExperimental)
@protocol IGListUpdatingDelegateExperimental <IGListUpdatingDelegate>

/**
 Experimental version of `performUpdateWithCollectionViewBlock` that uses `IGListTransitionData` to make updates safer.
 The adapter will use this method instead of the regular `performUpdateWithCollectionViewBlock` if implemented.
 */
- (void)performExperimentalUpdateAnimated:(BOOL)animated
                      collectionViewBlock:(IGListCollectionViewBlock)collectionViewBlock
                                dataBlock:(IGListTransitionDataBlock)dataBlock
                           applyDataBlock:(IGListTransitionDataApplyBlock)applyDataBlock
                               completion:(nullable IGListUpdatingCompletion)completion;

/**
 Perform a `[UICollectionView setDataSource:...]` swap within this block. It gives the updater the chance to cancel or
 execute any on-going updates. The block will be executed synchronously.

 @param block The block that will actuallty change the `dataSource`
 */
- (void)performDataSourceChange:(IGListDataSourceChangeBlock)block;

@end

NS_ASSUME_NONNULL_END
