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

final class LabelsItem: NSObject {

    let color: UIColor
    var labels1: [String] = []
    var labels2: [String] = []

    init(color: UIColor, labels1: [String], labels2: [String]) {
        self.color = color
        self.labels1 = labels1
        self.labels2 = labels2
        super.init()
    }
}

extension LabelsItem: ListDiffable {

    func diffIdentifier() -> NSObjectProtocol {
        return self
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return self === object ? true : self.isEqual(object)
    }
}

final class ReorderableStackedViewController: UIViewController, ListAdapterDataSource, ListAdapterMoveDelegate {

    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()

    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    var data: [ListDiffable] = [
        LabelsItem(color: UIColor(red: 56/255.0, green: 151/255.0, blue: 240/255.0, alpha: 1),
                   labels1: ["A", "B", "C"],
                   labels2: ["1", "2", "3"]),
        LabelsItem(color: UIColor(red: 128/255.0, green: 240/255.0, blue: 151/255.0, alpha: 1),
                   labels1: ["D"],
                   labels2: ["4"])
    ]

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 9.0, *) {
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(ReorderableStackedViewController.handleLongGesture(gesture:)))
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
        let sectionController = ListStackedSectionController(sectionControllers: [
            PrefixedLabelSectionController(prefix: "🔤", group: 1),
            PrefixedLabelSectionController(prefix: "🔢", group: 2)
        ])
        sectionController.inset = UIEdgeInsets(top: 0, left: 0, bottom: 44, right: 0)
        return sectionController
    }

    func emptyView(for listAdapter: ListAdapter) -> UIView? { return nil }

    // MARK: - ListAdapterMoveDelegate

    func listAdapter(_ listAdapter: ListAdapter, move object: Any, from previousObjects: [Any], to objects: [Any]) {
        guard let objects = objects as? [ListDiffable] else { return }
        data = objects
    }
}
