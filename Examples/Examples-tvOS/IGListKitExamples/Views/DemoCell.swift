/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit

final class DemoCell: UICollectionViewCell {

    lazy var label: UILabel = {
        let view = UILabel()
        view.textColor = .black
        view.font = .boldSystemFont(ofSize: 35)
        self.contentView.addSubview(view)
        return view
    }()

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        label.frame = contentView.bounds.insetBy(dx: 32, dy: 16)
    }

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        let newBackgroundOpacity: CGFloat = isFocused ? 0.6 : 0.3
        let newFontSize: CGFloat = isFocused ? 50 : 35

        contentView.backgroundColor = UIColor.white.withAlphaComponent(newBackgroundOpacity)
        label.font = .boldSystemFont(ofSize: newFontSize)
    }

}
