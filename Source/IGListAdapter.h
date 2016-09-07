/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant 
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

#import <IGListKit/IGListAdapterDataSource.h>
#import <IGListKit/IGListAdapterDelegate.h>
#import <IGListKit/IGListCollectionContext.h>
#import <IGListKit/IGListCollectionView.h>
#import <IGListKit/IGListExperiments.h>
#import <IGListKit/IGListItemType.h>
#import <IGListKit/IGListMacros.h>

@protocol IGListUpdatingDelegate;

@class IGListItemController;

NS_ASSUME_NONNULL_BEGIN

typedef void (^IGListUpdaterCompletion)(BOOL finished);

/**
 IGListAdapter objects provide an abstraction for feeds of objects in a UICollectionView by breaking each object into
 individual sections, called "list items". These items (objects conforming to IGListItemType) act as a data source
 and delegate for each section.

 Feed implementations must act as the data source for an IGListAdapter in order to drive the objects and list items in a
 collection view.
 */
IGLK_SUBCLASSING_RESTRICTED
@interface IGListAdapter : NSObject

/**
 The view controller that houses the adapter.
 */
@property (nonatomic, nullable, weak) UIViewController *viewController;

/**
 The collection view used with the adapter.
 */
@property (nonatomic, nullable, weak) IGListCollectionView *collectionView;

/**
 The object that acts as the data source for the list adapter.
 */
@property (nonatomic, nullable, weak) id <IGListAdapterDataSource> dataSource;

/**
 The object that receives high level display events for list items.
 */
@property (nonatomic, nullable, weak) id <IGListAdapterDelegate> delegate;

/**
 The object that receives UICollectionViewDelegate events.

 @discussion This object /will not/ receive UIScrollViewDelegate events. Instead use scrollViewDelegate.
 */
@property (nonatomic, nullable, weak) id <UICollectionViewDelegate> collectionViewDelegate;

/**
 The object that receives UIScrollViewDelegate events.
 */
@property (nonatomic, nullable, weak) id <UIScrollViewDelegate> scrollViewDelegate;

/**
 A bitmask of experiments to conduct on the adapter.
 */
@property (nonatomic, assign) IGListExperiment experiments;

/**
 Initialize a new IGListAdapter object with a collection view, data source, and updating delegate.

 @param updatingDelegate An object that manages updates to the UICollectionView.
 @param viewController   The view controller that will house the adapter.
 @param workingRangeSize The number of items before and after the viewport to consider within the working range.

 @return A new IGListAdapter object.

 @discussion The working range is the number of items beyond the visible items (plus and minus) that should be notified
 when they are close to being visible. For instance, if you have 3 items on screen and a working range of 2, the
 previous and succeeding 2 items will be notified that they are within the working range. As you scroll the list the
 range is updated as items enter and exit the working range.

 To opt out of using the working range, you can provide a value of 0.
 */
- (instancetype)initWithUpdatingDelegate:(id <IGListUpdatingDelegate>)updatingDelegate
                          viewController:(nullable UIViewController *)viewController
                        workingRangeSize:(NSUInteger)workingRangeSize NS_DESIGNATED_INITIALIZER;

#pragma mark - Editing

/**
 Perform an update from the previous state of the data source. This is analagous to calling
 -[UICollectionView performBatchUpdates:completion:].

 @param animated   A flag indicating if the transition should be animated.
 @param completion A block executed when the update completes.
 */
- (void)performUpdatesAnimated:(BOOL)animated completion:(nullable IGListUpdaterCompletion)completion;

/**
 Perform an immediate reload of the data in the data source, discarding the old items.

 @param completion A block executed when the reload completes.
 */
- (void)reloadDataWithCompletion:(nullable IGListUpdaterCompletion)completion;

/**
 Reload the infra for specific items only.

 @param items The items to reload.
 */
- (void)reloadItems:(NSArray *)items;


#pragma mark - Items & Sections

/**
 Query the section index of a list. Constant time lookup.

 @param itemController A list object.

 @return The section index of the list or NSNotFound.
 */
- (NSUInteger)sectionForItemController:(IGListItemController <IGListItemType> *)itemController;

/**
 Fetch an item controller for an object in the feed. Constant time lookup.

 @param item An item from the data source.

 @return An item controller or nil.

 @see -[IGListAdapterDataSource listAdapter:itemControllerForItem:]
 */
- (__kindof IGListItemController <IGListItemType> * _Nullable)itemControllerForItem:(id)item;

/**
 Fetch the item corresponding to a section in the feed. Constant time lookup.

 @param section A section in the feed.

 @return An item or nil.
 */
- (nullable id)itemAtSection:(NSUInteger)section;

/**
 Fetch the section corresponding to an item in the feed. Constant time lookup.

 @param item An item in the feed

 @return A section index if found or NSNotFound.
 */
- (NSUInteger)sectionForItem:(id)item;

/**
 A copy of all the items currently powering the adapter.

 @return An array of items.
 */
- (NSArray *)items;

/**
 An unordered array of the currently visible item controllers.

 @return An array of item controllers.
 */
- (NSArray<IGListItemController<IGListItemType> *> *)visibleItemControllers;


#pragma mark - UICollectionView

/**
 Scroll to an item in the list adapter.

 @param item               The item to scroll to.
 @param supplementaryKinds The types of supplementary views in the section.
 @param scrollDirection    A flag indicating the direction to scroll.
 @param animated           A flag indicating if the transition should be animated.
 */
- (void)scrollToItem:(id)item
  supplementaryKinds:(nullable NSArray<NSString *> *)supplementaryKinds
     scrollDirection:(UICollectionViewScrollDirection)scrollDirection
            animated:(BOOL)animated;


#pragma mark - Layout

/**
 Query the size of an item in the list at the specified index path.

 @param indexPath The index path of the item.

 @return The size of the item.
 */
- (CGSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 Query the size of a supplementary view in the list at the specified index path.

 @param elementKind The kind of supplementary view.
 @param indexPath   The index path of the supplementary view.

 @return The size of the supplementary view.
 */
- (CGSize)sizeForSupplementaryViewOfKind:(NSString *)elementKind
                             atIndexPath:(NSIndexPath *)indexPath;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
