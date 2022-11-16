/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import Foundation
import IGListKit

final class MonthTitleViewModel {

    let name: String

    init(name: String) {
        self.name = name
    }

}

extension MonthTitleViewModel: ListDiffable {

    func diffIdentifier() -> NSObjectProtocol {
        return name as NSObjectProtocol
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if self === object { return true }
        guard object is MonthTitleViewModel else { return false }
        // name is checked in the diffidentifier, so we can assume its equal
        return true
    }

}
