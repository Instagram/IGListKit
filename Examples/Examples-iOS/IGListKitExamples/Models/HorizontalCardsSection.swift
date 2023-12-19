/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import IGListKit
import Foundation

final class HorizontalCardsSection: NSObject {

    let cardCount: Int
    private(set) var items: [String] = []

    init(cardCount: Int) {
        self.cardCount = cardCount
        super.init()
        self.items = computeItems()
    }

    private func computeItems() -> [String] {
        return [Int](1...cardCount).map {
            String(describing: $0)
        }
    }
}

extension HorizontalCardsSection: ListDiffable {

    func diffIdentifier() -> NSObjectProtocol {
        return self
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return self === object ? true : self.isEqual(object)
    }

}
