/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

final class ListSwiftAdapter: NSObject {

    weak var dataSource: ListSwiftAdapterDataSource? {
        didSet {
            adapter.dataSource = self
        }
    }
    weak var emptyViewSource: ListSwiftAdapterEmptyViewSource?

    let adapter: ListAdapter

    init(updater: ListUpdatingDelegate = ListAdapterUpdater(),
         viewController: UIViewController? = nil,
         workingRangeSize: Int = 0
        ) {
        adapter = ListAdapter(updater: updater, viewController: viewController, workingRangeSize: workingRangeSize)
    }

    // MARK: ListAdapterDataSource

    fileprivate var map = [Int: (ListSwiftDiffable) -> (ListSectionController)]()

}