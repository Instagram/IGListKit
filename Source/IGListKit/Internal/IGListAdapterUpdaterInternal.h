/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

#import "IGListAdapterUpdater.h"
#import "IGListBatchUpdateState.h"

@class IGListUpdateTransactionBuilder;
@protocol IGListUpdateTransactable;

NS_ASSUME_NONNULL_BEGIN

@interface IGListAdapterUpdater ()

- (BOOL)hasChanges;

/// Force an update to start
- (void)update;

- (id<IGListUpdateTransactable>)transaction;
- (IGListUpdateTransactionBuilder *)transactionBuilder;
- (IGListUpdateTransactionBuilder *)lastTransactionBuilder;

@end

NS_ASSUME_NONNULL_END
