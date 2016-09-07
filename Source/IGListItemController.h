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
#import <IGListKit/IGListSupplementaryViewSource.h>
#import <IGListKit/IGListWorkingRangeDelegate.h>

/**
 The base class for item controllers used in the list infra. This class is meant to be subclassed.
 */
@interface IGListItemController : NSObject

/**
 The view controller housing the adapter that created this item controller.

 @discussion Use this view controller to push, pop, present, or do other custom transitions. It is considered very bad
 practice to cast this to a known view controller and call methods on it other than for navigations and transitions.
 */
@property (nonatomic, weak, nullable, readonly) UIViewController *viewController;

/**
 A context object for interacting with the collection i.e. accessing the collection size, dequeing cells,
 reloading/inserting/deleting, etc.
 */
@property (nonatomic, weak, nullable, readonly) id <IGListCollectionContext> collectionContext;

/**
 The margins used to lay out content in the item controller.

 @see -[UICollectionViewFlowLayout sectionInset]
 */
@property (nonatomic, assign) UIEdgeInsets inset;

/**
 The minimum spacing to use between rows of items.

 @see -[UICollectionViewFlowLayout minimumLineSpacing]
 */
@property (nonatomic, assign) CGFloat minimumLineSpacing;

/**
 The minimum spacing to use between items in the same row.

 @see -[UICollectionViewFlowLayout minimumInteritemSpacing]
 */
@property (nonatomic, assign) CGFloat minimumInteritemSpacing;

/**
 The supplementary view source for the item controller. Can be nil.

 @return An object that conforms to IGListSupplementaryViewSource or nil.

 @discussion You may wish to return self if your item controller implements this protocol.
 */
@property (nonatomic, weak, nullable) id <IGListSupplementaryViewSource> supplementaryViewSource;

/**
 An object that handles display events for the item controller. Can be nil.

 @return An object that conforms to IGListDisplayDelegate or nil.

 @discussion You may wish to return self if your item controller implements this protocol.
 */
@property (nonatomic, weak, nullable) id <IGListDisplayDelegate> displayDelegate;

/**
 An object that handles working range events for the item controller. Can be nil.

 @return An object that conforms to IGListWorkingRangeDelegate or nil.

 @discussion You may wish to return self if your item controller implements this protocol.
 */
@property (nonatomic, weak, nullable) id <IGListWorkingRangeDelegate> workingRangeDelegate;

@end
