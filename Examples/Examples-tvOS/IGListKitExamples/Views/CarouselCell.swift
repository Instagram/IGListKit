/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit

final class CarouselCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        let normalColor = UIColor(red: 174 / 255.0, green: 198 / 255.0, blue: 207 / 255.0, alpha: 1)
        let focusColor = UIColor(red: 117 / 255.0, green: 155 / 255.0, blue: 169 / 255.0, alpha: 1)

        backgroundColor = isFocused ? focusColor : normalColor
    }
}
