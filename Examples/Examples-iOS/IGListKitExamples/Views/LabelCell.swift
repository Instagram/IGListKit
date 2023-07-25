/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import IGListKit
import UIKit

final class LabelCell: UICollectionViewCell {
    enum Style {
        case `default`
        case grouped
    }

    fileprivate static let insets = UIEdgeInsets(top: 8, left: 15, bottom: 8, right: 15)
    fileprivate static let font = UIFont.systemFont(ofSize: 18)
    fileprivate static let symbolFont = UIFont.boldSystemFont(ofSize: 21)
    fileprivate static let cornerRadius = 12.0

    static var singleLineHeight: CGFloat {
        return font.lineHeight + insets.top + insets.bottom
    }

    static func textHeight(_ text: String, width: CGFloat) -> CGFloat {
        let constrainedSize = CGSize(width: width - insets.left - insets.right, height: CGFloat.greatestFiniteMagnitude)
        let attributes = [ NSAttributedString.Key.font: font ]
        let options: NSStringDrawingOptions = [.usesFontLeading, .usesLineFragmentOrigin]
        let bounds = (text as NSString).boundingRect(with: constrainedSize, options: options, attributes: attributes, context: nil)
        return ceil(bounds.height) + insets.top + insets.bottom
    }

    fileprivate let label: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.numberOfLines = 0
        label.font = LabelCell.font
        return label
    }()

    let separator: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.defaultSeparator.cgColor
        return layer
    }()

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .titleLabel
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    let disclosureImageView: UIImageView = {
        let configuration = UIImage.SymbolConfiguration(pointSize: 17, weight: .bold, scale: .small)
        let chevronImage = UIImage(systemName: "chevron.right", withConfiguration: configuration)
        let imageView = UIImageView(image: chevronImage)
        imageView.tintColor = .defaultSeparator
        imageView.isHidden = true
        return imageView
    }()

    let backdropView: UIView = {
        let view = UIView()
        view.layer.cornerCurve = .continuous
        return view
    }()

    var text: String? {
        get {
            return label.text
        }
        set {
            label.text = newValue
        }
    }

    var imageName: String? {
        didSet {
            guard let imageName else {
                return
            }
            let configuration = UIImage.SymbolConfiguration(font: LabelCell.symbolFont, scale: .default)
            let image = UIImage(systemName: imageName, withConfiguration: configuration)
            imageView.image = image
            setNeedsLayout()
        }
    }

    var style: Style = .default {
        didSet {
            backdropView.backgroundColor = backdropColor
            setHighlighted(isSelected)
        }
    }

    var isTopCell = false
    var isBottomCell = false

    var backdropColor: UIColor {
        (style == .grouped) ? .secondaryGroupedBackground : .background
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        contentView.addSubview(backdropView)
        contentView.addSubview(label)
        contentView.layer.addSublayer(separator)
        contentView.addSubview(disclosureImageView)
        contentView.addSubview(imageView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = contentView.bounds

        backdropView.frame = contentView.bounds

        let hasImage = imageName?.count ?? 0 > 0
        let imageCenterX = (hasImage ? LabelCell.insets.left + 15 : 0) + safeAreaInsets.left
        if hasImage {
            imageView.sizeToFit()
            imageView.frame.origin = CGPoint(x: imageCenterX - imageView.bounds.midX,
                                             y: bounds.midY - imageView.bounds.midY)
        }

        disclosureImageView.frame.origin = CGPoint(x: bounds.width - (LabelCell.insets.right + disclosureImageView.bounds.width + safeAreaInsets.right),
                                                   y: bounds.midY - disclosureImageView.bounds.midY)

        let labelX = hasImage ? imageCenterX + 25 : (LabelCell.insets.left + safeAreaInsets.left)
        label.frame = CGRect(x: labelX,
                             y: LabelCell.insets.top,
                             width: bounds.width - (labelX - disclosureImageView.frame.minX),
                             height: bounds.height - (LabelCell.insets.top + LabelCell.insets.bottom))

        let separatorHeight: CGFloat = 1.0 / (window?.screen.nativeScale ?? 2.0)
        let left = label.frame.minX
        separator.frame = CGRect(x: left, y: bounds.height - separatorHeight, width: bounds.width - left, height: separatorHeight)

        if style != .grouped {
            return
        }

        if isBottomCell {
            separator.isHidden = true
        }

        let layer = backdropView.layer
        layer.cornerRadius = LabelCell.cornerRadius

        if isTopCell {
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if isBottomCell {
            layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            layer.maskedCorners = []
        }

    }

    override var isHighlighted: Bool {
        didSet {
            setHighlighted(isHighlighted)
        }
    }

    override var isSelected: Bool {
        didSet {
            setHighlighted(isSelected)
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        separator.backgroundColor = UIColor.defaultSeparator.cgColor
    }

    private func setHighlighted(_ highlighted: Bool) {
        let color = highlighted ? UIColor.gray.withAlphaComponent(0.3) : backdropColor
        backdropView.backgroundColor = color
    }
}

extension LabelCell: ListBindable {

    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? String else { return }
        label.text = viewModel
    }

}
