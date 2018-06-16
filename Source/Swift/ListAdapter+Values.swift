/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

import UIKit

/**
 These extension functions make interacting with `IGListAdapter` APIs easier when using `ListSwiftDiffable` values.
 */
public extension ListAdapter {

    /**
     Get a value for a given section controller.

     @param sectionController The `ListSectionController` you want the associated value for.

     @return The unboxed value, if the `ListSectionController` is a member of the `IGListAdapter`.
     */
    public func value(for sectionController: ListSectionController) -> ListSwiftDiffable? {
        if let box = object(for: sectionController) {
            guard let box = box as? ListDiffableBox else {
                fatalError("All objects used with the IGListKit+Swift extension should be boxed")
            }
            return box.value
        }
        return nil
    }

    /**
     Get a section controller for a given value.

     @param value The value you want the associated `ListSectionController` for.

     @return The `ListSectionController`, if the value is a member of the `IGListAdapter`.
     */
    public func sectionController(for value: ListSwiftDiffable) -> ListSectionController? {
        return sectionController(for: value.sectionBox)
    }

    /**
     Get the section for a value.

     @param value The value you want the section of.

     @return The section, if the value is a member of the adapter.
     */
    public func section(for value: ListSwiftDiffable) -> Int? {
        let section = self.section(for: value.sectionBox)
        return section == NSNotFound ? nil : section
    }

    /**
     Get the value at a section.

     @param section The sectoin you want a value at.

     @return The unboxed value if the section exists in the `IGListAdapter`.
     */
    public func value(at section: Int) -> ListSwiftDiffable? {
        if let box = object(atSection: section) {
            guard let box = box as? ListDiffableBox else {
                fatalError("All objects used with the IGListKit+Swift extension should be boxed")
            }
            return box.value
        }
        return nil
    }

    /**
     Get all visible `UICollectionViewCell`s for a given value.

     @param value The value you want cells for.

     @return All currently visible cells in the `UICollectionView`. Array is empty if no cells are visible.
     */
    public func visibleCells(for value: ListSwiftDiffable) -> [UICollectionViewCell] {
        return visibleCells(for: value.sectionBox)
    }

    /**
     Scroll to a value's cells in the `IGListAdapter`.

     @param value The value to scroll to.
     @param supplementaryKinds Any supplementary kinds to include when scrolling.
     @param scrollDirection The direction of the scroll.
     @param scrollPosition The final position of the cells.
     @param animated A flag indicating if the scroll should be animated.
     */
    public func scroll(
        to value: ListSwiftDiffable,
        supplementaryKinds: [String]? = nil,
        scrollDirection: UICollectionViewScrollDirection = .vertical,
        scrollPosition: UICollectionViewScrollPosition = .centeredVertically,
        animated: Bool = true
        ) {
        scroll(
            to: value.sectionBox,
            supplementaryKinds: supplementaryKinds,
            scrollDirection: scrollDirection,
            scrollPosition: scrollPosition,
            animated: animated
        )
    }

    /**
     Get all values in the `IGListAdapter`.

     @return All unboxed values in the `IGListAdapter`.
     */
    public var values: [ListSwiftDiffable] {
        guard let objects = self.objects() as? [ListDiffableBox] else {
            fatalError("All objects used with the IGListKit+Swift extension should be boxed")
        }
        return objects.map { $0.value }
    }

    /**
     Get all visible values in the `IGListAdapter`.

     @return All visible, unboxed values in the `IGListAdapter`.
     */
    public var visibleValues: [ListSwiftDiffable] {
        guard let visibleObjects = self.visibleObjects() as? [ListDiffableBox] else {
            fatalError("All objects used with the IGListKit+Swift extension should be boxed")
        }
        return visibleObjects.map { $0.value }
    }

}
