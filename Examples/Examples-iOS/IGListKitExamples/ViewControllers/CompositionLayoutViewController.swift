/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import IGListKit
import UIKit

/// Enables SectionControllers to return their own layout. In the future, we might want IGListKit
/// to handle this, but for now, lets keep it simple.
protocol CompositionLayoutCapable {
    func collectionViewSectionLayout(layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection?
}

/// Like MixedDataViewController, but using UICollectionViewCompositionalLayout
final class CompositionLayoutViewController: UIViewController, ListAdapterDataSource {
    
    private var collectionView: UICollectionView?
    
    private lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    
    private let data: [Any] = [
        "Maecenas faucibus mollis interdum. Duis mollis, est non commodo luctus, nisi erat porttitor ligula, eget lacinia odio sem nec elit.",
        GridItem(color: UIColor(red: 237 / 255.0, green: 73 / 255.0, blue: 86 / 255.0, alpha: 1), itemCount: 6),
        User(pk: 2, name: "Ryan Olson", handle: "ryanolsonk"),
        HorizontalCardsSection(cardCount: 10),
        SwipeActionSection(),
        "Praesent commodo cursus magna, vel scelerisque nisl consectetur et.",
        User(pk: 4, name: "Oliver Rickard", handle: "ocrickard"),
        HorizontalCardsSection(cardCount: 2),
        GridItem(color: UIColor(red: 56 / 255.0, green: 151 / 255.0, blue: 240 / 255.0, alpha: 1), itemCount: 5),
        "Nullam quis risus eget urna mollis ornare vel eu leo. Praesent commodo cursus magna, vel scelerisque nisl consectetur et.",
        User(pk: 3, name: "Jesse Squires", handle: "jesse_squires"),
        GridItem(color: UIColor(red: 112 / 255.0, green: 192 / 255.0, blue: 80 / 255.0, alpha: 1), itemCount: 3),
        "Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh, ut fermentum massa justo sit amet risus.",
        GridItem(color: UIColor(red: 163 / 255.0, green: 42 / 255.0, blue: 186 / 255.0, alpha: 1), itemCount: 7),
        User(pk: 1, name: "Ryan Nystrom", handle: "_ryannystrom")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Layout
        let layout = UICollectionViewCompositionalLayout {[weak self] (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            guard let self = self else {
                return nil
            }
            let controller = self.adapter.sectionController(forSection: sectionIndex)
            guard let controller = controller as? CompositionLayoutCapable else {
                return nil
            }
            return controller.collectionViewSectionLayout(layoutEnvironment: layoutEnvironment)
        }
        
        // Collection View
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.collectionView = collectionView
        view.addSubview(collectionView)
        adapter.collectionView = collectionView
        adapter.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }
    
    // MARK: ListAdapterDataSource
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return data.map { $0 as! ListDiffable }
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        switch object {
        case is String:
            return ExpandableComposableSectionController()
        case is GridItem:
            return GridComposableSectionController()
        case is User:
            return UserComposableSectionController()
        case is HorizontalCardsSection:
            return HorizontalComposableSectionController()
        case is SwipeActionSection:
            return SwipeActionComposabelSectionController()
        default:
            return ListSectionController()
        }
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? { return nil }
    
}

