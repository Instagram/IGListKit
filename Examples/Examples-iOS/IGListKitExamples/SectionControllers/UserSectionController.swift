/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import IGListKit
import UIKit

final class UserSectionController: ListSectionController {

    private var user: User?
    private let isReorderable: Bool

    required init(isReorderable: Bool = false) {
        self.isReorderable = isReorderable
        super.init()
    }

    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 55)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell: DetailLabelCell = collectionContext.dequeueReusableCell(
            for: self,
            at: index
        )
        cell.title = user?.name
        cell.detail = "@" + (user?.handle ?? "")
        return cell
    }

    override func didUpdate(to object: Any) {
        self.user = object as? User
    }

    override func canMoveItem(at index: Int) -> Bool {
        return isReorderable
    }
}
