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

@protocol IGListSectionType;

NS_ASSUME_NONNULL_BEGIN

IGLK_SUBCLASSING_RESTRICTED
@interface IGListDisplayHandler : NSObject

/**
 Tells the handler that a cell will be displayed in the IGListKit infra.

 @param cell              A cell that will display.
 @param listAdapter       The adapter managing the infra.
 @param sectionController The section controller the cell is in.
 @param object            The object associated with the section controller.
 @param indexPath         The index path of the cell in the UICollectionView.
 */
- (void)willDisplayCell:(UICollectionViewCell *)cell
         forListAdapter:(IGListAdapter *)listAdapter
      sectionController:(IGListSectionController<IGListSectionType> *)sectionController
                 object:(id)object
              indexPath:(NSIndexPath *)indexPath;

/**
 Tells the handler that a cell did end display in the IGListKit infra.

 @param cell              A cell that did end display.
 @param listAdapter       The adapter managing the infra.
 @param sectionController The section controller the cell is in.
 @param indexPath         The index path of the cell in the UICollectionView.
 */
- (void)didEndDisplayingCell:(UICollectionViewCell *)cell
              forListAdapter:(IGListAdapter *)listAdapter
           sectionController:(IGListSectionController<IGListSectionType> *)sectionController
                   indexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
