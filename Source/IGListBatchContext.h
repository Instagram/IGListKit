/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

@class IGListSectionController;



NS_ASSUME_NONNULL_BEGIN

/**
 Objects conforming to the IGListBatchContext protocol provide a way for section controllers to mutate their cells or
 reload everything within the section.
 */
NS_SWIFT_NAME(ListBatchContext)
@protocol IGListBatchContext <NSObject>

/**
 Reloads cells in the section controller.
 
 @param sectionController  The section controller who's cells need reloading.
 @param indexes The indexes of items that need reloading.
 */
- (void)reloadInSectionController:(IGListSectionController *)sectionController
                        atIndexes:(NSIndexSet *)indexes;

/**
 Inserts cells in the list.
 
 @param sectionController The section controller who's cells need inserting.
 @param indexes The indexes of items that need inserting.
 */
- (void)insertInSectionController:(IGListSectionController *)sectionController
                        atIndexes:(NSIndexSet *)indexes;

/**
 Deletes cells in the list.
 
 @param sectionController The section controller who's cells need deleted.
 @param indexes The indexes of items that need deleting.
 */
- (void)deleteInSectionController:(IGListSectionController *)sectionController
                        atIndexes:(NSIndexSet *)indexes;

/**
 Invalidates layouts of cells at specific in the section controller.
 
 @param sectionController The section controller who's cells need invalidating.
 @param indexes The indexes of items that need invalidating.
 */
- (void)invalidateLayoutInSectionController:(IGListSectionController *)sectionController
                                  atIndexes:(NSIndexSet *)indexes;

/**
 Moves a cell from one index to another within the section controller.
 
 @param sectionController The section controller who's cell needs moved.
 @param fromIndex The index the cell is currently in.
 @param toIndex The index the cell should move to.
 */
- (void)moveInSectionController:(IGListSectionController *)sectionController
                      fromIndex:(NSInteger)fromIndex
                        toIndex:(NSInteger)toIndex;

/**
 Reloads the entire section controller.
 
 @param sectionController The section controller who's cells need reloading.
 */
- (void)reloadSectionController:(IGListSectionController *)sectionController;
    
/**
 Moves a section controller from one index to another during interactive reordering.
 
 @param sectionController The section controller to move.
 @param fromIndex The index where the section currently resides.
 @param toIndex The index the section should move to.
 */
- (void)moveSectionControllerInteractive:(IGListSectionController *)sectionController
                               fromIndex:(NSInteger)fromIndex
                                 toIndex:(NSInteger)toIndex NS_AVAILABLE_IOS(9_0);

/**
 Moves an object within a section controller from one index to another during interactive reordering.
 
 @param sectionController The section controller containing the object to move.
 @param fromIndex The index where the object currently resides.
 @param toIndex The index the object should move to.
 */
- (void)moveInSectionControllerInteractive:(IGListSectionController *)sectionController
                                 fromIndex:(NSInteger)fromIndex
                                   toIndex:(NSInteger)toIndex NS_AVAILABLE_IOS(9_0);
    
/**
 Reverts an move from one indexPath to another during interactive reordering.
 
 @param sourceIndexPath The indexPath the item was originally in.
 @param destinationIndexPath The indexPath the item was moving to.
 */
- (void)revertInvalidInteractiveMoveFromIndexPath:(NSIndexPath *)sourceIndexPath
                                      toIndexPath:(NSIndexPath *)destinationIndexPath NS_AVAILABLE_IOS(9_0);
@end

NS_ASSUME_NONNULL_END
