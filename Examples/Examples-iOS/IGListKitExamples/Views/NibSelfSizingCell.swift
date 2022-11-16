/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit

final class NibSelfSizingCell: UICollectionViewCell {

    @IBOutlet weak var contentLabel: UILabel!

    private var content: String? {
        get {
            return contentLabel.text
        }
        set {
            contentLabel.text = newValue
        }
    }

}
