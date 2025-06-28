/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import IGListKit

// MARK: - ListSectionController

// In IGListKit, section controllers manage a single type of data object
// and are responsible for:
// - Creating and configuring cells
// - Handling cell selection
// - Determining cell sizes
// - Managing section-specific actions
final class PostSectionController: ListSectionController {

    var post: Post?
    weak var delegate: PostSectionControllerDelegate?

    override init() {
        super.init()
        // Setting insets for the entire section
        self.inset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
    }

    // Determines the size of cells in this section
    // IGListKit calls this method to calculate cell dimensions
    override func sizeForItem(at index: Int) -> CGSize {
        // collectionContext is a bridge that connects the section controller
        // to the actual UICollectionView it exists within
        let width = collectionContext?.containerSize.width ?? 0
        return CGSize(width: width, height: width + 200)
    }

    // Creates and configures a cell for this section
    // Similar to cellForRowAt in UICollectionViewDataSource
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: PostCell.self, for: self, at: index) as? PostCell,
              let post = post else {
            fatalError("Failed to dequeue PostCell")
        }

        cell.configure(with: post)

        cell.optionsButtonTapped = { [weak self] (button: UIButton) in
            guard let self = self, let post = self.post else { return }
            self.delegate?.postSectionController(self, didSelectOptionsFor: post, from: button)
        }

        return cell
    }

    // Handles selection of cells in this section
    override func didSelectItem(at index: Int) {
        guard let post = post else { return }
        print("Post ID:\(post.id) was tapped.")
    }

    // Called when the data object for this section controller is updated
    // This is where you store a reference to your model object
    override func didUpdate(to object: Any) {
        post = object as? Post
    }
}
