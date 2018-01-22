/**
 Copyright (c) 2016-present, Facebook, Inc. All rights reserved.
 
 The examples provided by Facebook are for non-commercial testing and evaluation
 purposes only. Facebook reserves all rights not expressly granted.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 FACEBOOK BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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
        guard let cell = collectionContext?.dequeueReusableCellFromStoryboard(withIdentifier: "cell",
                                                                              for: self,
                                                                              at: index) as? StoryboardCell else {
                                                                                fatalError()
        }
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
