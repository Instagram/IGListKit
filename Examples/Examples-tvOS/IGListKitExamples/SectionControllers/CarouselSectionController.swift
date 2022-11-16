/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import IGListKit
import UIKit

final class CarouselSectionController: ListSectionController {

    var number: Int?

    override init() {
        super.init()
        self.inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
    }

    override func numberOfItems() -> Int {
        return 1
    }

    override func sizeForItem(at index: Int) -> CGSize {
        let height = collectionContext?.containerSize.height ?? 0
        let aspectRatio: CGFloat = 0.75 // 3:4
        let width = height * aspectRatio

        return CGSize(width: width, height: height)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(withNibName: "CarouselCell",
                                                                bundle: nil,
                                                                for: self,
                                                                at: index) as? CarouselCell else {
                                                                    fatalError()
        }
        let value = number ?? 0
        cell.titleLabel.text = "#\(value + 1)"
        return cell
    }

    override func didUpdate(to object: Any) {
        number = object as? Int
    }

}
