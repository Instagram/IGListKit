/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

@class IGListAdapter;
@class IGListSectionController;

NS_ASSUME_NONNULL_BEGIN

/**
 `IGListAdapterPerformanceDelegate` can be used to measure cell dequeue, display, size, and scroll callbacks. 
 */
NS_SWIFT_NAME(ListAdapterPerformanceDelegate)
@protocol IGListAdapterPerformanceDelegate <NSObject>

/**
 Will call `-[IGListAdapter collectionView:cellForItemAtIndexPath:]`.

 @param listAdapter The list adapter sending this information.
 */
- (void)listAdapterWillCallDequeueCell:(IGListAdapter *)listAdapter;

/**
 Did finish calling `-[IGListAdapter collectionView:cellForItemAtIndexPath:]`.

 @param listAdapter The list adapter sending this information.
 @param cell A cell that was dequeued.
 @param sectionController The section controller providing the cell.
 @param index Item index of the cell.
 */
- (void)listAdapter:(IGListAdapter *)listAdapter didCallDequeueCell:(UICollectionViewCell *)cell onSectionController:(IGListSectionController *)sectionController atIndex:(NSInteger)index;

/**
 Will call `-[IGListAdapter collectionView:willDisplayCell:forItemAtIndexPath:]`.

 @param listAdapter The list adapter sending this information.
 */
- (void)listAdapterWillCallDisplayCell:(IGListAdapter *)listAdapter;

/**
 Did finish calling `-[IGListAdapter collectionView:willDisplayCell:forItemAtIndexPath:]`.

 @param listAdapter The list adapter sending this information.
 @param cell A cell that will be displayed.
 @param sectionController The section controller for that cell.
 @param index Item index of the cell.

 @note Keep in mind this also includes calling the `IGListAdapter`'s collectionViewDelegate and workingRangeHandler.
 */
- (void)listAdapter:(IGListAdapter *)listAdapter didCallDisplayCell:(UICollectionViewCell *)cell onSectionController:(IGListSectionController *)sectionController atIndex:(NSInteger)index;

/**
 Will call `-[IGListAdapter collectionView:didEndDisplayingCell:forItemAtIndexPath:]`.

 @param listAdapter The list adapter sending this information.
 */
- (void)listAdapterWillCallEndDisplayCell:(IGListAdapter *)listAdapter;

/**
 Did finish calling `-[IGListAdapter collectionView:didEndDisplayingCell:forItemAtIndexPath:]`.

 @param listAdapter The list adapter sending this information.
 @param cell A cell that was displayed.
 @param sectionController The section controller for that cell.
 @param index Item index of the cell.

 @note Keep in mind this also includes calling the `IGListAdapter`'s collectionViewDelegate and workingRangeHandler.
 */
- (void)listAdapter:(IGListAdapter *)listAdapter didCallEndDisplayCell:(UICollectionViewCell *)cell onSectionController:(IGListSectionController *)sectionController atIndex:(NSInteger)index;

/**
 Will call `-[IGListAdapter collectionView:collectionViewLayout:sizeForItemAtIndexPath:]`.

 @param listAdapter The list adapter sending this information.
 */
- (void)listAdapterWillCallSize:(IGListAdapter *)listAdapter;

/**
 Did finish calling `-[IGListAdapter collectionView:collectionViewLayout:sizeForItemAtIndexPath:]`.

 @param listAdapter The list adapter sending this information.
 @param sectionController The section controller providing the size.
 @param index Item index used to calculate the size.
 */
- (void)listAdapter:(IGListAdapter *)listAdapter didCallSizeOnSectionController:(IGListSectionController *)sectionController atIndex:(NSInteger)index;

/**
 Will call `-[IGListAdapter scrollViewDidScroll:]`.

 @param listAdapter The list adapter sending this information.
 */
- (void)listAdapterWillCallScroll:(IGListAdapter *)listAdapter;

/**
 Did finish calling `-[IGListAdapter scrollViewDidScroll:]`.

 @param listAdapter The list adapter sending this information.
 @param scrollView The scroll view backing the UICollectionView.

 @note Keep in mind this also includes calling the `IGListAdapter`'s scrollViewDelegate and all visible `IGListSectioControllers`.
 */
- (void)listAdapter:(IGListAdapter *)listAdapter didCallScroll:(UIScrollView *)scrollView;

@end

NS_ASSUME_NONNULL_END
