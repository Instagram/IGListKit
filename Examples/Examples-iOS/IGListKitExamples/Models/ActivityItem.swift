/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import IGListKit

final class ActivityItem: ListDiffable {

    let bodyText: String
    let header: String?
    let footer: String?

    init(bodyText: String, header: String? = nil, footer: String? = nil) {
        self.bodyText = bodyText
        self.header = header
        self.footer = footer
    }

    // MARK: ListDiffable

    func diffIdentifier() -> NSObjectProtocol {
        return bodyText as NSObjectProtocol
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard self !== object else { return true }
        guard let object = object as? ActivityItem else { return false }
        return bodyText == object.bodyText
    }
}
