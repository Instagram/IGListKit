//
//  ItemSectionController.swift
//  Examples-iOS-SPM-Xcode
//
//  Created by Petro Rovenskyy on 18.11.2020.
//

import IGListKit
import UIKit

final class ItemSectionController: ListSectionController {

    private var object: Item?

    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 55)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell: LabelCell = collectionContext?.dequeueReusableCell(of: LabelCell.self,
                                                                           withReuseIdentifier: "labelCellId",
                                                                           for: self, at: index) as? LabelCell else {
            fatalError()
        }
        cell.text = object?.name
        return cell
    }

    override func didUpdate(to object: Any) {
        self.object = object as? Item
    }
}
