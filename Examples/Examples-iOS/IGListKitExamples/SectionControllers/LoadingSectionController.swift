/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import IGListKit

// MARK: - LoadingSectionController

// A simpler section controller that manages the loading indicator
// Note that each type of content gets its own section controller
// This is a key concept in IGListKit - each model type gets a dedicated controller
final class LoadingSectionController: ListSectionController {
    
    override init() {
        super.init()
        self.inset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
    }
    
    // Set the size for the loading indicator cell
    override func sizeForItem(at index: Int) -> CGSize {
        let width = collectionContext?.containerSize.width ?? 0
        return CGSize(width: width, height: 60)
    }
    
    // Create and return the loading cell
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: LoadingCell.self, for: self, at: index) else {
            fatalError("Failed to dequeue LoadingCell")
        }
        return cell
    }
    
    // Nothing to update for this simple controller
    override func didUpdate(to object: Any) {
    }
}
