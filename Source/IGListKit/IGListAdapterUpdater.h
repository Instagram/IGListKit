/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

#if __has_include(<IGListDiffKit/IGListDiffKit.h>)
#import <IGListDiffKit/IGListMacros.h>
#import <IGListDiffKit/IGListExperiments.h>
#else
#import "IGListMacros.h"
#import "IGListExperiments.h"
#endif
#import "IGListUpdatingDelegate.h"
#import "IGListAdapterUpdaterDelegate.h"

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
@interface IGListAdapterUpdater : NSObject <IGListUpdatingDelegate>

/**
 The delegate that receives events with data on the performance of a transition.
 */
@property (nonatomic, weak) id<IGListAdapterUpdaterDelegate> delegate;

/**
 A flag indicating if a section move should be treated as a section "delete, then insert" operation. This can be useful if you're
 performing a lot of updates and moves are too distracting.

 Default is NO.
 */
@property (nonatomic, assign) BOOL sectionMovesAsDeletesInserts;

/**
 ONLY used when there is N section, but each section only contains 1 item.
 We don't need to change move into delete+insert, and we dont need to call -reload at all.

 This unlocks many default UICollectionView animations: move/inline cell updates/deletes/inserts etc.

 Default is NO.

 @warning This should only work for Section that *ONLY* has single item setup.
 */
@property (nonatomic, assign) BOOL singleItemSectionUpdates;

/**
 A flag indicating that section reloads should be treated as item reloads, instead of converting them to "delete, then insert" operations.
 This only applies if the number of items for the section is unchanged.

 Default is NO.

 @note If the number of items for the section is changed, we would fallback to the default behavior and convert it to "delete + insert",
 because the collectionView can crash otherwise.
 */
@property (nonatomic, assign) BOOL preferItemReloadsForSectionReloads;

/**
 If there's more than 100 diff updates, fallback to using `reloadData` to avoid stalling the main thread.

 Default is YES.
 */
@property (nonatomic, assign) BOOL allowsReloadingOnTooManyUpdates;

/**
 Allow the diffing to be performed on a background thread.

 Default is NO.
 */
@property (nonatomic, assign) BOOL allowsBackgroundDiffing;

/**
 A bitmask of experiments to conduct on the updater.
 */
@property (nonatomic, assign) IGListExperiment experiments;


@end

NS_ASSUME_NONNULL_END
