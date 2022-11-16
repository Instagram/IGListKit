/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit

protocol RemoveCellDelegate: class {
    func removeCellDidTapButton(_ cell: RemoveCell)
}

final class RemoveCell: UICollectionViewCell {

    weak var delegate: RemoveCellDelegate?

    private lazy var label: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        self.contentView.addSubview(label)
        return label
    }()

    fileprivate lazy var button: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Remove", for: UIControl.State())
        button.setTitleColor(.blue, for: UIControl.State())
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(RemoveCell.onButton(_:)), for: .touchUpInside)
        self.contentView.addSubview(button)
        return button
    }()

    var text: String? {
        get {
            return label.text
        }
        set {
            label.text = newValue
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.backgroundColor = UIColor.background
        let bounds = contentView.bounds
        let divide = bounds.divided(atDistance: 100, from: .maxXEdge)
        label.frame = divide.slice.insetBy(dx: 15, dy: 0)
        button.frame = divide.remainder
    }

    @objc func onButton(_ button: UIButton) {
        delegate?.removeCellDidTapButton(self)
    }

}
