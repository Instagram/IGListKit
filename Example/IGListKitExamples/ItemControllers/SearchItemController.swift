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

protocol SearchItemControllerDelegate: class {
    func searchItemController(_ itemController: SearchItemController, didChangeText text: String)
}

class SearchItemController: IGListItemController, IGListItemType, IGListDisplayDelegate, UISearchBarDelegate {

    weak var delegate: SearchItemControllerDelegate?

    override init() {
        super.init()
        displayDelegate = self
    }

    func numberOfItems() -> UInt {
        return 1
    }

    func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 44)
    }

    func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeReusableCell(of: SearchCell.self, for: self, at: index) as! SearchCell
        cell.searchBar.delegate = self
        return cell
    }

    func didUpdate(toItem item: Any) {}
    func didSelect(at index: Int) {}

    //MARK: UISearchBarDelegate

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        delegate?.searchItemController(self, didChangeText: searchText)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        delegate?.searchItemController(self, didChangeText: "")
    }

    //MARK: IGListDisplayDelegate

    func listAdapter(_ listAdapter: IGListAdapter, didScrollItemController itemController: IGListItemController) {
        if let searchBar = (collectionContext?.cellForItem(at: 0, itemController: self) as? SearchCell)?.searchBar {
            searchBar.text = ""
            searchBar.resignFirstResponder()
        }
    }

    func listAdapter(_ listAdapter: IGListAdapter, willDisplay itemController: IGListItemController) {}
    func listAdapter(_ listAdapter: IGListAdapter, willDisplay itemController: IGListItemController, cell: UICollectionViewCell, at index: Int) {}
    func listAdapter(_ listAdapter: IGListAdapter, didEndDisplaying itemController: IGListItemController) {}
    func listAdapter(_ listAdapter: IGListAdapter, didEndDisplaying itemController: IGListItemController, cell: UICollectionViewCell, at index: Int) {}

}
