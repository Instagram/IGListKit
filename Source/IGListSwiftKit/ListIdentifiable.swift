/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#if SWIFT_PACKAGE || USE_SWIFT_PACKAGE_FROM_XCODE
import IGListKit
#else
import IGListDiffKit
#endif


/// The `ListIdentifiable` protocol is a subset of `ListDiffable`'s functionality,
/// for use with Swift value types and `ListValueSectionController`.
///
/// `ListIdentifiable` is an experimental, under-development API, and may change without warning in the future.
public protocol ListIdentifiable: Equatable {
    var diffIdentifier: NSObjectProtocol { get }
}

public extension ListIdentifiable {
    /// Provides an object version of the value that can be passed to Objective-C APIs from
    /// `IGListKit` that require objects.
    ///
    /// The object class is a private implementation detail of `IGListSwiftKit`. Use of this
    /// API must be paired with the `ListValueSectionController` class, which unwraps the
    /// value for its subclasses.
    func diffable() -> ListDiffable {
        return ListDiffableValueBox(value: self)
    }

    /// Determines whether an arbitrary `Any` value is an object version of the identifiable value.
    static func isDiffable(_ value: Any) -> Bool {
        return value is ListDiffableValueBox<Self>
    }

    // TODO(natesm): Should this be a public API? It is for now.
    init?(diffable: Any) {
        guard let value = (diffable as? ListDiffableValueBox<Self>)?.value else {
            return nil
        }
        self = value
    }
}

public extension Sequence where Element: ListIdentifiable {
    func diffables() -> [ListDiffable] {
        return map { $0.diffable() }
    }
}

/// An internal class for boxing Swift values, for use with the `ListValueSectionController` class.
///
/// The public boxing API is provided by a protocol extension of `ListIdentifiable`.
private final class ListDiffableValueBox<Value: ListIdentifiable>: NSObject, ListDiffable {
    let value: Value

    init(value: Value) {
        self.value = value
    }

    // MARK: - ListDiffable
    func diffIdentifier() -> NSObjectProtocol {
        return value.diffIdentifier
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let other = object as? ListDiffableValueBox<Value> else {
            return false
        }
        return value == other.value
    }
}
