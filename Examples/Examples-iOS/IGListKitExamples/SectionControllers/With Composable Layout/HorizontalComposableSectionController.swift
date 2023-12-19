/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import IGListKit
import UIKit

final class HorizontalComposableSectionController: ListSectionController, CompositionLayoutCapable {

    private var object: HorizontalCardsSection?

    override func numberOfItems() -> Int {
        return object?.cardCount ?? 0
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        // Size handled by cell
        return CGSizeZero
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell: CompositionLayoutCell = collectionContext.dequeueReusableCell(for: self, at: index)
        cell.text = object?.items[index] ?? "undefined"
        cell.contentView.backgroundColor = UIColor.secondarySystemBackground
        cell.contentView.layer.cornerRadius = 8
        return cell
    }

    override func didUpdate(to object: Any) {
        self.object = object as? HorizontalCardsSection
    }

    // MARK: CompositionLayoutCapable
    
    func collectionViewSectionLayout(layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? {
        // Item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 16)

        // Group
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(160))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        return section
    }
    
}
