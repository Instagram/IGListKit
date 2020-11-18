//
//  Item.swift
//  Examples-iOS-SPM-Xcode
//
//  Created by Petro Rovenskyy on 18.11.2020.
//

import Foundation
import IGListDiffKit

final class Item: NSObject {

    let name: String

    init(name: String) {
        self.name = name
        super.init()
    }

}

extension Item: ListDiffable {

    func diffIdentifier() -> NSObjectProtocol {
        return self.name as NSObjectProtocol
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if self === object { return true }
        guard let object = object as? Item else { return false }
        return self.name == object.name
    }

}
