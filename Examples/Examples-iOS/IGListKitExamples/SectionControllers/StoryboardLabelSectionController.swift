/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import IGListKit
import UIKit

protocol StoryboardLabelSectionControllerDelegate: class {
    func removeSectionControllerWantsRemoved(_ sectionController: StoryboardLabelSectionController)
}

final class StoryboardLabelSectionController: ListSectionController {

    private var object: Person?
    weak var delegate: StoryboardLabelSectionControllerDelegate?

    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: (self.object?.name.count)! * 7, height: (self.object?.name.count)! * 7)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell: StoryboardCell = collectionContext.dequeueReusableCellFromStoryboard(
            withIdentifier: "cell",
            for: self,
            at: index)
        cell.text = object?.name
        return cell
    }

    override func didUpdate(to object: Any) {
        self.object = object as? Person
    }

    override func didSelectItem(at index: Int) {
        delegate?.removeSectionControllerWantsRemoved(self)
    }

}
