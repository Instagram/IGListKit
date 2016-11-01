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

class StoryboardViewController: UIViewController, IGListAdapterDataSource {

    @IBOutlet weak var collectionView: IGListCollectionView!
    
    lazy var adapter: IGListAdapter = {
        return IGListAdapter(updater: IGListAdapterUpdater(), viewController: self, workingRangeSize: 0)
    }()
    
    lazy var words = "1Maecenas 2faucibus 3mollis 4interdum 5Praesent 6commodo 7cursus 8magna 9vel 10scelerisque 11nisl 12consectetur 13et 14Maecenas 15faucibus 16mollis 1Maecenas 2faucibus 3mollis 4interdum 5Praesent 6commodo 7cursus 8magna 9vel 10scelerisque 11nisl 12consectetur 13et 14Maecenas 15faucibus 16mollis 1Maecenas 2faucibus 3mollis 4interdum 5Praesent 6commodo 7cursus 8magna 9vel 10scelerisque 11nisl 12consectetur 13et 14Maecenas 15faucibus 16mollis 1Maecenas 2faucibus 3mollis 4interdum 5Praesent 6commodo 7cursus 8magna 9vel 10scelerisque 11nisl 12consectetur 13et 14Maecenas 15faucibus 16mollis".components(separatedBy: " ")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adapter.collectionView = collectionView
        adapter.dataSource = self
    }
    
    //MARK: IGListAdapterDataSource
    
    func objects(for listAdapter: IGListAdapter) -> [IGListDiffable] {
        let items: [IGListDiffable] = words as [IGListDiffable]
        return items
    }
    
    func listAdapter(_ listAdapter: IGListAdapter, sectionControllerFor object: Any) -> IGListSectionController {
        return StoryboardLabelSectionController()
    }
    
    func emptyView(for listAdapter: IGListAdapter) -> UIView? { return nil }
    
    func didSelect(_ sectionController: IGListSingleSectionController) {
        let section = adapter.section(for: sectionController) + 1
        let alert = UIAlertController(title: "Section \(section) was selected \u{1F389}", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
