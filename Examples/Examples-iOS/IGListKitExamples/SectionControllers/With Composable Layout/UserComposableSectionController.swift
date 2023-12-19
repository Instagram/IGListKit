/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import IGListKit
import UIKit

final class UserComposableSectionController: ListSectionController, CompositionLayoutCapable {

    private var user: User?

    override func sizeForItem(at index: Int) -> CGSize {
        // Size handled by cell
        return CGSizeZero
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

    // MARK: CompositionLayoutCapable
    
    func collectionViewSectionLayout(layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? {
        let config = UICollectionLayoutListConfiguration(appearance: .plain)
        return NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
    }
    
}
