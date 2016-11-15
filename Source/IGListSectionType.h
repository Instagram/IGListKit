/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

@protocol IGListSupplementaryViewSource;
@protocol IGListDisplayDelegate;
@protocol IGListWorkingRangeDelegate;

NS_ASSUME_NONNULL_BEGIN

/**
 Implement this protocol in order to be used within the `IGListKit` data infrastructure and be registered for use in an
 `IGListAdapter`. An `IGListSectionType` conforming object represents a single instance of an object in a collection of
 objects.

 The infrastructure uses each `IGListSectionType` conforming object as a "view model" to populate and control cells as
 part of a section in a `UICollectionView`. `IGListSectionType` objects should be architected without knowledge of
 "global" state of the list in which they are contained.

 Index paths are used as a convenience for communicating the section index to each section object without allowing each
 section to mutate its own position within a list. The row of an index path can be directly mapped to a cell within
 an `IGListSectionType` conforming object.
 */
@protocol IGListSectionType <NSObject>

/**
 Returns the number of items in the section.

 @return A count of items in the list.

 @note The count returned is used to drive the number of cells displayed for this list. You are free to change
 this value between data loading passes.
 */
- (NSInteger)numberOfItems;

/**
 The specific size for the item at the specified index.

 @param index The row index of the item.

 @return The size for the item at index.

 @note The returned size is not garaunteed to be used. The implementation may query sections for their
 layout information at will, or use its own layout metrics. For example, consider a dynamic-text sized list versus a fixed
 height-and-width grid. The former will ask each section for a size, and the latter will likely not.
 */
- (CGSize)sizeForItemAtIndex:(NSInteger)index;

/**
 Asks the section controller for a fully configured cell at the specified index.

 @param index The index of the requested row.

 @return A configured `UICollectionViewCell` subclass.

 @note This is your opportunity to do any cell setup and configuration. The infrastructure requests a cell when it
 will be used on screen. You should never allocate new cells in this method, instead use the provided adapter to call
 `-dequeCellClass:forIndexPath:` which either deques a cell from the collection view or creates a new one for you.
 */
- (__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index;

/**
 Tells the section that the controller was updated to a new object.

 @param object The object mapped to this section controller.

 @note When this method is called, all available contexts and configurations have been set for the section
 controller. Also, depending on the updating strategy used, your item models may have changed objects in memory, so you
 can use this event to update the object stored on your section controller.

 This method will only be called when the object instance has changed, including from `nil` or a previous object.
 */
- (void)didUpdateToObject:(id)object;

/**
 Tells the section that the cell at the specified index path was selected.

 @param index The index of the selected cell.
 */
- (void)didSelectItemAtIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
