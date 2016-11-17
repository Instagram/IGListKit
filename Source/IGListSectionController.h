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

/**
 The base class for section controllers used in a list. This class is intended to be subclassed.
 */
@interface IGListSectionController : NSObject

/**
 The view controller housing the adapter that created this section controller.

 @note Use this view controller to push, pop, present, or do other custom transitions. 
 
 @warning It is considered very bad practice to cast this to a known view controller 
 and call methods on it other than for navigations and transitions.
 */
@property (nonatomic, weak, nullable, readonly) UIViewController *viewController;

/**
 A context object for interacting with the collection. 
 
 Use this property for accessing the collection size, dequeing cells, reloading, inserting, deleting, etc.
 */
@property (nonatomic, weak, nullable, readonly) id <IGListCollectionContext> collectionContext;

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
 An object that handles display events for the section controller. Can be `nil`.

 @return An object that conforms to `IGListDisplayDelegate` or `nil`.

 @note You may wish to return `self` if your section controller implements this protocol.
 */
@property (nonatomic, weak, nullable) id <IGListScrollDelegate> scrollDelegate;

@end
