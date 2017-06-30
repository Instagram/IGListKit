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

final class SupplementaryViewController: UIViewController, ListAdapterDataSource {

    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: ListCollectionViewLayout(
        stickyHeaders: true, topContentInset: 0.0, stretchToEdge: false))

    let feedItems = [
        FeedItem(pk: 1, user: User(pk: 100, name: "Jesse", handle: "jesse_squires"), comments: [
            "You rock!",
            "Hmm you sure about that?",
            "You rock!",
            "Hmm you sure about that?",
            "You rock!",
            "Hmm you sure about that?"
            ]),
        FeedItem(pk: 2, user: User(pk: 101, name: "Ryan", handle: "_ryannystrom"), comments: [
            "lgtm",
            "lol",
            "Let's try it!",
            "lol",
            "Let's try it!",
            "Good luck!"
            ]),
        FeedItem(pk: 3, user: User(pk: 102, name: "Ann", handle: "abaum"), comments: [
            "Good luck!",
            "yoooooooo",
            "lol"
            ]),
        FeedItem(pk: 4, user: User(pk: 103, name: "Phil", handle: "phil"), comments: [
            "yoooooooo",
            "What's the eta?"
            ])
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

        if let flowLayout = collectionView.collectionViewLayout as? ListCollectionViewLayout {
            // If we are showing a navigation bar we need to change the y offset for the sticky headers as normal behaviour
            // of the UICollectionView to keep scrolling under the navigation bar. This case the sticky headers to end up below
            // this bar too hence this bit of calculation to determine what the correct y offset is
            flowLayout.stickyHeaderOriginYAdjustment = self.topLayoutGuide.length
            collectionView.collectionViewLayout = flowLayout
        }
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
