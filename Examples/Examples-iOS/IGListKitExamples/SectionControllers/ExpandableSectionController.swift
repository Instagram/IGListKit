/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import IGListKit
import IGListSwiftKit
import UIKit

final class ExpandableSectionController: ListSectionController {

    private var expanded = false
    private var object: String?

    override func sizeForItem(at index: Int) -> CGSize {
        let width = collectionContext!.containerSize.width
        let height = expanded ? LabelCell.textHeight(object ?? "", width: width) : LabelCell.singleLineHeight
        return CGSize(width: width, height: height)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell: LabelCell = collectionContext.dequeueReusableCell(for: self, at: index)
        cell.text = object
        return cell
    }

    override func didUpdate(to object: Any) {
        self.object = object as? String
    }

    override func didSelectItem(at index: Int) {
        expanded = !expanded
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.4,
                       initialSpringVelocity: 0.6,
                       options: [],
                       animations: {
                        self.collectionContext?.invalidateLayout(for: self)
        })
    }

}
