/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import IGListKit
import UIKit

final class CalendarDayCell: UICollectionViewCell {

    lazy fileprivate var label: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textAlignment = .center
        view.font = .boldSystemFont(ofSize: 16)
        view.layer.borderWidth = 2
        view.clipsToBounds = true
        self.contentView.addSubview(view)
        return view
    }()

    lazy fileprivate var dotsLabel: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textAlignment = .center
        view.textColor = .red
        view.font = .boldSystemFont(ofSize: 30)
        self.contentView.addSubview(view)
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

    var dots: String? {
        get {
            return dotsLabel.text
        }
        set {
            dotsLabel.text = newValue
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = contentView.bounds
        let half = bounds.height / 2
        label.frame = bounds
        label.layer.cornerRadius = half
        dotsLabel.frame = CGRect(x: 0, y: half - 10, width: bounds.width, height: half)
    }

}

extension CalendarDayCell: ListBindable {

    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? DayViewModel else { return }
        label.text = viewModel.day.description

        label.layer.borderColor = viewModel.today ? UIColor.red.cgColor : UIColor.clear.cgColor
        label.backgroundColor = viewModel.selected ? UIColor.red.withAlphaComponent(0.3) : UIColor.clear

        var dots = ""
        for _ in 0..<viewModel.appointments {
            dots += "."
        }
        dotsLabel.text = dots
    }

}
