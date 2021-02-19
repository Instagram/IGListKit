/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import IGListKit
import IGListSwiftKit

protocol RemoveSectionControllerDelegate: class {
    func removeSectionControllerWantsRemoved(_ sectionController: RemoveSectionController)
}

final class RemoveSectionController: ListSectionController, RemoveCellDelegate {

    weak var delegate: RemoveSectionControllerDelegate?
    private var number: Int?

    override init() {
        super.init()
        inset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
    }

    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 55)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell: RemoveCell = collectionContext.dequeueReusableCell(for: self, at: index)
        cell.text = "Cell: \((number ?? 0) + 1)"
        cell.delegate = self
        return cell
    }

    override func didUpdate(to object: Any) {
        number = object as? Int
    }

    // MARK: RemoveCellDelegate

    func removeCellDidTapButton(_ cell: RemoveCell) {
        delegate?.removeSectionControllerWantsRemoved(self)
    }

}
