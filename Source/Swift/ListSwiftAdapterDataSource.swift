/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

public class ValuePair {
    public static func pair<T>(_ value: T, _ constructor: @escaping () -> ListSwiftSectionController<T>) -> ValuePair {
        return ValuePair(value, constructor: constructor)
    }

    public let value: ListSwiftDiffable
    public let constructor: () -> ListSectionController

    public init<T>(_ value: T, constructor: @escaping () -> ListSwiftSectionController<T>) {
        self.value = value
        self.constructor = constructor
    }
}

public extension Optional where Wrapped == ValuePair {
    public static func pair<T>(_ value: T, _ constructor: @escaping () -> ListSwiftSectionController<T>) -> ValuePair? {
        return ValuePair.pair(value, constructor)
    }
}

public protocol ListSwiftAdapterDataSource: class {
    func values(adapter: ListSwiftAdapter) -> [ValuePair]
}
