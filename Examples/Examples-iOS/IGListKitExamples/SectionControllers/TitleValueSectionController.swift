//
//  TitleValueSectionController.swift
//  FSInvestor
//
//  Created by steven lee on 22/11/18.
//  Copyright © 2018 Funding Societies. All rights reserved.
//

import Foundation
import IGListKit
import UIKit

final class LabelAttribute {
    let titleColor: UIColor
    let titleFont: UIFont
    init(titleColor: UIColor, titleFont: UIFont) {
        self.titleColor = titleColor
        self.titleFont = titleFont
    }
}

final class CellAttribute {
    let cornerRadius: CornerRadius
    let cornerSize: CGFloat
    let backgroundColor: UIColor
    init (cornerRadius: CornerRadius = .none, cornerSize: CGFloat = 8, backgroundColor: UIColor = .clear) {
        self.cornerRadius = cornerRadius
        self.cornerSize = cornerSize
        self.backgroundColor = backgroundColor
    }
}

final class TitleValueSectionModel: NSObject, ListBoundable, ListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        return (title + value) as NSObjectProtocol
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return isEqual(object)
    }
    func boundedSectionController() -> ListSectionController {
        return TitleValueSectionController()
    }

    let title: String
    let value: String
    let titleAttribute: LabelAttribute
    let valueAttribute: LabelAttribute
    let cellAttribute: CellAttribute
    init(title: String, value: String, titleAttribute: LabelAttribute, valueAttribute: LabelAttribute, cellAttribute: CellAttribute = CellAttribute()) {
        self.title = title
        self.value = value
        self.titleAttribute = titleAttribute
        self.valueAttribute = valueAttribute
        self.cellAttribute = cellAttribute
    }
}

final class TitleValueSectionController: ListSectionController {
    private var model: TitleValueSectionModel!
    override init() {
        super.init()
        inset = UIEdgeInsets(top: 0, left: 0, bottom: 18, right: 0)
        minimumLineSpacing = 4
        minimumInteritemSpacing = 0
    }

    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 55)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {

        guard let cell = collectionContext?.dequeueReusableCell(withNibName: "PairedTitleValueCell", bundle: nil, for: self, at: index) as? PairedTitleValueCell else {
            fatalError()
        }
        cell.titleLabel.text = model.title
        cell.titleLabel.font = model.titleAttribute.titleFont
        cell.titleLabel.textColor = model.titleAttribute.titleColor
        cell.valueLabel.text = model.value
        cell.valueLabel.font = model.valueAttribute.titleFont
        cell.valueLabel.textColor = model.valueAttribute.titleColor
        cell.backgroundColor = model.cellAttribute.backgroundColor
        cell.roundCorners(cornersRadius: model.cellAttribute.cornerRadius, radius: model.cellAttribute.cornerSize)
        cell.backgroundColor = model.cellAttribute.backgroundColor
        return cell
    }

    override func didUpdate(to object: Any) {
        model = (object as! TitleValueSectionModel)
    }

    override func didSelectItem(at index: Int) {
    }
}
