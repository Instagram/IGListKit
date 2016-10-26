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

@class IGListSectionController;
@protocol IGListSectionType;

/**
 The collection context provides limited access to the collection related information that
 section controllers need for things like sizing, dequeing cells, insterting/deleting/reloading, etc.
 */
@protocol IGListCollectionContext <NSObject>

/**
 Size of the collection view. Provided primarily for sizing cells.
 */
@property (nonatomic, readonly) CGSize containerSize;

/**
 Query for the index a cell in the collection relative to the section controller.

 @param cell              An existing cell in the collection.
 @param sectionController The section controller requesting this information.

 @return The index of the cell or NSNotFound if it does not exist in the collection.
 */
- (NSUInteger)indexForCell:(UICollectionViewCell *)cell
         sectionController:(IGListSectionController<IGListSectionType> *)sectionController;

/**
 Query for a cell in the collection. May return nil if the cell is offscreen.

 @param index             The index of the desired cell.
 @param sectionController The section controller requesting this information.

 @return The collection view cell, or `nil` if not found.
 */
- (nullable __kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index
                                             sectionController:(IGListSectionController<IGListSectionType> *)sectionController;

/**
 Query for the visible cells for the given section controller.

 @param sectionController The section controller requesting this information.

 @return An array of visible cells, or an empty array if none are found.
 */
- (NSArray<UICollectionViewCell *> *)visibleCellsForSectionController:(IGListSectionController<IGListSectionType> *)sectionController;

/**
 Deselects a cell in the collection.

 @param index             The index of the item to deselect.
 @param sectionController The section controller requesting this information.
 @param animated          Pass `YES` to animate the change, `NO` otherwise.
 */
- (void)deselectItemAtIndex:(NSInteger)index
          sectionController:(IGListSectionController<IGListSectionType> *)sectionController
                   animated:(BOOL)animated;

/**
 Query the section index of an section controller.

 @param sectionController An section controller object.

 @return The section index of the list if found, otherwise `NSNotFound`.
 */
- (NSUInteger)sectionForSectionController:(IGListSectionController<IGListSectionType> *)sectionController;

/**
 Dequeues a cell from the UICollectionView reuse pool.

 @param cellClass         The class of the cell you want to dequeue.
 @param sectionController The section controller requesting this information.
 @param index             The index of the cell.

 @return A cell dequeued from the reuse pool or newly created.

 @note This method uses a string representation of the cell class as the identifier.
 */
- (__kindof UICollectionViewCell *)dequeueReusableCellOfClass:(Class)cellClass
                                         forSectionController:(IGListSectionController<IGListSectionType> *)sectionController
                                                      atIndex:(NSInteger)index;

/**
 Dequeues a cell from the UICollectionView reuse pool.
 
 @param nibName           The name of the nib file.
 @param bundle            The bundle in which to search for the nib file. If nil, this method looks for the nib file in the main bundle.
 @param sectionController The section controller requesting this information.
 @param index             The index of the cell.
 
 @return A cell dequeued from the reuse pool or newly created.
 
 @note This method uses a string representation of the cell class as the identifier.
 */
- (__kindof UICollectionViewCell *)dequeueReusableCellWithNibName:(NSString *)nibName
                                                           bundle:(nullable NSBundle *)bundle
                                             forSectionController:(IGListSectionController<IGListSectionType> *)sectionController
                                                          atIndex:(NSInteger)index;

/**
 Dequeues a storyboard prototype cell from the UICollectionView reuse pool.
 
 @param identifier        The identifier of the cell prototype in storyboard.
 @param sectionController The section controller requesting this information.
 @param index             The index of the cell.
 
 @return A cell dequeued from the reuse pool or newly created.
 */
- (__kindof UICollectionViewCell *)dequeueReusableCellFromStoryboardWithIdentifier:(NSString *)identifier
                                                              forSectionController:(IGListSectionController <IGListSectionType> *)sectionController
                                                                           atIndex:(NSInteger)index;

/**
 Dequeues a supplementary view from the UICollectionView reuse pool.

 @param elementKind       The kind of supplementary veiw.
 @param sectionController The section controller requesting this information.
 @param viewClass         The class of the supplementary view.
 @param index             The index of the supplementary vew.

 @return A supplementary view dequeued from the reuse pool or newly created.

 @note This method uses a string representation of the view class as the identifier.
 */
- (__kindof UICollectionReusableView *)dequeueReusableSupplementaryViewOfKind:(NSString *)elementKind
                                                         forSectionController:(IGListSectionController<IGListSectionType> *)sectionController
                                                                        class:(Class)viewClass
                                                                      atIndex:(NSInteger)index;

/**
 Dequeues a supplementary view from the UICollectionView reuse pool.
 
 @param elementKind       The kind of supplementary veiw.
 @param identifier        The identifier of the supplementary view in storyboard.
 @param sectionController The section controller requesting this information.
 @param index             The index of the supplementary vew.
 
 @return A supplementary view dequeued from the reuse pool or newly created.
 */
- (__kindof UICollectionReusableView *)dequeueReusableSupplementaryViewFromStoryboardOfKind:(NSString *)elementKind
                                                                             withIdentifier:(NSString *)identifier
                                                                       forSectionController:(IGListSectionController<IGListSectionType> *)sectionController
                                                                                    atIndex:(NSInteger)index;

/**
 Reloads cells in the section controller.

 @param sectionController  The section controller who's cells need reloading.
 @param indexes            The indexes of items that need reloading.
 */
- (void)reloadInSectionController:(IGListSectionController<IGListSectionType> *)sectionController
                        atIndexes:(NSIndexSet *)indexes;

/**
 Inserts cells in the feed.

 @param sectionController The section controller who's cells need inserting.
 @param indexes           The indexes of items that need inserting.
 */
- (void)insertInSectionController:(IGListSectionController<IGListSectionType> *)sectionController
                        atIndexes:(NSIndexSet *)indexes;

/**
 Deletes cells in the feed.

 @param sectionController The section controller who's cells need deleted.
 @param indexes           The indexes of items that need deleting.
 */
- (void)deleteInSectionController:(IGListSectionController<IGListSectionType> *)sectionController
                        atIndexes:(NSIndexSet *)indexes;

/**
 Reload the entire section controller.

 @param sectionController The list object who's cells need reloading.
 */
- (void)reloadSectionController:(IGListSectionController<IGListSectionType> *)sectionController;

/**
 Batch many cell-level updates in a single transaction.

 @param animated   A flag indicating if the transition should be animated.
 @param updates    A block containing all of the cell updates.
 @param completion An optional completion block to execute when the updates are finished.

 @discussion Use this method to batch cell updates (inserts, deletes, reloads) into a single transaction. This lets you
 make many changes to your data store and perform all the transitions at once.

 For example, inside your section controllers, you may want to delete /and/ insert into the data source that backs your
 section controller:

 [self.collectionContext performBatchItemUpdates:^{
 // perform data source changes inside the update block
 [self.items addObject:newItem];
 [self.items removeObjectAtIndex:0];

 NSIndexSet *inserts = [NSIndexSet indexSetWithIndex:[self.items count] - 1];
 [self.collectionContext insertInSectionController:self atIndexes:inserts];

 NSIndexSet *deletes = [NSIndexSet indexSetWithIndex:0];
 [self.collectionContext deleteInSectionController:self deletes];
 } completion:nil];

 Note that you **must** perform data modifications **inside** the update block. Updates will not be performed
 synchronously, so you should make sure that your data source changes only when necessary.
 */
- (void)performBatchAnimated:(BOOL)animated updates:(void (^)())updates completion:(nullable void (^)(BOOL finished))completion;

@end

NS_ASSUME_NONNULL_END
