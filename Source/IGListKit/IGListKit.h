/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#if !__has_include(<IGListDiffKit/IGListDiffKit.h>)
#import <IGListKit/IGListCompatibility.h>
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

// Shared (iOS, tvOS, macOS compatible):

#if !__has_include(<IGListDiffKit/IGListDiffKit.h>)
#import <IGListKit/IGListAssert.h>
#import <IGListKit/IGListBatchUpdateData.h>
#import <IGListKit/IGListDiff.h>
#import <IGListKit/IGListDiffable.h>
#import <IGListKit/IGListExperiments.h>
#import <IGListKit/IGListIndexPathResult.h>
#import <IGListKit/IGListIndexSetResult.h>
#import <IGListKit/IGListMoveIndex.h>
#import <IGListKit/IGListMoveIndexPath.h>
#import <IGListKit/NSNumber+IGListDiffable.h>
#import <IGListKit/NSString+IGListDiffable.h>
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
