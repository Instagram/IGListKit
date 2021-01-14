/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import IGListKit

/// A generic section controller that supports any Swift value conforming to `ListIdentifiable`.
///
/// For a type-safe base class for `ListDiffable` objects, see `ListGenericSectionController` instead.
///
/// `ListValueSectionController` is an experimental, under-development API, and may change without warning in the future.
open class ListValueSectionController<Value: ListIdentifiable>: ListSectionController {
    /// The section controller's current value.
    ///
    /// This value will be `nil` temporarily after initialization, but is exposed as an implicitly-unwrapped
    /// optional because it will be set by `didUpdate(to:)` before any other methods, like `cellForItem(at:)`,
    /// are invoked.
    public private(set) var value: Value!

    /// Subclasses of `ListValueSectionController` may not override `didUpdate(to:)` for objects.
    /// Instead, they must use the overload for generic values.
    public final override func didUpdate(to object: Any) {
        guard let value = Value(diffable: object) else {
            fatalError("Expected object for value section controller to be a boxed \(Value.self), but it was \(object)")
        }
        self.value = value
        didUpdate(to: value)
    }

    /// Updates the section controller to a new value.
    ///
    /// Subclasses of `ListValueSectionController` may override this method. Calling `super` is not required.
    open func didUpdate(to value: Value) {}
}
