/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import IGListKit
import IGListSwiftKit
import UIKit

final class EmbeddedSectionController: ListSectionController {

    private var number: Int?

    override init() {
        super.init()
        self.inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
    }

    override func sizeForItem(at index: Int) -> CGSize {
        let height = collectionContext?.containerSize.height ?? 0
        return CGSize(width: height, height: height)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell: CenterLabelCell = collectionContext.dequeueReusableCell(for: self, at: index)
        let value = number ?? 0
        cell.text = "\(value + 1)"
        cell.backgroundColor = UIColor(red: 237 / 255.0, green: 73 / 255.0, blue: 86 / 255.0, alpha: 1)
        return cell
    }

    override func didUpdate(to object: Any) {
        number = object as? Int
    }

}
