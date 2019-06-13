//
//  LabelSectionController.swift
//  IGListKitDemo
//
//  Created by steven lee on 13/3/19.
//  Copyright © 2019 steven lee. All rights reserved.
//

import Foundation
import IGListKit
import UIKit

final class TextLabelSectionModel: NSObject, ListBoundable, ListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        return string as NSObjectProtocol
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return isEqual(object)
    }

    func boundedSectionController() -> ListSectionController {
        return TextLabelSectionController()
    }

    let string: String
    let cellAttribute: CellAttribute
    init(string: String, cellAttribute: CellAttribute = CellAttribute()) {
        self.string = string
        self.cellAttribute = cellAttribute
    }
}

final class TextLabelSectionController: ListSectionController {

    private var model: TextLabelSectionModel!
    override init() {
        super.init()
        inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        minimumLineSpacing = 4
        minimumInteritemSpacing = 0
    }

    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 55)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {

        let cell = collectionContext?.dequeueReusableCell(of: LabelCell.self, for: self, at: index) as! LabelCell
        cell.text = model.string
        cell.roundCorners(cornersRadius: model.cellAttribute.cornerRadius, radius: model.cellAttribute.cornerSize)
        cell.backgroundColor = model.cellAttribute.backgroundColor
        return cell
    }

    override func didUpdate(to object: Any) {
        model = (object as! TextLabelSectionModel)
    }

    override func didSelectItem(at index: Int) {
    }
}
