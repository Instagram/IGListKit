/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import IGListKit
import UIKit

final class DemosViewController: UIViewController, ListAdapterDataSource {

    let horizontalInset = 16.0

    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    let demos: [DemoItem] = [
        DemoItem(name: "Tail Loading", imageName: "arrow.down.circle",
                 controllerClass: LoadMoreViewController.self),
        DemoItem(name: "Search Autocomplete", imageName: "magnifyingglass",
                 controllerClass: SearchViewController.self),
        DemoItem(name: "Mixed Data", imageName: "square.fill.text.grid.1x2",
                 controllerClass: MixedDataViewController.self),
        DemoItem(name: "Nested Adapter", imageName: "curlybraces",
                 controllerClass: NestedAdapterViewController.self),
        DemoItem(name: "Empty View", imageName: "exclamationmark.triangle",
                 controllerClass: EmptyViewController.self),
        DemoItem(name: "Single Section Controller", imageName: "1.square",
                 controllerClass: SingleSectionViewController.self),
        DemoItem(name: "Storyboard", imageName: "rectangle.on.rectangle",
                 controllerClass: SingleSectionViewController.self,
                 controllerIdentifier: "demo"),
        DemoItem(name: "Single Section Storyboard", imageName: "rectangle",
                 controllerClass: SingleSectionStoryboardViewController.self,
                 controllerIdentifier: "singleSectionDemo"),
        DemoItem(name: "Working Range", imageName: "arrow.left.and.right",
                 controllerClass: WorkingRangeViewController.self),
        DemoItem(name: "Diff Algorithm", imageName: "function",
                 controllerClass: DiffTableViewController.self),
        DemoItem(name: "Supplementary Views", imageName: "square.stack.3d.up",
                 controllerClass: SupplementaryViewController.self),
        DemoItem(name: "Self-sizing cells", imageName: "brain",
                 controllerClass: SelfSizingCellsViewController.self),
        DemoItem(name: "Display delegate", imageName: "megaphone",
                 controllerClass: DisplayViewController.self),
        DemoItem(name: "Objc Demo", imageName: "c.square",
                 controllerClass: ObjcDemoViewController.self),
        DemoItem(name: "Objc Generated Model Demo", imageName: "c.circle",
                 controllerClass: ObjcGeneratedModelDemoViewController.self),
        DemoItem(name: "Calendar (auto diffing)", imageName: "calendar",
                 controllerClass: CalendarViewController.self),
        DemoItem(name: "Dependency Injection", imageName: "syringe",
                 controllerClass: AnnouncingDepsViewController.self),
        DemoItem(name: "Reorder Cells", imageName: "arrow.up.and.down.and.arrow.left.and.right",
                 controllerClass: ReorderableViewController.self)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "IGListKit"
        navigationController?.navigationBar.prefersLargeTitles = true
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .groupedBackground
        collectionView.contentInset = UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)
        view.addSubview(collectionView)
        adapter.collectionView = collectionView
        adapter.dataSource = self
        if splitViewController?.viewControllers.count ?? 0 < 2, let demoItem = demos.first {
            let viewController = demoItem.controllerClass.init()
            viewController.title = demoItem.name
            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.navigationBar.prefersLargeTitles = true
            splitViewController?.viewControllers.append(navigationController)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.frame = view.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let splitViewController = splitViewController else {
            return
        }

        if splitViewController.viewControllers.count > 1 {
            // When on iPad, this view controller is visible all the time, so on initial launch, select the first section
            if let firstSection = adapter.sectionController(forSection: 0) {
                firstSection.collectionContext.selectItem(at: 0, sectionController: firstSection, animated: false, scrollPosition: .top)
                firstSection.didSelectItem(at: 0)
            }
        } else {
            // On iPhone, deselect all cells when returning to this view controller (since we'll be coming back from a navigation pop)
            for sectionController in adapter.visibleSectionControllers() {
                sectionController.collectionContext.deselectItem(at: 0, sectionController: sectionController, animated: animated)
                // UIColletionView doesn't call the deselection delegate by design when manually deselected, so manually deselect here
                sectionController.didDeselectItem(at: 0)
            }
        }
    }

    // MARK: ListAdapterDataSource

    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return demos
    }

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return DemoSectionController()
    }

    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }

}
