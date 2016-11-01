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

class DemosViewController: UIViewController, IGListAdapterDataSource {

    lazy var adapter: IGListAdapter = {
        return IGListAdapter(updater: IGListAdapterUpdater(), viewController: self, workingRangeSize: 0)
    }()
    let collectionView = IGListCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    let demos: [DemoItem] = [
        DemoItem(name: "Tail Loading", controllerClass: LoadMoreViewController.self),
        DemoItem(name: "Search Autocomplete", controllerClass: SearchViewController.self),
        DemoItem(name: "Mixed Data", controllerClass: MixedDataViewController.self),
        DemoItem(name: "Nested Adapter", controllerClass: NestedAdapterViewController.self),
        DemoItem(name: "Empty View", controllerClass: EmptyViewController.self),
        DemoItem(name: "Single Section Controller", controllerClass: SingleSectionViewController.self),
        DemoItem(name: "Storyboard", controllerClass: SingleSectionViewController.self, controllerIdentifier: "demo"),
        DemoItem(name: "Single Section Storyboard", controllerClass: SingleSectionViewController.self, controllerIdentifier: "singleSectionDemo"),
        DemoItem(name: "Working Range", controllerClass: WorkingRangeViewController.self),
        DemoItem(name: "Diff Algorithm", controllerClass: DiffTableViewController.self),
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

    //MARK: IGListAdapterDataSource

    func objects(for listAdapter: IGListAdapter) -> [IGListDiffable] {
        return demos
    }

    func listAdapter(_ listAdapter: IGListAdapter, sectionControllerFor object: Any) -> IGListSectionController {
        return DemoSectionController()
    }

    func emptyView(for listAdapter: IGListAdapter) -> UIView? {
        return nil
    }

}
