/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant 
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class IGListItemController;
@protocol IGListItemType;

/**
 The collection context provides limited access to the collection related information that
 item controllers need for things like sizing, dequeing cells, insterting/deleting/reloading, etc.
 */
@protocol IGListCollectionContext <NSObject>

/**
 Size of the collection view containing the items. Provided primarily for sizing cells.
 */
@property (nonatomic, readonly) CGSize containerSize;

/**
 Query for the index a cell in the collection relative to the item controller.

 @param cell               An existing cell in the collection.
 @param itemController The item controller requesting this information.

 @return The index of the cell or NSNotFound if it does not exist in the collection.
 */
- (NSUInteger)indexForCell:(UICollectionViewCell *)cell
            itemController:(IGListItemController<IGListItemType> *)itemController;

/**
 Query for a cell in the collection. May return nil if the cell is offscreen.

 @param index              The index of the desired cell.
 @param itemController The item controller requesting this information.

 @return The collection view cell, or `nil` if not found.
 */
- (nullable __kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index
                                                itemController:(IGListItemController<IGListItemType> *)itemController;

/**
 Query for the visible cells for the given item controller.

 @param itemController The item controller requesting this information.

 @return An array of visible cells, or an empty array if none are found.
 */
- (NSArray<UICollectionViewCell *> *)visibleCellsForItemController:(IGListItemController<IGListItemType> *)itemController;

/**
 Deselects a cell in the collection.

 @param index              The index of the item to deselect.
 @param itemController The item controller requesting this information.
 @param animated           Pass `YES` to animate the change, `NO` otherwise.
 */
- (void)deselectItemAtIndex:(NSInteger)index
             itemController:(IGListItemController<IGListItemType> *)itemController
                   animated:(BOOL)animated;

/**
 Query the section index of an item controller.

 @param itemController An item controller object.

 @return The section index of the list if found, otherwise `NSNotFound`.
 */
- (NSUInteger)sectionForItemController:(IGListItemController<IGListItemType> *)itemController;

/**
 Dequeues a cell from the UICollectionView reuse pool.

 @param cellClass          The class of the cell you want to dequeue.
 @param itemController The item controller requesting this information.
 @param index              The index of the cell.

 @return A cell dequeued from the reuse pool or newly created.

 @note This method uses a string representation of the cell class as the identifier.
 */
- (__kindof UICollectionViewCell *)dequeReusableCellOfClass:(Class)cellClass
                                          forItemController:(IGListItemController<IGListItemType> *)itemController
                                                    atIndex:(NSInteger)index;

/**
 Dequeues a supplementary view from the UICollectionView reuse pool.

 @param elementKind        The kind of supplementary veiw.
 @param itemController The item controller requesting this information.
 @param viewClass          The class of the supplementary view.
 @param index              The index of the supplementary vew.

 @return A supplementary view dequeued from the reuse pool or newly created.

 @note This method uses a string representation of the view class as the identifier.
 */
- (__kindof UICollectionReusableView *)dequeReusableSupplementaryViewOfKind:(NSString *)elementKind
                                                          forItemController:(IGListItemController<IGListItemType> *)itemController
                                                                      class:(Class)viewClass
                                                                    atIndex:(NSInteger)index;

/**
 Reloads list items in the feed.

 @param itemController The item controller that needs reloading.
 @param indexes            The indexes of items that need reloading.
 */
- (void)reloadItemsInItemController:(IGListItemController<IGListItemType> *)itemController
                          atIndexes:(NSIndexSet *)indexes;

/**
 Inserts list items in the feed.

 @param itemController The item controller that needs items inserted.
 @param indexes            The indexes of items that need inserting.
 */
- (void)insertItemsInItemController:(IGListItemController<IGListItemType> *)itemController
                          atIndexes:(NSIndexSet *)indexes;

/**
 Deletes list items in the feed.

 @param itemController The item controller that needs items deleted.
 @param indexes            The indexes of items that need deleting.
 */
- (void)deleteItemsInItemController:(IGListItemController<IGListItemType> *)itemController
                          atIndexes:(NSIndexSet *)indexes;

/**
 Reloads all items in an item controller.

 @param itemController The list object who's cells need reloading.
 */
- (void)reloadItemController:(IGListItemController<IGListItemType> *)itemController;

/**
 Batch many item-level updates in a single transaction.

 @param animated   A flag indicating if the transition should be animated.
 @param updates    A block containing all of the item updates.
 @param completion An optional completion block to execute when the updates are finished.

 @discussion Use this method to batch item updates (inserts, deletes, reloads) into a single transaction. This lets you
 make many changes to your data store and perform all the transitions at once.

 For example, inside your item controllers, you may want to delete /and/ insert into the data source that backs your
 item controller:

 [self.collectionContext performBatchItemUpdates:^{
 // perform data source changes inside the update block
 [self.items addObject:newItem];
 [self.items removeObjectAtIndex:0];

 NSIndexSet *inserts = [NSIndexSet indexSetWithIndex:[self.items count] - 1];
 [self.collectionContext insertItemsInItemController:self atIndexes:inserts];

 NSIndexSet *deletes = [NSIndexSet indexSetWithIndex:0];
 [self.collectionContext deleteItemsInItemController:self deletes];
 } completion:nil];

 Note that you **must** perform data modifications **inside** the update block. Updates will not be performed
 synchronously, so you should make sure that your data source changes only when necessary.
 */
- (void)performBatchAnimated:(BOOL)animated updates:(void (^)())updates completion:(nullable void (^)(BOOL finished))completion;

@end

NS_ASSUME_NONNULL_END
