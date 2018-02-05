/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

import Foundation

/**
 Wrap a `ListSwiftDiffable` conforming value so that it conforms to `ListDiffable` and can be used with other IGListKit
 systems.

 @note Wrapped values can be a Swift `class` or `struct`.
 */
public final class ListDiffableBox: ListDiffable {

    /**
     The boxed value.
     */
    public let value: ListSwiftDiffable

    /**
     Initialize a new `ListDiffableBox` object.

     @param value The value to be boxed.
     */
    public init(value: ListSwiftDiffable) {
        self.value = value
    }

    // MARK: ListDiffable

    /**
     :nodoc:
     */
    public func diffIdentifier() -> NSObjectProtocol {
        // namespace the identifier with the value type to further prevent collisions
        return "\(value.self)\(value.identifier)" as NSObjectProtocol
    }

    /**
     :nodoc:
     */
    public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if self === object { return true }
        guard let object = object as? ListDiffableBox else { return false }
        return value.isEqual(to: object.value)
    }

}

