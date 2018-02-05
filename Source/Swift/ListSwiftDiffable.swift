/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

/**
 Conform a Swift `struct` or `class` so that it can be diffed and used with IGListKit.
 */
public protocol ListSwiftDiffable {

    /**
     Return a `String` that uniquely identifies the instance.

     @note These identifiers are namespaced to the object type to avoid colliding identifiers between different value
     types.
     */
    var identifier: String { get }

    /**
     Indicate if the value is equal to another value.

     @param object The value to compare against.

     @return `true` if the two instances are equal in value. Otherwise `false`.
     */
    func isEqual(to value: ListSwiftDiffable) -> Bool

}
