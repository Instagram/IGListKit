/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

/**
 * Project version number for IGListKit.
 */
FOUNDATION_EXPORT double IGListKitVersionNumber;

/**
 * Project version string for IGListKit.
 */
FOUNDATION_EXPORT const unsigned char IGListKitVersionString[];

#import <IGListKit/IGListAssert.h>
#import <IGListKit/IGListAdapter.h>
#import <IGListKit/IGListAdapterDataSource.h>
#import <IGListKit/IGListAdapterDelegate.h>
#import <IGListKit/IGListAdapterUpdater.h>
#import <IGListKit/IGListAdapterUpdaterDelegate.h>
#import <IGListKit/IGListBatchUpdateData.h>
#import <IGListKit/IGListCollectionContext.h>
#import <IGListKit/IGListCollectionView.h>
#import <IGListKit/IGListDiff.h>
#import <IGListKit/IGListDiffable.h>
#import <IGListKit/IGListDisplayDelegate.h>
#import <IGListKit/IGListExperiments.h>
#import <IGListKit/IGListGridCollectionViewLayout.h>
#import <IGListKit/IGListIndexPathResult.h>
#import <IGListKit/IGListIndexSetResult.h>
#import <IGListKit/IGListSectionController.h>
#import <IGListKit/IGListSectionType.h>
#import <IGListKit/IGListMacros.h>
#import <IGListKit/IGListMoveIndex.h>
#import <IGListKit/IGListMoveIndexPath.h>
#import <IGListKit/IGListReloadDataUpdater.h>
#import <IGListKit/IGListScrollDelegate.h>
#import <IGListKit/IGListSingleSectionController.h>
#import <IGListKit/IGListStackedSectionController.h>
#import <IGListKit/IGListSupplementaryViewSource.h>
#import <IGListKit/IGListUpdatingDelegate.h>
#import <IGListKit/IGListWorkingRangeDelegate.h>
#import <IGListKit/NSNumber+IGListDiffable.h>
#import <IGListKit/NSString+IGListDiffable.h>
