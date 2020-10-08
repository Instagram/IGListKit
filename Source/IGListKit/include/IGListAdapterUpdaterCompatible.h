/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

#import "IGListUpdatingDelegate.h"
#if SWIFT_PACKAGE
#import "IGListExperiments.h"
#else
#import <IGListDiffKit/IGListExperiments.h>
#endif
#import "IGListAdapterUpdaterDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/**
Temporary protocol to test replacing `IGListAdapterUpdater` with `IGListExperimentalAdapterUpdater`.
It extends `IGListUpdatingDelegate` to add more functionaly that might not be needed for all updaters.
 */
NS_SWIFT_NAME(ListAdapterUpdaterCompatible)
@protocol IGListAdapterUpdaterCompatible <IGListUpdatingDelegate>

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
 A flag indicating whether this updater should skip diffing and simply call
 `reloadData` for updates when the collection view is not in a window. The default value is `YES`.

 Default is YES.

 @note This will result in better performance, but will not generate the same delegate
 callbacks. If using a custom layout, it will not receive `prepareForCollectionViewUpdates:`.

 @warning On iOS < 8.3, this behavior is unsupported and will always be treated as `NO`.
 */
@property (nonatomic, assign) BOOL allowsBackgroundReloading;

/**
 If there's more than 100 diff updates, fallback to using `reloadData` to avoid stalling the main thread.

 Default is YES.
 */
@property (nonatomic, assign) BOOL allowsReloadingOnTooManyUpdates;

/**
 A bitmask of experiments to conduct on the updater.
 */
@property (nonatomic, assign) IGListExperiment experiments;

@end

NS_ASSUME_NONNULL_END
