/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

internal final class ListDiffableBox: ListDiffable {

    internal let value: ListSwiftDiffable

    init(value: ListSwiftDiffable) {
        self.value = value
    }

    // MARK: ListDiffable

    func diffIdentifier() -> NSObjectProtocol {
        return value.identifier as NSObjectProtocol
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if self === object { return true }
        guard let object = object as? ListDiffableBox else { return false }
        return value.isEqual(to: object.value)
    }

}
