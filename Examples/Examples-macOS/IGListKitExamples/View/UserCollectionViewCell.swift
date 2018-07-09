//
//  UserCollectionViewCell.swift
//  IGListKitExamples
//
//  Created by Weyert de Boer on 27/08/2017.
//  Copyright © 2017 Instagram. All rights reserved.
//

import Cocoa

protocol UserCollectionViewCellDelegate: class {

    func itemDeleted(_ user: User)
}

final class UserCollectionViewCell: NSCollectionViewItem {

    weak var delegate: UserCollectionViewCellDelegate?

    @IBAction func deleteButtonClicked(_ sender: AnyObject) {
        guard let user = representedObject as? User else { return }
        delegate?.itemDeleted(user)
    }

    func bindViewModel(_ user: User) {
        representedObject = user
        textField?.stringValue = user.name
    }
}
