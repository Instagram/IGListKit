/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#if !__has_include(<IGListDiffKit/IGListDiffKit.h>)
#import "IGListCompatibility.h"
#else
#import <IGListDiffKit/IGListCompatibility.h>
#endif

/**
 * Project version number for IGListKit.
 */
FOUNDATION_EXPORT double IGListKitVersionNumber;

/**
 * Project version string for IGListKit.
 */
FOUNDATION_EXPORT const unsigned char IGListKitVersionString[];

#if TARGET_OS_EMBEDDED || TARGET_OS_SIMULATOR || TARGET_OS_MACCATALYST

// iOS and tvOS only:

#if !__has_include(<IGListKit/IGListKit.h>)
#import "IGListAdapter.h"
#import "IGListAdapterDataSource.h"
#import "IGListAdapterDelegate.h"
#import "IGListAdapterDelegateAnnouncer.h"
#import "IGListAdapterUpdateListener.h"
#import "IGListAdapterUpdater.h"
#import "IGListAdapterUpdaterDelegate.h"
#import "IGListBatchContext.h"
#import "IGListBindable.h"
#import "IGListBindingSectionController.h"
#import "IGListBindingSectionControllerDataSource.h"
#import "IGListBindingSectionControllerSelectionDelegate.h"
#import "IGListBindingSingleSectionController.h"
#import "IGListCollectionContext.h"
#import "IGListCollectionView.h"
#import "IGListCollectionViewLayout.h"
#import "IGListCollectionViewLayoutInvalidationContext.h"
#import "IGListDisplayDelegate.h"
#import "IGListGenericSectionController.h"
#import "IGListCollectionViewDelegateLayout.h"
#import "IGListReloadDataUpdater.h"
#import "IGListScrollDelegate.h"
#import "IGListSectionController.h"
#import "IGListSingleSectionController.h"
#import "IGListSupplementaryViewSource.h"
#import "IGListTransitionData.h"
#import "IGListTransitionDelegate.h"
#import "IGListUpdatingDelegate.h"
#import "IGListWorkingRangeDelegate.h"
#import "IGListCollectionViewDelegateLayout.h"
#import "UIViewController+IGListAdapter.h"
#else
#import <IGListKit/IGListAdapter.h>
#import <IGListKit/IGListAdapterDataSource.h>
#import <IGListKit/IGListAdapterDelegate.h>
#import <IGListKit/IGListAdapterDelegateAnnouncer.h>
#import <IGListKit/IGListAdapterUpdateListener.h>
#import <IGListKit/IGListAdapterUpdater.h>
#import <IGListKit/IGListAdapterUpdaterDelegate.h>
#import <IGListKit/IGListBatchContext.h>
#import <IGListKit/IGListBindable.h>
#import <IGListKit/IGListBindingSectionController.h>
#import <IGListKit/IGListBindingSectionControllerDataSource.h>
#import <IGListKit/IGListBindingSectionControllerSelectionDelegate.h>
#import <IGListKit/IGListBindingSingleSectionController.h>
#import <IGListKit/IGListCollectionContext.h>
#import <IGListKit/IGListCollectionView.h>
#import <IGListKit/IGListCollectionViewLayout.h>
#import <IGListKit/IGListCollectionViewLayoutInvalidationContext.h>
#import <IGListKit/IGListDisplayDelegate.h>
#import <IGListKit/IGListGenericSectionController.h>
#import <IGListKit/IGListCollectionViewDelegateLayout.h>
#import <IGListKit/IGListReloadDataUpdater.h>
#import <IGListKit/IGListScrollDelegate.h>
#import <IGListKit/IGListSectionController.h>
#import <IGListKit/IGListSingleSectionController.h>
#import <IGListKit/IGListSupplementaryViewSource.h>
#import <IGListKit/IGListTransitionData.h>
#import <IGListKit/IGListTransitionDelegate.h>
#import <IGListKit/IGListUpdatingDelegate.h>
#import <IGListKit/IGListWorkingRangeDelegate.h>
#import <IGListKit/IGListCollectionViewDelegateLayout.h>
#import <IGListKit/UIViewController+IGListAdapter.h>
#endif

#endif

// Shared (iOS, tvOS, macOS compatible):

#if !__has_include(<IGListDiffKit/IGListDiffKit.h>)
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
#else
#import <IGListDiffKit/IGListAssert.h>
#import <IGListDiffKit/IGListBatchUpdateData.h>
#import <IGListDiffKit/IGListDiff.h>
#import <IGListDiffKit/IGListDiffable.h>
#import <IGListDiffKit/IGListExperiments.h>
#import <IGListDiffKit/IGListIndexPathResult.h>
#import <IGListDiffKit/IGListIndexSetResult.h>
#import <IGListDiffKit/IGListMoveIndex.h>
#import <IGListDiffKit/IGListMoveIndexPath.h>
#import <IGListDiffKit/NSNumber+IGListDiffable.h>
#import <IGListDiffKit/NSString+IGListDiffable.h>
#endif
