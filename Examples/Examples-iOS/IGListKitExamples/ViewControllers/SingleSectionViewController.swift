/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import IGListKit
import UIKit

final class SingleSectionViewController: UIViewController, ListAdapterDataSource, ListSingleSectionControllerDelegate {

    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()

    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    let data = Array(0..<20)

    // MARK: - Lifecycle

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

    // MARK: - ListAdapterDataSource

    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return data as [ListDiffable]
    }

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        let configureBlock = { (item: Any, cell: UICollectionViewCell) in
            guard let cell = cell as? NibCell, let number = item as? Int else { return }
            cell.text = "Cell: \(number + 1)"
        }

        let sizeBlock = { (item: Any, context: ListCollectionContext?) -> CGSize in
            guard let context = context else { return CGSize() }
            return CGSize(width: context.containerSize.width, height: 44)
        }
        let sectionController = ListSingleSectionController(nibName: NibCell.nibName,
                                                            bundle: nil,
                                                            configureBlock: configureBlock,
                                                            sizeBlock: sizeBlock)
        sectionController.selectionDelegate = self

        return sectionController
    }

    func emptyView(for listAdapter: ListAdapter) -> UIView? { return nil }

    // MARK: - ListSingleSectionControllerDelegate

    func didSelect(_ sectionController: ListSingleSectionController, with object: Any) {
        let section = adapter.section(for: sectionController) + 1
        let alert = UIAlertController(
            title: "Section \(section) was selected \u{1F389}",
            message: "Cell Object: " + String(describing: object),
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

}
