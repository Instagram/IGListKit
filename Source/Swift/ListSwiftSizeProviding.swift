/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

import Foundation

/// Protocol for cells that can provide their own size based on context and value.
public protocol ListSwiftSizeProviding {
    static func sizeFor(context: ListCollectionContext, value: ListSwiftDiffable) -> CGSize
}

/// Protocol for full width, fixed height cells.
public protocol ListSwiftFixedHeightProviding: ListSwiftSizeProviding {
    /// The fixed height of the cell.
    static var fixedHeight: CGFloat { get }
}

extension ListSwiftFixedHeightProviding {
    static func sizeFor(context: ListCollectionContext, value: ListSwiftDiffable) -> CGSize {
        return CGSize(width: context.containerSize.width, height: Self.fixedHeight)
    }
}
