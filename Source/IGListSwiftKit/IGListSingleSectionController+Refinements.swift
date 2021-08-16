/*
* Copyright (c) Facebook, Inc. and its affiliates.
*
* This source code is licensed under the MIT license found in the
* LICENSE file in the root directory of this source tree.
*/

import IGListKit
import Foundation

extension ListSingleSectionController {
    /**
     Creates a new section controller for a given cell type that will always have only one cell when present in a list.

     - Parameters:
        - configure: A closure that configures the cell with the item given to the section controller.
        - size: A closure that returns the size for the cell given the collection context.

     - Returns: A new section controller.

     @warning Be VERY CAREFUL not to create retain cycles by holding strong references to: the object that owns the adapter
     (usually `self`) or the `ListAdapter`. Pass in locally scoped objects or use `weak` references!
    */
    public convenience init<Item, Cell: UICollectionViewCell>(
        configure: @escaping (Item, Cell) -> Void,
        size: @escaping (Item, ListCollectionContext?) -> CGSize
    ) {
        self.init(
            cellClass: Cell.self,
            configureBlock: { configure($0 as! Item, $1 as! Cell) },
            sizeBlock: { size($0 as! Item, $1) }
        )
    }

    /**
     Creates a new section controller for a given cell type that will always have only one cell when present in a list. Supports any Swift value conforming to `ListIdentifiable`.

     - Parameters:
        - configure: A closure that configures the cell with the Swift value item given to the section controller.
        - size: A closure that returns the size for the cell given the collection context.

     - Returns: A new section controller.

     @warning Be VERY CAREFUL not to create retain cycles by holding strong references to: the object that owns the adapter
     (usually `self`) or the `ListAdapter`. Pass in locally scoped objects or use `weak` references!
    */
    public convenience init<Value: ListIdentifiable, Cell: UICollectionViewCell>(
        configure: @escaping (Value, Cell) -> Void,
        size: @escaping (Value, ListCollectionContext?) -> CGSize
    ) {
        self.init(
            cellClass: Cell.self,
            configureBlock: { (item: Any, cell: UICollectionViewCell) in
                guard let value = Value(diffable: item) else {
                    fatalError("Expected object for value section controller to be a boxed \(Value.self), but it was \(item)")
                }
                configure(value, cell as! Cell)
            },
            sizeBlock: { (item: Any, context: ListCollectionContext?) in
                guard let value = Value(diffable: item) else {
                    fatalError("Expected object for value section controller to be a boxed \(Value.self), but it was \(item)")
                }
                return size(value, context)
            }
        )
    }
}
