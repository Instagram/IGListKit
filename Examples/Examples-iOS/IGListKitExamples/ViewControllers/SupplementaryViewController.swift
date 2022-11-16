/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import IGListKit
import UIKit

final class SupplementaryViewController: UIViewController, ListAdapterDataSource {

    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    let feedItems = [
        FeedItem(pk: 1, user: User(pk: 100, name: "Jesse", handle: "jesse_squires"), comments: ["You rock!", "Hmm you sure about that?"]),
        FeedItem(pk: 2, user: User(pk: 101, name: "Ryan", handle: "_ryannystrom"), comments: ["lgtm", "lol", "Let's try it!"]),
        FeedItem(pk: 3, user: User(pk: 102, name: "Ann", handle: "abaum"), comments: ["Good luck!"]),
        FeedItem(pk: 4, user: User(pk: 103, name: "Phil", handle: "phil"), comments: ["yoooooooo", "What's the eta?"])
    ]

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

    // MARK: ListAdapterDataSource

    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return feedItems
    }

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return FeedItemSectionController()
    }

    func emptyView(for listAdapter: ListAdapter) -> UIView? { return nil }

}
