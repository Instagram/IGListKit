//
//  IGListSectionControllerProtocol.h
//  Pods
//
//  Created by Jesse Squires on 1/12/17.
//
//

#import <UIKit/UIKit.h>

#import <IGListKit/IGListCollectionContext.h>
#import <IGListKit/IGListDisplayDelegate.h>
#import <IGListKit/IGListScrollDelegate.h>
#import <IGListKit/IGListSupplementaryViewSource.h>
#import <IGListKit/IGListWorkingRangeDelegate.h>

@protocol IGListSectionControllerProtocol <NSObject>

/// TEMP HACK TO COMPILE

@property (nonatomic, weak, readwrite, nullable) id<IGListCollectionContext> collectionContext;

@property (nonatomic, weak, readwrite, nullable) UIViewController *viewController;

@property (nonatomic, assign, readwrite) BOOL isFirstSection;

@property (nonatomic, assign, readwrite) BOOL isLastSection;





/**
 The view controller housing the adapter that created this section controller.

 @note Use this view controller to push, pop, present, or do other custom transitions.

 @warning It is considered very bad practice to cast this to a known view controller
 and call methods on it other than for navigations and transitions.
 */
//@property (nonatomic, weak, nullable, readonly) UIViewController *viewController;

/**
 A context object for interacting with the collection.

 Use this property for accessing the collection size, dequeing cells, reloading, inserting, deleting, etc.
 */
//@property (nonatomic, weak, nullable, readonly) id <IGListCollectionContext> collectionContext;

/**
 Returns `YES` if the section controller is the first section in the list, `NO` otherwise.
 */
//@property (nonatomic, assign, readonly) BOOL isFirstSection;

/**
 Returns `YES` if the section controller is the last section in the list, `NO` otherwise.
 */
//@property (nonatomic, assign, readonly) BOOL isLastSection;

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
