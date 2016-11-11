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

final class StoryboardViewController: UIViewController, IGListAdapterDataSource, StoryboardLabelSectionControllerDelegate {

    @IBOutlet weak var collectionView: IGListCollectionView!
    
    lazy var adapter: IGListAdapter = {
        return IGListAdapter(updater: IGListAdapterUpdater(), viewController: self, workingRangeSize: 0)
    }()
    
    lazy var words = "1Maecenas 2faucibus 3mollis 4interdum 5Praesent 6commodo 7cursus 8magna 9vel 10scelerisque 11nisl 12consectetur 13et 14Maecenas 15faucibus 16mollis 17magna 18magna 19vel 20scelerisque 21Maecenas 22faucibus 23mollis 24interdum 25Praesent 26commodo 27cursus 28magna 29vel 30scelerisque 31nisl 32consectetur 33et 34Maecenas 35faucibus 36mollis 37magna 38magna 39vel 40scelerisque".components(separatedBy: " ")
    
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
        let sectionController = StoryboardLabelSectionController()
        sectionController.delegate = self
        return sectionController
    }
    
    func emptyView(for listAdapter: IGListAdapter) -> UIView? { return nil }
    
    func removeSectionControllerWantsRemoved(_ sectionController: StoryboardLabelSectionController) {
        let section = adapter.section(for: sectionController)
        words.remove(at: Int(section))
        adapter.performUpdates(animated: true)
    }
}
