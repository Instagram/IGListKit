/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

extension Hashable {
    var identifier: Int {
        return hashValue
    }
}

extension Equatable {
    func isEqual(to object: ListSwiftEquatable) -> Bool {
        guard let object = object as? Self else { return false }
        return self == object
    }
}