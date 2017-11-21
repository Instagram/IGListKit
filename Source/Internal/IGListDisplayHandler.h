/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

#import <IGListKit/IGListMacros.h>

@class IGListAdapter;
@class IGListSectionController;



NS_ASSUME_NONNULL_BEGIN

IGLK_SUBCLASSING_RESTRICTED
@interface IGListDisplayHandler : NSObject

/**
 Counted set of the currently visible section controllers.
 */
@property (nonatomic, strong, readonly) NSCountedSet<IGListSectionController *> *visibleListSections;

/**
 Tells the handler that a cell will be displayed in the IGListAdapter.

 @param cell A cell that will be displayed.
 @param listAdapter The adapter the cell will display in.
 @param sectionController The section controller that manages the cell.
 @param object The object that powers the section controller.
 @param indexPath The index path of the cell in the UICollectionView.
 */
- (void)willDisplayCell:(UICollectionViewCell *)cell
         forListAdapter:(IGListAdapter *)listAdapter
      sectionController:(IGListSectionController *)sectionController
                 object:(id)object
              indexPath:(NSIndexPath *)indexPath;

/**
 Tells the handler that a cell did end display in the IGListAdapter.

 @param cell A cell that will be displayed.
 @param listAdapter The adapter the cell will display in.
 @param sectionController The section controller that manages the cell.
 @param indexPath The index path of the cell in the UICollectionView.
 */
- (void)didEndDisplayingCell:(UICollectionViewCell *)cell
              forListAdapter:(IGListAdapter *)listAdapter
           sectionController:(IGListSectionController *)sectionController
                   indexPath:(NSIndexPath *)indexPath;


/**
 Tells the handler that a supplementary view will be displayed in the IGListAdapter.

 @param view A supplementary view that will be displayed.
 @param listAdapter The adapter the supplementary view will display in.
 @param sectionController The section controller that manages the supplementary view.
 @param object The object that powers the section controller.
 @param indexPath The index path of the supplementary view in the UICollectionView.
 */
- (void)willDisplaySupplementaryView:(UICollectionReusableView *)view
                      forListAdapter:(IGListAdapter *)listAdapter
                   sectionController:(IGListSectionController *)sectionController
                              object:(id)object
                           indexPath:(NSIndexPath *)indexPath;


/**
 Tells the handler that a supplementary view did end display in the IGListAdapter.

 @param view A supplementary view that will be displayed.
 @param listAdapter The adapter the supplementary view will display in.
 @param sectionController The section controller that manages the supplementary view.
 @param indexPath The index path of the supplementary view in the UICollectionView.
 */
- (void)didEndDisplayingSupplementaryView:(UICollectionReusableView *)view
                           forListAdapter:(IGListAdapter *)listAdapter
                        sectionController:(IGListSectionController *)sectionController
                                indexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
