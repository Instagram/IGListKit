/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

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
