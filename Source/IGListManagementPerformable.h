/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class UIView;

@protocol IGListManagementPerformable <NSObject>

/**
 Executes a group of updates.

 @param updates A block containing all of the updates to batch
 @param completion A block that will be called once all updates have been executed. The `BOOL` parameter indicates if any associated animations have completed succesfully: `YES` for success and `NO` if the animations were interrupted. May be `nil`.
 */
- (void)performBatchUpdates:(void (^)(void))updates
                 completion:(void (^ __nullable)(BOOL))completion;

/**
 Perform an immediate reload of the data in the data source, discarding the old objects.
 */
- (void)reloadData;

/**
 Reload the data only for the specific sections.

 @param sections Indexes of sections to reload.
 */
- (void)reloadSections:(NSIndexSet *)sections;

/**
 Insert new sections at the specified indexes.

 @param sections Indexes of the sections to insert.
 */
- (void)insertSections:(NSIndexSet *)sections;

/**
 Delete existing sections at the specified indexes.

 @param sections Indexes of the existing sections to delete.
 */
- (void)deleteSections:(NSIndexSet *)sections;

/**
 Move an existing section from one index to another final index.

 @param section Initial index for the existing section.
 @param newSection Final index for the existing section.
 */
- (void)moveSection:(NSInteger)section toSection:(NSInteger)newSection;

/**
 Indicate that new data is being added to the data source at specific index paths. This should cause any corresponding view(s) to be created.

 @param indexPaths The index paths that have newly added data.
 */
- (void)insertItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;

/**
 Reload existing data from the data source and redisplay the associated view(s).

 @param indexPaths The index paths of the existing objects that should be reloaded.
 */
- (void)reloadItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;

/**
 Indicate that existing data is being removed from the data source at specific index paths. This should cause the corresponding view(s) to be removed also.

 @param indexPaths The index paths of the objects being removed.
 */
- (void)deleteItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;

/**
 Indicate that an existing object is moving from one index path to another. This should cause any corresponding view(s) to move also.

 @param indexPath The initial index path of the object.
 @param newIndexPath The final index path of the object.
 */
- (void)moveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath;

/**
 The number of sections being represented.
 */
- (NSInteger)numberOfSections;

/**
 The number of items being represented in a given section.

 @param section The section index being queried.
 */
- (NSInteger)numberOfItemsInSection:(NSInteger)section;

/**
 The visible views of the list being represented.
 */
- (NSArray<__kindof UIView *> *)visibleCells;

/**
 The index paths of the items that have views contained within the `visibleCells` collection.
 */
- (NSArray<NSIndexPath *> *)indexPathsForVisibleItems;

/**
 The index path of the given view.

 @param cell Cell for which to get the index path.

 @return The index path of the cell or `nil` if it is not currently owned/managed by this object.
 */
- (nullable NSIndexPath *)indexPathForCell:(__kindof UIView *)cell;

/**
 The cell for a given index path.

 @param indexPath Index path for which to get the cell.

 @return The cell at the index path or `nil` if there is no cell currently owned/managed by this object.
 */
- (nullable __kindof UIView *)cellForItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 The view for the given kind at the given index path.

 @param elementKind The kind of view to retrieve.
 @param indexPath Index path for which to get the supplementary view.

 @return The cell at the index path or `nil` if there is no cell currently owned/managed by this object.
 */
- (nullable __kindof UIView *)supplementaryViewForElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath;

/**
 Scroll to the item at the index path if possible.

 @param indexPath The index path of the object to be selected and displayed.
 @param scrollPosition The position within the bounds of the displaying object should the selected object appear.
 @param animated Should any animations associated with moving the object into the requested position happen with animation or not.
 */
- (void)scrollToItemAtIndexPath:(NSIndexPath *)indexPath
               atScrollPosition:(UICollectionViewScrollPosition)scrollPosition
                       animated:(BOOL)animated;

/**
 Selects the item at the index path and will attempt to display that item if requested.

 @param indexPath The index path of the object to be selected and displayed.
 @param animated Should any animation associated with displaying the object be executed.
 @param scrollPosition The position within the bounds of the displaying object should the selected object appear.
 */
- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath
                     animated:(BOOL)animated
               scrollPosition:(UICollectionViewScrollPosition)scrollPosition;

/**
 Deselects the item at the index path.

 @param indexPath The index path of the object to be deselected.
 @param animated Should any animation associated with deselection of the object be executed.
 */
- (void)deselectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;

/**
 Registers the given Class as a reusable cell with the presenting object.

 @param cellClass Class of the cell to register with the presenting object.
 @param identifier The reuse identifier for this specific cell class. Will be used to generate new instances of the class.
 */
- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier;

/**
 Registers the given nib as a reusable cell with the presenting object.

 @param nib Nib of the cell to register with the presenting object.
 @param identifier The reuse identifier for this specific nib. Will be used to generate new instances of the cell.
 */
- (void)registerNib:(UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier;

/**
 Registers the given Class as a reusable view of the specified type with the presenting object.

 @param viewClass Class of the view to register with the presenting object.
 @param elementKind The kind of object that this class represents.
 @param identifier The reuse identifier for this specific cell class. Will be used to generate new instances of the class.
 */
- (void)registerClass:(Class)viewClass forSupplementaryViewOfKind:(NSString *)elementKind withReuseIdentifier:(NSString *)identifier;

/**
 Registers the given nib as a reusable view of the specified type with the presenting object.

 @param nib Nib of the view to register with the presenting object.
 @param kind The kind of object that this nib represents.
 @param identifier The reuse identifier for this specific nib. Will be used to generate new instances of the class.
 */
- (void)registerNib:(UINib *)nib forSupplementaryViewOfKind:(NSString *)kind withReuseIdentifier:(NSString *)identifier;

/**
 Request a fully initialized, reusable cell registered for the identifier.

 @param identifier An identifier that was used for registering either a class or nib.
 @param indexPath The index path of the current object that can be used for any additional configuration specific to the presenting object.

 @return A fully configured cell object.

 @note If the presenting object does not have a registered Class or nib for this identifier, this method should error.
 */
- (__kindof UIView *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath;

/**
 Request a fully initialized, reusable view of the type and kind registered for the identifier.

 @param elementKind The kind of view to dequeue.
 @param identifier An identifier that was used for registering either a Class or nib.
 @param indexPath The index path of the current object that can be used for any additional configuration specific to the presenting object.

 @return A fully configured view object.

 @note If the presenting object does not have a registered Class or nib for this kind and identifier, then this method should error.
 */
- (__kindof UIView *)dequeueReusableSupplementaryViewOfKind:(NSString *)elementKind withReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath;

/**
 The distance the content is inset from the containing presenting object.
 */
- (UIEdgeInsets)contentInset;

/**
 The distance from the content origin to the origin of the presenting object.
 */
- (CGPoint)contentOffset;

/**
 Update the `contentOffset` property using an animation or not.

 @param contentOffset The updated content offset value.
 @param animated Whether or not to animate the change in `contentOffset`.
 */
- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated;

/**
 The `delegate` and `dataSource` objects are intended to be used in a similar manner to that of the `UICollectionView`
 delegate and data source objects. Implementations of this protocol will need to define their own protocols for the
 `delegate` and `dataSource` objects. In general keep the following in mind:

 - The `delegate` object should be used for customizing the behavior of the presenting object. Generally it will be responsible for responding to user interaction along with potentially layout customizations.
 - The `dataSource` object is responsible for providing the data to the presenting object. This responsibility will generally include number of items and any views to be displayed.
 */
@property (nonatomic, weak, nullable) id delegate;
@property (nonatomic, weak, nullable) id dataSource;

/**
 The view to display behind all content within the presenting object.
 */
@property (nonatomic, strong, nullable) UIView *backgroundView;

/**
 A vestige of the `UICollectionView` origins of `IGListKit`. Depending on the implementation of the presenting object, this may be ignored.
 */
@property (nonatomic, strong) id collectionViewLayout;

@end

NS_ASSUME_NONNULL_END
