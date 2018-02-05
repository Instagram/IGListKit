/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

import UIKit

extension ListSwiftAdapter: ListAdapterDataSource {

    public func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        guard let dataSource = self.dataSource else { return [] }

        return dataSource.values(adapter: self).map {
            let box = $0.value.boxed
            // side effect: store the function for use in listAdapter(:, sectionControllerFor object:)
            map[box.functionLookupHash] = $0.constructor
            return box
        }
    }

    public func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        guard let box = object as? ListDiffableBox else { fatalError() }
        let hash = box.functionLookupHash
        guard let function = map[hash] else { fatalError() }

        // pluck the function from the map so any objects retained in the closure are released upon execution
        map.removeValue(forKey: hash)

        return function()
    }

    public func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return emptyViewSource?.emptyView(adapter: self)
    }

}
