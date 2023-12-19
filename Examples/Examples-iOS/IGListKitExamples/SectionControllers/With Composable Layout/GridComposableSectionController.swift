/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import IGListKit
import UIKit


final class GridComposableSectionController: ListSectionController, CompositionLayoutCapable {

    private var object: GridItem?

    override func numberOfItems() -> Int {
        return object?.itemCount ?? 0
    }

    override func sizeForItem(at index: Int) -> CGSize {
        // Size handled by cell
        return CGSizeZero
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell: CompositionLayoutCell = collectionContext.dequeueReusableCell(for: self, at: index)
        cell.text = object?.items[index] ?? "undefined"
        cell.contentView.backgroundColor = object?.color
        return cell
    }

    override func didUpdate(to object: Any) {
        self.object = object as? GridItem
    }
    
    // MARK: CompositionLayoutCapable
    
    func collectionViewSectionLayout(layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? {
        // Item
        let columnCount:CGFloat = 3
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0 / columnCount),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

        // Group
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), 
                                               heightDimension: .fractionalWidth(1.0 / columnCount))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, 
                                                       subitems: [item])
        
        // Section
        return NSCollectionLayoutSection(group: group)
    }
}
