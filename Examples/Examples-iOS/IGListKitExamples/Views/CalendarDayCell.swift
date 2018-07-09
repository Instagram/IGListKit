/**
 Copyright (c) 2016-present, Facebook, Inc. All rights reserved.
 
 The examples provided by Facebook are for non-commercial testing and evaluation
 purposes only. Facebook reserves all rights not expressly granted.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 FACEBOOK BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import IGListKit
import UIKit

final class CalendarDayCell: UICollectionViewCell {

    lazy fileprivate var label: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textAlignment = .center
        view.textColor = .black
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
