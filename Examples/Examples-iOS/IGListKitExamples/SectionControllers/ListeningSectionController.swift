/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import IGListKit
import IGListSwiftKit

final class ListeningSectionController: ListSectionController, IncrementListener {

    private var value: Int = 0

    init(announcer: IncrementAnnouncer) {
        super.init()
        announcer.addListener(listener: self)
    }

    func configureCell(cell: LabelCell) {
        cell.text = "Section: \(self.section), value: \(value)"
    }

    // MARK: ListSectionController Overrides

    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 55)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell: LabelCell = collectionContext.dequeueReusableCell(for: self, at: index) 
        configureCell(cell: cell)
        return cell
    }

    // MARK: IncrementListener

    func didIncrement(announcer: IncrementAnnouncer, value: Int) {
        self.value = value
        guard let cell = collectionContext?.cellForItem(at: 0, sectionController: self) as? LabelCell else { return }
        configureCell(cell: cell)
    }

}
