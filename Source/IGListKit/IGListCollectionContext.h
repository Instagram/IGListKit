/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

#if !__has_include(<IGListDiffKit/IGListDiffKit.h>)
#import "IGListExperiments.h"
#else
#import <IGListDiffKit/IGListExperiments.h>
#endif
#import "IGListBatchContext.h"
#import "IGListCollectionScrollingTraits.h"

NS_ASSUME_NONNULL_BEGIN

@class IGListSectionController;

/**
 The collection context provides limited access to the collection-related information that
 section controllers need for operations like sizing, dequeuing cells, inserting, deleting, reloading, etc.
 */
NS_SWIFT_NAME(ListCollectionContext)
@protocol IGListCollectionContext <NSObject>

/**
 The size of the collection view. You can use this for sizing cells.
 */
@property (nonatomic, readonly) CGSize containerSize;

/**
 The content insets of the collection view. You can use this for sizing cells.
 */
@property (nonatomic, readonly) UIEdgeInsets containerInset;

/**
 The adjusted content insets of the collection view. Equivalent to containerInset under iOS 11.
 */
@property (nonatomic, readonly) UIEdgeInsets adjustedContainerInset;

/**
 The size of the collection view with content insets applied.
 */
@property (nonatomic, readonly) CGSize insetContainerSize;

/**
 The content offset of the collection view.
 */
@property (nonatomic, readonly) CGPoint containerContentOffset;

/**
 The trait collection of the collection view.
 */
@property (nonatomic, nullable, readonly) UITraitCollection *traitCollection;

/**
 The current scrolling traits of the underlying collection view.
 */
@property (nonatomic, readonly) IGListCollectionScrollingTraits scrollingTraits;

/**
 A bitmask of experiments to conduct on the section controller.
 */
@property (nonatomic, assign) IGListExperiment experiments;

/**
 Returns size of the collection view relative to the section controller.

 @param sectionController The section controller requesting this information.

 @return The size of the collection view minus the given section controller's insets.
 */
- (CGSize)containerSizeForSectionController:(IGListSectionController *)sectionController;

/**
 Returns the index of the specified cell in the collection relative to the section controller.

 @param cell An existing cell in the collection.
 @param sectionController The section controller requesting this information.

 @return The index of the cell or `NSNotFound` if it does not exist in the collection.
 */
- (NSInteger)indexForCell:(UICollectionViewCell *)cell
        sectionController:(IGListSectionController *)sectionController;

/**
 Returns the cell in the collection at the specified index for the section controller.

 @param index The index of the desired cell.
 @param sectionController The section controller requesting this information.

 @return The collection view cell, or `nil` if not found.

 @warning This method may return `nil` if the cell is offscreen.
 */
- (nullable __kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index
                                             sectionController:(IGListSectionController *)sectionController;

/**
 Returns the supplementary view in the collection at the specified index for the section controller.

 @param elementKind The element kind of the supplementary view.
 @param index The index of the desired cell.
 @param sectionController The section controller requesting this information.

 @return The collection reusable view, or `nil` if not found.

 @warning This method may return `nil` if the cell is offscreen.
 */
- (nullable __kindof UICollectionReusableView *)viewForSupplementaryElementOfKind:(NSString *)elementKind
                                                                          atIndex:(NSInteger)index
                                                                sectionController:(IGListSectionController *)sectionController;

/**
 Returns the fully visible cells for the given section controller.

 @param sectionController The section controller requesting this information.

 @return An array of fully visible cells, or an empty array if none are found.
 */
- (NSArray<UICollectionViewCell *> *)fullyVisibleCellsForSectionController:(IGListSectionController *)sectionController;

/**
 Returns the visible cells for the given section controller.

 @param sectionController The section controller requesting this information.

 @return An array of visible cells, or an empty array if none are found.
 */
- (NSArray<UICollectionViewCell *> *)visibleCellsForSectionController:(IGListSectionController *)sectionController;

/**
 Returns the visible paths for the given section controller.

 @param sectionController The section controller requesting this information.

 @return An array of visible index paths, or an empty array if none are found.
 */
- (NSArray<NSIndexPath *> *)visibleIndexPathsForSectionController:(IGListSectionController *) sectionController;

/**
 Deselects a cell in the collection.

 @param index The index of the item to deselect.
 @param sectionController The section controller requesting this information.
 @param animated Pass `YES` to animate the change, `NO` otherwise.
 */
- (void)deselectItemAtIndex:(NSInteger)index
          sectionController:(IGListSectionController *)sectionController
                   animated:(BOOL)animated;

/**
 Selects a cell in the collection.

 @param index The index of the item to select.
 @param sectionController The section controller requesting this information.
 @param animated Pass `YES` to animate the change, `NO` otherwise.
 @param scrollPosition An option that specifies where the item should be positioned when scrolling finishes.
 */
- (void)selectItemAtIndex:(NSInteger)index
        sectionController:(IGListSectionController *)sectionController
                 animated:(BOOL)animated
           scrollPosition:(UICollectionViewScrollPosition)scrollPosition;

/**
 Dequeues a cell from the collection view reuse pool.

 @param cellClass The class of the cell you want to dequeue.
 @param reuseIdentifier A reuse identifier for the specified cell. This parameter may be `nil`.
 @param sectionController The section controller requesting this information.
 @param index The index of the cell.

 @return A cell dequeued from the reuse pool or a newly created one.

 @note This method uses a string representation of the cell class as the identifier.
 */
- (__kindof UICollectionViewCell *)dequeueReusableCellOfClass:(Class)cellClass
                                          withReuseIdentifier:(nullable NSString *)reuseIdentifier
                                         forSectionController:(IGListSectionController *)sectionController
                                                      atIndex:(NSInteger)index;

/**
 Dequeues a cell from the collection view reuse pool.

 @param cellClass The class of the cell you want to dequeue.
 @param sectionController The section controller requesting this information.
 @param index The index of the cell.

 @return A cell dequeued from the reuse pool or a newly created one.

 @note This method uses a string representation of the cell class as the identifier.
 */
- (__kindof UICollectionViewCell *)dequeueReusableCellOfClass:(Class)cellClass
                                         forSectionController:(IGListSectionController *)sectionController
                                                      atIndex:(NSInteger)index;

/**
 Dequeues a cell from the collection view reuse pool.

 @param nibName The name of the nib file.
 @param bundle The bundle in which to search for the nib file. If `nil`, this method searches the main bundle.
 @param sectionController The section controller requesting this information.
 @param index The index of the cell.

 @return A cell dequeued from the reuse pool or a newly created one.

 @note This method uses the nib name as the reuse identifier.
 */
- (__kindof UICollectionViewCell *)dequeueReusableCellWithNibName:(NSString *)nibName
                                                           bundle:(nullable NSBundle *)bundle
                                             forSectionController:(IGListSectionController *)sectionController
                                                          atIndex:(NSInteger)index;

/**
 Dequeues a storyboard prototype cell from the collection view reuse pool.

 @param identifier The identifier of the cell prototype in storyboard.
 @param sectionController The section controller requesting this information.
 @param index The index of the cell.

 @return A cell dequeued from the reuse pool or a newly created one.
 */
- (__kindof UICollectionViewCell *)dequeueReusableCellFromStoryboardWithIdentifier:(NSString *)identifier
                                                              forSectionController:(IGListSectionController *)sectionController
                                                                           atIndex:(NSInteger)index;

/**
 Dequeues a supplementary view from the collection view reuse pool.

 @param elementKind The kind of supplementary view.
 @param sectionController The section controller requesting this information.
 @param viewClass The class of the supplementary view.
 @param index The index of the supplementary view.

 @return A supplementary view dequeued from the reuse pool or a newly created one.

 @note This method uses a string representation of the view class and the kind as the identifier.
 */
- (__kindof UICollectionReusableView *)dequeueReusableSupplementaryViewOfKind:(NSString *)elementKind
                                                         forSectionController:(IGListSectionController *)sectionController
                                                                        class:(Class)viewClass
                                                                      atIndex:(NSInteger)index;

/**
 Dequeues a supplementary view from the collection view reuse pool.

 @param elementKind The kind of supplementary view.
 @param identifier The identifier of the supplementary view in storyboard.
 @param sectionController The section controller requesting this information.
 @param index The index of the supplementary view.

 @return A supplementary view dequeued from the reuse pool or a newly created one.
 */
- (__kindof UICollectionReusableView *)dequeueReusableSupplementaryViewFromStoryboardOfKind:(NSString *)elementKind
                                                                             withIdentifier:(NSString *)identifier
                                                                       forSectionController:(IGListSectionController *)sectionController
                                                                                    atIndex:(NSInteger)index;
/**
 Dequeues a supplementary view from the collection view reuse pool.

 @param elementKind The kind of supplementary view.
 @param sectionController The section controller requesting this information.
 @param nibName The name of the nib file.
 @param bundle The bundle in which to search for the nib file. If `nil`, this method searches the main bundle.
 @param index The index of the supplementary view.

 @return A supplementary view dequeued from the reuse pool or a newly created one.

 @note This method uses the nib name as the reuse identifier.
 */
- (__kindof UICollectionReusableView *)dequeueReusableSupplementaryViewOfKind:(NSString *)elementKind
                                                         forSectionController:(IGListSectionController *)sectionController
                                                                      nibName:(NSString *)nibName
                                                                       bundle:(nullable NSBundle *)bundle
                                                                      atIndex:(NSInteger)index;

/**
 Invalidate the backing `UICollectionViewLayout` for all items in the section controller.

 @param sectionController The section controller that needs invalidating.
 @param completion An optional completion block to execute when the updates are finished.

 @note This method can be wrapped in `UIView` animation APIs to control the duration or perform without animations. This
 will end up calling `-[UICollectionView performBatchUpdates:completion:]` internally, so invalidated changes may not be
 reflected in the cells immediately.
 */
- (void)invalidateLayoutForSectionController:(IGListSectionController *)sectionController
                                  completion:(nullable void (^)(BOOL finished))completion;

/**
 Returns the layout attributes for the item at the specified index in the section controller.

 @param index The index of the item whose layout attributes are requested.
 @param sectionController The section controller requesting this information.

 @return The layout attributes for the item, or `nil` if the item is not found.
 */
- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndex:(NSInteger)index
                                                            sectionController:(IGListSectionController *)sectionController;
/**
 Batches and performs many cell-level updates in a single transaction.

 @param animated A flag indicating if the transition should be animated.
 @param updates A block with a context parameter to make mutations.
 @param completion An optional completion block to execute when the updates are finished.

 @note You should make state changes that impact the number of items in your section controller within the updates
 block alongside changes on the context object.

 For example, inside your section controllers, you may want to delete *and* insert into the data source that backs your
 section controller. For example:

 ```
 [self.collectionContext performBatchItemUpdates:^ (id<IGListBatchContext> batchContext>){
   // perform data source changes inside the update block
   [self.items addObject:newItem];
   [self.items removeObjectAtIndex:0];

   NSIndexSet *inserts = [NSIndexSet indexSetWithIndex:[self.items count] - 1];
   [batchContext insertInSectionController:self atIndexes:inserts];

   NSIndexSet *deletes = [NSIndexSet indexSetWithIndex:0];
   [batchContext deleteInSectionController:self atIndexes:deletes];
 } completion:nil];
 ```

 @warning You **must** perform data modifications **inside** the update block. Updates will not be performed
 synchronously, so you should make sure that your data source changes only when necessary.
 */
- (void)performBatchAnimated:(BOOL)animated
                     updates:(void (^)(id<IGListBatchContext> batchContext))updates
                  completion:(nullable void (^)(BOOL finished))completion;


/**
 Scrolls to the specified section controller in the list.

 @param sectionController The section controller.
 @param index The index of the item in the section controller to which to scroll.
 @param scrollPosition An option that specifies where the item should be positioned when scrolling finishes.
 @param animated A flag indicating if the scrolling should be animated.
 */
- (void)scrollToSectionController:(IGListSectionController *)sectionController
                          atIndex:(NSInteger)index
                   scrollPosition:(UICollectionViewScrollPosition)scrollPosition
                         animated:(BOOL)animated;

/**
 Returns the index path of the item at the specified point in the collection view.

 @param point The point in the collection view's coordinate system.

 @return The index path of the item at the specified point, or `nil` if no item is found at that location.
 */
- (nullable NSIndexPath *)indexPathForItemAtPoint:(CGPoint)point;

/**
 Converts a point from the coordinate system of a given view to that of the collection view.

 @param point The point to convert.
 @param view The view from which the point originates. If `nil`, the point is assumed to be in the window's coordinate system.

 @return The converted point in the collection view's coordinate system.
 */
- (CGPoint)convertPoint:(CGPoint)point fromView:(nullable UIView *)view;


@end

NS_ASSUME_NONNULL_END
