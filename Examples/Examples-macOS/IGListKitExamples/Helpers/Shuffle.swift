/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import Foundation

extension MutableCollection {

    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        guard count > 1 else { return }

        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: count, to: 1, by: -1)) {
            let distance: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            guard distance != 0 else { continue }

            let shuffleIndex = index(firstUnshuffled, offsetBy: distance)

            self.swapAt(firstUnshuffled, shuffleIndex)
        }
    }

}

extension Sequence {

    /// Returns an array with the contents of this sequence, shuffled.
    var shuffled: [Iterator.Element] {
        var result = Array(self)
        result.shuffle()

        return result
    }

}
