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
 Automatically conform `Hashable` structures to the identification part of `ListSwiftDiffable`.
 */
public extension ListSwiftIdentifiable where Self: Hashable {

    /**
     :nodoc:
     */
    var identifier: String {
        return "\(hashValue)"
    }

}

/**
 Automatically conform `Equatable` structures to the equality part of `ListSwiftDiffable`.
 */
public extension ListSwiftEquatable where Self: Equatable {

    /**
     :nodoc:
     */
    func isEqual(to object: ListSwiftDiffable) -> Bool {
        guard let object = object as? Self else { return false }
        return self == object
    }
    
}
