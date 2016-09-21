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

class EmptyViewController: UIViewController, IGListAdapterDataSource, RemoveItemControllerDelegate {

    lazy var adapter: IGListAdapter = {
        return IGListAdapter(updatingDelegate: IGListAdapterUpdater(), viewController: self, workingRangeSize: 0)
    }()
    let collectionView = IGListCollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())

    let emptyLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "No more data!"
        label.backgroundColor = UIColor.clear
        return label
    }()

    var tally = 4
    var data = [
        1,
        2,
        3,
        4
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(EmptyViewController.onAdd))

        collectionView.backgroundColor = UIColor(white: 0.9, alpha: 1)
        view.addSubview(collectionView)
        adapter.collectionView = collectionView
        adapter.dataSource = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }

    func onAdd() {
        data.append(tally + 1)
        tally += 1
        adapter.performUpdates(animated: true, completion: nil)
    }

    //MARK: IGListAdapterDataSource

    func items(for listAdapter: IGListAdapter) -> [IGListDiffable] {
        return data as [IGListDiffable]
    }

    func listAdapter(_ listAdapter: IGListAdapter, itemControllerForItem item: Any) -> IGListItemController {
        let itemController = RemoveItemController()
        itemController.delegate = self
        return itemController
    }

    func emptyView(for listAdapter: IGListAdapter) -> UIView? {
        return emptyLabel
    }

    //MARK: RemoveItemControllerDelegate

    func removeItemControllerWantsRemoved(_ itemController: RemoveItemController) {
        let section = adapter.section(for: itemController)
        guard let item = adapter.item(atSection: section) as? Int, let index = data.index(of: item) else { return }
        data.remove(at: index)
        adapter.performUpdates(animated: true, completion: nil)
    }

}
