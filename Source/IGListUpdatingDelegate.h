/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant 
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

@protocol IGListDiffable;

NS_ASSUME_NONNULL_BEGIN

typedef void (^IGListUpdatingCompletion)(BOOL finished);
typedef void (^IGListItemTransitionBlock)(NSArray *toItems);
typedef void (^IGListItemUpdateBlock)();
typedef void (^IGListReloadUpdateBlock)();

/**
 Implement this protocol in order to handle both section and row based update events. Implementation should forward or
 coalesce these events to a backing store or collection.
 */
@protocol IGListUpdatingDelegate

/**
 Asks the delegate for the pointer functions for looking up an item in a collection.

 @return Pointer functions for looking up an object in a collection.

 @discussion Since the updating delegate is responsible for transitioning between item sets, it becomes the "source of
 truth" for how items and their corresponding item controllers are mapped. This allows the updater to control if items
 are looked up by pointer, or more traditionally, with hash/isEqual.

 For behavior similar to NSDictionary, simply return
 +[NSPointerFunctions pointerFunctionsWithOptions:NSPointerFunctionsObjectPersonality].
 */
- (NSPointerFunctions *)itemLookupPointerFunctions;

/**
 Tells the delegate to perform a section transition from an old array of items to a new one.

 @param collectionView      The collection view to perform the transition on.
 @param fromItems           The previous items in the collection view. Items must conform to the IGListDiffable protocol.
 @param toItems             The new items in collection view. Items must conform to the IGListDiffable protocol.
 @param animated            A flag indicating if the transition should be animated.
 @param itemTransitionBlock A block that must be called when the adapter applies changes to the collection view.
 @param completion          A completion block to execute when the update is finished.

 @discussion Implementations determine how to transition between items. You can perform a diff on the items, reload each
 section, or simply call -reloadData on the collection view. In the end, the collection view must be setup with a
 section for each item in the toItems array.

 The `itemUpdateBlock` block should be called prior to making any UICollectionView updates, passing in the `toItems`
 that the updater is applying.
 */
- (void)performUpdateWithCollectionView:(UICollectionView *)collectionView
                              fromItems:(nullable NSArray<id <IGListDiffable>> *)fromItems
                                toItems:(nullable NSArray<id <IGListDiffable>> *)toItems
                               animated:(BOOL)animated
                    itemTransitionBlock:(IGListItemTransitionBlock)itemTransitionBlock
                             completion:(nullable IGListUpdatingCompletion)completion;

/**
 Tells the delegate to perform item inserts at the given index paths.

 @param collectionView The collection view to perform the transition on.
 @param indexPaths     The index paths to insert items into.
 */
- (void)insertItemsIntoCollectionView:(UICollectionView *)collectionView indexPaths:(NSArray <NSIndexPath *> *)indexPaths;

/**
 Tells the delegate to perform item deletes at the given index paths.

 @param collectionView The collection view to perform the transition on.
 @param indexPaths     The index paths to delete items from.
 */
- (void)deleteItemsFromCollectionView:(UICollectionView *)collectionView indexPaths:(NSArray <NSIndexPath *> *)indexPaths;

/**
 Tells the delegate to perform item reloads at the given index paths.

 @param collectionView The collection view to perform the transition on.
 @param indexPaths     The index paths of items to reload.
 */
- (void)reloadItemsInCollectionView:(UICollectionView *)collectionView indexPaths:(NSArray <NSIndexPath *> *)indexPaths;

/**
 Completely reload data in the collection.

 @param collectionView  The collection view to reload.
 @param itemUpdateBlock A block that must be called when the adapter reloads the collection view.
 @param completion      A completion block to execute when the reload is finished.
 */
- (void)reloadDataWithCollectionView:(UICollectionView *)collectionView
                     itemUpdateBlock:(IGListReloadUpdateBlock)itemUpdateBlock
                          completion:(nullable IGListUpdatingCompletion)completion;

/**
 Completely reload each section in the collection view.

 @param collectionView The collection view to reload.
 @param sections       The sections to reload.
 */
- (void)reloadCollectionView:(UICollectionView *)collectionView sections:(NSIndexSet *)sections;

/**
 Perform an item update block in the collection view.

 @param collectionView The collection view to update.
 @param animated       A flag indicating if the transition should be animated.
 @param itemUpdates    A block containing all of the updates.
 @param completion     A completion block to execute when the update is finished.
 */
- (void)performUpdateWithCollectionView:(UICollectionView *)collectionView
                               animated:(BOOL)animated
                            itemUpdates:(IGListItemUpdateBlock)itemUpdates
                             completion:(nullable IGListUpdatingCompletion)completion;

@end

NS_ASSUME_NONNULL_END
