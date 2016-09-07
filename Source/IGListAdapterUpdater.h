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
 This is an out-of-box upater for IGListAdapters. It conforms to IGListUpdatingDelegate and does re-entrant, coalesced
 updating on a UICollectionView.

 It also uses IGDiffKit (a least-minimal diff) for calculating UI updates when IGListAdapter calls
 -performUpdateWithCollectionView:fromObjects:toObjects:completion:.
 */
IGLK_SUBCLASSING_RESTRICTED
@interface IGListAdapterUpdater : NSObject <IGListUpdatingDelegate>

/**
 A delegate that receives events with data on the performance of a transition.
 */
@property (nonatomic, weak) id<IGListAdapterUpdaterDelegate> delegate;

/**
 A flag indicating if a move should be treated as a delete+insert.
 */
@property (nonatomic, assign) BOOL movesAsDeletesInserts;

/**
 A bitmask of experiments to conduct on the updater.
 */
@property (nonatomic, assign) IGListExperiment experiments;

@end

NS_ASSUME_NONNULL_END
