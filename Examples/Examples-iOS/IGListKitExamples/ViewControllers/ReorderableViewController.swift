/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import IGListKit
import UIKit

final class ReorderableViewController: UIViewController, ListAdapterDataSource, ListAdapterMoveDelegate {

    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()

    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    var data = Array(0..<20).map {
        "Cell: \($0 + 1)"
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 9.0, *) {
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(ReorderableViewController.handleLongGesture(gesture:)))
            collectionView.addGestureRecognizer(longPressGesture)
        }

        view.addSubview(collectionView)
        adapter.collectionView = collectionView
        adapter.dataSource = self
        if #available(iOS 9.0, *) {
            adapter.moveDelegate = self
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }

    // MARK: - Interactive Reordering

    @available(iOS 9.0, *)
    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            let touchLocation = gesture.location(in: self.collectionView)
            guard let selectedIndexPath = collectionView.indexPathForItem(at: touchLocation) else {
                break
            }
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            if let view = gesture.view {
                let position = gesture.location(in: view)
                collectionView.updateInteractiveMovementTargetPosition(position)
            }
        case .ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }

    // MARK: - ListAdapterDataSource

    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return data as [ListDiffable]
    }

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return ReorderableSectionController()
    }

    func emptyView(for listAdapter: ListAdapter) -> UIView? { return nil }

    // MARK: - ListAdapterMoveDelegate

    func listAdapter(_ listAdapter: ListAdapter, move object: Any, from previousObjects: [Any], to objects: [Any]) {
        guard let objects = objects as? [String] else { return }
        data = objects
    }
}
