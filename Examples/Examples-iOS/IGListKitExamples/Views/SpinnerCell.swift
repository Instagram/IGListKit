/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import IGListKit
import IGListSwiftKit
import UIKit

func spinnerSectionController() -> ListSingleSectionController {
    let configureBlock = { (_: Any, cell: SpinnerCell) in
        cell.activityIndicator.startAnimating()
    }

    let sizeBlock = { (_: Any, context: ListCollectionContext?) -> CGSize in
        guard let context = context else { return .zero }
        return CGSize(width: context.containerSize.width, height: 100)
    }

    return ListSingleSectionController(configure: configureBlock, size: sizeBlock)
}

final class SpinnerCell: UICollectionViewCell {

    lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.style = UIActivityIndicatorView.defaultStyle
        self.contentView.addSubview(view)
        return view
    }()

    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = contentView.bounds
        activityIndicator.center = CGPoint(x: bounds.midX, y: bounds.midY)
    }

}
