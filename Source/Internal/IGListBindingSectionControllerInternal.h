/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <IGListKit/IGListBindingSectionController.h>

#import "IGListWorkingRangeHandler.h"

NS_ASSUME_NONNULL_BEGIN

@interface IGListBindingSectionController () <IGListDisplayDelegate> {
    BOOL _isSendingBindingRangeBindUpdates;
}

@property (nonatomic, strong, readonly) IGListBindingRangeHandler *bindingRangeHandler;

@property (nonatomic, weak) id<IGListDisplayDelegate> displayDelegateProxy;

@end

NS_ASSUME_NONNULL_END

