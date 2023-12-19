/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import IGListKit
import UIKit

/// Like ExpandableSectionController, but supports UICollectionViewCompositionalLayout
final class ExpandableComposableSectionController: ListSectionController, CompositionLayoutCapable {

    private var expanded = false
    private var object: String?

    override func sizeForItem(at index: Int) -> CGSize {
        // Size handled by cell
        return CGSizeZero
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell: CompositionLayoutCell = collectionContext.dequeueReusableCell(for: self, at: index)
        cell.text = object
        cell.expanded = expanded
        return cell
    }

    override func didUpdate(to object: Any) {
        self.object = object as? String
    }

    override func didSelectItem(at index: Int) {
        expanded = !expanded
        
        guard let cell = collectionContext.cellForItem(at: index, sectionController: self) as? CompositionLayoutCell else {
            return
        }
        cell.expanded = expanded;

        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.4,
                       initialSpringVelocity: 0.6,
                       options: [],
                       animations: {
                        self.collectionContext?.invalidateLayout(for: self)
        })
    }
    
    // MARK: CompositionLayoutCapable
    
    func collectionViewSectionLayout(layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? {
        let config = UICollectionLayoutListConfiguration(appearance: .plain)
        return NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
    }

}
