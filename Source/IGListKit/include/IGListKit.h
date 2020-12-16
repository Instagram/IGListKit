/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGListCompatibility.h"

/**
 * Project version number for IGListKit.
 */
FOUNDATION_EXPORT double IGListKitVersionNumber;

/**
 * Project version string for IGListKit.
 */
FOUNDATION_EXPORT const unsigned char IGListKitVersionString[];

#if TARGET_OS_EMBEDDED || TARGET_OS_SIMULATOR  || TARGET_OS_MACCATALYST

// iOS and tvOS only:

#import "IGListAdapter.h"
#import "IGListAdapterDataSource.h"
#import "IGListAdapterDelegate.h"
#import "IGListAdapterUpdateListener.h"
#import "IGListAdapterUpdater.h"
#import "IGListAdapterUpdaterDelegate.h"
#import "IGListBatchContext.h"
#import "IGListBindable.h"
#import "IGListBindingSectionController.h"
#import "IGListBindingSectionControllerDataSource.h"
#import "IGListBindingSectionControllerSelectionDelegate.h"
#import "IGListCollectionContext.h"
#import "IGListCollectionView.h"
#import "IGListCollectionViewLayout.h"
#import "IGListDisplayDelegate.h"
#import "IGListGenericSectionController.h"
#import "IGListCollectionViewDelegateLayout.h"
#import "IGListReloadDataUpdater.h"
#import "IGListScrollDelegate.h"
#import "IGListSectionController.h"
#import "IGListSingleSectionController.h"
#import "IGListSupplementaryViewSource.h"
#import "IGListTransitionDelegate.h"
#import "IGListUpdatingDelegate.h"
#import "IGListWorkingRangeDelegate.h"
#import "IGListCollectionViewDelegateLayout.h"

#endif

// Shared (iOS, tvOS, macOS compatible):

#import "IGListAssert.h"
#import "IGListBatchUpdateData.h"
#import "IGListDiff.h"
#import "IGListDiffable.h"
#import "IGListExperiments.h"
#import "IGListIndexPathResult.h"
#import "IGListIndexSetResult.h"
#import "IGListMoveIndex.h"
#import "IGListMoveIndexPath.h"
#import "NSNumber+IGListDiffable.h"
#import "NSString+IGListDiffable.h"
