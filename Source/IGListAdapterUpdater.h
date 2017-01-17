/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

#import <IGListKit/IGListAdapterUpdaterDelegate.h>
#import <IGListKit/IGListExperiments.h>
#import <IGListKit/IGListMacros.h>
#import <IGListKit/IGListUpdatingDelegate.h>

NS_ASSUME_NONNULL_BEGIN

/**
 An `IGListAdapterUpdater` is a concrete type that conforms to `IGListUpdatingDelegate`.
 It is an out-of-box upater for `IGListAdapter` objects to use.

 @note This updater performs re-entrant, coalesced updating for a list. It also uses a least-minimal diff 
 for calculating UI updates when `IGListAdapter` calls 
 `-performUpdateWithCollectionView:fromObjects:toObjects:completion:`.
 */
IGLK_SUBCLASSING_RESTRICTED
@interface IGListAdapterUpdater : NSObject <IGListUpdatingDelegate>

/**
 The delegate that receives events with data on the performance of a transition.
 */
@property (nonatomic, weak) id<IGListAdapterUpdaterDelegate> delegate;

/**
 A flag indicating if a move should be treated as a "delete, then insert" operation.
 */
@property (nonatomic, assign) BOOL movesAsDeletesInserts;

/**
 A flag indicating whether this updater should skip diffing and simply call
 `reloadData` for updates when the collection view is not in a window. The default value is `YES`.
 
 @note This will result in better performance, but will not generate the same delegate
 callbacks. If using a custom layout, it will not receive `prepareForCollectionViewUpdates:`.

 @warning On iOS < 8.3, this behavior is unsupported and will always be treated as `NO`.
 */
@property (nonatomic, assign) BOOL allowsBackgroundReloading;

/**
 A bitmask of experiments to conduct on the updater.
 */
@property (nonatomic, assign) IGListExperiment experiments;

@end

NS_ASSUME_NONNULL_END
