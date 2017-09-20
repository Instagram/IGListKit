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
        button.setTitle("Remove", for: UIControlState())
        button.setTitleColor(.blue, for: UIControlState())
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
        contentView.backgroundColor = .white
        let bounds = contentView.bounds
        let divide = bounds.divided(atDistance: 100, from: .maxXEdge)
        label.frame = divide.slice.insetBy(dx: 15, dy: 0)
        button.frame = divide.remainder
    }

    @objc func onButton(_ button: UIButton) {
        delegate?.removeCellDidTapButton(self)
    }

}
