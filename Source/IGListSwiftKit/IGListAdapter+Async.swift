/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import IGListKit

public extension ListAdapter {
    /// Perform an update from the previous state of the data source. This is analogous to calling
    /// `UICollectionView.performBatchUpdates(_:completion:)`.
    ///
    /// - Parameter animated: A flag indicating if the transition should be animated.
    /// - Returns: `true` if the update animations completed successfully; otherwise `false`.
    @discardableResult
    @available(iOS 13.0, *)
    @available(tvOS 13.0, *)
    func performUpdates(animated: Bool) async -> Bool {
        return await withCheckedContinuation { continuation in
            performUpdates(animated: animated) { finished in
                continuation.resume(returning: finished)
            }
        }
    }

    /// Perform an immediate reload of the data in the data source, discarding the old objects.
    ///
    /// - Returns: `true` if the update animations completed successfully; otherwise `false`.
    ///
    /// @warning Do not use this method to update without animations as it can be very expensive to teardown and rebuild all
    /// section controllers. Use `performUpdates(animated:) async` instead.
    @discardableResult
    @available(iOS 13.0, *)
    @available(tvOS 13.0, *)
    func reloadData() async -> Bool {
        return await withCheckedContinuation { continuation in
            reloadData { finished in
                continuation.resume(returning: finished)
            }
        }
    }
}
