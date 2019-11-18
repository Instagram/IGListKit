//
// Copyright (c) Facebook, Inc. and its affiliates.
// All rights reserved.
//
// This source code is licensed under the BSD-style license found in the
// LICENSE file in the root directory of this source tree. An additional grant
// of patent rights can be found in the PATENTS file in the same directory.
//
// GitHub:
// https://github.com/Instagram/IGListKit
//
// Documentation:
// https://instagram.github.io/IGListKit/
//

import UIKit

extension ListCollectionContext {
    /**
     Dequeues a cell from the collection view reuse pool.

     - Parameters:
        - cellClass: The class of the cell you want to dequeue.
        - reuseIdentifier: A reuse identifier for the specified cell. This parameter may be `nil`.
        - sectionController: The section controller requesting this information.
        - index: The index of the cell.

     - Returns: A cell dequeued from the reuse pool or a newly created one.

     - Note: This method uses a string representation of the cell class as the identifier.
     */
    public func dequeueReusableCell<T: UICollectionViewCell>(
        of cellClass: T.Type, withReuseIdentifier reuseIdentifier: String,
        for sectionController: ListSectionController, at index: Int) -> T {
        guard
            let cell = self.__dequeueReusableCell(
                of: cellClass, withReuseIdentifier: reuseIdentifier,
                for: sectionController, at: index) as? T else {
                    fatalError()
        }

        return cell
    }

    /**
     Dequeues a cell from the collection view reuse pool.

     - Parameters:
         - cellClass: The class of the cell you want to dequeue.
         - sectionController: The section controller requesting this information.
         - index: The index of the cell.

     - Returns: A cell dequeued from the reuse pool or a newly created one.

     - Note: This method uses a string representation of the cell class as the identifier.
     */
    public func dequeueReusableCell<T: UICollectionViewCell>(
        of cellClass: T.Type,
        for sectionController: ListSectionController, at index: Int) -> T {
        guard
            let cell = self.__dequeueReusableCell(
                of: cellClass,
                for: sectionController, at: index) as? T else {
                    fatalError()
        }

        return cell
    }
}
