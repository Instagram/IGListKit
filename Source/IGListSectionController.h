/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

#import <IGListKit/IGListCollectionContext.h>
#import <IGListKit/IGListDisplayDelegate.h>
#import <IGListKit/IGListScrollDelegate.h>
#import <IGListKit/IGListSupplementaryViewSource.h>
#import <IGListKit/IGListWorkingRangeDelegate.h>
#import <IGListKit/IGListTransitionDelegate.h>

NS_ASSUME_NONNULL_BEGIN

/**
 The base class for section controllers used in a list. This class is intended to be subclassed.
 */
NS_SWIFT_NAME(ListSectionController)
@interface IGListSectionController : NSObject

/**
 Returns the number of items in the section.

 @return A count of items in the list.

 @note The count returned is used to drive the number of cells displayed for this section controller. The default 
 implementation returns 1. **Calling super is not required.**
 */
- (NSInteger)numberOfItems;

/**
 The specific size for the item at the specified index.

 @param index The row index of the item.

 @return The size for the item at index.

 @note The returned size is not guaranteed to be used. The implementation may query sections for their
 layout information at will, or use its own layout metrics. For example, consider a dynamic-text sized list versus a
 fixed height-and-width grid. The former will ask each section for a size, and the latter will likely not. The default
 implementation returns size zero. **Calling super is not required.**
 */
- (CGSize)sizeForItemAtIndex:(NSInteger)index;

/**
 Return a dequeued cell for a given index.

 @param index The index of the requested row.

 @return A configured `UICollectionViewCell` subclass.

 @note This is your opportunity to do any cell setup and configuration. The infrastructure requests a cell when it
 will be used on screen. You should never allocate new cells in this method, instead use the provided adapter to call
 one of the dequeue methods on the IGListCollectionContext. The default implementation will assert. **You must override
 this method without calling super.**
 */
- (__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index;

/**
 Updates the section controller to a new object.

 @param object The object mapped to this section controller.

 @note When this method is called, all available contexts and configurations have been set for the section
 controller. This method will only be called when the object instance has changed, including from `nil` or a previous
 object. **Calling super is not required.**
 */
- (void)didUpdateToObject:(id)object;

/**
 Tells the section controller that the cell at the specified index path was selected.

 @param index The index of the selected cell.

 @note The default implementation does nothing. **Calling super is not required.**
 */
- (void)didSelectItemAtIndex:(NSInteger)index;

/**
 Tells the section controller that the cell at the specified index path was deselected.

 @param index The index of the deselected cell.

 @note The default implementation does nothing. **Calling super is not required.**
 */
- (void)didDeselectItemAtIndex:(NSInteger)index;

/**
 Tells the section controller that the cell at the specified index path was highlighted.

 @param index The index of the highlighted cell.

 @note The default implementation does nothing. **Calling super is not required.**
 */
- (void)didHighlightItemAtIndex:(NSInteger)index;

/**
 Tells the section controller that the cell at the specified index path was unhighlighted.

 @param index The index of the unhighlighted cell.

 @note The default implementation does nothing. **Calling super is not required.**
 */
- (void)didUnhighlightItemAtIndex:(NSInteger)index;
    
/**
 Identifies whether an object can be moved through interactive reordering.
 
 @param index The index of the unhighlighted cell.
 
 @note Interactive reordering is supported both for items within a single section, as well as for reordering sections
 themselves when sections contain only one item. The default implementation returns false.
 */
- (BOOL)canMoveItemAtIndex:(NSInteger)index;

/**
 Notifies the section that a list object should move within a section as the result of interactive reordering.
 
 @param sourceIndex The starting index of the object.
 @param destinationIndex The ending index of the object.
 
 @note this method must be implemented if interactive reordering is enabled.
 */
- (void)moveObjectFromIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex NS_AVAILABLE_IOS(9_0);
    
/**
 The view controller housing the adapter that created this section controller.

 @note Use this view controller to push, pop, present, or do other custom transitions. 
 
 @warning It is considered very bad practice to cast this to a known view controller 
 and call methods on it other than for navigations and transitions.
 */
@property (nonatomic, weak, nullable, readonly) UIViewController *viewController;

/**
 A context object for interacting with the collection. 
 
 Use this property for accessing the collection size, dequeuing cells, reloading, inserting, deleting, etc.
 */
@property (nonatomic, weak, nullable, readonly) id <IGListCollectionContext> collectionContext;

/**
 Returns the section within the list for this section controller.

 @note This value also relates to the section within a `UICollectionView` that this section controller's cells belong.
 It also relates to the `-[NSIndexPath section]` value for individual cells within the collection view.
 */
@property (nonatomic, assign, readonly) NSInteger section;

/**
 Returns `YES` if the section controller is the first section in the list, `NO` otherwise.
 */
@property (nonatomic, assign, readonly) BOOL isFirstSection;

/**
 Returns `YES` if the section controller is the last section in the list, `NO` otherwise.
 */
@property (nonatomic, assign, readonly) BOOL isLastSection;

/**
 The margins used to lay out content in the section controller.

 @see `-[UICollectionViewFlowLayout sectionInset]`.
 */
@property (nonatomic, assign) UIEdgeInsets inset;

/**
 The minimum spacing to use between rows of items.

 @see `-[UICollectionViewFlowLayout minimumLineSpacing]`.
 */
@property (nonatomic, assign) CGFloat minimumLineSpacing;

/**
 The minimum spacing to use between items in the same row.

 @see `-[UICollectionViewFlowLayout minimumInteritemSpacing]`.
 */
@property (nonatomic, assign) CGFloat minimumInteritemSpacing;

/**
 The supplementary view source for the section controller. Can be `nil`.

 @return An object that conforms to `IGListSupplementaryViewSource` or `nil`.

 @note You may wish to return `self` if your section controller implements this protocol.
 */
@property (nonatomic, weak, nullable) id <IGListSupplementaryViewSource> supplementaryViewSource;

/**
 An object that handles display events for the section controller. Can be `nil`.

 @return An object that conforms to `IGListDisplayDelegate` or `nil`.

 @note You may wish to return `self` if your section controller implements this protocol.
 */
@property (nonatomic, weak, nullable) id <IGListDisplayDelegate> displayDelegate;

/**
 An object that handles working range events for the section controller. Can be `nil`.

 @return An object that conforms to `IGListWorkingRangeDelegate` or `nil`.

 @note You may wish to return `self` if your section controller implements this protocol.
 */
@property (nonatomic, weak, nullable) id <IGListWorkingRangeDelegate> workingRangeDelegate;

/**
 An object that handles scroll events for the section controller. Can be `nil`.

 @return An object that conforms to `IGListScrollDelegate` or `nil`.

 @note You may wish to return `self` if your section controller implements this protocol.
 */
@property (nonatomic, weak, nullable) id <IGListScrollDelegate> scrollDelegate;

/**
 An object that handles transition events for the section controller. Can be `nil`.

 @return An object that conforms to `IGListTransitionDelegat` or `nil`.

 @note You may wish to return `self` if your section controller implements this protocol.
 */
@property (nonatomic, weak, nullable) id<IGListTransitionDelegate> transitionDelegate;

@end

NS_ASSUME_NONNULL_END
