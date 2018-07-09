/**
 * Copyright (c) 2016-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

#import <IGListKit/IGListAdapterDataSource.h>
#import <IGListKit/IGListAdapterDelegate.h>
#import <IGListKit/IGListAdapterMoveDelegate.h>
#import <IGListKit/IGListCollectionContext.h>
#import <IGListKit/IGListAdapterUpdateListener.h>

#import <IGListKit/IGListExperiments.h>
#import <IGListKit/IGListMacros.h>

@protocol IGListUpdatingDelegate;

@class IGListSectionController;

NS_ASSUME_NONNULL_BEGIN

/**
 A block to execute when the list updates are completed.

 @param finished Specifies whether or not the update animations completed successfully.
 */
NS_SWIFT_NAME(ListUpdaterCompletion)
typedef void (^IGListUpdaterCompletion)(BOOL finished);

/**
 `IGListAdapter` objects provide an abstraction for feeds of objects in a `UICollectionView` by breaking each object 
 into individual sections, called "section controllers". These controllers (objects subclassing to 
 `IGListSectionController`) act as a data source and delegate for each section.

 Feed implementations must act as the data source for an `IGListAdapter` in order to drive the objects and section
 controllers in a collection view.
 */
IGLK_SUBCLASSING_RESTRICTED
NS_SWIFT_NAME(ListAdapter)
@interface IGListAdapter : NSObject

/**
 The view controller that houses the adapter.
 */
@property (nonatomic, nullable, weak) UIViewController *viewController;

/**
 The collection view used with the adapter.

 @note Setting this property will automatically set isPrefetchingEnabled to `NO` for performance reasons.
 */
@property (nonatomic, nullable, weak) UICollectionView *collectionView;

/**
 The object that acts as the data source for the adapter.
 */
@property (nonatomic, nullable, weak) id <IGListAdapterDataSource> dataSource;

/**
 The object that receives top-level events for section controllers.
 */
@property (nonatomic, nullable, weak) id <IGListAdapterDelegate> delegate;

/**
 The object that receives `UICollectionViewDelegate` events.

 @note This object *will not* receive `UIScrollViewDelegate` events. Instead use scrollViewDelegate.
 */
@property (nonatomic, nullable, weak) id <UICollectionViewDelegate> collectionViewDelegate;

/**
 The object that receives `UIScrollViewDelegate` events.
 */
@property (nonatomic, nullable, weak) id <UIScrollViewDelegate> scrollViewDelegate;

/**
 The object that receives `IGListAdapterMoveDelegate` events resulting from interactive reordering of sections.

 @note This works with UICollectionView interactive reordering available on iOS 9.0+
 */
@property (nonatomic, nullable, weak) id <IGListAdapterMoveDelegate> moveDelegate NS_AVAILABLE_IOS(9_0);

/**
 The updater for the adapter.
 */
@property (nonatomic, strong, readonly) id <IGListUpdatingDelegate> updater;

/**
 A bitmask of experiments to conduct on the adapter.
 */
@property (nonatomic, assign) IGListExperiment experiments;

/**
 Initializes a new `IGListAdapter` object.

 @param updater An object that manages updates to the collection view.
 @param viewController The view controller that will house the adapter.
 @param workingRangeSize The number of objects before and after the viewport to consider within the working range.

 @return A new list adapter object.

 @note The working range is the number of objects beyond the visible objects (plus and minus) that should be
 notified when they are close to being visible. For instance, if you have 3 objects on screen and a working range of 2,
 the previous and succeeding 2 objects will be notified that they are within the working range. As you scroll the list
 the range is updated as objects enter and exit the working range.

 To opt out of using the working range, use `initWithUpdater:viewController:` or provide a working range of `0`.
 */
- (instancetype)initWithUpdater:(id <IGListUpdatingDelegate>)updater
                 viewController:(nullable UIViewController *)viewController
               workingRangeSize:(NSInteger)workingRangeSize NS_DESIGNATED_INITIALIZER;

/**
 Initializes a new `IGListAdapter` object with a working range of `0`.
 
 @param updater An object that manages updates to the collection view.
 @param viewController The view controller that will house the adapter.
 
 @return A new list adapter object.
 */
- (instancetype)initWithUpdater:(id <IGListUpdatingDelegate>)updater
                 viewController:(nullable UIViewController *)viewController;

/**
 Perform an update from the previous state of the data source. This is analogous to calling
 `-[UICollectionView performBatchUpdates:completion:]`.

 @param animated A flag indicating if the transition should be animated.
 @param completion The block to execute when the updates complete.
 */
- (void)performUpdatesAnimated:(BOOL)animated completion:(nullable IGListUpdaterCompletion)completion;

/**
 Perform an immediate reload of the data in the data source, discarding the old objects.

 @param completion The block to execute when the reload completes.

 @warning Do not use this method to update without animations as it can be very expensive to teardown and rebuild all
 section controllers. Use `-[IGListAdapter performUpdatesAnimated:completion]` instead.
 */
- (void)reloadDataWithCompletion:(nullable IGListUpdaterCompletion)completion;

/**
 Reload the list for only the specified objects.

 @param objects The objects to reload.
 */
- (void)reloadObjects:(NSArray *)objects;

/**
 Query the section controller at a given section index. Constant time lookup.
 
 @param section A section in the list.

 @return A section controller or `nil` if the section does not exist.
 */
- (nullable IGListSectionController *)sectionControllerForSection:(NSInteger)section;

/**
 Query the section index of a list. Constant time lookup.

 @param sectionController A list object.

 @return The section index of the list if it exists, otherwise `NSNotFound`.
 */
- (NSInteger)sectionForSectionController:(IGListSectionController *)sectionController;

/**
 Returns the section controller for the specified object. Constant time lookup.

 @param object An object from the data source.

 @return A section controller or `nil` if `object` is not in the list.

 @see `-[IGListAdapterDataSource listAdapter:sectionControllerForObject:]`
 */
- (__kindof IGListSectionController * _Nullable)sectionControllerForObject:(id)object;

/**
 Returns the object corresponding to the specified section controller in the list. Constant time lookup.
 
 @param sectionController A section controller in the list.
 
 @return The object for the specified section controller, or `nil` if not found.
 */
- (nullable id)objectForSectionController:(IGListSectionController *)sectionController;

/**
 Returns the object corresponding to a section in the list. Constant time lookup.

 @param section A section in the list.

 @return The object for the specified section, or `nil` if the section does not exist.
 */
- (nullable id)objectAtSection:(NSInteger)section;

/**
 Returns the section corresponding to the specified object in the list. Constant time lookup.

 @param object An object in the list.

 @return The section index of `object` if found, otherwise `NSNotFound`.
 */
- (NSInteger)sectionForObject:(id)object;

/**
 Returns a copy of all the objects currently driving the adapter.

 @return An array of objects.
 */
- (NSArray *)objects;

/**
 An unordered array of the currently visible section controllers.

 @return An array of section controllers.
 */
- (NSArray<IGListSectionController *> *)visibleSectionControllers;

/**
 An unordered array of the currently visible objects.

 @return An array of objects
 */
- (NSArray *)visibleObjects;

/**
 An unordered array of the currently visible cells for a given object.
 
 @param object An object in the list
 
 @return An array of collection view cells.
 */
- (NSArray<UICollectionViewCell *> *)visibleCellsForObject:(id)object;

/**
 Scrolls to the specified object in the list adapter.

 @param object The object to which to scroll.
 @param supplementaryKinds The types of supplementary views in the section.
 @param scrollDirection An option indicating the direction to scroll.
 @param scrollPosition An option that specifies where the item should be positioned when scrolling finishes.
 @param animated A flag indicating if the scrolling should be animated.
 */
- (void)scrollToObject:(id)object
    supplementaryKinds:(nullable NSArray<NSString *> *)supplementaryKinds
       scrollDirection:(UICollectionViewScrollDirection)scrollDirection
        scrollPosition:(UICollectionViewScrollPosition)scrollPosition
              animated:(BOOL)animated;

/**
 Returns the size of a cell at the specified index path.

 @param indexPath The index path of the cell.

 @return The size of the cell.
 */
- (CGSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 Returns the size of a supplementary view in the list at the specified index path.

 @param elementKind The kind of supplementary view.
 @param indexPath The index path of the supplementary view.

 @return The size of the supplementary view.
 */
- (CGSize)sizeForSupplementaryViewOfKind:(NSString *)elementKind
                             atIndexPath:(NSIndexPath *)indexPath;

/**
 Adds a listener to the list adapter.

 @param updateListener The object conforming to the `IGListAdapterUpdateListener` protocol.

 @note Listeners are held weakly so there is no need to call `-[IGListAdapter removeUpdateListener:]` on `dealloc`.
 */
- (void)addUpdateListener:(id<IGListAdapterUpdateListener>)updateListener;

/**
 Removes a listener from the list adapter.

 @param updateListener The object conforming to the `IGListAdapterUpdateListener` protocol.
 */
- (void)removeUpdateListener:(id<IGListAdapterUpdateListener>)updateListener;

/**
 :nodoc:
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 :nodoc:
 */
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
