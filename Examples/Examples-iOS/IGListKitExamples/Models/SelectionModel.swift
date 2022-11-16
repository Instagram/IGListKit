/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import IGListKit

enum SelectionModelType: Int {
    case none, fullWidth, nib
}

final class SelectionModel: NSObject {

    let options: [String]
    let type: SelectionModelType

    init(options: [String], type: SelectionModelType = .none) {
        self.options = options
        self.type = type
    }

}

extension SelectionModel: ListDiffable {

    func diffIdentifier() -> NSObjectProtocol {
        return self
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return isEqual(object)
    }

}
