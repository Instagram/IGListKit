/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit
import IGListKit

final class LoadingCellModel {
    let identifier = "loading-cell"
}

// MARK: - ListDiffable Implementation

// Even simple models like this loading indicator need to conform to ListDiffable
// in order to be used with IGListKit
extension LoadingCellModel: ListDiffable {
    
    // The diffIdentifier uniquely identifies this object
    // For a singleton loading indicator, a static string ID is sufficient
    func diffIdentifier() -> any NSObjectProtocol {
        return self.identifier as NSObjectProtocol
    }
    
    // isEqual compares properties that affect the visual representation
    // For this simple case, comparing identifiers is enough
    func isEqual(toDiffableObject object: (any ListDiffable)?) -> Bool {
        guard let object = object as? LoadingCellModel else { return false }
        return self.identifier == object.identifier
    }
}
