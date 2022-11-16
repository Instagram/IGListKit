/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import IGListKit

final class FeedItem: ListDiffable {

    let pk: Int
    let user: User
    let comments: [String]

    init(pk: Int, user: User, comments: [String]) {
        self.pk = pk
        self.user = user
        self.comments = comments
    }

    // MARK: ListDiffable

    func diffIdentifier() -> NSObjectProtocol {
        return pk as NSObjectProtocol
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard self !== object else { return true }
        guard let object = object as? FeedItem else { return false }
        return user.isEqual(toDiffableObject: object.user) && comments == object.comments
    }

}
