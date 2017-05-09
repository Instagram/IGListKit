/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
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

@end

NS_ASSUME_NONNULL_END
