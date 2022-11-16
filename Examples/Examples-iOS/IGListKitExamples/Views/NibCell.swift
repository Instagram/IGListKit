/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit

final class NibCell: UICollectionViewCell {
    static let nibName = "NibCell"
    @IBOutlet private var textLabel: UILabel!
    var text: String? {
        didSet {
            textLabel.text = text
        }
    }
}
