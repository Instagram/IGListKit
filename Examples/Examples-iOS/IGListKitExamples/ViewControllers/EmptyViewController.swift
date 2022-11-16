/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import IGListKit
import UIKit

final class EmptyViewController: UIViewController, ListAdapterDataSource, RemoveSectionControllerDelegate {

    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()

    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = UIColor.secondaryBackground
        return collectionView
    }()

    let emptyLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "No more data!"
        label.backgroundColor = .clear
        return label
    }()

    var tally = 4

    var data = [1, 2, 3, 4]

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(EmptyViewController.onAdd))
        view.addSubview(collectionView)
        adapter.collectionView = collectionView
        adapter.dataSource = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }

    @objc func onAdd() {
        data.append(tally + 1)
        tally += 1
        adapter.performUpdates(animated: true, completion: nil)
    }

    // MARK: ListAdapterDataSource

    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return data as [ListDiffable]
    }

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        let sectionController = RemoveSectionController()
        sectionController.delegate = self
        return sectionController
    }

    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return emptyLabel
    }

    // MARK: RemoveSectionControllerDelegate

    func removeSectionControllerWantsRemoved(_ sectionController: RemoveSectionController) {
        let section = adapter.section(for: sectionController)
        guard let object = adapter.object(atSection: section) as? Int, let index = data.firstIndex(of: object) else { return }
        data.remove(at: index)
        adapter.performUpdates(animated: true, completion: nil)
    }

}
