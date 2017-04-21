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

import UIKit
import IGListKit

final class DisplaySectionController: IGListSectionController, IGListDisplayDelegate {

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
        let cell = collectionContext!.dequeueReusableCell(of: LabelCell.self, for: self, at: index) as! LabelCell
        let section = collectionContext!.section(for: self)
        cell.text = "Section \(section), cell \(index)"
        return cell
    }

    // MARK: IGListDisplayDelegate

    func listAdapter(_ listAdapter: IGListAdapter, willDisplay sectionController: IGListSectionController) {
        let section = collectionContext!.section(for: self)
        print("Will display section \(section)")
    }

    func listAdapter(_ listAdapter: IGListAdapter, willDisplay sectionController: IGListSectionController, cell: UICollectionViewCell, at index: Int) {
        let section = collectionContext!.section(for: self)
        print("Did will display cell \(index) in section \(section)")
    }

    func listAdapter(_ listAdapter: IGListAdapter, didEndDisplaying sectionController: IGListSectionController) {
        let section = collectionContext!.section(for: self)
        print("Did end displaying section \(section)")
    }

    func listAdapter(_ listAdapter: IGListAdapter, didEndDisplaying sectionController: IGListSectionController, cell: UICollectionViewCell, at index: Int) {
        let section = collectionContext!.section(for: self)
        print("Did end displaying cell \(index) in section \(section)")
    }

}
