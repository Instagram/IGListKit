/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit

final class UserFooterView: UICollectionViewCell {

    @IBOutlet private weak var commentsCountLabel: UILabel!

    var commentsCount: String? {
        get {
            return commentsCountLabel.text
        }
        set {
            commentsCountLabel.text = newValue
        }
    }
}
