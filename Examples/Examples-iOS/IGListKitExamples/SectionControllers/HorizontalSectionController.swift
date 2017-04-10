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

final class HorizontalSectionController: IGListSectionController, IGListSectionType, IGListAdapterDataSource {

    private var number: Int?

    lazy var adapter: IGListAdapter = {
        let adapter = IGListAdapter(updater: IGListAdapterUpdater(),
                                    viewController: self.viewController,
                                    workingRangeSize: 0)
        adapter.dataSource = self
        return adapter
    }()

    func numberOfItems() -> Int {
        return 1
    }

    func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 100)
    }

    func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeueReusableCell(of: EmbeddedCollectionViewCell.self, for: self, at: index) as! EmbeddedCollectionViewCell
        adapter.collectionView = cell.collectionView
        return cell
    }

    func didUpdate(to object: Any) {
        number = object as? Int
    }

    func didSelectItem(at index: Int) {}

    //MARK: IGListAdapterDataSource

    func objects(for listAdapter: IGListAdapter) -> [IGListDiffable] {
        guard let number = number else { return [] }
        return (0..<number).map { $0 as IGListDiffable }
    }

    func listAdapter(_ listAdapter: IGListAdapter, sectionControllerFor object: Any) -> IGListSectionController {
        return EmbeddedSectionController()
    }

    func emptyView(for listAdapter: IGListAdapter) -> UIView? {
        return nil
    }

}
