/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import IGListKit
import UIKit

final class DemosViewController: UIViewController, ListAdapterDataSource {

    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    let demos: [DemoItem] = [
        DemoItem(name: "Tail Loading",
                 controllerClass: LoadMoreViewController.self),
        DemoItem(name: "Search Autocomplete",
                 controllerClass: SearchViewController.self),
        DemoItem(name: "Mixed Data",
                 controllerClass: MixedDataViewController.self),
        DemoItem(name: "Nested Adapter",
                 controllerClass: NestedAdapterViewController.self),
        DemoItem(name: "Empty View",
                 controllerClass: EmptyViewController.self),
        DemoItem(name: "Single Section Controller",
                 controllerClass: SingleSectionViewController.self),
        DemoItem(name: "Storyboard",
                 controllerClass: SingleSectionViewController.self,
                 controllerIdentifier: "demo"),
        DemoItem(name: "Single Section Storyboard",
                 controllerClass: SingleSectionStoryboardViewController.self,
                 controllerIdentifier: "singleSectionDemo"),
        DemoItem(name: "Working Range",
                 controllerClass: WorkingRangeViewController.self),
        DemoItem(name: "Diff Algorithm",
                 controllerClass: DiffTableViewController.self),
        DemoItem(name: "Supplementary Views",
                 controllerClass: SupplementaryViewController.self),
        DemoItem(name: "Self-sizing cells",
                 controllerClass: SelfSizingCellsViewController.self),
        DemoItem(name: "Display delegate",
                 controllerClass: DisplayViewController.self),
        DemoItem(name: "Objc Demo",
                 controllerClass: ObjcDemoViewController.self),
        DemoItem(name: "Objc Generated Model Demo",
                 controllerClass: ObjcGeneratedModelDemoViewController.self),
        DemoItem(name: "Calendar (auto diffing)",
                 controllerClass: CalendarViewController.self),
        DemoItem(name: "Dependency Injection",
                 controllerClass: AnnouncingDepsViewController.self),
        DemoItem(name: "Reorder Cells",
                 controllerClass: ReorderableViewController.self)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Demos"
        view.addSubview(collectionView)
        adapter.collectionView = collectionView
        adapter.dataSource = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
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
