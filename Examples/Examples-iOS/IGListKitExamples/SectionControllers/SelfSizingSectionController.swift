/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import IGListKit
import IGListSwiftKit
import UIKit

final class SelfSizingSectionController: ListSectionController {

    private var model: SelectionModel!

    override init() {
        super.init()
        inset = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
        minimumLineSpacing = 4
        minimumInteritemSpacing = 4
    }

    override func numberOfItems() -> Int {
        return model.options.count
    }

    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 55)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let text = model.options[index]
        let cell: UICollectionViewCell
        switch model.type {
        case .none:
            let manualCell: ManuallySelfSizingCell = collectionContext.dequeueReusableCell(
                for: self,
                at: index
            )
            manualCell.text = text
            cell = manualCell
        case .fullWidth:
            let manualCell: FullWidthSelfSizingCell = collectionContext.dequeueReusableCell(
                for: self,
                at: index
            )
            manualCell.text = text
            cell = manualCell
        case .nib:
            let nibCell: NibSelfSizingCell = collectionContext.dequeueReusableCell(
                withNibName: "NibSelfSizingCell",
                bundle: nil,
                for: self,
                at: index
            )
            nibCell.contentLabel.text = text
            cell = nibCell
        }
        return cell
    }

    override func didUpdate(to object: Any) {
        self.model = object as? SelectionModel
    }

}
