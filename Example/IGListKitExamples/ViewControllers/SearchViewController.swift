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

class SearchViewController: UIViewController, IGListAdapterDataSource, SearchItemControllerDelegate {

    lazy var adapter: IGListAdapter = {
        return IGListAdapter(updatingDelegate: IGListAdapterUpdater(), viewController: self, workingRangeSize: 0)
    }()
    let collectionView = IGListCollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    lazy var words: [String] = {
        let str = "Humblebrag skateboard tacos viral small batch blue bottle, schlitz fingerstache etsy squid. Listicle tote bag helvetica XOXO literally, meggings cardigan kickstarter roof party deep v selvage scenester venmo truffaut. You probably haven't heard of them fanny pack austin next level 3 wolf moon. Everyday carry offal brunch 8-bit, keytar banjo pinterest leggings hashtag wolf raw denim butcher. Single-origin coffee try-hard echo park neutra, cornhole banh mi meh austin readymade tacos taxidermy pug tattooed. Cold-pressed +1 ethical, four loko cardigan meh forage YOLO health goth sriracha kale chips. Mumblecore cardigan humblebrag, lo-fi typewriter truffaut leggings health goth."
        var words = [String]()
        let range = str.startIndex ..< str.endIndex
        str.enumerateSubstrings(in: range, options: .byWords, { (substring, _, _, _) in
            words.append(substring!)
        })
        return words
    }()
    var filterString = ""
    let searchToken = NSObject()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        adapter.collectionView = collectionView
        adapter.dataSource = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }

    //MARK: IGListAdapterDataSource

    func items(for listAdapter: IGListAdapter) -> [IGListDiffable] {
        var items: [IGListDiffable] = [searchToken]
        for word in words {
            if filterString == "" || word.lowercased().contains(filterString.lowercased()) {
                items.append(word as IGListDiffable)
            }
        }
        return items
    }

    func listAdapter(_ listAdapter: IGListAdapter, itemControllerForItem item: Any) -> IGListItemController {
        if let obj = item as? NSObject, obj === searchToken {
            let itemController = SearchItemController()
            itemController.delegate = self
            return itemController
        } else {
            return LabelItemController()
        }
    }

    func emptyView(for listAdapter: IGListAdapter) -> UIView? {
        return nil
    }

    //MARK: SearchItemControllerDelegate

    func searchItemController(_ itemController: SearchItemController, didChangeText text: String) {
        filterString = text
        adapter.performUpdates(animated: true, completion: nil)
    }

}
