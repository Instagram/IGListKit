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
 Conform to this protocol to return a `UIView` when a `ListSwiftAdapter` has no content to display.
 */
public protocol ListSwiftAdapterEmptyViewSource: class {

    /**
     Return a `UIView` to display for empty content.

     @param adapter The adapter that is empty.

     @return An optional `UIView`. You should configure this view for display in this method. The view is sized to the
     bounds of the containing `UICollectionView`.
     */
    func emptyView(adapter: ListSwiftAdapter) -> UIView?
}
