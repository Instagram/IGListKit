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

final class DisplaySectionController: ListSectionController, ListDisplayDelegate {

    override init() {
        super.init()
        displayDelegate = self
        inset = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
    }

    override func numberOfItems() -> Int {
        return 4
    }

    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 55)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: LabelCell.self, for: self, at: index) as? LabelCell else {
            fatalError()
        }
        cell.text = "Section \(self.section), cell \(index)"
        return cell
    }

    // MARK: ListDisplayDelegate

    func listAdapter(_ listAdapter: ListAdapter, willDisplay sectionController: ListSectionController) {
        print("Will display section \(self.section)")
    }

    func listAdapter(_ listAdapter: ListAdapter,
                     willDisplay sectionController: ListSectionController,
                     cell: UICollectionViewCell,
                     at index: Int) {
                       print("Did will display cell \(index) in section \(self.section)")
    }

    func listAdapter(_ listAdapter: ListAdapter, didEndDisplaying sectionController: ListSectionController) {
        print("Did end displaying section \(self.section)")
    }

    func listAdapter(_ listAdapter: ListAdapter,
                     didEndDisplaying sectionController: ListSectionController,
                     cell: UICollectionViewCell,
                     at index: Int) {
                       print("Did end displaying cell \(index) in section \(self.section)")
    }

}
