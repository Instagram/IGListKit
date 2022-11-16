/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import IGListKit

final class User: ListDiffable {

    let pk: Int
    let name: String
    let handle: String

    init(pk: Int, name: String, handle: String) {
        self.pk = pk
        self.name = name
        self.handle = handle
    }

    // MARK: ListDiffable

    func diffIdentifier() -> NSObjectProtocol {
        return pk as NSObjectProtocol
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard self !== object else { return true }
        guard let object = object as? User else { return false }
        return name == object.name && handle == object.handle
    }

}
