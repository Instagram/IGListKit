/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

@class IGListTransitionData;
@protocol IGListDiffable;

NS_ASSUME_NONNULL_BEGIN

/**
 A completion block to execute when updates are finished.

 @param finished Specifies whether or not the update finished.
 */
NS_SWIFT_NAME(ListUpdatingCompletion)
typedef void (^IGListUpdatingCompletion)(BOOL finished);

/**
 A block to be called when the adapter applies changes to the collection view.

 @param toObjects The new objects in the collection.
 */
NS_SWIFT_NAME(ListObjectTransitionBlock)
typedef void (^IGListObjectTransitionBlock)(NSArray *toObjects);

/// A block that contains all of the updates.
NS_SWIFT_NAME(ListItemUpdateBlock)
typedef void (^IGListItemUpdateBlock)(void);

/// A block to be called when an adapter reloads the collection view.
NS_SWIFT_NAME(ListReloadUpdateBlock)
typedef void (^IGListReloadUpdateBlock)(void);

/// A block that returns an array of objects to transition to.
NS_SWIFT_NAME(ListToObjectBlock)
typedef NSArray * _Nullable (^IGListToObjectBlock)(void);

/// A block that returns a collection view to perform updates on.
NS_SWIFT_NAME(ListCollectionViewBlock)
typedef UICollectionView * _Nullable (^IGListCollectionViewBlock)(void);

/// A block that applies a `UICollectionView` dataSource change
NS_SWIFT_NAME(ListDataSourceChangeBlock)
typedef void (^IGListDataSourceChangeBlock)(void);

/// A block that returns the `IGListTransitionData` needed before an update.
NS_SWIFT_NAME(ListTransitionDataBlock)
typedef IGListTransitionData * _Nullable (^IGListTransitionDataBlock)(void);

/**
 A block to be called when the adapter applies changes to the collection view.

 @param data The new data that contains the from/to objects.
 */
NS_SWIFT_NAME(ListTransitionDataApplyBlock)
typedef void (^IGListTransitionDataApplyBlock)(IGListTransitionData *data);

/**
 Implement this protocol in order to handle both section and row based update events. Implementation should forward or
 coalesce these events to a backing store or collection.
 */
NS_SWIFT_NAME(ListUpdatingDelegate)
@protocol IGListUpdatingDelegate <NSObject>

/**
 Asks the delegate for the pointer functions for looking up an object in a collection.

 @return Pointer functions for looking up an object in a collection.

 @note Since the updating delegate is responsible for transitioning between object sets, it becomes the "source of
 truth" for how objects and their corresponding section controllers are mapped. This allows the updater to control if
 objects are looked up by pointer, or more traditionally, with `-hash`/`-isEqual`.

 For behavior similar to `NSDictionary`, simply return
 `+[NSPointerFunctions pointerFunctionsWithOptions:NSPointerFunctionsObjectPersonality]`.
 */
- (NSPointerFunctions *)objectLookupPointerFunctions;

/**
 Perform a **section** update from an old array of objects to a new one.

 @param collectionViewBlock A block returning the collecion view to perform updates on.
 @param animated A flag indicating if the transition should be animated.
 @param sectionDataBlock  A block that returns the section information (ex: from and to objects)
 @param applySectionDataBlock A block that must be called when the adapter applies changes to the collection view.
 @param completion A completion block to execute when the update is finished.

 @note Implementations determine how to transition between objects. You can perform a diff on the objects, reload
 each section, or simply call `-reloadData` on the collection view. In the end, the collection view must be setup with a
 section for each object in the `toObjects` array.

 The `applySectionDataBlock` block should be called prior to making any `UICollectionView` updates, passing in the `toObjects`
 that the updater is applying.
 */
- (void)performUpdateWithCollectionViewBlock:(IGListCollectionViewBlock)collectionViewBlock
                                    animated:(BOOL)animated
                            sectionDataBlock:(IGListTransitionDataBlock)sectionDataBlock
                       applySectionDataBlock:(IGListTransitionDataApplyBlock)applySectionDataBlock
                                  completion:(nullable IGListUpdatingCompletion)completion;

/**
 Perform an **item** update block in the collection view.

 @param collectionViewBlock A block returning the collecion view to perform updates on.
 @param animated A flag indicating if the transition should be animated.
 @param itemUpdates A block containing all of the updates.
 @param completion A completion block to execute when the update is finished.
 */
- (void)performUpdateWithCollectionViewBlock:(IGListCollectionViewBlock)collectionViewBlock
                                    animated:(BOOL)animated
                                 itemUpdates:(IGListItemUpdateBlock)itemUpdates
                                  completion:(nullable IGListUpdatingCompletion)completion;

/**
 Perform a `[UICollectionView setDataSource:...]` swap within this block. It gives the updater the chance to cancel or
 execute any on-going updates. The block should be executed synchronously.

 @param block The block that will actuallty change the `dataSource`
 */
- (void)performDataSourceChange:(IGListDataSourceChangeBlock)block;

/**
 Completely reload data in the collection.

 @param collectionViewBlock A block returning the collecion view to reload.
 @param reloadUpdateBlock A block that must be called when the adapter reloads the collection view.
 @param completion A completion block to execute when the reload is finished.
 */
- (void)reloadDataWithCollectionViewBlock:(IGListCollectionViewBlock)collectionViewBlock
                        reloadUpdateBlock:(IGListReloadUpdateBlock)reloadUpdateBlock
                               completion:(nullable IGListUpdatingCompletion)completion;

/**
 Tells the delegate to perform item inserts at the given index paths.

 @param collectionView The collection view on which to perform the transition.
 @param indexPaths The index paths to insert items into.
 */
- (void)insertItemsIntoCollectionView:(UICollectionView *)collectionView indexPaths:(NSArray <NSIndexPath *> *)indexPaths;

/**
 Tells the delegate to perform item deletes at the given index paths.

 @param collectionView The collection view on which to perform the transition.
 @param indexPaths The index paths to delete items from.
 */
- (void)deleteItemsFromCollectionView:(UICollectionView *)collectionView indexPaths:(NSArray <NSIndexPath *> *)indexPaths;

/**
 Tells the delegate to move an item from and to given index paths.

 @param collectionView The collection view on which to perform the transition.
 @param fromIndexPath The source index path of the item to move.
 @param toIndexPath The destination index path of the item to move.
 */
- (void)moveItemInCollectionView:(UICollectionView *)collectionView
                   fromIndexPath:(NSIndexPath *)fromIndexPath
                     toIndexPath:(NSIndexPath *)toIndexPath;

/**
 Tells the delegate to reload an item from and to given index paths.

 @param collectionView The collection view on which to perform the transition.
 @param fromIndexPath The source index path of the item to reload.
 @param toIndexPath The destination index path of the item to reload.

 @note Since UICollectionView is unable to handle calling -[UICollectionView reloadItemsAtIndexPaths:] safely while also
 executing insert and delete operations in the same batch updates, the updater must know about the origin and
 destination of the reload to perform a safe transition.
 */
- (void)reloadItemInCollectionView:(UICollectionView *)collectionView
                     fromIndexPath:(NSIndexPath *)fromIndexPath
                       toIndexPath:(NSIndexPath *)toIndexPath;

/**
 Tells the delegate to move a section from and to given indexes.

 @param collectionView The collection view on which to perform the transition.
 @param fromIndex The source index of the section to move.
 @param toIndex The destination index of the section to move.
 */
- (void)moveSectionInCollectionView:(UICollectionView *)collectionView
                          fromIndex:(NSInteger)fromIndex
                            toIndex:(NSInteger)toIndex;

/**
 Completely reload each section in the collection view.

 @param collectionView The collection view to reload.
 @param sections The sections to reload.
 */
- (void)reloadCollectionView:(UICollectionView *)collectionView sections:(NSIndexSet *)sections;

/**
 True if the updater is currently updating the source of truth, like executing applySectionDataBlock and
 itemUpdates just before updating the UICollectionView.
 */
- (BOOL)isInDataUpdateBlock;

@end

NS_ASSUME_NONNULL_END
