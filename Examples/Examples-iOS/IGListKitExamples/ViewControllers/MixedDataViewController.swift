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
import UIKit

final class MixedDataViewController: UIViewController, ListAdapterDataSource, ListAdapterMoveDelegate {

    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    var data: [Any] = [
        "Maecenas faucibus mollis interdum. Duis mollis, est non commodo luctus, nisi erat porttitor ligula, eget lacinia odio sem nec elit.",
        GridItem(color: UIColor(red: 237 / 255.0, green: 73 / 255.0, blue: 86 / 255.0, alpha: 1), itemCount: 6),
        User(pk: 2, name: "Ryan Olson", handle: "ryanolsonk"),
        "Praesent commodo cursus magna, vel scelerisque nisl consectetur et.",
        User(pk: 4, name: "Oliver Rickard", handle: "ocrickard"),
        GridItem(color: UIColor(red: 56 / 255.0, green: 151 / 255.0, blue: 240 / 255.0, alpha: 1), itemCount: 5),
        "Nullam quis risus eget urna mollis ornare vel eu leo. Praesent commodo cursus magna, vel scelerisque nisl consectetur et.",
        User(pk: 3, name: "Jesse Squires", handle: "jesse_squires"),
        GridItem(color: UIColor(red: 112 / 255.0, green: 192 / 255.0, blue: 80 / 255.0, alpha: 1), itemCount: 3),
        "Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh, ut fermentum massa justo sit amet risus.",
        GridItem(color: UIColor(red: 163 / 255.0, green: 42 / 255.0, blue: 186 / 255.0, alpha: 1), itemCount: 7),
        User(pk: 1, name: "Ryan Nystrom", handle: "_ryannystrom")
        ]

    let segments: [(String, Any.Type?)] = [
        ("All", nil),
        ("Colors", GridItem.self),
        ("Text", String.self),
        ("Users", User.self)
    ]

    var selectedClass: Any.Type?

    override func viewDidLoad() {
        super.viewDidLoad()

        let control = UISegmentedControl(items: segments.map { return $0.0 })
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(MixedDataViewController.onControl(_:)), for: .valueChanged)
        navigationItem.titleView = control

        if #available(iOS 9.0, *) {
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(MixedDataViewController.handleLongGesture(gesture:)))
            collectionView.addGestureRecognizer(longPressGesture)
        }

        view.addSubview(collectionView)
        adapter.collectionView = collectionView
        adapter.dataSource = self
        if #available(iOS 9.0, *) {
            adapter.moveDelegate = self
        }
    }

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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }

    @objc func onControl(_ control: UISegmentedControl) {
        selectedClass = segments[control.selectedSegmentIndex].1
        adapter.performUpdates(animated: true, completion: nil)
    }

    // MARK: ListAdapterDataSource

    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        guard selectedClass != nil else {
            return data.map { $0 as! ListDiffable }
        }
        return data.filter { type(of: $0) == selectedClass! }
            .map { $0 as! ListDiffable }
    }

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        switch object {
        case is String:   return ExpandableSectionController()
        case is GridItem: return GridSectionController(isReorderable: true)
        default:          return UserSectionController(isReorderable: true)
        }
    }

    func emptyView(for listAdapter: ListAdapter) -> UIView? { return nil }

    // MARK: - ListAdapterMoveDelegate
    
    func listAdapter(_ listAdapter: ListAdapter, move object: Any, from previousObjects: [Any], to objects: [Any]) {
        data = objects
    }
}
