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
#import <IGListKit/IGListSectionType.h>
#import <IGListKit/IGListMacros.h>

@protocol IGListUpdatingDelegate;

@class IGListSectionController;

NS_ASSUME_NONNULL_BEGIN

typedef void (^IGListUpdaterCompletion)(BOOL finished);

/**
 IGListAdapter objects provide an abstraction for feeds of objects in a UICollectionView by breaking each object into
 individual sections, called "section controllers". These controllers (objects conforming to IGListSectionType) act as a
 data source and delegate for each section.

 Feed implementations must act as the data source for an IGListAdapter in order to drive the objects and section
 controllers in a collection view.
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
 The object that receives top-level events for section controllers.
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
 @param workingRangeSize The number of objects before and after the viewport to consider within the working range.

 @return A new IGListAdapter object.

 @discussion The working range is the number of objects beyond the visible objects (plus and minus) that should be
 notified when they are close to being visible. For instance, if you have 3 objects on screen and a working range of 2,
 the previous and succeeding 2 objects will be notified that they are within the working range. As you scroll the list
 the range is updated as objects enter and exit the working range.

 To opt out of using the working range, you can provide a value of 0.
 */
- (instancetype)initWithUpdater:(id <IGListUpdatingDelegate>)updatingDelegate
                 viewController:(nullable UIViewController *)viewController
               workingRangeSize:(NSUInteger)workingRangeSize NS_DESIGNATED_INITIALIZER;

/**
 Perform an update from the previous state of the data source. This is analagous to calling
 -[UICollectionView performBatchUpdates:completion:].

 @param animated   A flag indicating if the transition should be animated.
 @param completion A block executed when the update completes.
 */
- (void)performUpdatesAnimated:(BOOL)animated completion:(nullable IGListUpdaterCompletion)completion;

/**
 Perform an immediate reload of the data in the data source, discarding the old objectss.

 @param completion A block executed when the reload completes.
 */
- (void)reloadDataWithCompletion:(nullable IGListUpdaterCompletion)completion;

/**
 Reload the infra for specific objectss only.

 @param objects The objects to reload.
 */
- (void)reloadObjects:(NSArray *)objects;

/**
 Query the section index of a list. Constant time lookup.

 @param sectionController A list object.

 @return The section index of the list or NSNotFound.
 */
- (NSUInteger)sectionForSectionController:(IGListSectionController <IGListSectionType> *)sectionController;

/**
 Fetch an section controller for an object in the feed. Constant time lookup.

 @param object An object from the data source.

 @return An section controller or nil.

 @see -[IGListAdapterDataSource listAdapter:sectionControllerForObject:]
 */
- (__kindof IGListSectionController <IGListSectionType> * _Nullable)sectionControllerForObject:(id)object;

/**
 Fetch the object corresponding to a section in the feed. Constant time lookup.

 @param section A section in the feed.

 @return An object or nil.
 */
- (nullable id)objectAtSection:(NSUInteger)section;

/**
 Fetch the section corresponding to an object in the feed. Constant time lookup.

 @param object An object in the feed

 @return A section index if found or NSNotFound.
 */
- (NSUInteger)sectionForObject:(id)object;

/**
 A copy of all the objects currently powering the adapter.

 @return An array of objects.
 */
- (NSArray *)objects;

/**
 An unordered array of the currently visible section controllers.

 @return An array of section controllers.
 */
- (NSArray<IGListSectionController<IGListSectionType> *> *)visibleSectionControllers;

/**
 Scroll to an object in the list adapter.

 @param object             The object to scroll to.
 @param supplementaryKinds The types of supplementary views in the section.
 @param scrollDirection    A flag indicating the direction to scroll.
 @param animated           A flag indicating if the transition should be animated.
 */
- (void)scrollToObject:(id)object
    supplementaryKinds:(nullable NSArray<NSString *> *)supplementaryKinds
       scrollDirection:(UICollectionViewScrollDirection)scrollDirection
              animated:(BOOL)animated;

/**
 Query the size of a cell at the specified index path.

 @param indexPath The index path of the cell.

 @return The size of the cell.
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
