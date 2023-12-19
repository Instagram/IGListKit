/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import IGListKit
import UIKit

final class SwipeActionComposabelSectionController: ListSectionController, CompositionLayoutCapable {
    
    private var object:SwipeActionSection?
    
    private var items = ["1. Swipe to delete me", "2. Swipe to delete me", "3. Swipe to delete me"]
    
    override func numberOfItems() -> Int {
        return items.count
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        // Compositional layout doesn't request sizes per NSIndexPath
        return CGSizeZero
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell: CompositionLayoutCell = collectionContext.dequeueReusableCell(for: self, at: index)
        cell.text = items[index]
        return cell
    }

    override func didUpdate(to object: Any) {
        self.object = object as? SwipeActionSection
    }
    
    func collectionViewSectionLayout(layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)

        config.trailingSwipeActionsConfigurationProvider = {[weak self] indexPath in
            // Sections should match, but just in case
            guard let self = self, indexPath.section == self.section else {
                return nil
            }
            return self.swipeActionFor(index: indexPath.item)
        }
        
        return NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
    }
    
    // MARK: CompositionLayoutCapable
    
    private func swipeActionFor(index:Int) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") {[weak self] action, view, block in
            self?.deleteItem(index: index, block: block)
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    private func deleteItem(index:Int, block: @escaping (Bool) -> ()) {
        self.collectionContext.performBatch(animated: true) {updates in
            self.items.remove(at: index)
            updates.delete(in: self, at: IndexSet(integer: index))
        } completion: { completed in
            block(completed)
        }
    }

}
