/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit

/// A cell that works with composition layout.
/// 1. It overrides -sizeThatFits for cell sizing
/// 2. Unlike LabelCell, it doesn't need to add separators, since that's taken care of by the layout
class CompositionLayoutCell: UICollectionViewCell {

    private let insets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        contentView.backgroundColor = UIColor.systemBackground
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds.inset(by: insets)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.backgroundColor = UIColor.systemBackground
        contentView.layer.cornerRadius = 0
    }

    // MARK: Label

    private let label: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()

    var text: String? {
        get {
            return label.text
        }
        set {
            label.text = newValue
        }
    }

    var expanded:Bool = false {
        didSet {
            label.numberOfLines = expanded ? 0 : 1
        }
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let labelMaxSize = CGRect(origin: .zero, size: size).inset(by: insets).size
        let labelSize = label.sizeThatFits(labelMaxSize)
        return CGSize(width: labelSize.width + insets.left + insets.right,
                      height: labelSize.height + insets.top + insets.bottom)
    }

}
