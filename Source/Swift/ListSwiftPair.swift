/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

import Foundation

public typealias ListSwiftPairConstructor<T: ListSwiftIdentifiable> = () -> ListSwiftSectionController<T>

/**
 Query a value for a given section controller.

 @param sectionController The section controller you want the associated value for.

 @return The unboxed value, if found.
 */
public class ListSwiftPair {

    public static func pair<T>(_ value: T, _ constructor: @escaping ListSwiftPairConstructor<T>) -> ListSwiftPair {
        return ListSwiftPair(value, constructor: constructor)
    }

    public let value: ListSwiftIdentifiable

    public let constructor: () -> ListSectionController

    public init<T>(_ value: T, constructor: @escaping ListSwiftPairConstructor<T>) {
        self.value = value
        self.constructor = constructor
    }

}

/**
 Query a value for a given section controller.

 @param sectionController The section controller you want the associated value for.

 @return The unboxed value, if found.
 */
public extension Optional where Wrapped == ListSwiftPair {
    public static func pair<T>(_ value: T, _ constructor: @escaping ListSwiftPairConstructor<T>) -> ListSwiftPair? {
        return ListSwiftPair.pair(value, constructor)
    }
}
