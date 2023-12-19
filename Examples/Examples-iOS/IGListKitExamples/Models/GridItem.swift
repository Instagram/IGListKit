/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import IGListKit
import Foundation

final class GridItem: NSObject {

    let color: UIColor
    let itemCount: Int

    var items: [String] = []

    init(color: UIColor, itemCount: Int) {
        self.color = color
        self.itemCount = itemCount

        super.init()

        self.items = computeItems()
    }

    private func computeItems() -> [String] {
        return [Int](1...itemCount).map {
            String(describing: $0)
        }
    }
}

extension GridItem: ListDiffable {

    func diffIdentifier() -> NSObjectProtocol {
        return self
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return self === object ? true : self.isEqual(object)
    }

}
