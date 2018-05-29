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
 This object provides a streamlined bridge between Swift and `ListAdapter`. When using IGListKit in Swift, create a
 `ListSwiftAdapter` and assign its `dataSource`. You may still interact directly with the `ListAdapter` through the
 public `listAdapter` reference.
 */
public final class ListSwiftAdapter: NSObject, ListAdapterDataSource {

    /**
     The Swift-bridge data source to interact with the adapter using `ListSwiftDiffable` values.
     */
    public weak var dataSource: ListSwiftAdapterDataSource? {
        didSet {
            listAdapter.dataSource = self
        }
    }

    /**
     Assign to display views when the data source has no data to display.
     */
    public weak var emptyViewSource: ListSwiftAdapterEmptyViewSource?

    /**
     The underlying `ListAdapter` powering the list.
     */
    public let listAdapter: ListAdapter

    /**
     TODO
     */
    public var collectionView: UICollectionView? {
        get { return listAdapter.collectionView }
        set { listAdapter.collectionView = newValue }
    }

    /**
     TODO
     */
    public func sectionController<T>(for value: ListSwiftDiffable) -> T? {
        return listAdapter.sectionController(for: value) as? T
    }

    /**
     Create a new `ListSwiftAdapter` object.

     @param updater An object that manages updates to the collection view.
     @param viewController The view controller that will house the adapter.
     @param workingRangeSize The number of objects before and after the viewport to consider within the working range.

     @return A new adapter object.

     @note You must attach a `ListSwiftAdapterDataSource` before anything can be displayed.
     */
    public init(
        updater: ListUpdatingDelegate = ListAdapterUpdater(),
        viewController: UIViewController? = nil,
        workingRangeSize: Int = 0
        ) {
        listAdapter = ListAdapter(
            updater: updater,
            viewController: viewController,
            workingRangeSize: workingRangeSize
        )
    }

    // MARK: ListAdapterDataSource

    internal var map = [Int: () -> (ListSectionController)]()

    /**
     :nodoc:
     */
    public func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        guard let dataSource = self.dataSource else { return [] }

        return dataSource.values(adapter: self).map {
            let box = ListDiffableBox(value: $0.value)
            // side effect: store the function for use in listAdapter(:, sectionControllerFor object:)
            map[box.functionLookupHash] = $0.constructor
            return box
        }
    }

    /**
     :nodoc:
     */
    public func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        guard let box = object as? ListDiffableBox else {
            fatalError("Must only use boxes with IGListKit+Swift.")
        }
        let hash = box.functionLookupHash
        guard let function = map[hash] else {
            fatalError("Must have set a pairing function with boxed value \(box.value)")
        }

        // pluck the function from the map so any objects retained in the closure are released upon execution
        map.removeValue(forKey: hash)

        return function()
    }

    /**
     :nodoc:
     */
    public func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return emptyViewSource?.emptyView(adapter: self)
    }

}
