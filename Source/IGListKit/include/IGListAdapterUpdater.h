/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

#if SWIFT_PACKAGE || USE_PACKAGE_FROM_XCODE
#import "IGListMacros.h"
#else
#import <IGListDiffKit/IGListMacros.h>
#endif

#import "IGListAdapterUpdaterCompatible.h"

NS_ASSUME_NONNULL_BEGIN

/**
 An `IGListAdapterUpdater` is a concrete type that conforms to `IGListUpdatingDelegate`.
 It is an out-of-box updater for `IGListAdapter` objects to use.

 @note This updater performs re-entrant, coalesced updating for a list. It also uses a least-minimal diff
 for calculating UI updates when `IGListAdapter` calls
 `-performUpdateWithCollectionView:fromObjects:toObjects:completion:`.
 */
IGLK_SUBCLASSING_RESTRICTED
NS_SWIFT_NAME(ListAdapterUpdater)
@interface IGListAdapterUpdater : NSObject <IGListAdapterUpdaterCompatible>

@end

NS_ASSUME_NONNULL_END
